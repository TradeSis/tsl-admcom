{admcab.i }
def var vpreco like estoq.estvenda.
def var i as i.
def var vdata like plani.pladat.
def var vetb  as int format ">>99" extent 22.
def var vqtd  as int format ">>>9" extent 22.
def var vcatcod like produ.catcod.
repeat:
    assign
         vetb[1] = 999
         vetb[2] = 997
         vetb[3] = 02
         vetb[4] = 04
         vetb[5] = 07
         vetb[6] = 09
         vetb[7] = 10
         vetb[8] = 12
         vetb[9] = 13
         vetb[10] = 15
         vetb[11] = 16
         vetb[12] = 17
         vetb[13] = 18
         vetb[14] = 19
         vetb[15] = 20
         vetb[16] = 21
         vetb[17] = 24
         vetb[18] = 25
         vetb[19] = 26
         vetb[20] = 27
         vetb[21] = 28
         vetb[22] = 29.

    update vdata   label "Nao Movimentado desde"
           vcatcod label "Departamento"
                with frame f1 side-label width 80.

    {confir.i 1 "Livro de Preco"}
    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """REL1"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """NAO MOVIMENTADOS DESDE "" +
                        STRING(VDATA)"
        &Width     = "160"
        &Form      = "frame f-cab"}

    put
        "CODIGO-D DESCRICAO                               "
  "PR.VENDA            S A L D O  E M  E S T O Q U E  N A S  F I L I A I S"
   skip
  " " space(57) vetb skip
        fill("-",160) format "x(160)" skip.


    for each produ where produ.catcod = vcatcod no-lock by pronom.
        find first movim where movim.procod = produ.procod and
                               movim.movtdc = 5            and
                               movim.movdat >= vdata no-lock no-error.
        if avail movim
        then next.
        assign vqtd[1] = 0
               vqtd[2] = 0
               vqtd[3] = 0
               vqtd[4] = 0
               vqtd[5] = 0
               vqtd[6] = 0
               vqtd[7] = 0
               vqtd[8] = 0
               vqtd[9] = 0
               vqtd[10] = 0
               vqtd[11] = 0
               vqtd[12] = 0
               vqtd[13] = 0
               vqtd[14] = 0
               vqtd[15] = 0
               vqtd[16] = 0
               vqtd[17] = 0
               vqtd[18] = 0
               vqtd[19] = 0
               vqtd[20] = 0
               vqtd[21] = 0
               vqtd[22] = 0.
        do i = 1 to 22:
            find estoq where estoq.etbcod = vetb[i] and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then vqtd[i] = 0.
            else vqtd[i] = estoq.estatual.
            vpreco = estoq.estvenda.
        end.

        display produ.procod
                produ.pronom format "x(40)"
                vpreco format ">,>>9.99" space(2)
                vqtd[1] space(0) vqtd[2] space(0) vqtd[3] space(0)
                vqtd[4] space(0) vqtd[5] space(0) vqtd[6] space(0)
                vqtd[7] space(0) vqtd[8] space(0) vqtd[9] space(0)
                vqtd[10] space(0) vqtd[11] space(0) vqtd[12] space(0)
                vqtd[13] space(0) vqtd[14] space(0) vqtd[15] space(0)
                vqtd[16] space(0) vqtd[17] space(0) vqtd[18] space(0)
                vqtd[19] space(0) vqtd[20] space(0) vqtd[21] space(0)
                vqtd[22] with frame f2 down no-label no-box width 160.
    end.
    output close.
end.
