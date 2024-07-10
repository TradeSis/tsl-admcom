{admcab.i}
def var vnome like produ.pronom.
def var tot1 like plani.platot.
def var tot2 like plani.platot.
def var tot3 like plani.platot.
def var dt    as date format "99/99/9999".
def var vdti   as date format "99/99/9999".
def var vdtf   as date format "99/99/9999".
def var vetb1 like estab.etbcod.
def var vetb2 like estab.etbcod.
repeat:
    tot1 = 0.
    tot2 = 0.
    tot3 = 0.
    update vetb1 label "Filial"
           vetb2 label "Filial"
            with frame f-etb centered color blue/cyan row 12
                                    title " Filial " side-label.

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".

        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""PL""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """PLANILHA DE FECHAMENTO FILIAL "" +
                          string(estab.etbcod) + "" VENDAS DE  "" +
                          string(vdti,""99/99/9999"") + "" ate "" +
                          string(vdtf,""99/99/9999"")"

            &Width     = "130"
            &Form      = "frame f-cabcab"}

    for each estab where estab.etbcod >= vetb1 and
                         estab.etbcod <= vetb2 no-lock:
        do dt = vdti to vdtf:

            for each plani where plani.movtdc = 5             and
                                 plani.etbcod = estab.etbcod  and
                                 plani.pladat = dt no-lock:
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat no-lock:

                    find produ where produ.procod = movim.procod
                                                        no-lock no-error.
                    if not avail produ
                    then next.
                    if produ.pronom begins "PNEU"           or
                       produ.pronom begins "scooter"
                    then.
                    else next.
                    if pronom begins "Pneu" or
                       pronom begins "SCOOTER"
                    then do:
                        vnome = produ.pronom.
                        
                        
                        if produ.procod = 400257 or
                           produ.procod = 400428 or
                           produ.procod = 400427
                        then vnome = "TELEFONE ERICSSON".

                        if produ.procod = 400262
                        then vnome = "TELEFONE GRADIENTE STRIKE".
                        
                        if produ.procod = 400237
                        then vnome = "TELEFONE GRADIENTE CONCEPT".
                                                  
                        
                        if produ.procod = 400238
                        then vnome = "TELEFONE NOKIA R.6120".

                        if produ.procod = 400204
                        then vnome = "TELEFONE NOKIA".
                        
                         

                        display plani.pladat
                                plani.numero
                                plani.serie
                                vnome column-label "Descricao"
                                (movim.movqt * movim.movpc)
                                        column-label "Total"
                                    with frame f1 down width 200.
                        tot1 = tot1 + (movim.movpc * movim.movqtm).
                        tot2 = tot2 + plani.platot.
                    end.
                end.
            end.
        end.
        if tot1 > 0
        then
        put skip(1)
            tot1 at 74.
        tot1 = 0.
        tot2 = 0.
        dt = vdti.
        do dt = vdti to vdtf:

            for each plani where plani.movtdc = 5             and
                                 plani.etbcod = estab.etbcod  and
                                 plani.pladat = dt no-lock:
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat no-lock:

                    find produ where produ.procod = movim.procod
                                                        no-lock no-error.
                    if not avail produ
                    then next.
                    if produ.pronom begins "Telefone"       or
                       produ.pronom begins "computador"
                    then.
                    else next.
                    
                    vnome = produ.pronom.

                                 
                    if produ.procod = 400257 or
                       produ.procod = 400428 or
                       produ.procod = 400427
                    then vnome = "TELEFONE ERICSSON".


                    
                    if produ.procod = 400237
                    then vnome = "TELEFONE GRADIENTE CONCEPT".

                    if produ.procod = 400262
                    then vnome = "TELEFONE GRADIENTE STRIKE".
                         
                        
                    if produ.procod = 400238
                    then vnome = "TELEFONE NOKIA R.6120".

                    if produ.procod = 400204
                    then vnome = "TELEFONE NOKIA".

                    display plani.pladat
                            plani.numero
                            plani.serie
                            vnome column-label "Descricao"
                            (movim.movqt * movim.movpc)
                                    column-label "Total"
                                with frame ff1 down width 200.
                    tot1 = tot1 + (movim.movpc * movim.movqtm).
                end.
            end.
        end.
        if tot1 > 0
        then
        put skip(1)
            tot1 at 74.
    end.
    output close.
end.
