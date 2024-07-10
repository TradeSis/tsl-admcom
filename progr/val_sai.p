{admcab.i}


/****************** Notas Fiscais de Saida ********************/
def var vcod as char format "x(18)".

def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var vali    as int.

repeat:

    update vetbcod with frame f1.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
    
        find estab where estab.etbcod = vetbcod no-lock.

        display estab.etbnom no-label with frame f1.
        
    end.
    
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.

 

                                                               
    output to l:\audit\saida.txt.
    for each tipmov where tipmov.movtnota = yes and
                          tipmov.movtdeb  = yes no-lock:

        for each estab where if vetbcod = 0
                             then true 
                             else estab.etbcod = vetbcod no-lock:
            for each plani where plani.etbcod = estab.etbcod  and
                                 plani.movtdc = tipmov.movtdc and
                                 plani.pladat >= vdti         and
                                 plani.pladat <= vdtf no-lock:

             if plani.movtdc = 6
             then do:
                vopccod = "5152".
                vcod = "E" + string(plani.desti,"9999999") + "          ". 
             end.
             else do:
                find forne where forne.forcod = plani.desti no-lock no-error.
                if not avail forne
                then next.

                vcod = "F" + string(forne.forcod,"9999999") + "          ". 
                
                if forne.ufecod = "RS"
                then find first opcom where 
                                opcom.movtdc = plani.movtdc no-lock.
                else find last opcom where 
                               opcom.movtdc = plani.movtdc no-lock.
                
                vopccod = string(opcom.opccod). 
                
             end.

             if plani.bicms > 0
             then vali = int((plani.icms * 100) / plani.bicms).
             else vali = 0.

             if plani.protot = 0
             then do:
             
             


             for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat no-lock:
                                
                 put unformatted 
                    string(plani.etbcod,">>9")   
                    "P"  format "x(1)"                           
                    "01" format "x(2)"  
                    "NF" format "x(05)"            
                    "01 " format "x(05)" 
                    string(plani.numero,">>>>>>999999")                     string(year(plani.pladat),"9999") 
                    string(month(plani.pladat),"99") 
                    string(day(plani.pladat),"99") 
                    string(year(plani.datexp),"9999")
                    string(month(plani.datexp),"99") 
                    string(day(plani.datexp),"99") 
                    vcod  format "x(18)" 
                    " " format "x(1)" 
                    "V" format "x(1)" 
                    plani.platot   format "9999999999999.99" 
                    plani.descprod format "9999999999999.99" 
                    plani.protot   format "9999999999999.99" 
                    plani.icms     format "9999999999999.99" 
                    plani.ipi      format "9999999999999.99" 
                    plani.icmssubst format "9999999999999.99"  
                    " " format "x(20)" 
                    plani.frete    format "9999999999999.99" 
                    plani.seguro   format "9999999999999.99" 
                    "0000000000000.00" 
                    "RODOVIARIO"   format "x(15)" 
                    "CIF"          format "x(3)"  
                    "0" format "x(18)" 
                    "0000000000000.00" 
                    "UNIDADE" format "x(10)"  
                    "000000000000.000" 
                    "000000000000.000" 
                    " " format "x(17)" 
                    plani.vlserv format "9999999999999.99" 
                    "0000.00" 
                    "0000000000000.00" 
                    "0000000000000.00"  
                    "0000000000000.00"  
                    "0000000000000.00"  
                    "0000000000000.00"  
                    "0000000000000.00"  
                    "0000000000000.00"  
                    "0000000000000.00"  
                    "0000000000000.00"  
                    "0000000000000.00"  
                    "0000000000000.00"  
                    "0000000000000.00"  
                    "0000000000000.00"  
                    plani.notobs[1] format "x(50)" 
                    plani.notobs[2] format "x(50)" 
                    " " format "x(30)" 
                    " " format "x(1)"  
                    string(movim.procod) format "x(20)" 
                    " " format "x(45)" 
                    vopccod format "x(6)" 
                    " " format "x(6)" 
                    " " format "x(10)" 
                    " " format "x(3)"   /* 789-791 */
                    movim.movqtm  format "99999999999.9999" /* 792-807 */
                    "UN" format "x(3)" 
                    movim.movpc                  format "99999999999.9999" 
                    (movim.movpc * movim.movqtm) format "9999999999999.99" 
                    movim.movdes                 format "9999999999999.99"  
                    " " format "x(1)"
                    (movim.movpc * movim.movqtm) format "9999999999999.99" 
 /* 876-882 */      movim.movalicms              format "9999.99"       
                    ((movim.movpc * movim.movqtm) * (movim.movalicms / 100))
                            format "9999999999999.99" 
                    plani.isenta      format "9999999999999.99" 
                    plani.outras      format "9999999999999.99" 
                    "0000000000000.00" 
                    "0000000000000.00" 
                    " " format "x(1)"  
                    (movim.movpc * movim.movqtm) format "9999999999999.99" 
 /* 980-986  */     movim.movalipi format "9999.99" 
 /* 987-1002 */   ((movim.movpc * movim.movqtm) * (movim.movalipi / 100))
                            format "9999999999999.99" 
                    "0000000000000.00" 
                    "0000000000000.00" 
                    "0000000000000.00" 
                    "0000000000000.00" 
 /* 1067-1073 */    "0000.00"    
                    "0000000000000.00"  
                    "0000000000000.00"
 /* 1106-1112 */    "0000.00"  
                    "0000000000000.00" 
                    "0000000000000.00" 
 /* 1145-1151 */    "0000.00"  
                    "0000000000000.00" 
                    "0000000000000.00"
/*  1184-1190 */    "0000.00"
                    "0000000000000.00"
                    " " format "x(14)"
                    "0000000000000.00" 
                    "0000.00"  
                    "0000000000000.00"  
                    "0000000000000.00"  
                    "0000.00"  
                    "0000000000000.00"  
                    (movim.movpc * movim.movqtm) format "9999999999999.99" 
                    " " format "x(86)" skip.
                end.
            
            end.                                 
        end.
    end.
    
end.    
