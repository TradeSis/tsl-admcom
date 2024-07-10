{admcab.i}
        
def var vflag as log.
def var ii as int.
def var vv as char.
def var cc as char.

def var varquivo as char.
def var zz as int.
def stream stela.
def var vetbcod like estab.etbcod.
def var vdata       like titulo.titdtemi.
def var vdt1        as   date  format "99/99/9999" initial today. 
def var vdt2        as   date  format "99/99/9999" initial today.
def var vlote       like lancxa.livre1.
def var vlote1      as char format "xxxx".
def var vlote2      as int  format "9999".
def var totval like plani.platot.
def stream tela.

def var vtipo as l format "Entrada/Saida" initial no.

repeat with 1 down side-label width 80 row 4 color blue/white:

    
    update vlote label "Lote" colon 20
           vtipo label "Movimento" colon 20.

    if vtipo = yes
    then vv = "D".
    else vv = "C".

    totval = 0.
    for each lancxa where lancxa.livre1 = vlote 
                      and lancxa.lansit = "F" 
                          no-lock:
        
        find hispad where hispad.hiscod = lancxa.lanhis no-lock no-error.
        if not avail hispad
        then next.

        if lancxa.lancod <> 13 
        then do :
            find tablan where tablan.landeb = lancxa.lancod no-lock no-error.
            if not avail tablan
            then next.
        end.
        else do :
            find first tablan where tablan.landeb = lancxa.cxacod 
                no-lock no-error.
            if not avail tablan
            then next.
        end.
        totval = totval + lancxa.vallan.
    end.

    varquivo = "m:\simy\Ext" + string(vlote,"9999").
                                  
    output to value(varquivo).

    output stream stela to terminal.
    
        for each lancxa where lancxa.livre1 = vlote
                          and lancxa.lansit = "F"  
                              no-lock:
            
            find hispad where hispad.hiscod = lancxa.lanhis no-lock no-error.
            if not avail hispad
            then next.

            if lancxa.lancod <> 13 
            then do :
                find tablan where tablan.landeb = lancxa.lancod 
                            no-lock no-error.
                if not avail tablan
                then next.
            end.
            else do :
                find first tablan where tablan.landeb = lancxa.cxacod
                                  no-lock no-error.
                if not avail tablan
                then next.
            end.
            
            put vlote format "9999"
                day(lancxa.datlan)   format "99"
                month(lancxa.datlan) format "99"
                year(lancxa.datlan)  format "9999".
            
            put "D" format "x(01)".
            put ( totval * 100) format "999999999999999".

            
            put  lancxa.lancod format "99999"
                ( lancxa.vallan * 100) format "999999999999999"  
                lancxa.lanhis format "999".
        
            zz = 0.
            ii = 0.
            vflag = no.
            put lancxa.comhis format "x(50)" skip.
            
            /*
            find tablan where tablan.landeb = lancxa.cxacod no-lock no-error.
            if not avail tablan
            then next.
            */
            
            put vlote format "9999"
                day(lancxa.datlan)   format "99"
                month(lancxa.datlan) format "99"
                year(lancxa.datlan)  format "9999".
            
            put "C" format "x(01)".
            put ( totval * 100) format "999999999999999".

            
            put  lancxa.lancod format "99999"
                (lancxa.vallan * 100) format "999999999999999"  
                lancxa.lanhis format "999".
        
            zz = 0.
            ii = 0.
            vflag = no.
            put lancxa.comhis format "x(50)" skip.
        end.

    output stream stela close.
    output close.

end.
