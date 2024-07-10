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
def var vtotcomp    like himov.himqtm extent 12.
def var vtotpedi    like himov.himqtm extent 03.
def var vtotvend    like himov.himqtm extent 12.
def var vtotesto    like hiest.hiestf extent 12.
def var vfabcod     like fabri.fabcod.
def var vcatcod     like categoria.catcod.
def var vlin        as int initial 0.

def temp-table wfpro
    field cod like produ.procod.

def buffer bestoq   for estoq.

define            variable vmes  as char format "x(03)" extent 12 initial
    ["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"].

def var vmes2 as char format "x(4)" extent 12.
def var vmes2ped as char format "x(4)" extent 03.

def var vnummes as int format ">>>" extent 12.
def var vnummesped as int format ">>>" extent 03.
def var vnumano as int format ">>>>" extent 12.
def var vnumanoped as int format ">>>>" extent 03.

def var aux-etb as int.
def stream stela.

update vfabcod label "Fornecedor" colon 20
                        with frame f-for centered side-label
                                                    color white/red row 4.
find fabri where fabri.fabcod = vfabcod no-lock.
disp fabri.fabnom no-label with frame f-for.
update vcatcod label "Departamento" colon 20 with frame f-for.
find categoria where categoria.catcod = vcatcod no-lock.
disp categoria.catnom no-label with frame f-for.

vpro = ?.
repeat:

    update vpro colon 20 with frame f-for.

    if vpro = ?
    then leave.

    find produ where produ.procod = vpro no-lock.
    if produ.fabcod <> vfabcod
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


update skip(1) vimp colon 20 with frame f-FOR.
disp " Prepare a Impressora para Imprimir Relatorio e pressione ENTER"
                    with frame f-imp centered row 10.
pause.
message "Imprimindo Relatorio... Aguarde".

    if vimp = no
    then do:
    {mdadm080.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = ""RELFIN""
        &Nom-Sis   = """SISTEMA DE ESTOQUE - ENTRADAS"""
        &Tit-Rel   = """INFORMACOES PARA COMPRA - FORNECEDORES"""
        &Width     = "160"
        &Form      = "frame f-cab"}
    end.
    else do:
    {mdadm132.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = ""RELFIN""
        &Nom-Sis   = """SISTEMA DE ESTOQUE - ENTRADAS"""
        &Tit-Rel   = """INFORMACOES PARA COMPRA - FORNECEDORES"""
        &Width     = "160"
        &Form      = "frame f-cab2"}
    end.


vaux    = month(today).
vano    = year(today).
vaux    = vaux + 1.
do i = 1 to 12:
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

put
"DESCRICAO                                CODIGO           "

"P E D I D O" AT 87
"|" AT 100
"C O M P R A D O" AT 123

vmes2ped[3] AT 87 space(1)
vmes2ped[2] space(1)
vmes2ped[1] space(1)

vmes2[1] AT 102 space(1)
vmes2[2] space(1)
vmes2[3] space(1)
vmes2[4] space(1)
vmes2[5] space(1)
vmes2[6] space(1)
vmes2[7] space(1)
vmes2[8] space(1)
vmes2[9] space(1)
vmes2[10] space(1)
vmes2[11] space(1)
vmes2[12] skip

fill("-",160) format "x(160)" .

FIND FIRST WFPRO NO-ERROR.
IF NOT AVAIL WFPRO
THEN DO:

