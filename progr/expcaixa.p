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
def var vlote       as int  format "9999".
def var vlote1      as char format "xxxx".
def var vlote2      as int  format "9999".
def var totval like plani.platot.
def stream tela.

def var vtipo as l format "Entrada/Saida" initial no.

repeat with 1 down side-label width 80 row 4 color blue/white:

    
    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final" 
           vlote label "Lote" colon 20
           vtipo label "Movimento" colon 20.

    if vtipo = yes
    then vv = "D".
    else vv = "C".

    totval = 0.
    for each lancxa where lancxa.datlan >= vdt1 and
                          lancxa.datlan <= vdt2 and
                          lancxa.lantip = vv no-lock:
        
        find hispad where hispad.hiscod = lancxa.lanhis no-lock no-error.
        if not avail hispad
        then next.


        find tablan where tablan.lancod = lancxa.lancod no-lock no-error.
        if not avail tablan
        then next.

        totval = totval + lancxa.vallan.
        
    end.


    if vtipo
    then varquivo = "m:\simy\Ent" + string(vlote,"9999").
    else varquivo = "m:\simy\Sai" + string(vlote,"9999"). 
    
                                  
    output to value(varquivo).

    output stream stela to terminal.
    
    do vdata = vdt1 to vdt2:
        for each lancxa where lancxa.datlan = vdata and
                              lancxa.lantip = vv no-lock:
            
            find hispad where hispad.hiscod = lancxa.lanhis no-lock no-error.
            if not avail hispad
            then next.

            find tablan where tablan.lancod = lancxa.lancod no-lock no-error.
            if not avail tablan
            then next.
            put vlote format "9999"
                day(lancxa.datlan)   format "99"
                month(lancxa.datlan) format "99"
                year(lancxa.datlan)  format "9999".
            
            if vv = "D"
            then put "C" format "x(01)".
            else put "D" format "x(01)".
                
            put ( totval * 100) format "999999999999999".
            

            if vv = "C"
            then put tablan.landeb format "99999".
            else put tablan.lancre format "99999".
             
            
            put
                ( lancxa.vallan * 100) format "999999999999999"  
                lancxa.lanhis format "999".
        
            zz = 0.
            ii = 0.
            vflag = no.
            do zz = 1 to 50. /* length(hisdes). */
                if substring(hispad.hisdes,zz,1) = ""
                then ii = ii + 1.
                else ii = 0.
    
                cc = cc + substring(hispad.hisdes,zz,1).
                if ii >= 3
                then do:
                    vflag = yes.
                    cc = cc + lancxa.comhis.
                    put cc format "x(50)" skip.
                    cc = "".
                    leave.
                end.
            end.
            if vflag = no
            then do:
                put cc format "x(50)" skip.
                cc = "".
            end.
        end.
    end.
    if vv = "C"
    then do:
        put vlote 
            day(vdt1)   format "99"
            month(vdt1) format "99"
            year(vdt1)  format "9999"
            "C"                  format "x(01)"
            ( totval * 100) format "999999999999999"
              "00013" format "99999"
            ( totval * 100) format "999999999999999"  
              "031"            format "999"
              "PAGAMENTOS N/DATA" format "x(50)" skip.
    end.
    else do:
        put vlote 
            day(vdt1)   format "99"
            month(vdt1) format "99"
            year(vdt1)  format "9999"
            "D"                  format "x(01)"
            ( totval * 100) format "999999999999999"
              "00013" format "99999"
            ( totval * 100) format "999999999999999"  
              "030" format "999"
              "RECEBIMENTO N/DATA" format "x(50)" skip.
    end.

    output stream stela close.
    output close.
/*     dos silent ved value(varquivo).   */
end.
