{admcab.i}  

def var vdata like plani.pladat.
def var vdti  like plani.pladat.
def var vdtf  like plani.pladat.
def var vetbi like estab.etbcod.
def var vdif as char format "x(3)".
def var vetbf like estab.etbcod.
def var varquivo as char.

def buffer xplani for plani.
def buffer bcontnf for contnf.
def var vvltotal as dec.
def var wcompra as dec.


def new shared temp-table ttconf
    field etbcod like estab.etbcod label "Fl"
    field totplani as dec          label "Tot.Vendas" format ">,>>>,>>9.99"
    field totmovim as dec          label "Tot.Linhas" format ">,>>>,>>9.99"
    field totvista as dec          label "Tot.Vista"  
    field totcomissao as dec       label "Tot.Comissao" format ">,>>>,>>9.99"
    field totprazo as dec          label "Tot.Prazo"    format ">,>>>,>>9.99"
    field totcontr as dec          label "Tot.Contrato" format ">,>>>,>>9.99"
    field tottitul as dec          label "Tot.Titulos"  format ">,>>>,>>9.99" 
    field totpagos as dec          label "Tot.Pagos"    format ">,>>>,>>9.99" 
    field totdepos as dec          label "Tot.Deposito"
        index ind-1 etbcod.

repeat:

    update vdti label "Data Inicial" 
           vdtf label "Data Final" with frame f1 side-label width 80.
    
    update vetbi label "Filial"
           vetbf label "Filial" with frame f1.

    connect dragao -N tcp -S sdragao -H tigre -ld d. 

    run paglp.p (input vdti,
                 input vdtf,
                 input vetbi,
                 input vetbf).
    disconnect d.

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
    
        disp estab.etbcod with 1 down. pause 0.
        
        find first ttconf where ttconf.etbcod = estab.etbcod no-lock no-error.
        if not avail ttconf
        then do:
            create ttconf.
            assign ttconf.etbcod = estab.etbcod.
        end.

        do vdata = vdti to vdtf:
        for each plani where plani.movtdc = 5 and
                             plani.etbcod = estab.etbcod and
                             plani.pladat = vdata no-lock:

            disp plani.numero format "9999999"
                    with 1 down.  pause 0.   

            find first ttconf where ttconf.etbcod = estab.etbcod 
                        no-lock no-error.
            if not avail ttconf
            then do:
                create ttconf.
                assign ttconf.etbcod = estab.etbcod.
            end.
                
            wcompra = 0.
            
            if plani.crecod = 1
            then wcompra =  plani.protot + plani.acfprod -
                            plani.descprod - plani.vlserv.
                             
            if plani.crecod = 2
            then if plani.biss > 0
                 then wcompra  = plani.biss.
                 else wcompra  = plani.platot   - plani.vlserv - 
                                 plani.descprod + plani.acfprod.   


            ttconf.totcomissao = ttconf.totcomissao + wcompra.            
            ttconf.totplani = ttconf.totplani + plani.platot.    
          
            if plani.crecod = 1
            then ttconf.totvista = ttconf.totvista + plani.platot.
            else
            ttconf.totprazo  = ttconf.totprazo  + plani.biss.
                      
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movdat = plani.pladat and
                                 movim.movtdc = plani.movtdc no-lock:
                
                find first ttconf where ttconf.etbcod = estab.etbcod 
                        no-lock no-error.
                if not avail ttconf
                then do:
                    create ttconf.
                    assign ttconf.etbcod = estab.etbcod.
                end.
                
                ttconf.totmovim = ttconf.totmovim + 
                                  (movim.movqtm * movim.movpc).         
            end.

            
        end.
        end.
        do vdata = vdti to vdtf:
        for each contrato where contrato.etbcod = estab.etbcod and
                                contrato.dtinicial = vdata no-lock.
                
            disp contrato.contnum with 1 down. pause 0.
            
            find first ttconf where ttconf.etbcod = estab.etbcod 
                    no-lock no-error.
            if not avail ttconf
            then do:
                create ttconf.
                assign ttconf.etbcod = estab.etbcod.
            end.
            ttconf.totcontr = ttconf.totcontr + contrato.vltotal.
            
            for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE" and
                                  titulo.etbcod = contrato.etbcod and 
                                  titulo.clifor = contrato.clicod and
                                  titulo.titnum = string(contrato.contnum)
                                    no-lock:
            
                disp titulo.titnum with 1 down. pause 0.    
                
                ttconf.tottitul = ttconf.tottitul + titulo.titvlcob.
            end.
        
        end.
        end.
        do vdata = vdti to vdtf:
        for each titulo where titulo.etbcobra = estab.etbcod and
                              titulo.titdtpag = vdata no-lock:
                
            disp titulo.titnum with 1 down. pause 0.
            
            find first ttconf where ttconf.etbcod = estab.etbcod 
                    no-lock no-error.
            if not avail ttconf
            then do:
                create ttconf.
                assign ttconf.etbcod = estab.etbcod.
            end.
            ttconf.totpagos = ttconf.totpagos + titulo.titvlpag.
        end.
        end.

        do vdata = vdti to vdtf:
        for each deposito where deposito.etbcod = estab.etbcod and
                                deposito.datmov = vdata no-lock.
                                                           
            find first ttconf where ttconf.etbcod = estab.etbcod 
                    no-lock no-error.
            if not avail ttconf
            then do:
                create ttconf.
                assign ttconf.etbcod = estab.etbcod.
            end.
            ttconf.totdepos = ttconf.totdepos + deposito.cheglo.
        end.
        end.
        
        
        /*************
        for each depban where depban.etbcod = estab.etbcod and
                              depban.datmov = vdata no-lock.
                                                                
            find first ttconf where ttconf.etbcod = estab.etbcod 
                        no-lock no-error.
            if not avail ttconf
            then do:
                create ttconf.
                assign ttconf.etbcod = estab.etbcod.
            end.
            ttconf.totdepos = ttconf.totdepos + depban.valdep.
        end.
        **************/
    
    end.

    varquivo = "l:\relat\conf" + string(time).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""confimp""
        &Nom-Sis   = """SISTEMA GERENCIAL"""
        &Tit-Rel   = """CONFERENCIA DE TRANSMISSAO"" +
                      "" DE "" + string(vdti,""99/99/9999"") +
                      "" ATE "" +  string(vdti,""99/99/9999"")"
       &Width     = "135"
       &Form      = "frame f-cabcab"}
    
    for each ttconf:
    
        vdif = "".
    /*  if totprazo <> totcontr
        then vdif = " * ".  */
        if totcontr <> tottitul and
          (totcontr - tottitul) > 1 or
          (totcontr - tottitul) < -1
        then vdif = " * ".
    /*  if totprazo <> tottitul and
        then vdif = " * ".  */
        
        display ttconf.etbcod    column-label "Fl" format  ">99"
                totplani(total)  column-label "Tot.Vendas"
                totmovim(total)  column-label "Tot.Linhas"
                " * " when totplani <> totmovim no-label
                totcomissao(total) column-label "Tot.Comissao"
                totvista(total)  column-label "Tot.Vista"
                totprazo(total)  column-label "Tot.Prazo"
                totcontr(total)  column-label "Tot.Contrato"
                tottitul(total)  column-label "Tot.Titulos"
                vdif no-label
                totpagos(total)  column-label "Tot.Pagos"
                totdepos(total)  column-label "Tot.Deposito"
                    with frame f2 down width 200.

    end.
    
    output close.
    /*
    message "Deseja Imprimir Relatorio" update sresp.
    if sresp
    then dos silent value("type " + varquivo + "  > prn").
    */
    {mrod.i}

end.