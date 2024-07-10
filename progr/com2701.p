{admcab.i}
def var x like plani.platot.
def var y like plani.platot.
def var w like plani.platot.
def var z like plani.platot.
def temp-table wmargem
    field data like plani.pladat
    field valor like plani.platot.

def temp-table w-demo
    field etbcod  like estab.etbcod
    field etbnom  like estab.etbnom
    field wtot    like plani.platot
    field wtotal  like plani.platot
    field wtotacr like plani.platot
    field wtotser like plani.platot.
def buffer bplani for plani.
def buffer bcontnf for contnf.
def var vtot like plani.platot.
def var wacr like plani.platot.
def var vetbcod like estab.etbcod.
def var vdt1 like plani.pladat.
def var vdt2 like plani.pladat.
def var vtotal like plani.platot.
def var vtotal1 like plani.platot.
def var vtotal2 like plani.platot.
def var valortot like plani.platot.
def var vvltotal like plani.platot.
def var vtotacr like plani.platot.
def var vtotser like plani.platot.
def var vvlcont like plani.platot.
def var wper like plani.platot.
def var vvldesc like plani.platot.
def var vvlacre like plani.platot.
repeat:
    for each wmargem:
        delete wmargem.
    end.
    for each w-demo:
        delete w-demo.
    end.
    update vetbcod with frame f1 side-label width 80.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
    else display "GERAL" @ estab.etbnom with frame f1.

    update vdt1 label "Periodo"
           vdt2 no-label with frame f1.
    for each estab where ( if vetbcod = 0
                           then true
                           else estab.etbcod = vetbcod ) no-lock.
        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5 and
                             plani.pladat >= vdt1 and
                             plani.pladat <= vdt2 no-lock break by plani.etbcod:
            disp plani.etbcod vtotal label "Bonus" with frame stela
                                1 down. pause 0.
            vtotal = vtotal + plani.descprod.
            if last-of(plani.etbcod)
            then do:
                create w-demo.
                assign w-demo.etbcod  = estab.etbcod
                       w-demo.etbnom  = estab.etbnom
                       w-demo.wtot    = vtotal.
                clear frame f2 no-pause.
                /*
                for each w-demo break by w-demo.etbcod:
                    display w-demo.etbnom format "x(18)"
                            wtot column-label "Total Liq." format ">,>>>,>>9.99"
                                                    with frame f2 down width 80.
                    down with frame f2.
                    pause 0.
                end. */
                vtotal = 0.
            end.
        end.
    end.
    message "Confirma emissao de relatorio" update sresp.
    if sresp
    then do:

        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""COM2701""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """DEMONSTRATIVO DE BONUS POR FILIAL - PERIODO DE "" +
                                  string(vdt1,""99/99/9999"") + "" A "" +
                                  string(vdt2,""99/99/9999"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}

        for each w-demo:
            display w-demo.etbnom format "x(20)"
                    wtot(total) column-label "Total Bonus" format ">,>>>,>>9.99"
                                    with frame f4 down width 200.
        end.
        output close.
    end.




end.
