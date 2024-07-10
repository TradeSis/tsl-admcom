{admcab.i}


def var vtotvlcob like titulo.titvlcob.
def var vtotvlpag like titulo.titvlpag.

def var varquivo as   char.
def var fila     as   char.
def var vetbcod  like estab.etbcod.
def var vdata    as   date format "99/99/9999".
def var vdata1   as   date format "99/99/9999".
def var vdata2   as   date format "99/99/9999".
def var vmoecod  like moeda.moecod.
def var vtipo as log format "Vencimento/Emissao".

form 
    vetbcod label "Estabelecimento"
    estab.etbnom no-label
    skip
    vtipo label "Periodo........"
    vdata1  label "Data Inicial"
    vdata2  label " Data Final"
    skip
    vmoecod  label "Moeda.........."
    moeda.moenom no-label
    with frame f-up side-labels width 80.


repeat:

    do on error undo:
        update vetbcod
               help "Informe o codigo do estabelecimento ou zero para todos"
               with frame f-up.
        if vetbcod = 0
        then disp "TODOS" @ estab.etbnom with frame f-up.
        else do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Estabelecimento nao cadastrado".
                undo.
            end.
            else disp estab.etbnom no-label with frame f-up.
        end.    
    end.       

    vtipo = yes. 
    update vtipo
           help "[E] Emissao  [V] Vencimento"
           with frame f-up.
    
    update vdata1 vdata2
           with frame f-up.

    do on error undo:
        vmoecod = "".

        update vmoecod
               with frame f-up.
        if vmoecod <> ""
        then do:
            find moeda where moeda.moecod = vmoecod no-lock no-error.
            if not avail moeda
            then do:
                message "Moeda nao cadastrada".
                undo.
            end.
            else do:
                if moeda.moetit = no
                then do:
                    message "Moeda invalida para este relatorio.".
                    undo.
                end.    
                else disp moeda.moenom with frame f-up. 
            end.
        end.
        else disp "TODAS" @ moeda.moenom with frame f-up.
    end.

    if opsys = "UNIX"
    then do:                                    /*
        find first impress where impress.codimp = setbcod no-lock no-error.
        if avail impress
        then assign fila = string(impress.dfimp)*/  
                    varquivo = "/admcom/relat/relcar" + string(time).    
    
    end.
    else assign fila = ""
                varquivo = "l:\relat\relcar" + string(time).

    message "Aguarde...".
    
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "63" 
        &Cond-Var  = "120"  
        &Page-Line = "66"
        &Nom-Rel   = ""relcar""  
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """ RELATORIO CONFERENCIA DE CARTOES DE CREDITO"""
        &Width     = "120"
        &Form      = "frame f-cabcab"}

    
    if vtipo = yes /*Dt Vencimento*/
    then do:
        
        for each modal where modal.modcod = "CRE"
                          or modal.modcod = "CAR" no-lock:
            for each estab where
                     estab.etbcod = (if vetbcod <> 0 
                                     then vetbcod 
                                     else estab.etbcod) no-lock:
                do vdata = vdata1 to vdata2:
                    for each titulo use-index titdtven
                                        where titulo.empcod   = 19
                                          and titulo.titnat   = no
                                          and titulo.modcod   = modal.modcod
                                          and titulo.etbcod   = estab.etbcod
                                          and titulo.titdtven = vdata no-lock:
                                /*
                        if modal.modcod = "CRE"
                        then*/ if vmoecod <> ""
                             then if titulo.moecod <> vmoecod
                                  then next.
                        
                        find moeda where
                             moeda.moecod = titulo.moecod no-lock no-error.
                        if not avail moeda     
                        then next.
                        if moeda.moetit = no
                        then next.
                        
                        disp titulo.etbcod
                             titulo.titnum
                             titulo.titpar
                             titulo.modcod
                             titulo.moecod
                             titulo.titdtemi
                             titulo.titdtven
                             titulo.titvlcob
                             titulo.titdtpag
                             titulo.titvlpag
                             titulo.titsit
                             with width 120.
                        vtotvlcob = vtotvlcob + titulo.titvlcob.
                        vtotvlpag = vtotvlpag + titulo.titvlpag.
                    end.
                end.
            end.
        end.
        disp vtotvlcob to 70 vtotvlpag to 98 "TOTAL"
             with no-labels width 120.
        
    end.
    else do: /*Dt emissao*/

        for each modal where modal.modcod = "CRE"
                          or modal.modcod = "CAR" no-lock:
            for each estab where
                     estab.etbcod = (if vetbcod <> 0 
                                     then vetbcod 
                                     else estab.etbcod) no-lock:
                do vdata = vdata1 to vdata2:
                    for each titulo where titulo.empcod   = 19
                                      and titulo.titnat   = no
                                      and titulo.modcod   = modal.modcod
                                      and titulo.titdtemi = vdata
                                      and titulo.etbcod   = estab.etbcod
                                      no-lock:
                              /*
                        if modal.modcod = "CRE"
                        then*/ if vmoecod <> ""
                             then if titulo.moecod <> vmoecod
                                  then next.

                        find moeda where
                             moeda.moecod = titulo.moecod no-lock no-error.
                        if not avail moeda     
                        then next.
                        if moeda.moetit = no
                        then next.


                        disp titulo.etbcod
                             titulo.titnum
                             titulo.titpar
                             titulo.modcod
                             titulo.moecod
                             titulo.titdtemi
                             titulo.titdtven
                             titulo.titvlcob
                             titulo.titdtpag
                             titulo.titvlpag
                             titulo.titsit
                             with width 120.
                        vtotvlcob = vtotvlcob + titulo.titvlcob.
                        vtotvlpag = vtotvlpag + titulo.titvlpag.

                    end.
                end.
            end.
        end.
        disp vtotvlcob to 70 vtotvlpag to 98 "TOTAL"
             with no-labels width 120.

    end.
    output close.
    
    hide message no-pause.
    
    if opsys = "UNIX"
    then do:

        message "Deseja imprimir relatorio" update sresp.
        if sresp
        then /*os-command silent lpr value(fila + " " + varquivo).*/
             run visurel.p (input varquivo,
                       input "").
                       
    end.
    else do:
        {mrod.i}.
    end.


end.
