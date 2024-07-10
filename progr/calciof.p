 
 FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
 
 def input parameter vrowid as rowid.
  def output parameter viof as dec.
  def output parameter vjuro as dec.
  def output parameter txjuro as dec.
  
  def var dvalorcet as dec decimals 6 format "->,>>9.999999". 
  def var dvalorcetanual as dec decimals 6 format "->,>>9.999999".  
  def var vacrescimo as dec no-undo.
  def var vnumpar as int.
  

    def var rec-plani as recid.
  def var vprazo as int.
  def var periof as dec decimals 6 .
  def var valjuro as dec.
  def var auxvlr as dec.
  def var va as int.
  def var vchepres as dec.
  def var valor-av as dec.
              
  def shared temp-table tttitulo
      field titdtven  as date
      field titvlcob  like titulo.titvlcob.
                               def var vi as int.
                               def var vx as int.

  find contrato where rowid(contrato) = vrowid no-lock no-error.
  if not avail contrato then return.

      find first contnf where contnf.etbcod = contrato.etbcod and
                            contnf.contnum = contrato.contnum
                             no-lock no-error.
                            
      if avail contnf then
            repeat:
                find first plani use-index pladat 
                    where plani.movtdc = 5 and
                          plani.etbcod = contrato.etbcod and
                          plani.pladat = contrato.dtinicial and
                          plani.placod = contnf.placod and
                          plani.dest   = contrato.clicod and
                          plani.serie  = "V" no-lock no-error.
                if not avail plani
                then find first plani use-index pladat 
                    where plani.movtdc = 5 and
                          plani.etbcod = contrato.etbcod and
                          plani.pladat = contrato.dtinicial and
                          plani.placod = contnf.placod and
                          plani.dest   = contrato.clicod and
                          plani.serie  = "3" no-lock no-error.
                
                if not avail plani
                then find first plani use-index pladat 
                    where plani.movtdc = 5 and
                          plani.etbcod = contrato.etbcod and
                          plani.pladat = contrato.dtinicial and
                          plani.placod = contnf.placod and
                          plani.dest   = contrato.clicod 
                              no-lock no-error.

                if not avail plani
                then find first plani 
                    where plani.movtdc = 5 and
                          plani.etbcod = contrato.etbcod and
                          plani.placod = contnf.placod and
                          plani.dest   = contrato.clicod 
                              no-lock no-error.
                 
                if avail plani 
                then do:
                    rec-plani = recid(plani).
                    leave.
                end.
                find next contnf where contnf.etbcod = contrato.etbcod and
                               contnf.contnum = contrato.contnum
                             no-lock no-error.
                if not avail contnf
                then leave.
            end.
            if rec-plani = ? then return.
            find first plani where recid(plani) = rec-plani no-lock.

      
       find finan where finan.fincod = contrato.crecod no-lock no-error.

            vchepres = 0.
            valor-av = 0.
            if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ?
            then do va = 1 to int(acha("QTDCHQUTILIZADO",plani.notobs[3])):
                vchepres = vchepres +  dec(acha("VALCHQPRESENTEUTILIZACAO" + 
                            string(va),plani.notobs[3])) .
            end.    
            valor-av = plani.platot -
                        (plani.vlserv + plani.descprod + vchepres).


       if plani.biss > valor-av /*plani.platot - plani.vlserv*/
       then txjuro = (((plani.biss - (valor-av)) * 100) /
             (valor-av)) / finan.finnpc .
       else txjuro = 0.
      
       for each tttitulo no-lock: 
          delete tttitulo. 
       end.
       
       viof = 0.
       auxvlr = (contrato.vltotal - contrato.vlent).
       vjuro = 0.
       vnumpar = 0.
       for each titulo where titulo.empcod = 19  and 
                             titulo.titnat = no   and
                             titulo.modcod = contrato.modcod and      
                             titulo.etbcod = contrato.etbcod and
                             titulo.clifor = contrato.clicod and
                             titulo.titnum = string(contrato.contnum) and 
                             titulo.tpcontrato = "" /*titpar < 30*/ no-lock
                     /*  by titulo.titnum
                       by titulo.titpar descending */.
            vnumpar = vnumpar + 1.           
            assign vprazo =    titulo.titpar 
                   periof = (3 / vprazo) 
                   valjuro = titulo.titvlcob * (txjuro / 100)
                   vjuro = vjuro + valjuro
                   auxvlr = auxvlr - (titulo.titvlcob - valjuro)
                   viof = viof + ((titulo.titvlcob /* - valjuro */ ) 
                                  * (periof / 100 )).
                                 /*
               disp titulo.titpar
                    periof format "9.999999"
                    viof format "->>9.99" 
                    auxvlr format ">>9.99" column-label "Amort"
                    titulo.titvlcob FORMAT ">>9.99" COLUMN-LABEL "titcob"
                    valjuro  format ">9.99"
                    contrato.vltotal format ">>>9.99" column-label "tot" 
                    plani.biss format ">>>9.99" column-label "Bis"
                    plani.platot format ">>>9.99" column-label "PLTO"
                    txjuro format "9.99" column-label "%".
                                   */
                    
            find first tttitulo where tttitulo.titdtve = titulo.titdtven 
                                        no-error.
            if not avail tttitulo
            then create tttitulo.
            tttitulo.titdtve = titulo.titdtven.
            tttitulo.titvlcob = tttitulo.titvlcob + titulo.titvlcob.
       end.
       viof = viof + (contrato.vltotal * (0.38 / 100)) .

