{admcab.i}
def var vmov like plani.platot extent 100.
def var vcon like plani.platot extent 100.
def var i as i.
def var vcat like produ.catcod initial 41.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vcatcod     like produ.catcod.
def var vcatcod2    like produ.catcod.
def var vdt like plani.pladat.
def var vmes as char format "X(3)" extent 12
initial["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET",
        "OUT","NOV","DEZ"].
def var vm as int extent 12.

def stream stela.
def temp-table wpro
    field wetb like estab.etbcod
    field wmes as int format "99"
    field wcat like produ.catcod
    field wqtd like movim.movqtm.

repeat:
    for each wpro:
        delete wpro.
    end.
    vcon = 0.
    vmov = 0.

    vcatcod2 = 0.

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".
    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".

    do vdt = vdti to vdtf:
        for each movim where movim.movtdc = 5 and
                             movim.movdat = vdt and
                             movim.etbcod >= vetbi and
                             movim.etbcod <= vetbf no-lock:

            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.
            find first wpro where wpro.wetb = movim.etbcod and
                                  wpro.wmes = month(movim.movdat) and
                                  wpro.wcat = produ.catcod no-lock no-error.
            if not avail wpro
            then do:
                create wpro.
                assign wpro.wetb = movim.etbcod
                       wpro.wmes = month(movim.movdat)
                       wpro.wcat = produ.catcod.
                vm[month(movim.movdat)] = month(movim.movdat).
            end.
            wpro.wqtd = wpro.wqtd + movim.movqtm.
            disp movim.procod movim.movdat movim.etbcod
                with 1 down. pause 0.
        end.
    end.

    {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""GERAL""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """QUANTIDADE DE PRODUTOS VENDIDOS - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}
    for each wpro break by wpro.wcat
                        by wpro.wetb
                        by wpro.wmes.

        if first-of(wpro.wcat)
        then do:
            find categoria where categoria.catcod = wpro.wcat no-lock no-error.
            if not avail categoria
            then next.
            disp categoria.catcod
                 categoria.catnom with frame f-cat side-label width 200.
            i = 0.
            put " " at 29.
            do i = 1 to 12:
                if vm[i] = 0
                then next.
                put vmes[vm[i]] space(4).
            end.
        end.
        if first-of(wpro.wetb)
        then do:
            find estab where estab.etbcod = wpro.wetb no-lock.
            put skip estab.etbnom.
        end.
        put wpro.wqtd.
        if wpro.wcat = 31 or
           wpro.wcat = 35
        then vmov[wpro.wmes] = vmov[wpro.wmes] + wpro.wqtd.
        if wpro.wcat = 41 or
           wpro.wcat = 45
        then vcon[wpro.wmes] = vcon[wpro.wmes] + wpro.wqtd.
    end.

    i = 0.
    put skip(3)
    "TOTAIS..............    MOVEIS                   CONFECCOES" SKIP.
    do i = 1 to 12:
        if vmov[i] = 0 and
           vcon[i] = 0
        then next.
        put vmes[i] space(15) vmov[i] space(15) vcon[i] skip.
    end.


    output close.
end.
