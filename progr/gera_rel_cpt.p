{admcab.i new}

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vmes as int format "99".
def var vano as int format "9999".
def var vclien as char.

def temp-table tt-cli
    field clicod like clien.clicod
    field clinom like clien.clinom
    field contnum like contrato.contnum
    field principal as dec
    field acrescimo as dec
    index i1 clicod
    index i2 clinom.
   
def var acutot as dec format ">>>,>>>,>>9.99".
    
update vdti label "Data Inicial"
       vdtf label "Final"
       with frame f-1 1 down side-label
       .

vmes = month(vdti).
vano = year(vdti).    

def buffer barqclien for arqclien.

def var vq as int.
for each arqclien where
         arqclien.mes = vmes and
         arqclien.ano = vano and
         arqclien.tipo begins "ACRESCIMO"
         NO-LOCK:

    vclien = substr(arqclien.campo2,2,10).
    
    /*find first tt-cli where
               tt-cli.clicod = int(vclien) no-error.
    if not avail tt-cli
    then*/ do:
        create tt-cli.
        tt-cli.clicod = int(vclien).
        tt-cli.contnum = int(arqclien.campo5).
    end.
    tt-cli.acrescimo = tt-cli.acrescimo + dec(arqclien.campo8).           

    find first barqclien where barqclien.mes = vmes and
                               barqclien.ano = vano and
                               barqclien.tipo begins "EMISSAO" AND
                               barqclien.campo5 = arqclien.campo5
                               no-lock no-error.
    if avail arqclien
    then tt-cli.principal =  tt-cli.principal + dec(barqclien.campo8).   
    /*vq = vq + 1.
    if vq = 100
    then leave.
      */                                      
end.       

def var vdtc as date.

def temp-table wplani
    field   wclicod  like clien.clicod
    field   wclinom  like clien.clinom
    field   wven     like plani.platot
    field   wacr     like plani.platot
        index ind-1 wclinom
        index ind-2 wclicod
        index ind-3 wven.
 
for each tt-cli use-index i2:
    find clien where clien.clicod = tt-cli.clicod no-lock no-error.

    find first wplani where wplani.wclicod = clien.clicod
                no-error.
    if not avail wplani
    then do:
                
        create wplani.
            assign wplani.wclicod = clien.clicod
                   wplani.wclinom = clien.clinom
                   .
    end.
    assign               
        wplani.wven    = wplani.wven + principal
        wplani.wacr    = wplani.wacr + acrescimo
        .
                   
end.       


    if year(vdtf) = 2009
        then do:
               if month(vdtf) = 1
                      then vdtc = vdtf + 4.
                             if month(vdtf) = 2
                                    then vdtc = vdtf + 2.
                                           if month(vdtf) = 3
                                                  then vdtc = vdtf + 1.
                                                         if month(vdtf) = 4
                                                                then vdtc = vdtf + 4.
       if month(vdtf) = 5
              then vdtc = vdtf + 1.
                     if month(vdtf) = 6
                            then vdtc = vdtf + 1.
                                   if month(vdtf) = 7
                                          then vdtc = vdtf + 3.
                                          
                                                 if month(vdtf) = 8
                                                        then vdtc = vdtf + 1.
                                                               if month(vdtf) = 9
       then vdtc = vdtf + 1.
              if month(vdtf) = 10
                     then vdtc = vdtf + 2.
                            if month(vdtf) = 11
                                   then vdtc = vdtf + 1.
                                          if month(vdtf) = 12
                                                 then vdtc = vdtf + 4.
                                                     end.
                                                     
    def var varquivo as char.
    varquivo = "/admcom/audit/acrescimo/competencia/relacr_" +
                    trim(string(0,"999")) + "_" +
                                    string(day(vdti),"99") +
                                                    string(month(vdti),"99") +
                                                                    string(year(vdti),"9999") + "_" +
                string(day(vdtf),"99") +
                                string(month(vdtf),"99") +
                                                string(year(vdtf),"9999") + ".txt".

    def var totacr as dec format ">>>,>>>,>>9.99".
    totacr = 0.
    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""acr_fin""
        &Nom-Sis   = """SISTEMA CONTABIL"""
        &Tit-Rel   = """ACRESCIMO SOBRE A VENDA A PRAZO "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "130"
        &Form      = "frame f-cabcab"}

        
        for each wplani use-index ind-1:
        
                display wplani.wclicod column-label "Conta"
                        wplani.wclinom column-label "Nome do Cliente"
                        wplani.wven    column-label "Valor!Venda"
                        wplani.wacr    column-label "Valor!Acrescimo"
                        (wplani.wven + wplani.wacr)
                                   column-label "Valor!Total"
                            with frame f-ind1 down width 200.
                    
            totacr = totacr + wplani.wacr. 
        end.
        


        put skip(1)
            "Total.........................." at 35
            totacr to 77.
    
 
        output close.

        run visurel.p(varquivo,"").

        disp totacr. pause.
