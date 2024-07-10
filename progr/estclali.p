{admcab.i}
def var vpreco like estoq.estvenda.
def var i as i.
def var vdata like plani.pladat.
def var vetb  as int format ">>99" extent 22.
def var vqtd  as int format ">>>9" extent 22.
def var vclacod like produ.clacod.
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

    update vclacod label "Classe"
                with frame f1 side-label centered color white/red row 4.
    find clase where clase.clacod = vclacod no-lock.
    disp clase.clanom no-label with frame f1.

    {confir.i 1 "Livro de Preco"}
    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """ESTCLALI"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE"""
        &Width     = "160"
        &Form      = "frame f-cab"}

    put
        "CODIGO-D DESCRICAO                               "
  "PR.VENDA            S A L D O  E M  E S T O Q U E  N A S  F I L I A I S"
   skip
  " " space(57) vetb skip
        fill("-",160) format "x(160)" skip.


    for each produ where produ.clacod = vclacod no-lock by pronom.
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
        vpreco = 0.
        do i = 1 to 22:
            find estoq where estoq.etbcod = vetb[i] and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then vqtd[i] = 0.
            else do:
                vqtd[i] = estoq.estatual.
                if estoq.estvenda > 0
                then vpreco = estoq.estvenda.
            end.
        end.

        display produ.procod
                produ.pronom format "x(40)"
                vpreco format ">,>>9.99" space(2)
                vqtd[1] (TOTAL) space(0)
                vqtd[2] (TOTAL) space(0)
                vqtd[3] (TOTAL) space(0)
                vqtd[4] (TOTAL) space(0)
                vqtd[5] (TOTAL) space(0)
                vqtd[6] (TOTAL) space(0)
                vqtd[7] (TOTAL) space(0)
                vqtd[8] (TOTAL) space(0)
                vqtd[9] (TOTAL) space(0)
                vqtd[10] (TOTAL) space(0)
                vqtd[11] (TOTAL) space(0)
                vqtd[12] (TOTAL) space(0)
                vqtd[13] (TOTAL) space(0)
                vqtd[14] (TOTAL) space(0)
                vqtd[15] (TOTAL) space(0)
                vqtd[16] (TOTAL) space(0)
                vqtd[17] (TOTAL) space(0)
                vqtd[18] (TOTAL) space(0)
                vqtd[19] (TOTAL) space(0)
                vqtd[20] (TOTAL) space(0)
                vqtd[21] (TOTAL) space(0)
                vqtd[22] (TOTAL)
                with frame f2 down no-label no-box width 160.
    end.
    output close.
end.
