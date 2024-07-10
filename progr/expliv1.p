{admcab.i}
def var vperiodo as char format "x(30)".
def var vtipo as char format "x(15)" extent 3 
               initial["GERAL","MOVIMENTADO","NAO MOVIMENTADO"].
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
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
def var vetb2  as int format ">>99" extent 40.
DEF VAR VDPT AS I FORMAT "99" LABEL "Departamento".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".
def var vcont   as int initial 0.
def var vtip    as char format "XX".
def var vcol as i format ">".
def buffer bestoq for estoq.
def var vesc as int.

    
    vesc = 0.  
    display "L I V R O   D E   P R E C O" 
            with frame f-cabe side-label centered row 5.
    display vtipo no-label with frame f-esc side-label row 8 centered. 
    choose field vtipo with frame f-esc.       
    if frame-index = 2 
    then do:
        update vdti label "Periodo"
               vdtf no-label with frame f-data side-label centered.
        vesc = 2.
    end.
 
    if frame-index = 3 
    then do:
        update vdti label "Data de Referencia"
                 with frame f-data1 side-label centered.
        vesc = 3.
    end.
    if vesc = 0
    then vperiodo = "  GERAL".
    if vesc = 2
    then vperiodo = "  Periodo: " + string(vdti,"99/99/9999")
                       + " ATE "  + string(vdtf,"99/99/9999").
    if vesc = 3
    then vperiodo = "  Nao Comprado desde: " + string(vdti,"99/99/9999").

 
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
         vetb2[33] = 39
         vetb2[34] = 40
         vetb2[35] = 41
         vetb2[36] = 42
         vetb2[37] = 95
         vetb2[38] = 43
         vetb2[39] = 44
         vetb2[40] = 45.

    vcont = 0.
    vdia = 90.
    find categoria where categoria.catcod = 31 no-lock.



    vcont = 0.
    output to l:\relat\liv.
    for each produ where produ.catcod = categoria.catcod
                                 no-lock break by pronom.
        vqtdtot= 0.
        
        if vesc = 2 
        then do:
            find first movim where movim.procod = produ.procod and
                                   movim.movtdc = 04           and
                                   movim.datexp >= vdti        and
                                   movim.datexp <= vdtf no-lock no-error.
            if not avail movim
            then find first movim where movim.procod = produ.procod and
                                        movim.movtdc = 01           and
                                        movim.datexp >= vdti        and
                                        movim.datexp <= vdtf no-lock no-error.
                                        
                 if not avail movim
                 then next.
                 
        end.
        
        if vesc = 3 
        then do:
            find first movim where movim.procod = produ.procod and
                                   movim.movtdc = 04           and
                                   movim.datexp >= vdti no-lock no-error.
            if avail movim
            then next.
            find first movim where movim.procod = produ.procod and
                                   movim.movtdc = 01           and
                                   movim.datexp >= vdti no-lock no-error.
                                        
            if avail movim
            then next.
                 
        end.
        

        
        output stream stela to terminal.
            display stream stela "Gerando Livro.."
                                 produ.procod
                                 produ.pronom 
                                    with frame f-stela 
                                        1 down no-label centered.
            pause 0.
        output stream stela close.
        vqtd = 0.
        vpreco = 0.
        vok = no.
        do i = 1 to 40:
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

        
        if estoq.estprodat <> ?
        then do:
            if estoq.estprodat >= today
            then vtip = string(estoq.estproper).
        end.
        
        
        find first simil where simil.procod = produ.procod 
                                no-lock no-error.
        if avail simil
        then vtip = "*" + vtip.
        else do:
            find first movim where movim.datexp >= (today - 20) and
                                   movim.procod = produ.procod and
                                   movim.movtdc = 4 no-lock no-error.
            if avail movim 
            then vtip = "E" + vtip.
        end.
        
        put produ.procod format "999999" 
            vtip         format "x(4)" 
            vpreco       format ">,>>9.99" 
            vqtdtot      format "->,>>9.99" skip.

        vqtdtot = 0.
        
    end.
    output close.
    
    dos silent value("c:\dlc\bin\quoter -c 1-6,7-10,11-18,19-27 
               l:\relat\liv > l:\work\livro.txt").  

    run impliv1.p (input vperiodo).
    hide frame f-stela no-pause.
