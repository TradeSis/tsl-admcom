{admcab.i}
def var vdata like plani.pladat.
def var sal-atu like estoq.estatual format "->,>>9.99".
def var vforcod like produ.fabcod.
def var vqtd like estoq.estatual.
repeat:


    prompt-for categoria.catcod colon 16 with frame f1 side-label width 80.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.


    {confir.i 1 "Posicao de Estoque"}
    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = """negativo"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE NEGATIVO"""
        &Width     = "80"
        &Form      = "frame f-cab"}
     for each produ no-lock by pronom.

        if produ.catcod <> categoria.catcod
        then next.

        vqtd = 0.
        for each estoq where estoq.procod = produ.procod no-lock:
            vqtd = vqtd + estoq.estatual.
        end.
        if vqtd >= 0
        then next.

        display produ.procod column-label "Codigo"
                produ.pronom FORMAT "x(35)"
                vqtd (TOTAL) column-label "Qtd." format "->>>>9"
                                with frame f2 down width 80.
     end.
     output close.
end.
