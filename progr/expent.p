{admcab.i}
def buffer bestab for estab.
def var vcgc as char format "x(14)".
def var ii as int.

def var vemp like estab.etbcod.
def var varquivo as char.
def var codigo-emite like plani.emite.
def var outras-icms as dec format "->>>,>>9.99".
def var /* input parameter */ vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     as date format "99/99/9999".

def var /* input parameter */ vdti    as date format "99/99/9999".
def var /* input parameter */ vdtf    as date format "99/99/9999".

def stream sarq.
def var vcod as int format "99999".
def var codigo-livros like forne.livcod.


    
repeat:

    update vetbcod with frame f1.
    
    vemp = vetbcod.
    if vemp = 98
    then vemp = 995.
 
 


    find estab where estab.etbcod = vetbcod no-lock.

    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.


    

    varquivo = "m:\livros\ent" + string(estab.etbcod,">>9") + ".imp".
 

    output to value(varquivo).


    do vdt = vdti to vdtf:

        for each tipmov where tipmov.movtdc = 4 or
                              tipmov.movtdc = 12 no-lock:
                          
            for each fiscal where fiscal.movtdc = tipmov.movtdc and
                                  fiscal.desti  = estab.etbcod  and
                                  fiscal.plarec = vdt no-lock:

                if fiscal.emite = 5027
                then next.
                outras-icms = 0.
                
                if tipmov.movtdc = 4
                then do:
                
                    find forne where forne.forcod = fiscal.emite 
                        no-lock no-error.
                    if not avail forne
                    then next.
                    codigo-livros = forne.livcod.
                    
                    ii = 0.
                    vcgc = "".
        
            
                    do ii = 1 to 20:
                        if substring(forne.forcgc,ii,1) = "." or
                           substring(forne.forcgc,ii,1) = "-" or
                           substring(forne.forcgc,ii,1) = "/"
                        then.
                        else vcgc = vcgc + substring(forne.forcgc,ii,1).
        
                    end.
          
                end.
                else do:
                    vcgc = "".
                    do ii = 1 to 20:
                        if substring(estab.etbcgc,ii,1) = "." or
                           substring(estab.etbcgc,ii,1) = "-" or
                           substring(estab.etbcgc,ii,1) = "/"
                        then.
                        else vcgc = vcgc + substring(estab.etbcgc,ii,1).
                    end.
                end.
        
        
                nu = nu + 1.
        
                if tipmov.movtdc = 12 and fiscal.opfcod = 1202
                then codigo-livros = estab.etbcod.

                if tipmov.movtdc = 12 and fiscal.opfcod = 1102
                then do:

                    find lancxa where lancxa.numlan = fiscal.numero 
                                no-lock no-error.
                    if avail lancxa
                    then do:
    
                        if lancxa.forcod = 101998 or
                           lancxa.forcod = 102044 or
                           lancxa.forcod = 533    or
                           lancxa.forcod = 103114
                        then codigo-livros = 1281.

                        if lancxa.forcod = 100071
                        then codigo-livros = 6189.

                    
                    end.
                end.                
        
                
                
                if codigo-livros = 4573
                then codigo-livros = 3495.
                
                if codigo-livros = 1252
                then codigo-livros = 1230.
                
                
        
       /* 01 */ put unformatted nu  at 1                 ",".
    
       /* 02 */ put unformatted codigo-livros         ",".

       /* 03 */ put trim(string(year(fiscal.plaemi),"9999") +
                         string(month(fiscal.plaemi),"99")  +
                         string(day(fiscal.plaemi),"99"))        ",".

       /* 04 */ put trim(string(year(fiscal.plarec),"9999") +
                         string(month(fiscal.plarec),"99")  +
                         string(day(fiscal.plarec),"99"))        ",".

       /* 05 */ put unformatted fiscal.numero ",".
    
       /* 06 */ put unformatted chr(34) "MOD.1" chr(34) ",".
        
       /* 07 */ put unformatted chr(34) "NFF" chr(34) ",".
        
       /* 08 */ put unformatted fiscal.platot  format ">>>>>9.99"   ",".
        
       /* 09 */ put unformatted chr(34) "0" chr(34) ",".
        
       /* 10 */ put unformatted chr(34)  
                  substring(string(fiscal.opfcod),1,1) + "." + 
                  substring(string(fiscal.opfcod),2,3) + chr(34) ",".

       /* 11 */ put unformatted fiscal.bicms  format ">>>>>9.99"  ",".
       /* 12 */ put unformatted "0.00"                            ",".
       /* 13 */ put unformatted fiscal.outras format ">>>>>9.99"      ",".
       /* 14 */ put unformatted fiscal.alicms format "99.99"  ",".
       /* 15 */ put unformatted fiscal.icms  format ">>>>9.99"    ",".
       /* 16 */ put unformatted "0.00"                            ",".
       /* 17 */ put unformatted "0.00"                            ",".
       /* 18 */ put unformatted "0.00"                            ",". 
       /* 19 */ put unformatted "0.00"                            ",".
       /* 20 */ put unformatted fiscal.ipi    format ">>>>9.99"   ",".
       /* 21 */ put unformatted "0.00"                            ",".
       /* 22 */ put unformatted "0.00"                            ",". 
       /* 23 */ put unformatted "0"                               ",".
       /* 24 */ put unformatted chr(34)  chr(34)                  ",".
       /* 25 */ put unformatted "0"                               ",".
       /* 26 */ put unformatted "0"                               ",".
       /* 27 */ put unformatted chr(34) "P" chr(34)               ",".
       /* 28 */ put unformatted "0"                               ",".
       /* 29 */ put unformatted "0"                               ",".
       /* 30 */ put unformatted "55"                              ",".
       /* 31 */ put unformatted "0"                               ",".
       /* 32 */ put unformatted vemp                              ",".
       /* 33 */ put unformatted "0.00"                            ",".
       /* 34 */ put unformatted "0.00"                            ",".
       /* 35 */ put unformatted "0.00"                            ",".
       /* 36*/  put unformatted chr(34) chr(34)                   ",".
       /* 37*/  put unformatted "J"                               ",".
       /* 38 */ put unformatted vcgc                              skip.

            end.
        end.
    end.
     
    do vdt = vdti - 30 to vdtf + 30:
    
        for each plani where plani.movtdc = 6       and
                             plani.desti  = estab.etbcod and
                             plani.pladat = vdt no-lock:
        
            ii = 0.
            vcgc = "".
            do ii = 1 to 20:

                find bestab where bestab.etbcod = plani.emite no-lock.

                if substring(bestab.etbcgc,ii,1) = "." or
                   substring(bestab.etbcgc,ii,1) = "-" or
                   substring(bestab.etbcgc,ii,1) = "/"
                then.
                else vcgc = vcgc + substring(bestab.etbcgc,ii,1).
        
            end.
            
            
            if plani.datexp >= vdti and
               plani.datexp <= vdtf
            then.
            else next.


            outras-icms = 0.

            if plani.ipi > 0
            then do:
                if (plani.platot - plani.bicms) > plani.ipi
                then outras-icms = plani.platot - plani.bicms - plani.ipi.
            end.
            else outras-icms = plani.platot - plani.bicms.

            nu = nu + 1.

            codigo-emite = plani.emite.
            
            if codigo-emite = 98
            then codigo-emite = 995.

   /* 01 */ put unformatted nu  at 1       ",".
   /* 02 */ put unformatted codigo-emite   ",".

   /* 03 */ put trim(string(year(plani.datexp),"9999") +
                     string(month(plani.datexp),"99")  +
                     string(day(plani.datexp),"99"))        ",".

   /* 04 */ put trim(string(year(plani.datexp),"9999") +
                     string(month(plani.datexp),"99")  +
                     string(day(plani.datexp),"99"))        ",".

   /* 05 */ put unformatted plani.numero    ",".
   /* 06 */ put unformatted chr(34) "MOD.1" chr(34)      ",".
   
   /* 07 */ put unformatted chr(34) "NFF"  chr(34) ",".
   /* 08 */ put unformatted plani.platot  format ">>>>>9.99" ",".

   /* 09 */ put unformatted  chr(34) "0"     chr(34) ",".
   /* 10 */ put unformatted  chr(34) "1.152" chr(34) ",".

   /* 11 */ put "0.00"                                ",".
   /* 12 */ put unformatted "0.00"                    ",".
   /* 13 */ put unformatted outras-icms format "->>>>9.99"      ",".
   /* 14 */ put unformatted "00.00" ",".
   /* 15 */ put unformatted "0.00"   ",".
   /* 16 */ put unformatted "0.00"                            ",".
   /* 17 */ put unformatted "0.00"                            ",".
   /* 18 */ put unformatted "0.00"                            ",". 
   /* 19 */ put unformatted "0.00"                            ",".
   /* 20 */ put unformatted plani.ipi   format ">>>>>9.99"    ",".
   /* 21 */ put unformatted "0.00"                            ",".
   /* 22 */ put unformatted "0.00"                            ",". 
   /* 23 */ put unformatted "0"                               ",".
   /* 24 */ put unformatted chr(34)  chr(34)                  ",".
   /* 25 */ put unformatted "0"                               ",".
   /* 26 */ put unformatted "0"                               ",".
   /* 27 */ put unformatted chr(34) "P" chr(34)               ",".
   /* 28 */ put unformatted "0"                               ",".
   /* 29 */ put unformatted "0"                               ",".
   /* 30 */ put unformatted "55"                              ",".
   /* 31 */ put unformatted "0"                               ",".
   /* 32 */ put unformatted vemp                              ",".
   /* 33 */ put unformatted "0.00"                            ",".
   /* 34 */ put unformatted "0.00"                            ",".
   /* 35 */ put unformatted "0.00"                            ",".
   /* 36*/  put unformatted chr(34) chr(34)                   ",".
   /* 37*/  put unformatted "J"                               ",".
   /* 38 */ put unformatted vcgc                              skip.

        end.
    
    end.
end.

output close.
