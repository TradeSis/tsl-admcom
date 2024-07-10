/*******************************************************************************
 Programador        : Cristiano Borges Brasil
 Nome do Programa   : PagPer.p
 Programa           : Lista os Pagamentos
 Criacao            : 15/07/1996.
 ultima Alteracao   : 15/07/1996.
******************************************************************************/

    {admcab.i}
    def var vetbcod                 like estab.etbcod.
    def var vdatini                 like titulo.cxmdat.
    def var vdatfim                 like titulo.cxmdat.
    def var vdata                   like titulo.cxmdat.
    def var i                       as   int.
    def var tcob                    like titulo.titvlcob.
    def var tjur                    like titulo.titjuro.
    def var tdes                    like titulo.titdesc.
    def var vjuro                   like titulo.titjuro.
    def var vdesc                   like titulo.titdesc.
    def var vpago                   like titulo.titdesc.

    def buffer bestab for  estab.

    def temp-table wpag
        field wetbcod like estab.etbcod
        field wdata   like titulo.cxmdat
        field wpago   like vpago
        field ppago   as dec
        field wjuro   like vjuro
        field wdesc   like vdesc.

    update vetbcod
           vdatini
           vdatfim with centered 1 column color white/cyan width 80.

    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab then undo.

    def var vparcial as dec.
    display estab.etbnom no-label.
    assign
        vpago = 0
        vdesc = 0
        vjuro = 0
        vparcial = 0.
    do:
        do vdata = vdatini to vdatfim:
            for each titulo where titulo.empcod = wempre.empcod and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE" and
                                  titulo.titdtpag = vdata and
                                  titulo.etbcobra = estab.etbcod and
                                  titulo.titpar > 0    
                                  no-lock :
                if titulo.etbcobra <> estab.etbcod or titulo.clifor = 1
                then next.
                assign 
                       vjuro = vjuro + if titulo.titjuro = titulo.titdesc
                                       then 0
                                       else titulo.titjuro
                       vdesc = vdesc + if titulo.titjuro = titulo.titdesc
                                       then 0
                                       else titulo.titdesc .
                if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
                then vparcial = vparcial + titulo.titvlpag
                            - titulo.titjuro + titulo.titdesc.
                else vpago = vpago + titulo.titvlpag
                                 - titulo.titjuro + titulo.titdesc.
                         
            end.

            create wpag.
            assign wpag.wetbcod = estab.etbcod
                   wpag.wdata   = vdata
                   wpag.wpago   = vpago
                   wpag.ppago   = vparcial
                   wpag.wjuro   = vjuro
                   wpag.wdesc   = vdesc.

            assign vpago = 0
                   vdesc = 0
                   vjuro = 0
                   vparcial = 0.
        end.
    end.

    def var varquivo as char.
    varquivo = "/admcom/relat/pagper." + string(time).
    
    output to value(varquivo) page-size 64.
    form header
         wempre.emprazsoc
                 space(6) "PAGPER"   at 60
                 "Pag.: " at 71 page-number format ">>9" skip
                 "RESUMO DE DIGITACAO DE PAGAMENTOS POR PERIODO"   at 1
                 vdatini format "99/99/99" at 50
                 vdatfim format "99/99/99" at 60
                 string(time,"hh:mm:ss") at 73
                 skip fill("-",80) format "x(80)" skip
                 with frame fcab no-label page-top no-box width 137.
    view frame fcab.

    for each wpag:
            display estab.etbcod      column-label "Etb" format ">>9"
                    estab.etbnom                         format "x(20)"
                    wpag.wdata column-label "Data"       format "99/99/99"
                    wpag.wpago(total) column-label "Valor Pago"
                    wpag.ppago(total) column-label "Valor Pago Parcial"
                    wpag.wjuro(total) column-label "Valor Juro"
                    wpag.wdesc(total) column-label "Valor Desconto"
                    (wpag.wpago + wpag.ppago + wpag.wjuro) - wpag.wdesc
                    (total) column-label "Valor Total"
                    with width 137.
    end.
    output close.

    run visurel.p(varquivo, "").
