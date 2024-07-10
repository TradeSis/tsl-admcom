def var vobs like plani.notobs.
def var itvaloroutroicm like plani.platot.

def var ipi_base  like plani.platot.
def var ipi_capa  like plani.platot.
def var ipi_item  like plani.platot.
def var base_icms like plani.platot.
def var vdatexp like plani.datexp.
def var vcod as char format "x(18)".
def var vemite like plani.emite.
def var vdesti like plani.desti.
def input parameter vetbcod like estab.etbcod.
def input parameter vdti like plani.pladat.
def input parameter vdtf like plani.pladat.
def var vopccod as char.
def var vali    as int.
def var varq    as char. 
def var val_contabil like plani.platot.
def var visenta like plani.platot.
def var voutras like plani.platot.
def buffer bmovim for movim.
 
 


    varq = "/admcom/audit/sai" + string(vetbcod,">>9") + "_" +
           string(day(vdti),"99") + 
           string(month(vdti),"99") + 
           string(year(vdti),"9999") + "_" + 
          
           string(day(vdtf),"99") + 
           string(month(vdtf),"99") + 
           string(year(vdtf),"9999") + ".txt".

 
                                                               
    output to value(varq).
        for each tipmov where tipmov.movtnota = yes and
                              tipmov.movtdeb  = yes no-lock:

        if tipmov.movtdc = 5
        then next.
        for each estab where if vetbcod = 0
                             then true 
                             else estab.etbcod = vetbcod no-lock:
            for each plani where plani.etbcod = estab.etbcod  and
                                 plani.movtdc = tipmov.movtdc and
                                 plani.datexp >= vdti         and
                                 plani.datexp <= vdtf no-lock:
               
                
                ipi_base = 0.
                ipi_item = 0.
                ipi_capa = 0.
                
                if plani.platot = 0
                then next.
                                
                if plani.serie = "U" 
                then. 
                else next.
          
                if plani.emite = 995 and
                   plani.desti = 998 
                then next.
                if plani.emite = 998 and
                   plani.desti = 995
                then next.   
                
                vdatexp = plani.datexp.
                if plani.movtdc = 13 and
                   plani.datexp >= 01/01/2005 and
                   plani.datexp <= 05/31/2005
                then vdatexp = date(07,
                                    day(plani.datexp),
                                    year(plani.datexp)).
        

             
             
                vemite = plani.emite.  
                if vemite = 998  
                then vemite = 995.
            
                vdesti = plani.desti.  
                if vdesti = 998  
                then vdesti = 995.
               
               
                assign visenta      = 0 
                       voutras      = 0.

               


             
                if plani.movtdc = 6 or
                   plani.movtdc = 9 or
                   plani.movtdc = 22
                then do:   
                    if plani.protot = 0 
                    then next. 
                    vopccod = "5152". 
                    vcod = "E" + string(vdesti,"9999999") + "          ". 
                end.    
                else do: 
                    find forne where forne.forcod = vdesti no-lock no-error.
                    if not avail forne 
                    then next.

                    vcod = "F" + string(forne.forcod,"9999999") + 
                            "          ". 
                
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
             
                base_icms = 0.
                find first bmovim where bmovim.etbcod = plani.etbcod and
                                        bmovim.placod = plani.placod and
                                        bmovim.movtdc = plani.movtdc and
                                        bmovim.movdat = plani.pladat 
                                                no-lock no-error.
                if avail bmovim 
                then do: 
                    
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat no-lock:
                             
                
                        if movim.movpc = 0 or
                           movim.movqtm = 0
                        then next.   
                        itvaloroutroicm =  movim.movpc * movim.movqtm.

                    
                        base_icms = 0.  
                                            
                        
                        val_contabil = movim.movpc * movim.movqtm.
 
                        if vopccod = "6901" 
                        then assign visenta = val_contabil  
                                              - (movim.movpc * movim.movqtm) 
                                              - plani.ipi.
                                    voutras = val_contabil 
                                              - (movim.movpc * movim.movqtm) 
                                              - plani.ipi - visenta.

                        if vopccod = "5202" or 
                           vopccod = "6202"
                        then assign base_icms = movim.movpc * movim.movqtm
                                    itvaloroutroicm = 0 
                                    val_contabil = val_contabil + 
                                                ((movim.movpc * movim.movqtm) * 
                                                (movim.movalipi / 100))
                                    ipi_capa = plani.ipi
                                    ipi_item =  ((movim.movpc * movim.movqtm) * 
                                                (movim.movalipi / 100))
                                    ipi_base = if movim.movalipi <> 0
                                               then (movim.movpc *   
                                                     movim.movqtm)
                                               else 0.
                        else assign ipi_capa = 0
                                    ipi_item = 0
                                    ipi_base = 0.
                                    
                        vobs[1] = plani.notobs[1].
                        vobs[2] = plani.notobs[2].
                        
                        if vobs[1] = "" and
                           ipi_capa > 0
                        then vobs[1] = "VALOR IPI: " + 
                                       string(ipi_capa,">>,>>9.99").

             
                                    
                        put unformatted 
                            string(vemite,">>9")    
                            "P"  format "x(1)"                           
                            "01" format "x(2)"  
                            "NF" format "x(05)"            
                            "01 " format "x(05)" 
                            string(plani.numero,">>>>>>999999")  
                            string(year(vdatexp),"9999") 
                            string(month(vdatexp),"99") 
                            string(day(vdatexp),"99") 
                            string(year(vdatexp),"9999")
                            string(month(vdatexp),"99") 
                            string(day(vdatexp),"99") 
                        vcod  format "x(18)" 
                        " " format "x(1)" 
                        "V" format "x(1)" 
                        plani.platot   format "9999999999999.99" 
                        plani.descprod format "9999999999999.99" 
                        plani.protot   format "9999999999999.99" 
                        plani.icms     format "9999999999999.99" 
                        ipi_capa       format "9999999999999.99" 
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
                        vobs[1] format "x(50)" 
                        vobs[2] format "x(50)" 
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
      /*860-875 */      base_icms format "9999999999999.99" 
     /* 876-882 */      movim.movalicms              format "9999.99"       
                        ((movim.movpc * movim.movqtm) * 
                        (movim.movalicms / 100)) format "9999999999999.99" 
     /* 899-914 */      visenta      format "9999999999999.99" 
     /* 915-930 */      itvaloroutroicm format "9999999999999.99" 
     /* 931-946 */      "0000000000000.00" 
     /* 947-962 */      "0000000000000.00" 
     /* 963-963 */      " " format "x(1)"  
     /* 964-979 */      ipi_base       format "9999999999999.99" 
     /* 980-986  */     movim.movalipi format "9999.99" 
     /* 987-1002 */     ipi_item       format "9999999999999.99" 
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
        /* 1299-1314 */ val_contabil format "9999999999999.99" 
                        " " format "x(86)" skip.
                    end.
                end.
                else do:
                
                    base_icms = 0.
                    itvaloroutroicm = plani.platot.
                    

                    val_contabil = plani.platot.
                    visenta = 0.

                    voutras = val_contabil.
 
  
                    if vopccod = "6901"  
                    then assign visenta = val_contabil  
                                          - (plani.platot) 
                                          - plani.ipi.
                                voutras = val_contabil 
                                          - (plani.platot) 
                                          - plani.ipi - visenta.
                    
                    if vopccod = "5202" or
                       vopccod = "6202"
                    then assign base_icms = plani.platot 
                                itvaloroutroicm = 0
                                val_contabil = val_contabil + plani.ipi.
                  
                    vobs[1] = plani.notobs[1]. 
                    vobs[2] = plani.notobs[2].
                        
                    if vobs[1] = "" and 
                       plani.ipi > 0
                    then vobs[1] = "VALOR IPI: " + 
                                   string(plani.ipi,">>,>>9.99").

                                           
 
 
                    put unformatted 
                        string(vemite,">>9")    
                        "P"  format "x(1)"                           
                        "01" format "x(2)"  
                        "NF" format "x(05)"            
                        "01 " format "x(05)" 
                        string(plani.numero,">>>>>>999999")  
                        string(year(vdatexp),"9999") 
                        string(month(vdatexp),"99") 
                        string(day(vdatexp),"99") 
                        string(year(vdatexp),"9999")
                        string(month(vdatexp),"99") 
                        string(day(vdatexp),"99") 
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
                        vobs[1] format "x(50)" 
                        vobs[2] format "x(50)" 
                        " " format "x(30)" 
                        " " format "x(1)"  
                        " " format "x(20)" 
                        " " format "x(45)" 
                        vopccod format "x(6)" 
                        " " format "x(6)" 
                        " " format "x(10)" 
                        " " format "x(3)"   /* 789-791 */
                        "00000000001.0000" /* 792-807 */
                        "UN" format "x(3)" 
                        plani.platot format "99999999999.9999" 
                        plani.platot format "9999999999999.99" 
                        "0000000000000.00"  
                        " " format "x(1)"
     /*860-875 */      base_icms format "9999999999999.99" 
     /* 876-882 */     "0000.00"       
                        (plani.platot * 
                        (plani.icms / 100)) format "9999999999999.99" 
     /* 899-914 */      visenta      format "9999999999999.99" 
     /* 915-930 */      itvaloroutroicm  format "9999999999999.99" 
                        "0000000000000.00" 
                        "0000000000000.00" 
                        " " format "x(1)"  
                        "0000000000000.00" 
     /* 980-986  */     "0000.00" 
     /* 987-1002 */     "0000000000000.00" 
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
        /* 1299-1314 */ val_contabil format "9999999999999.99" 
                        " " format "x(86)" skip.

                
                end.
            end.                                 
        end.
    end.
