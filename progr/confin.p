{admcab.i}
DEF VAR VPRO LIKE PRODU.PROCOD INITIAL ?.
def buffer xmovim for movim.
def var vimp as log format "80/132" label "Tipo de Impressao".
def var vmovqtmcar as char format "x(4)".
def buffer cestoq for estoq.
def var VTOTGERPED as int.
def var VTOTGERCOM as int.
def var VTOTGERVEN as int.
def var VTOTGEREST as int.
def var VVALGERPED as int.
def var VVALGERCOM as int.
def var VVALGERVEN as int.
def var VVALGEREST as int.
def var vtotest     like estoq.estatual.
def var vtotdep     like estoq.estatual.
def var vmargen     as dec format "->>>>9 %".
def var vultcomp    as date format "99/99/9999".
def var vultcust    like estoq.estcusto.
def var vmovqtm     like movim.movqtm.
def var vmovdat     as date format "99/99/9999".
def var vmm         as int.
def var vaa         as int.
def var i           as int.
def var vaux        as int.
def var vauxped     as int.
def var vano        as int.
def var vanoped     as int.
def var vtotcomp    like himov.himqtm extent 6.
def var vtotpedi    like himov.himqtm extent 03.
def var vtotvend    like himov.himqtm extent 6.
def var vtotesto    like hiest.hiestf extent 6.
def var vvalcomp    like himov.himqtm extent 6.
def var vvalpedi    like himov.himqtm extent 03.
def var vvalvend    like himov.himqtm extent 6.
def var vvalesto    like hiest.hiestf extent 6.
def var vforcod     like forne.forcod.
def var vcatcod     like categoria.catcod.
def var vlin        as int initial 0.

def buffer bestoq   for estoq.

define            variable vmes  as char format "x(07)" extent 12 initial
    ["    JAN","    FEV","    MAR","    ABR","    MAI","    JUN",
     "    JUL","    AGO","    SET","    OUT","    NOV","    DEZ"].

def var vmes2 as char format "x(7)" extent 6.
def var vmes2ped as char format "x(7)" extent 03.

def var vnummes as int format ">>>" extent 6.
def var vnummesped as int format ">>>" extent 03.
def var vnumano as int format ">>>>" extent 6.
def var vnumanoped as int format ">>>>" extent 03.

def stream stela.

update vforcod label "Fornecedor" colon 20
                        with frame f-for width 80 side-label
                                                    color white/red row 4.
find fabri where fabri.fabcod = vforcod no-lock.
disp fabri.fabnom colon 30 no-label with frame f-for.

update vcatcod label "Departamento" colon 20 with frame f-for.
find categoria where categoria.catcod = vcatcod no-lock.
disp categoria.catnom colon 30 no-label with frame f-for.

vaux    = month(today).
vano    = year(today).
vaux    = vaux + 1.
do i = 1 to 6:
    vaux = vaux - 1.
    if vaux = 0
    then do:
        vmes2[i] = "DEZ".
        vaux = 12.
        vano = vano - 1.
    end.
    vmes2[i] = vmes[vaux].
    vnummes[i] = vaux.
    vnumano[i] = vano.
end.

vauxped = month(today).
vanoped = year(today).
do i = 1 to 3:
    if vauxped = 13
    then do:
        vmes2ped[i] = "JAN".
        vauxped = 01.
        vanoped = vanoped + 1.
    end.
    vmes2ped[i] = vmes[vauxped].
    vnummesped[i] = vauxped.
    vnumanoped[i] = vanoped.
    vauxped = vauxped + 1.
end.

