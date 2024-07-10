{admcab.i}
def var a as i.
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
def var vforcod     like fabri.fabcod.
def var vcatcod     like categoria.catcod.
def var vlin        as int initial 0.

def temp-table wfpro
    field cod like produ.procod.

def buffer bestoq   for estoq.

define            variable vmes  as char format "x(04)" extent 12 initial
    [" JAN"," FEV"," MAR"," ABR"," MAI"," JUN",
     " JUL"," AGO"," SET"," OUT"," NOV"," DEZ"].

def var vmes2 as char format "x(4)" extent 6.
def var vmes2ped as char format "x(4)" extent 03.

def var vnummes as int format ">>>" extent 6.
def var vnummesped as int format ">>>" extent 03.
def var vnumano as int format ">>>>" extent 6.
def var vnumanoped as int format ">>>>" extent 03.

def stream stela.

update vforcod label "Fornecedor" colon 20
                        with frame f-for width 80 side-label
                                                    color white/red row 3.
find fabri where fabri.fabcod = vforcod no-lock.
disp fabri.fabnom no-label with frame f-for.


update vcatcod label "Departamento" colon 20 with frame f-for.
find categoria where categoria.catcod = vcatcod no-lock.
disp categoria.catnom no-label with frame f-for.

vpro = ?.
repeat:

    update vpro help "[P] - PROCURA" colon 20 go-on(P p)
                    with frame f-for.

    if keyfunction(lastkey) = "P" or
       keyfunction(lastkey) = "p"
        then do:
            {zoomesq.z produ produ.procod pronom 50 Produtos
                                           "produ.catcod = vcatcod and
                                            produ.fabcod = vforcod"}
             vpro = int(frame-value).
        end.

    if vpro = ?
    then leave.

    find produ where produ.procod = vpro no-lock.
    if produ.fabcod <> vforcod
    then do:
        message "Produto nao pertence a este FABRICANTE. Invalido.". pause.
        undo,retry.
    end.
    if produ.catcod <> vcatcod
    then do:
        message "Produto nao pertence a este DEPARTAMENTO. Invalido.". pause.
        undo,retry.
    end.

    find first wfpro where wfpro.cod = vpro no-error.
    if not avail wfpro
    then do:
        create wfpro.
        assign wfpro.cod = vpro.
    end.
end.

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


FIND FIRST WFPRO NO-ERROR.
IF NOT AVAIL WFPRO
THEN DO:
    a = 1.
    for each produ where produ.catcod = vcatcod and
                         produ.fabcod = vforcod no-lock
                                  by produ.pronom.

        vtotest = 0.
        vtotdep = 0.
        for each bestoq where bestoq.procod = produ.procod no-lock.
            vtotest = vtotest + bestoq.estatual.
            if bestoq.etbcod > 995 or  bestoq.etbcod = 900
            then vtotdep = vtotdep + bestoq.estatual.
        end.
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
        vtotgerped = 0.
        do i = 1 to 3:
            vtotpedi[i] = 0.

            for each liped where liped.pedtdc = 1 and
                                 liped.procod = produ.procod and
                                 month(liped.predt) = vnummesped[i] and
                                 year(liped.predt)  = vnumanoped[i] no-lock:
                vtotpedi[i] = vtotpedi[i] + liped.lipqtd.
                VTOTGERPED = VTOTGERPED + liped.lipqtd.
            end.
            if vtotpedi[i] < 0
            then vtotpedi[i] = 0.

        end.

        VTOTGERCOM = 0.
        VTOTGERVEN = 0.
        VTOTGEREST = 0.
        do i = 1 to 6:
            vtotcomp[i] = 0.
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
            end.
            if vtotcomp[i] < 0
            then vtotcomp[i] = 0.

            vtotvend[i] = 0.
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
            end.
            if vtotvend[i] < 0
            then vtotvend[i] = 0.

            vmm    = vnummes[i].
            vaa    = vnumano[i].

            vmm    = vmm - 1.

            if vmm = 0
            then do:
                vmm = 12.
                vaa = vaa - 1.
            end.

            vtotesto[i] = 0.
            for each estab no-lock:
                find hiest where hiest.etbcod = estab.etbcod and
                                 hiest.procod = produ.procod and
                                 hiest.hiemes = vmm          and
                                 hiest.hieano = vaa          no-lock no-error.
                if not avail hiest
                then next.
                vtotesto[i] = vtotesto[i] + hiest.hiestf.
                VTOTGEREST = VTOTGEREST + HIEST.HIESTF.
            end.
            if vtotesto[i] < 0
            then vtotesto[i] = 0.

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
        /*
        if a = 1
        then do:
        */
            a = a + 1.

            disp produ.procod
                 produ.pronom no-label with frame ff33 side-labels row 8 no-box
                                       overlay.

            disp space(35)
            vmes2ped[3] space(1)
            vmes2ped[2] space(1)
            vmes2ped[1] space(1)

            vmes2[1] space(1)
            vmes2[2] space(1)
            vmes2[3] space(1)
            vmes2[4] space(1)
            vmes2[5] space(1)
            vmes2[6] space(1) skip
            with frame fff4 with no-labels color white/gray no-box width 80
                            overlay.

            disp
            "PC:" at 13
            estoq.estcusto format ">,>>9.99"

             "C=" at 32
            vtotpedi[3] format ">>>9" space(1)
            vtotpedi[2] format ">>>9" space(1)
            vtotpedi[1] format ">>>9" space(1)

            vtotcomp[1] format ">>>9"  space(1)
            vtotcomp[2] format ">>>9" space(1)
            vtotcomp[3] format ">>>9" space(1)
            vtotcomp[4] format ">>>9" space(1)
            vtotcomp[5] format ">>>9" space(1)
            vtotcomp[6] format ">>>9" skip

            "EG:"
            vtotest format "->>,>>9"

            "PV:"
            estoq.estvenda format ">,>>9.99"

             "V=" at 32
            space(16)
            vtotvend[1] format ">>>9" space(1)
            vtotvend[2] format ">>>9" space(1)
            vtotvend[3] format ">>>9" space(1)
            vtotvend[4] format ">>>9" space(1)
            vtotvend[5] format ">>>9" space(1)
            vtotvend[6] format ">>>9" skip

            "ED:"
            vtotdep format "->>,>>9"

            "MG:"
            vmargen

             "E=" at 32
            space(16)
            vtotesto[1] format ">>>9" space(1)
            vtotesto[2] format ">>>9" space(1)
            vtotesto[3] format ">>>9" space(1)
            vtotesto[4] format ">>>9" space(1)
            vtotesto[5] format ">>>9" space(1)
            vtotesto[6] format ">>>9"

            with frame fff5 no-labels centered
            color white/gray title " Quantidade "
                                         width 80.
        /*
        end.
        */
        /*
        else do:

            view frame ff33.
            view frame fff4.
            view frame fff5.

            disp produ.procod
             produ.pronom no-label with frame fff33 side-labels row 16 no-box
                                   overlay.

            disp space(35)
            vmes2ped[3] space(1)
            vmes2ped[2] space(1)
            vmes2ped[1] space(1)

            vmes2[1] space(1)
            vmes2[2] space(1)
            vmes2[3] space(1)
            vmes2[4] space(1)
            vmes2[5] space(1)
            vmes2[6] space(1) skip
            with frame f4 with no-labels color white/gray no-box width 80
                          overlay.

            disp
            "PC:" at 13
            estoq.estcusto format ">,>>9.99"

             "C=" at 32
            vtotpedi[3] format ">>>9" space(1)
            vtotpedi[2] format ">>>9" space(1)
            vtotpedi[1] format ">>>9" space(1)

            vtotcomp[1] format ">>>9"  space(1)
            vtotcomp[2] format ">>>9" space(1)
            vtotcomp[3] format ">>>9" space(1)
            vtotcomp[4] format ">>>9" space(1)
            vtotcomp[5] format ">>>9" space(1)
            vtotcomp[6] format ">>>9" skip

            "EG:"
            vtotest format "->>,>>9"

            "PV:"
            estoq.estvenda format ">,>>9.99"

             "V=" at 32
            space(16)
            vtotvend[1] format ">>>9" space(1)
            vtotvend[2] format ">>>9" space(1)
            vtotvend[3] format ">>>9" space(1)
            vtotvend[4] format ">>>9" space(1)
            vtotvend[5] format ">>>9" space(1)
            vtotvend[6] format ">>>9" skip

            "ED:"
            vtotdep format "->>,>>9"

            "MG:"
            vmargen

             "E=" at 32
            space(16)
            vtotesto[1] format ">>>9" space(1)
            vtotesto[2] format ">>>9" space(1)
            vtotesto[3] format ">>>9" space(1)
            vtotesto[4] format ">>>9" space(1)
            vtotesto[5] format ">>>9" space(1)
            vtotesto[6] format ">>>9"

            with frame f5 no-labels centered
            color white/gray title " Quantidade "
                                         width 80 overlay.
            a = 1.
        end.
        */
    end.
end.

ELSE DO:

    FOR EACH WFPRO:

        find produ where produ.procod = wfpro.cod no-lock.

        vtotest = 0.
        vtotdep = 0.
        for each bestoq where bestoq.procod = produ.procod no-lock.
            vtotest = vtotest + bestoq.estatual.
            if bestoq.etbcod > 995 or bestoq.etbcod = 900
            then vtotdep = vtotdep + bestoq.estatual.
        end.
        find first estoq of produ no-lock no-error.
        if not avail estoq
        then next.
        vtotgerped = 0.
        do i = 1 to 3:
            vtotpedi[i] = 0.

            for each liped where liped.pedtdc = 1 and
                                 liped.procod = produ.procod no-lock:
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock.
                if month(pedid.peddti) = vnummesped[i] and
                   year(pedid.peddti)  = vnumanoped[i]
                then assign vtotpedi[i] = vtotpedi[i] + liped.lipqtd
                            VTOTGERPED = VTOTGERPED + liped.lipqtd.
            end.
            if vtotpedi[i] < 0
            then vtotpedi[i] = 0.

        end.

        VTOTGERCOM = 0.
        VTOTGERVEN = 0.
        VTOTGEREST = 0.
        do i = 1 to 6:
            vtotcomp[i] = 0.
            for each estab where estab.etbcod >= 995 or
                                 estoq.etbcod = 900  no-lock:
                find himov where himov.etbcod = estab.etbcod and
                                 himov.procod = produ.procod and
                                 himov.movtdc = 4            and
                                 himov.himmes = vnummes[i]   and
                                 himov.himano = vnumano[i] no-lock no-error.
                if not avail himov
                then next.
                vtotcomp[i] = vtotcomp[i] + himov.himqtm.
                VTOTGERCOM = VTOTGERCOM + HIMOV.HIMQTM.
            end.
            if vtotcomp[i] < 0
            then vtotcomp[i] = 0.

            vtotvend[i] = 0.
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
            end.
            if vtotvend[i] < 0
            then vtotvend[i] = 0.

            vmm    = vnummes[i].
            vaa    = vnumano[i].

            vmm    = vmm - 1.

            if vmm = 0
            then do:
                vmm = 12.
                vaa = vaa - 1.
            end.

            vtotesto[i] = 0.
            for each estab no-lock:
                find hiest where hiest.etbcod = estab.etbcod and
                                 hiest.procod = produ.procod and
                                 hiest.hiemes = vmm          and
                                 hiest.hieano = vaa          no-lock no-error.
                if not avail hiest
                then next.
                vtotesto[i] = vtotesto[i] + hiest.hiestf.
                VTOTGEREST = VTOTGEREST + HIEST.HIESTF.
            end.
            if vtotesto[i] < 0
            then vtotesto[i] = 0.

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
            a = a + 1.

            disp produ.procod
                 produ.pronom no-label with frame ff33x side-labels row 8 no-box
                                       overlay.

            disp space(35)
            vmes2ped[3] space(1)
            vmes2ped[2] space(1)
            vmes2ped[1] space(1)

            vmes2[1] space(1)
            vmes2[2] space(1)
            vmes2[3] space(1)
            vmes2[4] space(1)
            vmes2[5] space(1)
            vmes2[6] space(1) skip
            with frame fff4x with no-labels color white/gray no-box width 80
                            overlay.

            disp
            "PC:" at 13
            estoq.estcusto format ">,>>9.99"

             "C=" at 32
            vtotpedi[3] format ">>>9" space(1)
            vtotpedi[2] format ">>>9" space(1)
            vtotpedi[1] format ">>>9" space(1)

            vtotcomp[1] format ">>>9"  space(1)
            vtotcomp[2] format ">>>9" space(1)
            vtotcomp[3] format ">>>9" space(1)
            vtotcomp[4] format ">>>9" space(1)
            vtotcomp[5] format ">>>9" space(1)
            vtotcomp[6] format ">>>9" skip

            "EG:"
            vtotest format "->>,>>9"

            "PV:"
            estoq.estvenda format ">,>>9.99"

             "V=" at 32
            space(16)
            vtotvend[1] format ">>>9" space(1)
            vtotvend[2] format ">>>9" space(1)
            vtotvend[3] format ">>>9" space(1)
            vtotvend[4] format ">>>9" space(1)
            vtotvend[5] format ">>>9" space(1)
            vtotvend[6] format ">>>9" skip

            "ED:"
            vtotdep format "->>,>>9"

            "MG:"
            vmargen

             "E=" at 32
            space(16)
            vtotesto[1] format ">>>9" space(1)
            vtotesto[2] format ">>>9" space(1)
            vtotesto[3] format ">>>9" space(1)
            vtotesto[4] format ">>>9" space(1)
            vtotesto[5] format ">>>9" space(1)
            vtotesto[6] format ">>>9"

            with frame fff5x no-labels centered
            color white/gray title " Quantidade "
                                         width 80.
    pause.
    end.
end.
