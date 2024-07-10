{admcab.i}
def var varquivo as char format "x(12)".
def var xx as i.
def var vv like plani.platot.
def var v-lib like plani.platot.
def var v-pag like plani.platot.
def var vger like plani.platot.
def var t-sal like plani.platot.
def var v-sal like plani.platot.
def var vdata like plani.pladat initial today.
def var vsaldo like plani.platot.
def temp-table wctb
    field forcod like forne.forcod
    field wsaldo like titulo.titvlcob
    field wdif   like titulo.titvlcob.
repeat:
    vsaldo = 0.
    vger = 0.
    v-lib = 0.
    v-pag = 0.
    xx = 0.
    for each wctb:
        delete wctb.
    end.

    update vdata label "Data Base"
           vsaldo label "Saldo Contabil"
                with frame f1 side-label width 80.
    for each titctb where titctb.titdtemi <= vdata no-lock.
        if titctb.titdtpag > vdata or
           titctb.titdtpag = ?
        then vger = vger + titvlcob.
    end.
    if vsaldo > vger
    then vv = (vsaldo - vger).
    else vv = (vger - vsaldo).
    disp vger label "Sistema" with frame f1.
    for each titctb use-index ind-1 where titctb.titdtemi <= vdata and
                                          (titctb.titdtpag > vdata  or
                                           titctb.titdtpag = ?)
                                                no-lock break by titctb.forcod:
            v-sal = v-sal + titctb.titvlcob.
            t-sal = t-sal + titctb.titvlcob.

            if last-of(titctb.forcod)
            then do:
                create wctb.
                assign wctb.forcod = titctb.forcod
                       wctb.wsaldo = v-sal.
                v-sal = 0.
                xx = xx + 1.
            end.
    end.
    varquivo = "..\relat\ctb" + string(day(today)).

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = ""ctb""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
        &Tit-Rel   = """SALDO DE FORNECEDORES  EM  "" +
                                  string(vdata,""99/99/9999"")"
        &Width     = "80"
        &Form      = "frame f-cabcab"}
    for each wctb:
        wctb.wdif = vv / xx.
        if vsaldo > vger
        then wctb.wsaldo = wctb.wsaldo + wctb.wdif.
        else wctb.wsaldo = wctb.wsaldo - wctb.wdif.
        find forne where forne.forcod = wctb.forcod no-lock no-error.
        display forne.fornom format "x(25)"
                wctb.wsaldo(total) column-label "Saldo"
                        with frame f-2 down.
    end.
    output close.
    dos silent value("type " + varquivo + "  > prn").
end.
