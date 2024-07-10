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
def var vetbcod  like estab.etbcod.
DEF VAR VDPT AS I FORMAT "99" LABEL "Departamento".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".
def var vcont   as int initial 0.
def var vtip    as char format "XX".
def var vcol as i format ">".
def buffer bestoq for estoq.
def var vesc as int.

    update vetbcod label "Filial" with frame f-estab side-label width 80.
                
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f-estab.
    
    vesc = 0.  
    display "L I V R O   D E   P R E C O" 
            with frame f-cabe side-label centered row 7.
    display vtipo no-label with frame f-esc side-label row 10 centered. 
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

 

    vcont = 0.
    vdia = 90.
    find categoria where categoria.catcod = 31 no-lock.



    vcont = 0.
    output to l:\work7\liv.
    for each produ where produ.catcod = categoria.catcod
                                 no-lock break by pronom.
        
        vqtdtot = 0.
        
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        
        if estoq.estatual <= 0
        then next.
        else assign vpreco = estoq.estvenda.
 
        
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
        for each bestoq where bestoq.etbcod >= 94 and
                              bestoq.procod = produ.procod no-lock.
                              
            if bestoq.etbcod >= 900 and bestoq.etbcod < 994 then next.
                              
            if bestoq.estatual > 0
            then VQTDTOT = VQTDTOT + bestoq.estatual.
        end.



        vcol = vcol + 1.
       
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
        
    dos silent value("i:\dlc\bin\quoter -c 1-6,7-10,11-18,19-27 
               l:\work7\liv > l:\work7\livro.txt").  
               
    run impliv5.p (input vperiodo).
    
    hide frame f-stela no-pause.
