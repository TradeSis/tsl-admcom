{admcab.i}
def var x as i.
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
def var vforcod     like fabri.fabcod.
def var vcatcod     like categoria.catcod.
def var vlin        as int initial 0.
def var varquivo    as char format "X(20)". 
def buffer bestoq   for estoq.

define            variable vmes  as char format "x(03)" extent 12 initial
    ["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"].

def var vmes2 as char format "x(4)" extent 12.

def var vnummes as int format ">>>" extent 12.
def var vnumano as int format ">>>>" extent 12.

def stream stela.

update vforcod label "Fornecedor" colon 15
                        with frame f-for centered side-label
                                                    color white/red row 4.
find fabri where fabri.fabcod = vforcod no-lock.
disp fabri.fabnom no-label with frame f-for.
update vcatcod label "Departamento" colon 15 with frame f-for.
find categoria where categoria.catcod = vcatcod no-lock.
disp categoria.catnom no-label with frame f-for.

update skip(1) vimp colon 20 with frame f-FOR.
disp " Prepare a Impressora para Imprimir Relatorio e pressione ENTER"
                    with frame f-imp centered row 10.
pause.
message "Imprimindo Relatorio... Aguarde".
varquivo = "c:\temp\for0505".
    if vimp = no
    then do:
    {mdadm080.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = ""for0505""
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
        &Nom-Rel   = ""for0505""
        &Nom-Sis   = """SISTEMA DE ESTOQUE - ENTRADAS"""
        &Tit-Rel   = """INFORMACOES PARA COMPRA - FORNECEDORES"""
        &Width     = "160"
        &Form      = "frame f-cab2"}
    end.


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
"DESCRICAO                              CODIGO  PRECO  ULT.ALT    SALDO "
"MARGEM ---  ULTIMA COMPRA  ---  C O M P R A  M E S E S  A N T E R I O R E S"
skip
"                                               VENDA           EST. LUCRO%
 DATA        PRECO QTDE   "
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

fill("-",156) format "x(156)" .


for each produ where produ.catcod = vcatcod and
                     produ.fabcod = vforcod no-lock
                        break by produ.fabcod
                              by produ.pronom.
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
    for each estab no-lock:
        for each bestoq where bestoq.etbcod = estab.etbcod and
                              bestoq.procod = produ.procod no-lock.
            vtotest = vtotest + bestoq.estatual.
        end.
    end.
    find last estoq of produ no-lock no-error.
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
    if avail movim and movim.movdat > vultcomp and vultcomp <> ?
    then vultcomp = movim.movdat.
    if vultcomp = ?
    then do:
        find cestoq where cestoq.etbcod = 999 and
                          cestoq.procod = produ.procod no-lock no-error.
        if avail cestoq
        then vultcomp = cestoq.estinvdat.
    end.
    vmovqtm = 0.
    
    for each estab where estab.etbcod >= 995 no-lock:
       find himov where himov.etbcod = estab.etbcod and
                        himov.procod = produ.procod and
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
    
        for each estab where estab.etbcod >= 995 no-lock:
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
        /*
        for each estab no-lock:
        for each movim where movim.procod = produ.procod and
                             movim.etbcod = estab.etbcod and
                             movim.movtdc = 1            and
                             month(movim.movdat) = i     and
                             year(movim.movdat)  = 1998 no-lock:
                vtotcomp[i] = vtotcomp[i] + movim.movqtm.
                VTOTGER = VTOTGER + movim.movqtm.
        end.
        end.
        */
    end.
    if vforcod = 5412
    then do:
        if vtotest = 0 and
           vultcomp = ? and
           vtotger  = 0
        then next.
    end.


    output stream stela close.
    vlin = vlin + 1.
    vmargen = (((estoq.estvenda / estoq.estcusto) - 1) * 100).
    if vmovqtm <= 0
    then vmovqtmcar = " ".
    else vmovqtmcar = string(vmovqtm).
    put skip
        produ.pronom format "x(38)" 
        produ.procod space(1)
        estoq.estvenda format ">>>9" space(1)
        estoq.estdtven format "99/99/9999" space(1)
        vtotest format "->>>>9" space(1)
        vmargen space(1)
        vultcomp format "99/99/9999" space(1)
        estoq.estcusto format ">>9.99" space(1)
        vmovqtmcar format "x(4)" 
        vtotcomp[1] format ">>>>9" 
        vtotcomp[2] format ">>>>9" 
        vtotcomp[3] format ">>>>9" 
        vtotcomp[4] format ">>>>9" 
        vtotcomp[5] format ">>>>9" 
        vtotcomp[6] format ">>>>9" 
        vtotcomp[7] format ">>>>9" 
        vtotcomp[8] format ">>>>9" 
        vtotcomp[9] format ">>>>9" 
        vtotcomp[10] format ">>>>9"
        vtotcomp[11] format ">>>>9"
        vtotcomp[12] format ">>>>9".

if vlin = 48
then do:
    page.
put
"DESCRICAO                                CODIGO  PRECO  ULT.ALT    SALDO "
"MARGEM ---  ULTIMA COMPRA  ---  C O M P R A  M E S E S  A N T E R I O R E S"
skip
"                                                 VENDA           EST. LUCRO%
 DATA        PRECO QTDE   "
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

fill("-",156) format "x(156)" .

vlin = 0.
end.
end.
output close.
dos silent value("type " + varquivo + "> prn"). 
