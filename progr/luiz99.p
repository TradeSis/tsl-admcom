{admcab.i}
def var varquivo as char format "x(20)".
def var vok as log.
def var vpreco like estoq.estvenda.
def var i as i.
def var vdata like plani.pladat.
def var vetb  as int format ">>99" extent 26.
def var vqtd  as int format "->>9" extent 26.
def var vclacod like produ.clacod.
DEF VAR VDPT AS I FORMAT "99" LABEL "Departamento".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".
def var vcont   as int initial 0.
def var vtip    as char format "X".
def var vprocod like produ.procod.

def temp-table wfcod
    field cod like produ.procod.

repeat:

    update vprocod with frame ff2 centered SIDE-LABEL.
    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do:
        message "produto nao cadastrado".
        undo, retry.
    end.
    display produ.pronom no-label with frame ff2.

    find first wfcod where wfcod.cod = produ.procod no-error.
    if not avail wfcod
    then do:
        create wfcod.
        assign wfcod.cod = produ.procod.
    end.
end.


    assign
         vetb[1] = 02
         vetb[2] = 04
         vetb[3] = 07
         vetb[4] = 09
         vetb[5] = 10
         vetb[6] = 12
         vetb[7] = 13
         vetb[8] = 15
         vetb[09] = 16
         vetb[10] = 17
         vetb[11] = 18
         vetb[12] = 19
         vetb[13] = 20
         vetb[14] = 21
         vetb[15] = 24
         vetb[16] = 25
         vetb[17] = 26
         vetb[18] = 27
         vetb[19] = 28
         vetb[20] = 29
         vetb[21] = 30
         vetb[22] = 31
         vetb[23] = 32
         vetb[24] = 33
         vetb[25] = 34
         vetb[26] = 35.

    {confir.i 1 "Livro de Preco"}
    varquivo = "c:\temp\anacom" + STRING(day(today)).


    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """LUIZ24"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE"""
        &Width     = "160"
        &Form      = "frame f-cab"}

    put
        "CODIGO-D DESCRICAO                               "
  "PR.VENDA            S A L D O  E M  E S T O Q U E  N A S  F I L I A I S"
   skip
  " " space(52) vetb  skip
        fill("-",160) format "x(160)" skip.

    for each wfcod:
    for each produ where produ.procod = wfcod.cod no-lock by produ.pronom:

        ASSIGN VQTDTOT = 0.
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
               vqtd[22] = 0
               vqtd[23] = 0
               vqtd[24] = 0
               vqtd[25] = 0
               vqtd[26] = 0.


        vpreco = 0.
        VOK = no.
        do i = 1 to 26:
            find estoq where estoq.etbcod = vetb[i] and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then vqtd[i] = 0.
            else do:
                vqtd[i] = estoq.estatual.
                if estoq.estvenda > 0
                then vpreco = estoq.estvenda.
            end.
            VQTDTOT = VQTDTOT + VQTD[I].
            if avail estoq and estoq.estatual <> 0
            then vok = yes.
        end.

        IF VOK = NO
        THEN NEXT.
        vtip = "".
        vcont = vcont + 1.

        if vcont = 54
        then do:
            put
                "*  NAO MOVIMENTADOS DESDE " at 20 today - 90 skip
                "P  PRODUTOS EM PROMOCAO" at 20 skip
                "E  PRODUTOS COM ENTRADAS NOS ULTIMOS 10 DIAS" at 20.
            page.
            put
                "CODIGO-D DESCRICAO                               "
  "PR.VENDA                S A L D O  E M  E S T O Q U E  N A S  F I L I A I S"
            skip
            " " space(52) vetb  skip
            fill("-",160) format "x(160)" skip.
            vcont = 0.
        end.

        find first movim where movim.movdat > (today - 90) and
                               movim.procod = produ.procod and
                               (movim.movtdc = 4 or
                               movim.movtdc = 5) no-lock no-error.
        if avail movim
        then vtip = "".
        else vtip = "*".

        find first movim where movim.movdat >= (today - 10) and
                               movim.procod = produ.procod and
                               movim.movtdc = 4 no-lock no-error.
        if avail movim
        then vtip = "E".


        display produ.procod
                produ.pronom format "x(33)"
                vpreco format ">,>>9.99" space(2)
                vqtd[1] space(0) vqtd[2] space(0) vqtd[3] space(0)
                vqtd[4] space(0) vqtd[5] space(0) vqtd[6] space(0)
                vqtd[7] space(0) vqtd[8] space(0) vqtd[9] space(0)
                vqtd[10] space(0) vqtd[11] space(0) vqtd[12] space(0)
                vqtd[13] space(0) vqtd[14] space(0) vqtd[15] space(0)
                vqtd[16] space(0) vqtd[17] space(0) vqtd[18] space(0)
                vqtd[19] space(0) vqtd[20] space(0) vqtd[21] space(0)
                vqtd[22] space(0) vqtd[23] space(0) vqtd[24] space(0)
                vqtd[25] space(0) vqtd[26]
                with frame f2 down no-label no-box width 160.
    end.
    end.
    output close.
    dos silent value("type " + varquivo + " > prn").
