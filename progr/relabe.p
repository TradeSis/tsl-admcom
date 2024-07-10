{admcab.i}
def var varquivo as char format "x(30)".


def var vetbcod     like estab.etbcod.
def var vvalor      like titulo.titvlcob.
def var vnumtit     as   int.
def var vnumcli     as   int.
def var vnumcon     as   int.
def var i           as   int.
def var icli        as   int.
def var vcli        as   int.

repeat with row 4 width 80 frame f1 1 down side-label.
    form
        skip(1)
        vnumcon label "No. de Contratos "   colon 25
        vnumtit label "No. de Parcelas  "   colon 25
        vnumcli label "No. de Clientes  "   colon 25 skip(1)
        vvalor  label "Valor Total Aberto"  colon 25 skip(2)
        vcli    label "No. Total de Clientes" colon 25 skip(1)
        with frame f2 side-label
            title " Total Aberto " centered row 7 width 45.
    vnumtit = 0.
    vnumcli = 0.
    vnumcon = 0.
    update vetbcod colon 20.
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento Invalido".
            undo.
        end.
        display estab.etbnom no-label.
    end.
    else
        display "Geral" @ estab.etbnom.

    if vetbcod = 0
    then do:
        for each clien.
            vcli = vcli + 1.
        end.
        for each contrato break by contrato.clicod.
            i = 0.
            for each titulo where
                              titulo.titnum = string(contrato.contnum) and
                              titulo.titnat = no                       and
                              titulo.clifor = contrato.clicod          and
                              titulo.modcod = "CRE"                    and
                              titulo.titsit = "LIB" no-lock .
                vnumtit = vnumtit + 1.
                i = i + 1.
                vvalor = vvalor + titulo.titvlcob.
            end.
            if i > 0
            then
                vnumcon = vnumcon + 1.
            icli = icli + 1.
            if last-of(contrato.clicod)
            then do:
                if icli > 0
                then
                    vnumcli = vnumcli + 1.
                else.
                icli = 0.
            end.
            display vnumcon
                    vnumtit
                    vnumcli
                    vvalor
                    with frame f2.
        end.

    end.
    else do:
        for each contrato where contrato.etbcod = vetbcod no-lock
                                            break by contrato.clicod.
            i = 0.
            for each titulo where
                              titulo.titnum = string(contrato.contnum) and
                              titulo.titnat = no                       and
                              titulo.clifor = contrato.clicod          and
                              titulo.modcod = "CRE"                    and
                              titulo.titsit = "LIB" no-lock .
                vnumtit = vnumtit + 1.
                i = i + 1.
                vvalor = vvalor + titulo.titvlcob.
            end.
            if i > 0
            then
                assign
                    vnumcon = vnumcon + 1
                    icli    = icli + 1.
            if last-of(contrato.clicod)
            then do:
                if icli > 0
                then
                    vnumcli = vnumcli + 1.
                else.
                icli = 0.
            end.
            display vnumcon
                    vnumtit
                    vnumcli
                    vvalor
                    with frame f2.
        end.
    end.
    display
            vnumcon
            vnumtit
            vnumcli
            vvalor
            vcli
            with frame f2.
    message "Imprimir o relatorio ?" update sresp.
    if sresp = no
    then next.

    varquivo = "..\relat\relabe.rel".
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = """RELABE"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """TOTAL DE CONTRATOS, PARCELAS E CLIENTES EM ATRASO"""
        &Width     = "80"
        &Form      = "frame f-cab"}
    if vetbcod > 0
    then
        display estab.etbcod
                estab.etbnom no-label
                with frame fimp1 side-label width 90.
    else
        display "Geral" @ estab.etbnom
                with frame fimp1 side-label width 90.
    display
        skip(1)
        vnumcon label "No. de Contratos "   colon 25
        vnumtit label "No. de Parcelas  "   colon 25
        vnumcli label "No. de Clientes  "   colon 25 skip(1)
        vvalor  label "Valor Total Aberto"  colon 25 skip(2)
        with frame fimp2 side-label
            title " Total Aberto " centered row 7 width 45.
    output close.
    dos silent value("type " + varquivo + " > prn").
end.