for each produ where produ.catcod = vcatcod and
                     produ.fabcod = vfabcod no-lock
                        break by produ.fabcod
                              by produ.pronom.
    /*output stream stela to terminal.
    disp stream stela produ.procod with 1 down centered.
    pause 0.
    output stream stela close.*/
    if first-of(produ.fabcod)
    then do:
        find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
        if avail fabri
        then do:
            disp fabri.fabcod
                 fabri.fabnom no-label with frame f-fab side-label.
        end.
    end.
    vtotest = 0.
    vtotdep = 0.
    for each bestoq where bestoq.procod = produ.procod no-lock.
        vtotest = vtotest + bestoq.estatual.
        if ( bestoq.etbcod > 900 or
            {conv_igual.i bestoq.etbcod}) 
        then vtotdep = vtotdep + bestoq.estatual.
    end.
    find first estoq of produ no-lock no-error.
    if not avail estoq
    then next.
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
    do i = 1 to 12:
        vtotcomp[i] = 0.
        for each estab where estab.etbcod >= 900 no-lock:
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

        repeat aux-etb = 993 to 999: 
          for each estab where estab.etbcod = aux-etb no-lock:
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
    vlin = vlin + 1.
    vmargen = (((estoq.estvenda / vultcust) - 1) * 100).
    if vmovqtm <= 0
    then vmovqtmcar = " ".
    else vmovqtmcar = string(vmovqtm).
    put skip(1)
        produ.pronom format "x(40)" space(1)
        produ.procod
        " PC:" at 65
        estoq.estcusto format ">,>>9.99"

        "C = " at 82

        vtotpedi[3] format ">>>9" AT 86 space(1)
        vtotpedi[2] format ">>>9" space(1)
        vtotpedi[1] format ">>>9" space(1)

        vtotcomp[1] format ">>>9" at 101 space(1)
        vtotcomp[2] format ">>>9" space(1)
        vtotcomp[3] format ">>>9" space(1)
        vtotcomp[4] format ">>>9" space(1)
        vtotcomp[5] format ">>>9" space(1)
        vtotcomp[6] format ">>>9" space(1)
        vtotcomp[7] format ">>>9" space(1)
        vtotcomp[8] format ">>>9" space(1)
        vtotcomp[9] format ">>>9" space(1)
        vtotcomp[10] format ">>>9" space(1)
        vtotcomp[11] format ">>>9" space(1)
        vtotcomp[12] format ">>>9" skip

        space(42)
        " EG:" AT 50
        vtotest format "->>,>>9" space(1)
        " PV:" AT 65
        estoq.estvenda format ">,>>9.99" space(1)

        "V = " at 82
        vtotvend[1] format ">>>9" at 101 space(1)
        vtotvend[2] format ">>>9" space(1)
        vtotvend[3] format ">>>9" space(1)
        vtotvend[4] format ">>>9" space(1)
        vtotvend[5] format ">>>9" space(1)
        vtotvend[6] format ">>>9" space(1)
        vtotvend[7] format ">>>9" space(1)
        vtotvend[8] format ">>>9" space(1)
        vtotvend[9] format ">>>9" space(1)
        vtotvend[10] format ">>>9" space(1)
        vtotvend[11] format ">>>9" space(1)
        vtotvend[12] format ">>>9" skip
        space(42)

        " ED:" AT 50
        vtotdep format "->>,>>9" space(1)
        " MG:" AT 65
        vmargen space(1)

        "E = " at 82
        vtotesto[1] format ">>>9" at 101 space(1)
        vtotesto[2] format ">>>9" space(1)
        vtotesto[3] format ">>>9" space(1)
        vtotesto[4] format ">>>9" space(1)
        vtotesto[5] format ">>>9" space(1)
        vtotesto[6] format ">>>9" space(1)
        vtotesto[7] format ">>>9" space(1)
        vtotesto[8] format ">>>9" space(1)
        vtotesto[9] format ">>>9" space(1)
        vtotesto[10] format ">>>9" space(1)
        vtotesto[11] format ">>>9" space(1)
        vtotesto[12] format ">>>9".

    if vlin = 13
    then do:
        page.

        put
        "DESCRICAO                                CODIGO           "
        "P E D I D O" AT 87
        "||" AT 100
        "C O M P R A D O" AT 123

        vmes2ped[3] AT 87 space(1)
        vmes2ped[2] space(1)
        vmes2ped[1] space(1)

        vmes2[1] AT 102 space(1)
        vmes2[2] space(1)
        vmes2[3] space(1)
        vmes2[4] space(1)
        vmes2[5] space(1)
        vmes2[6] space(1)
        vmes2[7] space(1)
        vmes2[8] space(1)
        vmes2[9] space(1)
        vmes2[10] space(1)
        vmes2[11] space(1)
        vmes2[12] skip

        fill("-",160) format "x(160)" .

        vlin = 0.
    end.
end.
END.
ELSE DO:
    disp fabri.fabcod
         fabri.fabnom no-label with frame f-fab2 side-label.

