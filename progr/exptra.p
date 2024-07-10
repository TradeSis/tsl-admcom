{admcab.i}


def var valor-contabil like plani.platot.
    
def temp-table tt-icms
    field procod like produ.procod.

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
    

    
    update vetbcod with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.

    display estab.etbnom no-label with frame f1.

    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.

    

    
    output to value("m:\livros\tra" + string(estab.etbcod,">>9") + ".imp").

 
    do vdt = vdti to vdtf:
    for each tipmov where tipmov.movtdc = 6  or 
                          tipmov.movtdc = 13 or
                          tipmov.movtdc = 14 or
                          tipmov.movtdc = 16 no-lock,
        each plani where  plani.etbcod = estab.etbcod and
                          plani.pladat = vdt and
                          plani.movtdc = tipmov.movtdc no-lock:
         
        alicota-icms = 0.
        outras-icms  = 0.
        valor-icms   = 0.
        
        
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
        then vemp = plani.desti.
        else find forne where forne.forcod = plani.desti no-lock no-error.

        if vemp = 98
        then vemp = 95.



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
 /*40*/ put unformatted plani.etbcod                      ",".
 /*41*/ put unformatted "0.00"                            ",".
 /*42*/ put unformatted "0"                               ",".
 /*43*/ put unformatted "0.00"                            ",".
 /*44*/ put unformatted "0.00"                            ",".
 /*45*/ put unformatted "0"                               ",".
 /*46*/ put unformatted "0"                               ",".
 /*47*/ put unformatted "0.00"                            ",".
 /*48*/ put unformatted chr(34) chr(34)                   skip.


    end.
end.
end.




output close.
