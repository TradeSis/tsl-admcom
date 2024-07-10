{admcab.i}
def temp-table westab
    field wetbcod like estab.etbcod.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def stream stela.
def var varquivo as char format "x(20)".
DEF VAR vdia as int format ">99".
def var vimp as log format "80/132" label "Tipo de Impressao".
def var vok as log.
def var vpreco like estoq.estvenda.
def var i as i.
def var vdata like plani.pladat.
def var vqtd  as int format "->>9".
def var vclacod like produ.clacod.
def var vetb2  as int format ">>99" extent 25.
DEF VAR VDPT AS I FORMAT "99" LABEL "Departamento".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".
def var vcont   as int initial 0.
def var vtip    as char format "XX".
def var vcol as i format ">".
def buffer bestoq for estoq.

repeat:
    assign
         vetb2[1] = 999
         vetb2[2] = 98
         vetb2[3] = 997
         vetb2[4] = 02
         vetb2[5] = 03
         vetb2[6] = 04
         vetb2[7] = 07
         vetb2[8] = 09
         vetb2[9] = 10
         vetb2[10] = 12
         vetb2[11] = 13
         vetb2[12] = 15
         vetb2[13] = 16
         vetb2[14] = 17
         vetb2[15] = 18
         vetb2[16] = 19
         vetb2[17] = 20
         vetb2[18] = 21
         vetb2[19] = 24
         vetb2[20] = 25
         vetb2[21] = 26
         vetb2[22] = 27
         vetb2[23] = 28
         vetb2[24] = 29
         vetb2[25] = 30.

    vcont = 0.
    for each westab:
        delete westab.
    end.

    /*
    update vclacod label "Classe"
                with frame f1 side-label width 80.
    */

    prompt-for categoria.catcod colon 20
                with frame f1 side-label centered color white/cyan row 7.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.
    /*
    update vetbi colon 20
           vetbf with frame f1. */
    repeat:
        update vetbi colon 20 with frame f1.
        find first westab where westab.wetbcod = vetbi no-error.
        if not avail westab
        then do:
            create westab.
            assign westab.wetbcod = vetbi.
        end.
    end.

    update skip vimp colon 20 with frame f1.
    update skip vdia label "Nao movimentado desde" with frame f1.

    {confir.i 1 "Livro de Preco"}
    for each westab :
    for each estab where estab.etbcod = westab.wetbcod no-lock:

    vcont = 0.
    varquivo = "c:\temp\liv" + STRING(estab.etbcod,">>9") + ".txt".

    if vimp = no
    then do:
    {mdadm080.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """PRECOLI4"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE NA "" +
                    ""FILIAL "" + string(estab.etbcod)"
        &Width     = "160"
        &Form      = "frame f-cab"}
    end.
    else do:
    {mdadm132.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """GERA-LIV"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE NA "" +
                    ""FILIAL "" + string(estab.etbcod)"
        &Width     = "160"
        &Form      = "frame f-cab2"}
    end.
    put
        "CODIGO-D DESCRICAO                                   "
  "PROM.  VENDA    QTD   EST   "
        "CODIGO-D DESCRICAO                                 "
  "PROM.    VENDA   QTD    EST " skip
        fill("-",160) format "x(160)" skip.


    for each produ where produ.catcod = categoria.catcod
                                 no-lock break by pronom.

        output stream stela to terminal.
            display stream stela estab.etbcod
                                 produ.procod
                                 produ.pronom with frame f-stela 1 down.
            pause 0.
        output stream stela close.
        assign vqtd = 0.
        vpreco = 0.
        vok = no.
        do i = 1 to 25:
            find bestoq where bestoq.etbcod = vetb2[i] and
                              bestoq.procod = produ.procod no-lock no-error.
            if avail bestoq and
                     bestoq.etbcod >= 95
            then VQTDTOT = VQTDTOT + bestoq.estatual.
            if avail bestoq and bestoq.estatual <> 0
            then vok = yes.
        end.

        IF VOK = NO
        THEN NEXT.

        vcol = vcol + 1.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then vqtd = 0.
        else do:
           vqtd = estoq.estatual.
           vpreco = estoq.estvenda.
        end.
        vtip = "".
        if vcont = 54
        then do:
            put
                "*  NAO MOVIMENTADOS DESDE " at 20 today - vdia 
                    format "99/99/9999" skip
                "P  PRODUTOS EM PROMOCAO" at 20 skip
                "E  PRODUTOS COM ENTRADAS NOS ULTIMOS 10 DIAS" at 20.
            page.

            put
                "CODIGO-D DESCRICAO                                    "
                "PROM.   VENDA   QTD   EST   "
                "CODIGO-D DESCRICAO                                  "
                "PROM.   VENDA   QTD   EST " skip
                    fill("-",160) format "x(160)" skip.
            vcont = 0.
        end.

        find first movim where movim.movdat > (today - vdia) and
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
        if estoq.estprodat <> ?
        then do:
            if estoq.estprodat >= today
            then vtip = string(estoq.estproper).
        end.

        if vcol = 1
        then do:
            put
                produ.procod space(1)
                produ.pronom format "x(45)" space(1)
                vtip  format "x(4)" space(1)
                vpreco format ">,>>9.99" space(2)
                vqtd  space(2)
                vqtdtot space(1).
        end.
        if vcol = 2
        then do:
            put
                produ.procod at 81 space(1)
                produ.pronom format "x(45)" space(1)
                vtip format "x(5)" space(1)
                vpreco format ">,>>9.99" space(2)
                vqtd  space(2)
                vqtdtot skip.
            vcont = vcont + 1.
            vcol = 0.
        end.
        vqtdtot = 0.
    end.
    output close.

    dos silent value("copy " + varquivo + " ..\export\cpd" +
                     string(estab.regcod,"99")) /y.
    end.
    end.
/*  dos silent value("type " + varquivo + " > prn").  */
end.
