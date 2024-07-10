{admcab.i}
    
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vativo  as log.

    
def var vprocod like produ.procod.
def var vfil      like estab.etbcod.
def var tot-valor like plani.platot.
def var tot-base  like plani.platot.
def var tot-icms  like plani.platot.
def buffer bestab for estab.

def temp-table tt-ecf
    field etbcod like estab.etbcod
    field cxacod like caixa.cxacod
    field codecf as int format "99999"
        index ind-1 etbcod
                    cxacod.



def var v-ecf as int format ">>>>>>>>>>>>>99".
def var vcgc as char format "x(14)".
def var ii as int.
def var valor-contabil like plani.platot.
    

def temp-table tt-icms
    field procod like produ.procod
    field dtini  like plani.pladat
    field dtfin  like plani.pladat
    field ativo  as log
        index ind-1 procod.




def temp-table tt-07
    field etbcod like estab.etbcod
    field cxacod like plani.cxacod
    field data   like plani.pladat
    field valor  like plani.platot.
    

def var val07 as dec.

 


def var vise like plani.platot.

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
def var vemp like estab.etbcod.
def var valor-icms as dec.
def var alicota-icms as dec.

repeat:
    
    
    input from ..\progr\tt-ecf.txt.
    repeat:
        create tt-ecf.
        import tt-ecf.
    end.
    input close.

    for each tt-ecf where tt-ecf.etbcod = 0.
        delete tt-ecf.
    end.

    
    for each tt-07. 
        delete tt-07. 
    end.
    
    for each tt-icms:
        delete tt-icms.
    end.
    
    input from ..\progr\icms.txt.
    repeat:
        import vprocod
               vdtini
               vdtfin
               vativo.
        find first tt-icms where tt-icms.procod = vprocod no-error.
        if not avail tt-icms
        then do:
               
        
            create tt-icms.
            assign tt-icms.procod = vprocod
                   tt-icms.dtini  = vdtini
                   tt-icms.dtfin  = vdtfin
                   tt-icms.ativo  = vativo.
                   
                   
            
        end.
        
    end.
    input close.

    for each tt-icms.

        find produ where produ.procod = tt-icms.procod no-lock no-error.
        if not avail produ
        then do:
            delete tt-icms.
            next.
        end.
    
    end.    
     
    
        
    
    assign tot-valor = 0 
           tot-base  = 0 
           tot-icms  = 0.


    
    update vetbcod with frame f1.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
    
        find estab where estab.etbcod = vetbcod no-lock.

        display estab.etbnom no-label with frame f1.
        
    end.
    
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.

    
    for each tt-icms where tt-icms.dtini <= vdti and
                           tt-icms.dtfin >= vdtf:   

        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,
            each movim where movim.etbcod = estab.etbcod and
                             movim.movtdc = 5            and
                             movim.movdat >= vdti        and
                             movim.movdat <= vdtf        and
                             movim.procod = tt-icms.procod no-lock.
                             
            find plani where plani.etbcod = movim.etbcod and
                             plani.placod = movim.placod and
                             plani.movtdc = movim.movtdc and
                             plani.pladat = movim.movdat no-lock no-error.
        
            if not avail plani
            then next.
                
            find first tt-07 where tt-07.etbcod = plani.etbcod and
                                   tt-07.cxacod = plani.cxacod and
                                   tt-07.data   = plani.pladat no-error.
            if not avail tt-07
            then do:
                create tt-07.
                assign tt-07.etbcod = plani.etbcod
                       tt-07.cxacod = plani.cxacod
                       tt-07.data   = plani.pladat.
            end.
            tt-07.valor = tt-07.valor + (movim.movpc * movim.movqtm).
    
        end.
    
    end.        
 

    
    find estab where estab.etbcod = vetbcod no-lock.
    
    
    if vetbcod = 0
    then output to value("m:\livros\sai" + string(00,"99") + ".imp").
    else output to value("m:\livros\sai" + string(estab.etbcod,">>9") + ".imp").


 
    do vdt = vdti to vdtf:
    for each tipmov where tipmov.movtdc = 6  or 
                          tipmov.movtdc = 13 or
                          tipmov.movtdc = 14 or
                          tipmov.movtdc = 16 no-lock,
        each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each plani where  plani.etbcod = estab.etbcod and
                          plani.pladat = vdt and
                          plani.movtdc = tipmov.movtdc no-lock:
         
        alicota-icms = 0.
        outras-icms  = 0.
        valor-icms   = 0.
        
        ii = 0.
        vcgc = "".
        
        if tipmov.movtdc = 06
        then do:

            find bestab where bestab.etbcod = plani.desti no-lock.
        
            do ii = 1 to 20:
                if substring(bestab.etbcgc,ii,1) = "." or
                   substring(bestab.etbcgc,ii,1) = "-" or
                   substring(bestab.etbcgc,ii,1) = "/"
                then.
                else vcgc = vcgc + substring(bestab.etbcgc,ii,1).
        
            end.
        end.
        
        
        find first movim where movim.etbcod = plani.etbcod and
                               movim.placod = plani.placod and
                               movim.movtdc = plani.movtdc and
                               movim.movdat = plani.pladat no-lock no-error.
        if avail movim
        then assign alicota-icms = movim.movalicms
                    valor-icms   = (plani.bicms * (movim.movalicms / 100)).
        else alicota-icms = 0.
                               
        
        if plani.ipi > 0
        then do:
            if (plani.platot - plani.bicms) > plani.ipi
            then outras-icms = plani.platot - plani.bicms - plani.ipi.
        end.
        else if plani.bicms < plani.platot
             then outras-icms = plani.platot - plani.bicms.
        
        vemp = estab.etbcod.
   
        nu = nu + 1.
        
        if plani.movtdc = 6
        then.
        else do:
            
            find forne where forne.forcod = plani.desti no-lock no-error.
            do ii = 1 to 20:

                if substring(forne.forcgc,ii,1) = "." or
                   substring(forne.forcgc,ii,1) = "-" or
                   substring(forne.forcgc,ii,1) = "/"
                then.
                else vcgc = vcgc + substring(forne.forcgc,ii,1).
        
            end.

            

        end.
        
        vemp = plani.desti.
        
        if vemp = 98
        then vemp = 95.

        vfil = vetbcod.
        if vfil = 98
        then vfil = 95.



 /*01*/ put unformatted nu  at 1  ",".
 /*02*/ put unformatted vemp      ",".
 /*03*/ put trim(string(year(vdt),"9999") +
                 string(month(vdt),"99")  +
                 string(day(vdt),"99"))        ",".
                 
 /*04*/ put unformatted  chr(34) string(plani.numero) chr(34) ",".
        
 /*05*/ put unformatted  chr(34) string(plani.numero) chr(34) ",".
        
 /*06*/ put unformatted  chr(34) "MOD.1" chr(34)              ",".
 /*07*/ put unformatted  chr(34) "NFF"   chr(34)                 ",".
 /*08*/ put unformatted  plani.platot  format ">>>>>>9.99"    ",".
 /*09*/ put unformatted  chr(34) "0" chr(34) ",".
        
 /*10*/ if plani.movtdc = 16 
        then do:
            put unformatted chr(34)
                if forne.ufecod = "RS"
                then "5.915"
                else "6.949" chr(34) ",".
        end.

 /*10*/ if plani.movtdc = 14 
        then do:
            put unformatted chr(34)
                if forne.ufecod = "RS"
                then "5.901"
                else "6.901" chr(34) ",".
        end.
 
 /*10*/ if plani.movtdc = 13 
        then do:
            put unformatted chr(34)
                if forne.ufecod = "RS"
                then "5.202"
                else "6.202" chr(34) ",".
        end.
 /*10*/ if plani.movtdc = 6
        then put unformatted chr(34) "5.152" chr(34)         ",".
 /*11*/ put unformatted plani.bicms  format ">>>>>>9.99"     ",".
 /*12*/ put unformatted "0.00"                               ",".
 /*13*/ put unformatted outras-icms  format ">>>>>>9.99"     ",".
 /*14*/ put unformatted alicota-icms format  "99.99"         ",".
 /*15*/ put unformatted valor-icms   format ">>>>>>9.99"     ",".
 /*16*/ put unformatted "0.00"                               ",".
 /*17*/ put unformatted "0.00"                               ",".
 /*18*/ put unformatted "0.00"                               ",".
 /*19*/ put unformatted "00.00"                              ",".
 /*20*/ put unformatted plani.ipi    format ">>>>>>9.99"     ",".
 /*21*/ put unformatted "0.00"                            ",".
 /*22*/ put unformatted "0.00"                            ",". 
 /*23*/ put unformatted "0"                               ",".
 /*24*/ put unformatted chr(34)  chr(34)                  ",".
 /*25*/ put unformatted "0"                               ",".
 /*26*/ put unformatted "0"                               ",".
 /*27*/ put unformatted chr(34) "P" chr(34)               ",".
 /*28*/ put unformatted "0"                               ",".
 /*29*/ put unformatted "0"                               ",".
 /*30*/ put unformatted "0"                               ",".
 /*31*/ put unformatted "0"                               ",".
 /*32*/ put unformatted "0"                               ",".
 /*33*/ put unformatted "0.00"                            ",".
 /*34*/ put unformatted "0.00"                            ",".
 /*35*/ put unformatted "0.00"                            ",".
 /*36*/ put unformatted "0.00"                            ",".
 /*37*/ put unformatted "0"                               ",".
 /*38*/ put unformatted "55"                              ",".
 /*39*/ put unformatted "0"                               ",".
 /*40*/ put unformatted vfil                              ",".
 /*41*/ put unformatted "0.00"                            ",".
 /*42*/ put unformatted "0"                               ",".
 /*43*/ put unformatted "0.00"                            ",".
 /*44*/ put unformatted "0.00"                            ",".
 /*45*/ put unformatted "0"                               ",".
 /*46*/ put unformatted "0"                               ",".
 /*47*/ put unformatted "0.00"                            ",".
 /*48*/ put unformatted "J"                               ",".
 /*49*/ put unformatted vcgc                              ",".
 /*50*/ put unformatted "0.00"                            ",".
 /*51*/ put unformatted "0.00"                            ",".
 /*52*/ put unformatted chr(34) chr(34)                   ",".
 /*53*/ put unformatted "0"                               ",".
 /*54*/ put unformatted chr(34) chr(34)                   skip.


    end.
