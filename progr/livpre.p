{admcab.i}
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
def var vetb2  as int format ">>99" extent 33.
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
         vetb2[25] = 30
         vetb2[26] = 31
         vetb2[27] = 32
         vetb2[28] = 33
         vetb2[29] = 35
         vetb2[30] = 36
         vetb2[31] = 37
         vetb2[32] = 38
         vetb2[33] = 39.

    vcont = 0.

    prompt-for categoria.catcod colon 20
                with frame f1 side-label centered color white/cyan row 7.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.

    update skip vimp colon 20 with frame f1.
    update skip vdia label "Nao movimentado desde" with frame f1.

    {confir.i 1 "Livro de Preco"}

    vcont = 0.
    /* varquivo = "i:\admcom\relat\liv" + STRING(day(today),"99") + ".txt". */
    output to l:\relat\liv.
    for each produ where produ.catcod = categoria.catcod
                                 no-lock break by pronom.
        output stream stela to terminal.
            display stream stela estab.etbcod
                                 produ.procod
                                 produ.pronom with frame f-stela 1 down.
            pause 0.
        output stream stela close.
        vqtd = 0.
        vpreco = 0.
        vok = no.
        do i = 1 to 33:
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
        find estoq where estoq.etbcod = 1 and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then vqtd = 0.
        else do:
           vqtd = estoq.estatual.
           vpreco = estoq.estvenda.
        end.
        vtip = "".

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

        put produ.procod format "999999" 
            vtip         format "x(4)" 
            vpreco       format ">,>>9.99" 
            vqtdtot      format "->,>>9.99" skip.

        vqtdtot = 0.
    end.
    output close.
    dos value("quoter -c 1-6,7-10,11-18,19-27 
               l:\relat\liv > l:\relat\livro.txt").  

end.
