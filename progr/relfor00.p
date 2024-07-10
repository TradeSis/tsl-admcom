{admcab.i}

def var vaux-datexp as char format "x(5)".
def var vaux-ultcomp as char format "x(5)".

def var varquivo as char.
def new shared temp-table tt-produ
        field procod like produ.procod
        field fabcod like produ.fabcod
        field pronom like produ.pronom.
    
def var vdt like plani.pladat.

def var vest as l.
def var vimp as log format "80/132" label "Impressao".
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

def temp-table ttaux
    field fabcod like fabri.fabcod
    field fabnom like fabri.fabnom
    field procod like produ.procod
    field pronom like produ.pronom format "x(40)"
    field catcod like produ.catcod
    field estvenda like estoq.estvenda format ">,>>9"
    field auxdatexp as char format "x(5)"
    field totest like estoq.estatual format "->>>9"
    field vmargem as dec format "->>9"
    field auxultcomp as char format "x(5)"
    field estcusto like estoq.estcusto format ">>>9,99"
    field movqtmcar as char format "x(4)"
    field totcomp like himov.himqtm extent 12
    field dtultcomp as date.


def stream stela.

update vcatcod label "Departamento" colon 15 with frame f-for centered
                                                  color white/red side-labels.
                                                 
find categoria where categoria.catcod = vcatcod no-lock.
disp categoria.catnom no-label with frame f-for.

    
    for each tt-produ: delete tt-produ. end.
    for each ttaux. delete ttaux. end.

    vdt = today - 365.
                                     
    update vdt label "Ultima Compra" colon 15 with frame f-for.
                                         
    varquivo = "..\relat\relfor" + string(time) + ".txt".

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "00"
        &Cond-Var  = "152"
        &Page-Line = "00"
        &Nom-Rel   = ""RELFOR00""
        &Nom-Sis   = """SISTEMA DE ESTOQUE - ENTRADAS"""
        &Tit-Rel   = """INFORMACOES PARA COMPRA - FORNECEDORES"""
        &Width     = "152"
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

"DESCRICAO                                CODIGO PRECO ULT.  SALDO "
at 2
"MARG. DT.ULT               ------  C O M P R A  M E S E S  A N T E R I O R E S"
skip
"                                                 VENDA ALT.   EST. LUC.% COMPRA   PRECO QTD   "

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

fill("-",152) format "x(152)" skip.

for each fabri where fabri.fabcod > 0 no-lock,
    first forne where forne.forcod = fabri.fabcod no-lock
               by /*fabri.fabcod fabri.fabnom:*/ forne.forfant:

vfabcod = fabri.fabcod.

for each produ where produ.catcod = vcatcod and
                     produ.fabcod = vfabcod no-lock
                                            break by produ.fabcod
                                                  by produ.pronom.


    
    output stream stela to terminal.
        disp stream stela   produ.fabcod
                            produ.procod with 1 down centered.
        pause 0.
    output stream stela close.
    
    vultcomp = 01/01/1999.
