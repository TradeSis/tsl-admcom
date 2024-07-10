{admcab.i}
def var vdtini      as   date label "Data Inicial" format "99/99/9999".
def var vdtfin      as   date label "Data Final" format "99/99/9999".
def var vetbcod     like estab.etbcod.

def temp-table wcli
    field wcli  like clien.clicod
    field wnom  like clien.clinom
    field wcad  like clien.dtcad
    field wsaldo like titulo.titvlcob
    field wcompra like titulo.titvlcob.
repeat:
    for each wcli:
        delete wcli.
    end.

    update vetbcod colon 20 with frame f1.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    display estab.etbnom no-label with frame f1.
    update vdtini  colon 20
           vdtfin  colon 20 with frame f1 centered side-label width 80.

    output to /admcom/TI/leote/relat_tora.txt

    for each plani where plani.movtdc = 5       and
                         plani.etbcod = vetbcod and
                         plani.pladat >= vdtini and
                         plani.pladat <= vdtfin no-lock:
        if plani.crecod = 1
        then next.
        find first wcli where wcli.wcli = plani.desti no-error.
        if not avail wcli
        then do:
            find clien where clien.clicod = plani.desti no-lock no-error.
            if not avail clien
            then next.
            create wcli.
            assign wcli.wcli = plani.desti
                   wcli.wnom = clien.clinom
                   wcli.wcad = clien.dtcad.
        end.
        find first contnf where contnf.etbcod = plani.etbcod and
                                contnf.placod = plani.placod no-lock no-error.
        if avail contnf
        then do:
            find contrato where contrato.contnum = contnf.contnum
                                                 no-lock no-error.
            if avail contrato
            then wcli.wcompra = wcli.wcompra + contrato.vltotal.
        end.
    end.
    for each wcli:
        for each titulo where titulo.clifor = wcli.wcli no-lock:
            if titulo.titsit <> "LIB"
            then next.
            if titulo.modcod <> "CRE"
            then next.
            wcli.wsaldo = wcli.wsaldo + titulo.titvlcob.
        end.
    end.



{mdadmcab.i
    &Saida     = "printer"
    &Page-Size = "64"
    &Cond-Var  = "140"
    &Page-Line = "66"
    &Nom-Rel   = """CRE01"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """CLIENTES NOVOS PARA ANALISE DE CREDITO - PERIODO DE "" +
                    string(vdtini) + "" A "" + string(vdtfin) + ""   "" +
                    estab.etbnom "
    &Width     = "140"
    &Form      = "frame f-cab"}

    for each wcli by wcli.wnom:
        display
            wcli.wcli
            wcli.wnom
            wcli.wcompra(total)  column-label "Valor Compra"
            wcli.wsaldo(total)   column-label "Saldo"
            wcli.wcad
            "   NOVO" when wcli.wcompra = wcli.wsaldo
                            with width 200 no-box.
    end.
    output close.
end.
