/*Semanal - Movimentado*/
/*{admcab.i}*/

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
def var vdata as char.
def var vqtd  as int format "->>9".
def var vclacod like produ.clacod.
DEF VAR VDPT AS I FORMAT "99" LABEL "Departamento".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".
def var vcont   as int initial 0.
def var vtip    as char format "XX".
def var vcol as i format ">".
def buffer bestoq for estoq.
def var vesc as int.
def var v15  like com.estoq.estvenda.


def temp-table tt-pro
    field procod like produ.procod.
    
vdata = string(year(today),"9999") + 
        string(month(today),"99").  
         

for each tt-pro:
    delete tt-pro.
end.

for each admprog where admprog.menpro begins vdata no-lock.

    find first tt-pro where tt-pro.procod = int(substring(progtipo,1,6)) 
                                                    no-error.
    if not avail tt-pro
    then do:
        create tt-pro.
        assign tt-pro.procod = int(substring(progtipo,1,6)).
    end.    
end.

    vdti = today - 360.
    vdtf = today.
    vesc = 0.  

    /*******************
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
    **/

    vesc = 2.
    vcont = 0.
    vdia = 90.
    
    find categoria where categoria.catcod = 31 no-lock.



    find finan where finan.fincod = 17 no-lock no-error.

    vcont = 0.

    output to /admcom/connect/gerarel/livro-sem. 
    
    for each produ where produ.catcod = categoria.catcod
                                 no-lock break by pronom.
        vqtdtot = 0.

        find first tt-pro where tt-pro.procod = produ.procod no-error.
        if vesc = 2 and not avail tt-pro
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
        
        if vesc = 3 and not avail tt-pro 
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
        
        /**
        output stream stela to terminal.
            display stream stela "Gerando Livro.."
                                 produ.procod
                                 produ.pronom 
                                    with frame f-stela 
                                        1 down no-label centered.
            pause 0.
        output stream stela close.
        **/
        
        vqtd   = 0.
        vpreco = 0.
        vok    = no.
        
        for each bestoq where bestoq.procod = produ.procod no-lock.
            if bestoq.etbcod >= 93
            then VQTDTOT = VQTDTOT + bestoq.estatual.
            if bestoq.estatual <> 0
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
        v15 = ((estoq.estvenda * finan.finfat) * 15).

        if estoq.estprodat <> ?
        then do:
            if estoq.estprodat >= today
            then do:
                vtip = string(estoq.estproper).
                v15 = ((estoq.estproper * finan.finfat) * 15).
            end.
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
        
        if vtip = "" 
        then vtip = ".".
         
        put produ.procod format "999999" 
            vtip         format "x(4)" 
            vpreco       format ">,>>9.99" 
            vqtdtot      format "->,>>9.99" 
            v15          format ">,>>9.99" skip.

        vqtdtot = 0.
        
    end.
    output close.
                            
    os-command silent value("/usr/dlc/bin/quoter -c 1-6,7-10,11-18,19-27,28-35 
/admcom/connect/gerarel/livro-sem > /admcom/connect/gerarel/livro-sem.txt").

    os-command silent rm -f /admcom/connect/gerarel/livro-sem.
/*    os-command silent gzip -f /admcom/connect/gerarel/livro-sem.txt.*/

   os-command silent /home/drebes/scripts/rcp-arq.sh enviar lista 
           /admcom/connect/gerarel/livro-sem.txt /usr/admcom/connect/gerarel &.