/* 
    if first-of(produ.fabcod)
    then disp fabri.fabcod at 15 
              fabri.fabnom no-label skip(1)
              with frame f-fab side-label.

*/    
    find last movim where movim.movtdc = 4 and
                          movim.procod = produ.procod no-lock no-error.
    if avail movim
    then vultcomp = movim.movdat.
        
    find last movim where movim.movtdc = 1 and
                          movim.procod = produ.procod no-lock no-error.
    if avail movim and 
       movim.movdat > vultcomp and 
       vultcomp <> ?
    then vultcomp = movim.movdat.

    if vultcomp = ? or vultcomp < vdt
    then do:
        find first tt-produ where tt-produ.procod = produ.procod no-error.
        if not avail tt-produ
        then do:
            create tt-produ.
            assign tt-produ.procod = produ.procod
                   tt-produ.pronom = produ.pronom
                   tt-produ.fabcod = produ.fabcod.
        end.
        next.
    end.

    vtotest = 0.
    vest = no.
    for each bestoq where bestoq.procod = produ.procod no-lock.
        vtotest = vtotest + bestoq.estatual.
        if vest = no
        then do:
            if bestoq.estatual <> 0
            then vest = yes.
        end.
    end.

    find last estoq of produ no-lock no-error.
    if not avail estoq
    then next.
    vmovdat = ?.
    
    /*
    vmovqtm = 0.
    
    find last movim use-index datsai
                    where movim.procod = produ.procod and
                          movim.movtdc = 4 no-lock no-error.
    if avail movim
    then do:
        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.pladat = movim.movdat and
                               plani.movtdc = movim.movtdc no-lock no-error.
        if avail plani
        then vultcomp = plani.dtinclu.
        else vultcomp = movim.movdat.
    end.
    else do:
    
        find cestoq where cestoq.etbcod = 999 and
                          cestoq.procod = produ.procod no-lock no-error.
        if avail cestoq
        then vultcomp = cestoq.estinvdat.
    
    end.
    */
    
    vmovqtm = 0.
    
    for each estab where estab.etbcod >= 993
                      or estab.etbcod = 900   no-lock:
       find himov where himov.etbcod = estab.etbcod and
                        himov.procod = produ.procod and
                        himov.movtdc = 4            and
                        himov.himmes = month(today) and
                        himov.himano = year(today) no-lock no-error.
       if not avail himov
       then next.
       vmovqtm = vmovqtm + HIMOV.HIMQTM.
    end.

    find ttaux where ttaux.procod = produ.procod no-error.
    if not avail ttaux
    then do:
        create ttaux.
        assign ttaux.procod = produ.procod
               ttaux.pronom = produ.pronom
               ttaux.fabcod = fabri.fabcod
               ttaux.fabnom = /*fabri.fabnom*/ forne.forfant
               ttaux.catcod = produ.catcod.
    end.
    
    VTOTGER = 0.
    do i = 1 to 12:
        vtotcomp[i] = 0.
        
        ttaux.totcomp[i] = 0.
        
        for each estab where estab.etbcod >= 993
                          or estab.etbcod = 900 no-lock:
            find himov where himov.etbcod = estab.etbcod and
                             himov.procod = produ.procod and
                             himov.movtdc = 4            and
                             himov.himmes = vnummes[i]   and
                             himov.himano = vnumano[i] no-lock no-error.
            if not avail himov
            then next.
            vtotcomp[i] = vtotcomp[i] + himov.himqtm.
            ttaux.totcomp[i] = ttaux.totcomp[i] + himov.himqtm.
            
            VTOTGER = VTOTGER + HIMOV.HIMQTM.
        end.
    end.

    output stream stela close.
    
    if vest = no
    then IF VTOTEST = 0 and
            VTOTGER = 0
         THEN next.
    
    vmargen = (((estoq.estvenda / estoq.estcusto) - 1) * 100).
    ttaux.vmargem = (((estoq.estvenda / estoq.estcusto) - 1) * 100).
     
    if vmovqtm <= 0
    then vmovqtmcar = " ".
    else vmovqtmcar = string(vmovqtm).
    
    if vmovqtm <= 0
    then ttaux.movqtmcar = " ".
    else ttaux.movqtmcar = string(vmovqtm).

    vaux-datexp = string(month(estoq.datexp),"99").
    ttaux.auxdatexp = string(month(estoq.datexp),"99").
    
    vaux-datexp = vaux-datexp + "/" + 
               substring(string(year(estoq.datexp),"9999"),3,2).

    ttaux.auxdatexp = ttaux.auxdatexp + "/" +
               substring(string(year(estoq.datexp),"9999"),3,2).

    vaux-ultcomp = string(month(vultcomp),"99").
    ttaux.auxultcomp = string(month(vultcomp),"99").
    ttaux.dtultcomp = vultcomp.
    vaux-ultcomp = vaux-ultcomp + "/" + 
               substring(string(year(vultcomp),"9999"),3,2).

    ttaux.auxultcomp = ttaux.auxultcomp + "/" +
               substring(string(year(vultcomp),"9999"),3,2).
    
    ttaux.estcusto = estoq.estcusto.
    ttaux.estvenda = estoq.estvenda.
    ttaux.totest   = vtotest.
    
    /***
    if first-of(produ.fabcod)
    then disp fabri.fabcod at 15 
              fabri.fabnom no-label skip(1)
              with frame f-fab side-label.

    put 
        produ.pronom format "x(45)" at 15
        space(1)
        produ.procod space(1)
        estoq.estvenda format ">,>>9" space(1)
        /***estoq.datexp format "99/99/9999" space(1)***/
        vaux-datexp format "x(5)" space(1)
        vtotest format "->>>9" space(1)
        vmargen space(1)
        vultcomp format "99/99/9999" space(1)
        /**
        vaux-ultcomp format "x(5)" space(1)
        **/
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
        vtotcomp[12] format "->>>9" skip.***/
end.

    /*mostrar os produtos...*/

    find first ttaux where ttaux.fabcod = fabri.fabcod no-lock no-error.
    if not avail ttaux
    then next.
    
    
    disp fabri.fabcod at 2
         /*fabri.fabnom*/
         forne.forfant no-label skip(1) with frame f-fab side-label.

    for each ttaux where ttaux.fabcod = fabri.fabcod no-lock
                break by ttaux.pronom.
    
        put ttaux.pronom      format "x(40)" at 2 space(1)
            ttaux.procod                           space(1)
            ttaux.estvenda    format ">,>>9"       space(1)
            ttaux.auxdatexp   format "x(5)"        space(1)
            ttaux.totest      format "->>>9"       space(2)
            ttaux.vmargem     space(2)
            /*ttaux.auxultcomp  format "x(5)"        space(1)
            */
            ttaux.dtultcomp format "99/99/99" space(1)
            ttaux.estcusto    format ">>>9.99"     space(1)
            ttaux.movqtmcar   format "x(4)"
            ttaux.totcomp[1]  format ">>>>9" 
            ttaux.totcomp[2]  format "->>>9" 
            ttaux.totcomp[3]  format "->>>9" 
            ttaux.totcomp[4]  format "->>>9" 
            ttaux.totcomp[5]  format "->>>9" 
            ttaux.totcomp[6]  format "->>>9" 
            ttaux.totcomp[7]  format "->>>9" 
            ttaux.totcomp[8]  format "->>>9" 
            ttaux.totcomp[9]  format "->>>9" 
            ttaux.totcomp[10] format "->>>9"
            ttaux.totcomp[11] format "->>>9"
            ttaux.totcomp[12] format "->>>9" skip.
    end.

end.

output close.
if opsys = "UNIX"
then run visurel.p (input varquivo, input "").
else /*{mrod.i}*/ 
     os-command silent start value(varquivo).


message "Deseja Imprimir todos os produtos" update sresp.
if sresp
then run relfor02.p.
