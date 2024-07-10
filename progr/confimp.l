{admcab.i new}

def var vdata like plani.pladat.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var varquivo as char.
def temp-table ttconf

    field etbcod like estab.etbcod label "Filial"
    field totplani as dec          label "Tot.Vendas"
    field totmovim as dec          label "Tot.Linhas"
    field totvista as dec          label "Tot.Vista"
    field totprazo as dec          label "Tot.Prazo"
    field totcontr as dec          label "Tot.Contrato"
    field tottitul as dec          label "Tot.Titulos"
    field totpagos as dec          label "Tot.Pagos"
    field totdepos as dec          label "Tot.Deposito".

repeat:

    update vdata with frame f1 side-label width 80.
    update vetbi label "Filial"
           vetbf label "Filial" with frame f1.
    
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
    
        disp estab.etbcod with 1 down. pause 0.
        
        find first ttconf where ttconf.etbcod = estab.etbcod no-error.
        if not avail ttconf
        then do:
            create ttconf.
            assign ttconf.etbcod = estab.etbcod.
        end.

        for each plani where plani.movtdc = 5 and
                             plani.etbcod = estab.etbcod and
                             plani.pladat = vdata no-lock:

            disp plani.numero with 1 down.  pause 0.   

            find first ttconf where ttconf.etbcod = estab.etbcod no-error.
            if not avail ttconf
            then do:
                create ttconf.
                assign ttconf.etbcod = estab.etbcod.
            end.
                
            ttconf.totplani = ttconf.totplani + plani.platot.    
          
            if plani.crecod = 1
            then ttconf.totvista = ttconf.totvista + plani.platot.
            else
            ttconf.totprazo  = ttconf.totprazo  + plani.biss.
                      
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod no-lock:
                
                find first ttconf where ttconf.etbcod = estab.etbcod no-error.
                if not avail ttconf
                then do:
                    create ttconf.
                    assign ttconf.etbcod = estab.etbcod.
                end.
                
              ttconf.totmovim = ttconf.totmovim + (movim.movqtm * movim.movpc).              end.

            
        end.

        for each contrato where contrato.etbcod = estab.etbcod and
                                contrato.dtinicial = vdata no-lock.
                
            disp contrato.contnum with 1 down. pause 0.
            
            find first ttconf where ttconf.etbcod = estab.etbcod no-error.
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
         
        for each titulo where titulo.etbcobra = estab.etbcod and
                              titulo.titdtpag = vdata no-lock:
                
            disp titulo.titnum with 1 down. pause 0.
            
            find first ttconf where ttconf.etbcod = estab.etbcod no-error.
            if not avail ttconf
            then do:
                create ttconf.
                assign ttconf.etbcod = estab.etbcod.
            end.
            ttconf.totpagos = ttconf.totpagos + titulo.titvlpag.
        end.
    
        for each depban where depban.etbcod = estab.etbcod and
                              depban.datmov = vdata no-lock.
                                                                
            find first ttconf where ttconf.etbcod = estab.etbcod no-error.
            if not avail ttconf
            then do:
                create ttconf.
                assign ttconf.etbcod = estab.etbcod.
            end.
            ttconf.totdepos = ttconf.totdepos + depban.valdep.
        end.
    end.

    
    varquivo = "l:\relat\conf" + string(time).

    
    
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""confimp""
        &Nom-Sis   = """SISTEMA GERENCIAL"""
        &Tit-Rel   = """CONFERENCIA DE TRANSMISSAO"" +
                      "" DE "" + string(vdata,""99/99/9999"")"
       &Width     = "135"
       &Form      = "frame f-cabcab"}
    


    for each ttconf:
    
        display ttconf.etbcod column-label "Filial"
                totplani(total)  column-label "Tot.Vendas"
                totmovim(total)  column-label "Tot.Linhas"
                totvista(total)  column-label "Tot.Vista"
                totprazo(total)  column-label "Tot.Prazo"
                totcontr(total)  column-label "Tot.Contrato"
                tottitul(total)  column-label "Tot.Titulos"
                totpagos(total)  column-label "Tot.Pagos"
                totdepos(total)  column-label "Tot.Deposito"
                    with frame f2 down width 200.

    end.
    
    output close.
    
    message "Deseja Imprimir Relatorio" update sresp.
    if sresp
    then dos silent value("type " + varquivo + "  > prn").


end.