FOR EACH WFPRO:

    find produ where produ.procod = wfpro.cod no-lock.
    /*output stream stela to terminal.
    disp stream stela produ.procod with 1 down centered.
    pause 0.
    output stream stela close.*/
    vtotest = 0.
    vtotdep = 0.
    for each bestoq where bestoq.procod = produ.procod no-lock.
        vtotest = vtotest + bestoq.estatual.
        if ( bestoq.etbcod > 900 or
         {conv_igual.i bestoq.etbcod})
        then vtotdep = vtotdep + bestoq.estatual.
    end.
    find first estoq of produ no-lock no-error.
    if not avail estoq
    then next.
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
    do i = 1 to 12:
        vtotcomp[i] = 0.
        for each estab where estab.etbcod >= 900 no-lock:
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
        
        repeat aux-etb = 993 to 999:
            for each estab where estab.etbcod = 900 no-lock:
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
    vlin = vlin + 1.
    vmargen = (((estoq.estvenda / vultcust) - 1) * 100).
    if vmovqtm <= 0
    then vmovqtmcar = " ".
    else vmovqtmcar = string(vmovqtm).
    put skip(1)
        produ.pronom format "x(40)" space(1)
        produ.procod
        " PC:" at 65
        estoq.estcusto format ">,>>9.99"

        "C = " at 82

        vtotpedi[3] format ">>>9" AT 86 space(1)
        vtotpedi[2] format ">>>9" space(1)
        vtotpedi[1] format ">>>9" space(1)

        vtotcomp[1] format ">>>9" at 101 space(1)
        vtotcomp[2] format ">>>9" space(1)
        vtotcomp[3] format ">>>9" space(1)
        vtotcomp[4] format ">>>9" space(1)
        vtotcomp[5] format ">>>9" space(1)
        vtotcomp[6] format ">>>9" space(1)
        vtotcomp[7] format ">>>9" space(1)
        vtotcomp[8] format ">>>9" space(1)
        vtotcomp[9] format ">>>9" space(1)
        vtotcomp[10] format ">>>9" space(1)
        vtotcomp[11] format ">>>9" space(1)
        vtotcomp[12] format ">>>9" skip

        space(42)
        " EG:" AT 50
        vtotest format "->>,>>9" space(1)
        " PV:" AT 65
        estoq.estvenda format ">,>>9.99" space(1)

        "V = " at 82
        vtotvend[1] format ">>>9" at 101 space(1)
        vtotvend[2] format ">>>9" space(1)
        vtotvend[3] format ">>>9" space(1)
        vtotvend[4] format ">>>9" space(1)
        vtotvend[5] format ">>>9" space(1)
        vtotvend[6] format ">>>9" space(1)
        vtotvend[7] format ">>>9" space(1)
        vtotvend[8] format ">>>9" space(1)
        vtotvend[9] format ">>>9" space(1)
        vtotvend[10] format ">>>9" space(1)
        vtotvend[11] format ">>>9" space(1)
        vtotvend[12] format ">>>9" skip
        space(42)

        " ED:" AT 50
        vtotdep format "->>,>>9" space(1)
        " MG:" AT 65
        vmargen space(1)

        "E = " at 82
        vtotesto[1] format ">>>9" at 101 space(1)
        vtotesto[2] format ">>>9" space(1)
        vtotesto[3] format ">>>9" space(1)
        vtotesto[4] format ">>>9" space(1)
        vtotesto[5] format ">>>9" space(1)
        vtotesto[6] format ">>>9" space(1)
        vtotesto[7] format ">>>9" space(1)
        vtotesto[8] format ">>>9" space(1)
        vtotesto[9] format ">>>9" space(1)
        vtotesto[10] format ">>>9" space(1)
        vtotesto[11] format ">>>9" space(1)
        vtotesto[12] format ">>>9".

    if vlin = 13
    then do:
        page.

        put
        "DESCRICAO                                CODIGO           "
        "P E D I D O" AT 87
        "||" AT 100
        "C O M P R A D O" AT 123

        vmes2ped[3] AT 87 space(1)
        vmes2ped[2] space(1)
        vmes2ped[1] space(1)

        vmes2[1] AT 102 space(1)
        vmes2[2] space(1)
        vmes2[3] space(1)
        vmes2[4] space(1)
        vmes2[5] space(1)
        vmes2[6] space(1)
        vmes2[7] space(1)
        vmes2[8] space(1)
        vmes2[9] space(1)
        vmes2[10] space(1)
        vmes2[11] space(1)
        vmes2[12] skip

        fill("-",160) format "x(160)" .

        vlin = 0.
    end.
end.
end.


output close.