end.


nu = 0.
do vdt = vdti to vdtf:


    

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each serial where serial.etbcod = estab.etbcod and
                          serial.serdat = vdt          and
                          serial.icm17 > 0 no-lock:

    
        
        find first tt-07 where tt-07.etbcod = serial.etbcod and
                               tt-07.cxacod = serial.cxacod and
                               tt-07.data   = serial.serdat no-error.
        if avail tt-07
        then val07 = tt-07.valor.
        else val07 = 0.
    
        outras-icms = serial.icm17 - 
                      ((serial.icm17 - val07) + (val07 * 0.41177)).
        if outras-icms < 0
        then outras-icms = 0.
                  
        
        nu = nu + 1.
        
        ii = 0.
        vcgc = "00000000000".
        /*
        do ii = 1 to 20:
            if substring(estab.etbcgc,ii,1) = "." or
               substring(estab.etbcgc,ii,1) = "-" or
               substring(estab.etbcgc,ii,1) = "/"
            then.
            else vcgc = vcgc + substring(estab.etbcgc,ii,1).
        
        end.
        */

        v-ecf = 0.
        find first tt-ecf where tt-ecf.etbcod = serial.etbcod and
                                tt-ecf.cxacod = serial.cxacod no-error.
        if avail tt-ecf
        then v-ecf = tt-ecf.codecf.
                                

        assign tot-valor = tot-valor +  (serial.icm17 + serial.sersub)  
               tot-base  = tot-base  + ((serial.icm17 - val07) + 
                                        (val07 * 0.41177))  
               tot-icms  = tot-icms +  ( ((serial.icm17 - val07) * 0.17) 
                                           + (val07 * 0.07) ) .






 /*01*/ put unformatted nu at 1 ",".   

 /*02*/ put unformatted 6341 ",". 
    
 /*03*/ put trim(string(year(serial.serdat),"9999") +
                 string(month(serial.serdat),"99")  +
                 string(day(serial.serdat),"99"))      ",".  
    
                        
 /*04*/ put unformatted  chr(34) string(serial.redcod) chr(34) ",".
        
 /*05*/ put unformatted  chr(34) string(serial.redcod) chr(34) ",".
        
 /*06*/ put unformatted  chr(34) "ECF" chr(34)   ",".
 /*07*/ put unformatted  chr(34) "CF"  chr(34)   ",".

 /*08*/ put unformatted "0.00" /* (serial.icm17 + serial.sersub) 
                        format ">>>>>9.99" */    ",".    
 /*09*/ put unformatted chr(34) "0" chr(34) ",".

    
 /*10*/ put unformatted chr(34) "5.102" chr(34) ",".

 /*11*/ put unformatted  
        ((serial.icm17 - val07) + (val07 * 0.41177)) format ">>>>>9.99"  ",".
 /*12*/ put unformatted "0.00"               ",".
 /*13*/ put unformatted outras-icms  format ">>>>>9.99"  ",".
 /*14*/ put unformatted "17.00"              ",".
 /*15*/ put unformatted  ( ((serial.icm17 - val07) * 0.17) 
                            + (val07 * 0.07) ) format ">>>>>9.99"    ",".
 /*16*/ put unformatted "0.00"                            ",".
 /*17*/ put unformatted "0.00"                            ",".
 /*18*/ put unformatted "0.00"                            ",".
 /*19*/ put unformatted "00.00"                           ",".
 /*20*/ put unformatted "0.00"                            ",".
 /*21*/ put unformatted "0.00"                            ",".
 /*22*/ put unformatted "0.00"                            ",". 
 /*23*/ put unformatted "0"                               ",".
 /*24*/ put unformatted chr(34)  chr(34)                  ",".
 /*25*/ put unformatted "0"                               ",".
 /*26*/ put unformatted "0"                               ",".
 /*27*/ put unformatted chr(34) "V" chr(34)               ",".
 /*28*/ put unformatted "0"                               ",".
 /*29*/ put unformatted "0"                               ",".
 /*30*/ put unformatted chr(34) v-ecf  
                        format "999999999999999" chr(34) ",".
 /*31*/ put unformatted chr(34) serial.cxacod format "99" chr(34) ",".
 /*32*/ put unformatted chr(34) string(serial.redcod) chr(34) ",".
 /*33*/ put unformatted /* serial.serval */ 
             (serial.icm17 + serial.sersub) format ">>>>>9.99"  ",".
 /*34*/ put unformatted "0.00"                            ",".
 /*35*/ put unformatted "0.00"                            ",".
 /*36*/ put unformatted serial.sersub format ">>>>>9.99"  ",".
 /*37*/ put unformatted "0"                               ",".
 /*38*/ put unformatted "55"                              ",".
 /*39*/ put unformatted "0"                               ",".
 /*40*/ put unformatted serial.etbcod                     ",". 
 /*41*/ put unformatted "0.00"                            ",".
 /*42*/ put unformatted "0"                               ",".
 /*43*/ put unformatted "0.00"                            ",".
 /*44*/ put unformatted "0.00"                            ",".
 /*45*/ put unformatted "0.00"                            ",".
 /*46*/ put unformatted "0.00"                            ",".
 /*47*/ put unformatted "0.00"                            ",".
 /*48*/ put unformatted "F"                               ",".
 /*49*/ put unformatted vcgc                              ",".
 /*50*/ put unformatted "0.00"                            ",".
 /*51*/ put unformatted "0.00"                            ",".
 /*52*/ put unformatted chr(34) chr(34)                   ",".
 /*53*/ put unformatted "0"                               ",".
 /*54*/ put unformatted chr(34) chr(34)                   skip.

 
    end.
    
