/******************************************************************************/
/*                                                              pagmag.p      */
/*             programa de pagamentos efetuados na filial                     */
/*                                                                            */
/*                   e' disparado pelo programa pagreb4.p                     */
/*                                                                            */
/******************************************************************************/


    {admcab.i}
    def input parameter vetbcobra     like estab.etbcod.
    def input parameter vcxai       like titulo.cxacod.
    def input parameter vcxaf       like titulo.cxacod.
    def input parameter vdata       like titulo.cxmdat.
    def input parameter sresumo     as log.

    def var i                       as   int.
    def temp-table wftot
    field  vcxacod                 like titulo.cxacod
    field  vtotcob                 like titulo.titvlcob
    field  vtotjur                 like titulo.titjuro
    field  vtotdes                 like titulo.titdesc.
    def var tcob                    like titulo.titvlcob.
    def var tjur                    like titulo.titjuro.
    def var tdes                    like titulo.titdesc.
    def var vconta                  as integer  initial 0.

    def var vjuro                   like titulo.titjuro.
    def var vdesc                   like titulo.titdesc.

    def buffer bestab for estab.
    find bestab where bestab.etbcod = vetbcobra no-lock.

def stream tela.
output stream tela to terminal.

if sresumo
then do:
    for each wftot.
        delete wftot.
    end.
    FOR EACH ESTAB where estab.etbcod =  1 or
                         estab.etbcod =  6 or
                         estab.etbcod =  7 or
                         estab.etbcod = 15 or
                         estab.etbcod = 17 :
        pause 0.
        disp stream tela
             estab.etbcod
             vdata with frame ft side-labels centered 1 down.

        do i = vcxai to vcxaf:
            assign tcob = 0
                   tjur = 0
                   tdes = 0.
            pause 0.

            disp stream tela i label "Caixa" with frame ft.
            for each titulo where titulo.etbcod = estab.etbcod  and
                                  titulo.cxacod = i             and
                                  titulo.cxmdat = vdata:

                if titulo.titdtpag = ?
                then next.
                if titulo.titpar    = 0
                then next.
                if titulo.clifor = 1
                then next.
                /*
                if titulo.etbcobra <> ESTAB.etbcobra
                then next .
                */

                vconta = vconta + 1.
                display stream tela vconta          label "Contador"
                                    titulo.etbcod
                                    titulo.etbcobra
                                    titulo.titnum
                                    titulo.titpar
                                    titulo.clifor
                                    with 1 column centered row 6 color blue/cyan
                                    frame fbb1.
                                    pause 0.

                find clien where clien.clicod = titulo.clifor no-error.
                vjuro = if titulo.titjuro = titulo.titdesc
                        then 0
                        else titulo.titjuro.
                vdesc = if titulo.titjuro = titulo.titdesc
                        then 0
                        else titulo.titdesc.
                assign tcob = tcob + titulo.titvlcob
                       tjur = tjur + vjuro
                       tdes = tdes + vdesc.
                find first wftot where wftot.vcxacod = titulo.cxacod no-error.
                if not avail wftot
                then create wftot.
                assign
                    wftot.vcxacod = titulo.cxacod
                    wftot.vtotcob = wftot.vtotcob + titulo.titvlcob
                    wftot.vtotjur = wftot.vtotjur + vjuro
                    wftot.vtotdes = wftot.vtotdes + vdesc.
            end.
        end.
    end.

    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "133"
        &Page-Line = "66"
        &Nom-Rel   = """PAGMAG"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """RESUMO DE DIGITACAO DE PAGAMENTOS"""
        &Width     = "133"
        &Form      = "frame f-cabLOJ"}
    for each wftot break by wftot.vcxacod.
        display     bestab.etbcod
                bestab.etbnom
                vdata   column-label "Data"
                wftot.vcxacod
                wftot.vtotcob column-label "Valor Pago" (total)
                wftot.vtotjur column-label "Valor Juro" (total)
                wftot.vtotdes column-label "Valor Desconto" (total)
                with width 133 frame flin2 down.
        down with frame flin2.
    end.

    output to close.
end.
else do:
    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "133"
        &Page-Line = "66"
        &Nom-Rel   = """PAGMAG"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """LISTAGEM DE DIGITACAO DE PAGAMENTOS - ESTAB. "" +
                    STRING(bestab.etbcod) + ""- "" + bestab.etbnom +
                            ""   DATA PAGAMENTO: ""
                                    + string(vdata,""99/99/9999"") "
        &Width     = "133"
        &Form      = "frame f-cab"}

    form with frame f1.
    vconta = 0.

    do i = vcxai to vcxaf:
        display i label "Caixa No."
                with frame f2 no-box side-label.
        assign
            tcob = 0
            tjur = 0
            tdes = 0.

        FOR EACH ESTAB where estab.etbcod =  1 or
                             estab.etbcod =  6 or
                             estab.etbcod =  7 or
                             estab.etbcod = 15 or
                             estab.etbcod = 17,
            each titulo where titulo.etbcod = estab.etbcod  and
                              titulo.cxacod = i             and
                              titulo.cxmdat = vdata
                                                    by titulo.moecod
                                                    by titulo.titnum
                                                    by titulo.titpar.
            if titulo.titdtpag = ?
            then
                next.
            if titulo.titpar    = 0
            then
                next.
            if titulo.clifor = 1
            then
                next.
            /*
            if titulo.etbcobra <> vetbcobra
            then
                next .
            */

                vconta = vconta + 1.
                display stream tela vconta          label "Contador"
                                    titulo.etbcod
                                    titulo.etbcobra
                                    titulo.titnum
                                    titulo.titpar
                                    titulo.clifor
                                    with 1 column centered row 6 color blue/cyan
                                    frame fbb2.
                                    pause 0.

            find clien where clien.clicod = titulo.clifor no-error.
            vjuro = if titulo.titjuro = titulo.titdesc
                    then 0
                    else titulo.titjuro.
            vdesc = if titulo.titjuro = titulo.titdesc
                    then 0
                    else titulo.titdesc.
            display titulo.etbcod   column-label "Fil."
                    titulo.etbcobra column-label "Cob."
                    titulo.titnum   column-label "Contr."
                    titulo.titpar   column-label "Pr."
                    titulo.clifor   column-label "Cliente"
                    clien.clinom    column-label "Nome" format "x(35)"
                                    when avail clien
                    titulo.titdtven
                    titulo.titdtpag
                    titulo.moecod   column-label "Moeda"
                    if titulo.titdtpag <> vdata
                    then "*"
                    else "" no-label format "x"
                    titulo.titvlcob column-label
                                    "Valor Pago" format ">>>,>>9.99"
                    vjuro format ">>>,>>9.99"
                    vdesc format "->>,>>9.99"
                    with no-box width 150 frame f1 down.
                down with frame f1.
            assign
                tcob = tcob + titulo.titvlcob
                tjur = tjur + vjuro
                tdes = tdes + vdesc
                vtotcob = vtotcob + titulo.titvlcob
                vtotjur = vtotjur + vjuro
                vtotdes = vtotdes + vdesc.
        end.
        display "----------"    @ titulo.titvlcob
                "----------"    @ vjuro
                "----------"    @ vdesc
                with frame f1.
        down with frame f1.
        display tcob         @ titulo.titvlcob
                tjur         @ vjuro
                tdes         @ vdesc
                with frame f1 .
        down 2 with frame f1.
    end.
    down with frame f1.

    display "Total da Loja" @ clien.clinom
            vtotcob         @ titulo.titvlcob
            vtotjur         @ vjuro
            vtotdes         @ vdesc
            with frame f1 .

    output close.
end.
