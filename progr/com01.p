{admcab.i}
def var vimp as log format "80/132" label "Tipo de Impressao".
def var vmovqtmcar as char format "x(4)".
def var vtotger as i.
def buffer cestoq for estoq.
def var vtotest     like estoq.estatual.
def var vmargen     as dec format "->>9".
def var vultcomp    as date format "99/99/9999".
def var vmovqtm     like movim.movqtm.
def var vmovdat     as date format "99/99/9999".
def var i           as int.
def var vaux        as int.
def var vano        as int.
def var vtotcomp    like himov.himqtm extent 12.
def var vcatcod     like categoria.catcod.
def var vlin        as int initial 0.

def buffer bestoq   for estoq.

define            variable vmes  as char format "x(03)" extent 12 initial
    ["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"].

def var vmes2 as char format "x(4)" extent 12.

def var vnummes as int format ">>>" extent 12.
def var vnumano as int format ">>>>" extent 12.
def stream stela.

def var vfabcod like fabri.fabcod.
update vfabcod with frame f1 side-label width 80 row 4.
find fabri where fabri.fabcod = vfabcod no-lock.
disp fabri.fabnom no-label with frame f1.
find last produ where produ.fabcod = vfabcod no-lock.
find categoria where categoria.catcod = produ.catcod no-lock.

vaux    = month(today).
vano    = year(today).
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

for each produ where produ.catcod = categoria.catcod and
                     produ.fabcod = vfabcod no-lock
                        break by produ.fabcod
                              by produ.pronom.
    vtotest = 0.
    for each estab no-lock:
        for each bestoq where bestoq.etbcod = estab.etbcod and
                              bestoq.procod = produ.procod no-lock.
            vtotest = vtotest + bestoq.estatual.
        end.
    end.
    find first estoq of produ no-lock no-error.
    if not avail estoq
    then next.
    vmovdat = ?.
    vultcomp = ?.
    vmovqtm = 0.
    
    find last movim where movim.movtdc = 4 and
                          movim.procod = produ.procod no-lock no-error.
    if avail movim
    then vultcomp = movim.movdat.
    
    find last movim where movim.movtdc = 1 and
                          movim.procod = produ.procod no-lock no-error.
    if avail movim and vultcomp < movim.movdat 
    then vultcomp = movim.movdat.

    
    if vultcomp < today - 360 or vultcomp = ? 
    then next.
 
    vmovqtm = 0.
    
    for each movim where movim.movtdc = 4 and
                         movim.procod = produ.procod and
                         movim.movdat >= date(month(today),1,year(today)) and
                         movim.movdat <= (date(month(today),1,year(today)) +
                                          31) no-lock.

        if month(movim.movdat) = month(today)
        then vmovqtm  = vmovqtm + movim.movqtm.
    end.
    
    for each movim where movim.movtdc = 1 and
                         movim.procod = produ.procod and
                         movim.movdat >= date(month(today),1,year(today)) and
                         movim.movdat <= (date(month(today),1,year(today)) +
                                          31) no-lock.

        if month(movim.movdat) = month(today)
        then vmovqtm  = vmovqtm + movim.movqtm.
    end.

 
    VTOTGER = 0.
    do i = 1 to 12:
        vtotcomp[i] = 0.
        for each estab where estab.etbcod >= 94 no-lock:

             if estab.etbcod >= 900 and estab.etbcod < 994 then next.
        
            find himov where himov.etbcod = estab.etbcod and
                             himov.procod = produ.procod and
                             himov.movtdc = 4            and
                             himov.himmes = vnummes[i]   and
                             himov.himano = vnumano[i] no-lock no-error.
            if not avail himov
            then next.
            vtotcomp[i] = vtotcomp[i] + himov.himqtm.
            VTOTGER = VTOTGER + HIMOV.HIMQTM.
        end.
    end.
    vlin = vlin + 1.
    vmargen = (((estoq.estvenda / estoq.estcusto) - 1) * 100).
    if vmovqtm <= 0
    then vmovqtmcar = " ".
    else vmovqtmcar = string(vmovqtm).
    disp
        produ.procod column-label "Codigo"
        produ.pronom format "x(30)"
        estoq.estvenda format ">,>>9"
        vtotest format "->>>9"  column-label "Est"
        trim(string(day(vultcomp),"99") + "/" +  string(month(vultcomp),"99"))
                            column-label "Ult.!Comp." format "x(05)"
        estoq.estcusto format ">>>9.99"
        vmovqtmcar format "x(4)" column-label "Qtd"
        vtotcomp[1] format ">>>9" column-label "Mes1"
        vtotcomp[2] format ">>>9" column-label "Mes2"
                  with frame f-1 down width 80.

end.