end.

nu = 0.
do vdt = vdti to vdtf:


    

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each serial where serial.etbcod = estab.etbcod and
                          serial.serdat = vdt          and
                          serial.icm12 > 0 no-lock:

        vise = serial.icm12 - (serial.icm12 * 0.705889).
    
        nu = nu + 1.
        
        ii = 0.
        vcgc = "00000000000".
        /*
        do ii = 1 to 20:
            if substring(estab.etbcgc,ii,1) = "." or
               substring(estab.etbcgc,ii,1) = "-" or
               substring(estab.etbcgc,ii,1) = "/"
            then.
            else vcgc = vcgc + substring(estab.etbcgc,ii,1).
        
        end.
        */
        
        v-ecf = 0.
        find first tt-ecf where tt-ecf.etbcod = serial.etbcod and
                                tt-ecf.cxacod = serial.cxacod no-error.
        if avail tt-ecf
        then v-ecf = tt-ecf.codecf.
        
        assign tot-valor = tot-valor + serial.serval 
               tot-base  = tot-base  +  (serial.icm12 * 0.705889) 
               tot-icms  = tot-icms + ((serial.icm12 * 0.705889) * 0.17).  




 
         
         

  
 /*01*/ put unformatted nu at 1 ",".   

 /*02*/ put unformatted 6341 ",". 
    
 /*03*/ put trim(string(year(serial.serdat),"9999") +
                 string(month(serial.serdat),"99")  +
                 string(day(serial.serdat),"99"))      ",".  
    
                        
 /*04*/ put unformatted  chr(34) string(serial.redcod) chr(34) ",".
        
 /*05*/ put unformatted  chr(34) string(serial.redcod) chr(34) ",".
        
 /*06*/ put unformatted  chr(34) "ECF" chr(34)   ",".
 /*07*/ put unformatted  chr(34) "CF"  chr(34)   ",".

 /*08*/ put unformatted serial.icm12  format ">>>>>9.99"     ",".    
 /*09*/ put unformatted chr(34) "0" chr(34) ",".

    
 /*10*/ put unformatted chr(34) "5.102" chr(34) ",".

 /*11*/ put unformatted (serial.icm12 * 0.705889) format ">>>>>9.99"  ",".
 
 /*12*/ put unformatted vise  format ">>>>>9.99"       ",".
 /*13*/ put unformatted "0.00"                         ",".
 /*14*/ put unformatted "17.00"                        ",".
 /*15*/ put unformatted ((serial.icm12 * 0.705889) * 0.17)  
                                    format ">>>>>9.99"    ",".
 /*16*/ put unformatted "0.00"                            ",".
 /*17*/ put unformatted "0.00"                            ",".
 /*18*/ put unformatted "0.00"                            ",".
 /*19*/ put unformatted "00.00"                           ",".
 /*20*/ put unformatted "0.00"                            ",".
 /*21*/ put unformatted "0.00"                            ",".
 /*22*/ put unformatted "0.00"                            ",". 
 /*23*/ put unformatted "0"                               ",".
 /*24*/ put unformatted chr(34)  chr(34)                  ",".
 /*25*/ put unformatted "0"                               ",".
 /*26*/ put unformatted "0"                               ",".
 /*27*/ put unformatted chr(34) "V" chr(34)               ",".
 /*28*/ put unformatted "0"                               ",".
 /*29*/ put unformatted "0"                               ",".
 /*30*/ put unformatted chr(34) v-ecf format "999999999999999" chr(34) ",".
 /*31*/ put unformatted chr(34) serial.cxacod format "99" chr(34) ",".
 /*32*/ put unformatted chr(34) string(serial.redcod) chr(34) ",".
 /*33*/ put unformatted serial.serval format ">>>>>9.99"  ",".
 /*34*/ put unformatted "0.00"                            ",".
 /*35*/ put unformatted "0.00"                            ",".
 /*36*/ put unformatted serial.sersub format ">>>>>9.99"  ",".
 /*37*/ put unformatted "0"                               ",".
 /*38*/ put unformatted "55"                              ",".
 /*39*/ put unformatted "0"                               ",".
 /*40*/ put unformatted serial.etbcod                     ",". 
 /*41*/ put unformatted "0.00"                            ",".
 /*42*/ put unformatted "0"                               ",".
 /*43*/ put unformatted "0.00"                            ",".
 /*44*/ put unformatted "0.00"                            ",".
 /*45*/ put unformatted "0.00"                            ",".
 /*46*/ put unformatted "0.00"                            ",".
 /*47*/ put unformatted "0.00"                            ",".
 /*48*/ put unformatted "F"                               ",".
 /*49*/ put unformatted vcgc                              ",".
 /*50*/ put unformatted "0.00"                            ",".
 /*51*/ put unformatted "0.00"                            ",".
 /*52*/ put unformatted chr(34) chr(34)                   ",".
 /*53*/ put unformatted "0"                               ",".
 /*54*/ put unformatted chr(34) chr(34)                   skip.

    end.
    
end.
output close.


display tot-valor label "Valor Contabil"
        tot-base  label "Base de Calc"
        tot-icms  label "ICMS"
                    with frame f-tot centered 1 column.
                    
pause.                    




end.





