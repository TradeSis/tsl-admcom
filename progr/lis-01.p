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

    if vimp = no
    then do:
    {mdadm080.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = ""lis-01""
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
        &Nom-Rel   = ""lis-01""
        &Nom-Sis   = """SISTEMA DE ESTOQUE - ENTRADAS"""
        &Tit-Rel   = """INFORMACOES PARA COMPRA - FORNECEDORES"""
        &Width     = "160"
        &Form      = "frame f-cab2"}
    end.

put
"DESCRICAO                               "
 "          CODIGO       PRECO     PROMOCAO         "
skip

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
    find last estoq of produ no-lock no-error.
    if not avail estoq
    then next.

    output stream stela close.
    vlin = vlin + 1.
    put skip
        produ.pronom  
        produ.procod space(2)
        estoq.estvenda space(4)
        estoq.estproper format ">,>>9.99" space(1).

if vlin = 48
then do:
    page.
put
"DESCRICAO                                  CODIGO     PRECO       PROMOCAO   "
 skip

fill("-",156) format "x(156)" .

vlin = 0.
end.
end.
output close.
