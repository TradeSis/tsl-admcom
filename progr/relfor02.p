{admcab.i}                                   

def shared temp-table tt-produ
        field procod like produ.procod
        field fabcod like produ.fabcod
        field pronom like produ.pronom.
def var varquivo as char.
def var vest as l.
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
def var vfabcod     like fabri.fabcod.
def var vcatcod     like categoria.catcod.

def buffer bestoq   for estoq.

define            variable vmes  as char format "x(03)" extent 12 initial
    ["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"].

def var vmes2 as char format "x(4)" extent 12.

def var vnummes as int format ">>>" extent 12.
def var vnumano as int format ">>>>" extent 12.

def stream stela.

    varquivo = "..\relat\rel02" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "145"
        &Page-Line = "64"
        &Nom-Rel   = ""RELFOR02""
        &Nom-Sis   = """SISTEMA DE ESTOQUE - ENTRADAS"""
        &Tit-Rel   = """INFORMACOES PARA COMPRA - FORNECEDORES"""
        &Width     = "145"
        &Form      = "frame f-cab"}

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

put 
"DESCRICAO                           CODIGO  PRECO  ULT.ALT   SALDO "
at 15
"MARGEM ULT.COMPRA    ------  C O M P R A  M E S E S  A N T E R I O R E S"
skip
"                                                          VENDA             EST. LUCRO% DATA      PRECO  QTDE  "



vmes2[1] space(1)
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

fill("-",170) format "x(170)" skip.

for each tt-produ  break by tt-produ.fabcod
                         by tt-produ.pronom.

        
    output stream stela to terminal.
        disp stream stela   tt-produ.fabcod
                            tt-produ.procod with 1 down centered.
        pause 0.
    output stream stela close.
    
 
    
    if first-of(tt-produ.fabcod)
    then do:
        find fabri where fabri.fabcod = tt-produ.fabcod no-lock.
        disp fabri.fabcod at 15
             fabri.fabnom no-label with frame f-fab side-label.
    end.
    vtotest = 0.
    vest = no.
    for each bestoq where bestoq.procod = tt-produ.procod no-lock.
        vtotest = vtotest + bestoq.estatual.
        if vest = no
        then do:
            if bestoq.estatual <> 0
            then vest = yes.
        end.
    end.
    find produ where produ.procod = tt-produ.procod no-lock no-error.
    find last estoq of produ no-lock no-error.
    if not avail estoq
    then next.
    vmovdat = ?.
    vultcomp = ?.
    vmovqtm = 0.
    
    for each tipmov where tipmov.movtdc = 01 or
                          tipmov.movtdc = 04 no-lock:
        find last movim use-index datsai
                        where movim.procod = produ.procod and
                              movim.movtdc = tipmov.movtdc no-lock no-error.
        if avail movim
        then do:
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.pladat = movim.movdat and
                                   plani.movtdc = movim.movtdc 
                                            no-lock no-error.
            if avail plani
            then do:
                if vultcomp = ? or
                   vultcomp < plani.dtinclu
                then vultcomp = plani.dtinclu.
            end.
            else do:
                if vultcomp = ? or
                   vultcomp < movim.movdat
                then vultcomp = movim.movdat.
            end.
        end.
        
        else do:
            find cestoq where cestoq.etbcod = 999 and
                              cestoq.procod = tt-produ.procod no-lock no-error.
            if avail cestoq
            then vultcomp = cestoq.estinvdat.
        end.
        
    end.
    

    vmovqtm = 0.
    
    for each estab where estab.etbcod >= 993
                      or estab.etbcod = 900 no-lock:
       find himov where himov.etbcod = estab.etbcod and
                        himov.procod = tt-produ.procod and
                        himov.movtdc = 4            and
                        himov.himmes = month(today) and
                        himov.himano = year(today) no-lock no-error.
       if not avail himov
       then next.
       vmovqtm = vmovqtm + HIMOV.HIMQTM.
    end.


    VTOTGER = 0.
    do i = 1 to 12:
        vtotcomp[i] = 0.
        for each estab where estab.etbcod >= 993
                          or estab.etbcod = 900 no-lock:
            find himov where himov.etbcod = estab.etbcod and
                             himov.procod = tt-produ.procod and
                             himov.movtdc = 4            and
                             himov.himmes = vnummes[i]   and
                             himov.himano = vnumano[i] no-lock no-error.
            if not avail himov
            then next.
            vtotcomp[i] = vtotcomp[i] + himov.himqtm.
            VTOTGER = VTOTGER + HIMOV.HIMQTM.
        end.
    end.
    output stream stela close.
    if vest = no
    then IF VTOTEST = 0 and
            VTOTGER = 0
         THEN next.
    vmargen = (((estoq.estvenda / estoq.estcusto) - 1) * 100).
    if vmovqtm <= 0
    then vmovqtmcar = " ".
    else vmovqtmcar = string(vmovqtm).

    put
        tt-produ.pronom format "x(36)" at 15
        tt-produ.procod space(1)
        estoq.estvenda format ">,>>9" space(1)
        estoq.datexp format "99/99/9999" space(1)
        vtotest format "->>>9" space(1)
        vmargen space(1)
        vultcomp format "99/99/9999" space(1)
        estoq.estcusto format ">>>9.99" space(1)
        vmovqtmcar format "x(4)" 
        vtotcomp[1] format ">>>>9" 
        vtotcomp[2] format "->>>9" 
        vtotcomp[3] format "->>>9" 
        vtotcomp[4] format "->>>9" 
        vtotcomp[5] format "->>>9" 
        vtotcomp[6] format "->>>9" 
        vtotcomp[7] format "->>>9" 
        vtotcomp[8] format "->>>9" 
        vtotcomp[9] format "->>>9" 
        vtotcomp[10] format "->>>9"
        vtotcomp[11] format "->>>9"
        vtotcomp[12] format "->>>9" skip.
end.
output close. 
{mrod.i}