do:

    vtotgerped = 0.
    vvalgerped = 0.
    VTOTGERCOM = 0.
    VVALGERCOM = 0.
    VTOTGERVEN = 0.
    VVALGERVEN = 0.
    VTOTGEREST = 0.
    VVALGEREST = 0.
    for each produ where produ.catcod = vcatcod and
                         produ.fabcod = vforcod no-lock.

        disp produ.procod produ.pronom no-label
                                       with 1 down centered color red/white
                                       title " Processando ... " frame f3
                                       side-labels.
        pause 0.
        /*
        vtotest = 0.
        vtotdep = 0.
        for each bestoq where bestoq.procod = produ.procod no-lock.
            vtotest = vtotest + bestoq.estatual.
            if bestoq.etbcod > 995
            then vtotdep = vtotdep + bestoq.estatual.
        end.
        */

        find first estoq of produ no-lock no-error.
        if not avail estoq
        then next.

        /*
        vmovdat = ?.
        vultcomp = ?.
        vultcust = estoq.estcusto.
        vmovqtm = 0.
        find last movim where movim.movtdc = 4 and
                              movim.procod = produ.procod no-lock no-error.
        if avail movim
        then do:
            vultcomp = movim.movdat.
            vultcust = movim.movpc.
            vmovqtm = 0.
            for each xmovim where xmovim.procod = produ.procod and
                                  xmovim.movtdc = 4 and
                                  month(xmovim.movdat) = month(today) and
                                  year(xmovim.movdat)  = year(today) no-lock:
                vmovqtm  = xmovim.movqtm.
            end.
        end.
        else do:
            find cestoq where cestoq.etbcod = 999 and
                              cestoq.procod = produ.procod no-lock no-error.
            if avail cestoq
            then do:
                vultcomp = cestoq.estinvdat.
                if month(cestoq.estinvdat) = month(today)
                then vmovqtm  = cestoq.estinvqtd .
                else vmovqtm = 0.
            end.
        end.
        */

        do i = 1 to 3:
            /*
            vtotpedi[i] = 0.
            vvalpedi[i] = 0.
            */
            for each liped where liped.pedtdc = 1 and
                                 liped.procod = produ.procod and
                                 month(liped.predt) = vnummesped[i] and
                                 year(liped.predt)  = vnumanoped[i] no-lock:
                vtotpedi[i] = vtotpedi[i] + liped.lipqtd.
                VTOTGERPED = VTOTGERPED + liped.lipqtd.
                vvalpedi[i] = vvalpedi[i] + (liped.lipqtd * liped.lippreco).
                VVALGERPED = VVALGERPED + (liped.lipqtd * liped.lippreco).
            end.
            if vtotpedi[i] < 0
            then vtotpedi[i] = 0.
            if vvalpedi[i] < 0
            then vvalpedi[i] = 0.

        end.

        do i = 1 to 6:
            /*
            vtotcomp[i] = 0.
            vvalcomp[i] = 0.
            */
            for each estab where estab.etbcod >= 995 or
                                 estab.etbcod = 900 no-lock:
                find himov where himov.etbcod = estab.etbcod and
                                 himov.procod = produ.procod and
                                 himov.movtdc = 4            and
                                 himov.himmes = vnummes[i]   and
                                 himov.himano = vnumano[i] no-lock no-error.
                if not avail himov
                then next.
                vtotcomp[i] = vtotcomp[i] + himov.himqtm.
                VTOTGERCOM = VTOTGERCOM + HIMOV.HIMQTM.
                vvalcomp[i] = vvalcomp[i] + (himov.himqtm * estoq.estcusto).
                VVALGERCOM = VVALGERCOM + (HIMOV.HIMQTM * ESTOQ.ESTCUSTO).
            end.
            if vtotcomp[i] < 0
            then vtotcomp[i] = 0.
            if vvalcomp[i] < 0
            then vvalcomp[i] = 0.
            /*
            vtotvend[i] = 0.
            vvalvend[i] = 0.
            */
            for each estab no-lock:
                find himov where himov.etbcod = estab.etbcod and
                                 himov.procod = produ.procod and
                                 himov.movtdc = 5            and
                                 himov.himmes = vnummes[i]   and
                                 himov.himano = vnumano[i] no-lock no-error.
                if not avail himov
                then next.
                vtotvend[i] = vtotvend[i] + himov.himqtm.
                VTOTGERVEN = VTOTGERVEN + HIMOV.HIMQTM.
                vvalvend[i] = vvalvend[i] + (himov.himqtm * estoq.estvenda).
                VVALGERVEN = VVALGERVEN + (HIMOV.HIMQTM * ESTOQ.ESTVENDA).
            end.
            if vtotvend[i] < 0
            then vtotvend[i] = 0.
            if vvalvend[i] < 0
            then vvalvend[i] = 0.

            vmm    = vnummes[i].
            vaa    = vnumano[i].

            vmm    = vmm - 1.

            if vmm = 0
            then do:
                vmm = 12.
                vaa = vaa - 1.
            end.
            /*
            vtotesto[i] = 0.
            vvalesto[i] = 0.
            */
            for each estab no-lock:
                find hiest where hiest.etbcod = estab.etbcod and
                                 hiest.procod = produ.procod and
                                 hiest.hiemes = vmm          and
                                 hiest.hieano = vaa          no-lock no-error.
                if not avail hiest
                then next.
                vtotesto[i] = vtotesto[i] + hiest.hiestf.
                VTOTGEREST = VTOTGEREST + HIEST.HIESTF.
                vvalesto[i] = vvalesto[i] + (hiest.hiestf * estoq.estcusto).
                VVALGEREST = VVALGEREST + (HIEST.HIESTF * ESTOQ.ESTCUSTO).
            end.
            if vtotesto[i] < 0
            then vtotesto[i] = 0.
            if vvalesto[i] < 0
            then vvalesto[i] = 0.

        end.
        IF VTOTEST    = 0 and
           VTOTGERCOM = 0 and
           VTOTGERVEN = 0 and
           VTOTGEREST = 0
        THEN next.
        vmargen = (((estoq.estvenda / vultcust) - 1) * 100).
        if vmovqtm <= 0
        then vmovqtmcar = " ".
        else vmovqtmcar = string(vmovqtm).
    end.

    hide frame f3 no-pause.

    /*
    disp
        "  PC: "
        estoq.estcusto format ">,>>9.99"

        "  PV: "
        estoq.estvenda format ">,>>9.99"

        "  MG: "
        vmargen

        "  EG: "
        vtotest format "->>,>>9"

        "  ED: "
        vtotdep format "->>,>>9"

        space(1)
        with frame f2 no-labels color white/cyan.
    */

        /*
        "P E D I D O" AT 87
        "|" AT 100
        "C O M P R A D O" AT 123
        */

    disp skip(1) with frame f0 no-box.
    disp space(8)
        vmes2ped[3] space(1)
        vmes2ped[2] space(1)
        vmes2ped[1] space(1)

        vmes2[1] space(1)
        vmes2[2] space(1)
        vmes2[3] space(1)
        vmes2[4] space(1)
        vmes2[5] space(1)
        vmes2[6] space(1) skip
        with frame f4 with no-labels color white/gray no-box width 80 row 9.

    disp

         "COMP.="
        vtotpedi[3] format ">>>,>>9" space(1)
        vtotpedi[2] format ">>>,>>9" space(1)
        vtotpedi[1] format ">>>,>>9" space(1)

        vtotcomp[1] format ">>>,>>9"  space(1)
        vtotcomp[2] format ">>>,>>9" space(1)
        vtotcomp[3] format ">>>,>>9" space(1)
        vtotcomp[4] format ">>>,>>9" space(1)
        vtotcomp[5] format ">>>,>>9" space(1)
        vtotcomp[6] format ">>>,>>9" skip

         "VEND.=          "
        space(15)
        vtotvend[1] format ">>>,>>9" space(1)
        vtotvend[2] format ">>>,>>9" space(1)
        vtotvend[3] format ">>>,>>9" space(1)
        vtotvend[4] format ">>>,>>9" space(1)
        vtotvend[5] format ">>>,>>9" space(1)
        vtotvend[6] format ">>>,>>9" skip

         "ESTO.=          "
        space(15)
        vtotesto[1] format ">>>,>>9" space(1)
        vtotesto[2] format ">>>,>>9" space(1)
        vtotesto[3] format ">>>,>>9" space(1)
        vtotesto[4] format ">>>,>>9" space(1)
        vtotesto[5] format ">>>,>>9" space(1)
        vtotesto[6] format ">>>,>>9"

        with frame f5 no-labels centered color white/gray title " Quantidade ".

    disp

         "COMP.="
        vvalpedi[3] format ">>>,>>9" space(1)
        vvalpedi[2] format ">>>,>>9" space(1)
        vvalpedi[1] format ">>>,>>9" space(1)

        vvalcomp[1] format ">>>,>>9"  space(1)
        vvalcomp[2] format ">>>,>>9" space(1)
        vvalcomp[3] format ">>>,>>9" space(1)
        vvalcomp[4] format ">>>,>>9" space(1)
        vvalcomp[5] format ">>>,>>9" space(1)
        vvalcomp[6] format ">>>,>>9" skip

         "VEND.=          "
        space(15)
        vvalvend[1] format ">>>,>>9" space(1)
        vvalvend[2] format ">>>,>>9" space(1)
        vvalvend[3] format ">>>,>>9" space(1)
        vvalvend[4] format ">>>,>>9" space(1)
        vvalvend[5] format ">>>,>>9" space(1)
        vvalvend[6] format ">>>,>>9" skip

         "ESTO.=          "
        space(15)
        vvalesto[1] format ">>>,>>9" space(1)
        vvalesto[2] format ">>>,>>9" space(1)
        vvalesto[3] format ">>>,>>9" space(1)
        vvalesto[4] format ">>>,>>9" space(1)
        vvalesto[5] format ">>>,>>9" space(1)
        vvalesto[6] format ">>>,>>9"

        with frame f7 no-labels centered
             color white/gray title " Valor " row 16.
        pause.
end.
