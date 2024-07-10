{admcab.i}

def var vprocod like produ.procod.
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat. 
def var vativo  as log.

    
def var outras-icms as dec.       

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

    
    



def var vdata as date format "99/99/9999".
def var vise like plani.platot.
def input parameter vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     as date format "99/99/9999".

def input parameter vdti    like plani.pladat.
def input parameter vdtf    like plani.pladat.

def stream sarq.

find estab where estab.etbcod = vetbcod no-lock.

vlannum = 1.

def temp-table wnota
    field crecod    like plani.crecod
    field sequen    as   int    format ">>>9"
    field serie     like plani.serie
    field numini    like plani.numero
    field numfin    like plani.numero
    field valor     like plani.platot.

def var vtot like wnota.valor.
def var vtotcre like wnota.valor.
def var d-dtini     as   date init today                            no-undo.
def var i-nota      like plani.numero                               no-undo.
def var i-seq       as   int format ">>>9"                          no-undo.



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
         

  

for each tt-icms where tt-icms.dtini <= vdti and
                       tt-icms.dtfin >= vdtf:
    for each movim where movim.etbcod = estab.etbcod and
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
 




output stream sarq to value("l:\livros\saida" + 
                             string(estab.etbcod,">>9") + ".txt").                              
/************************  I C M S  17  *****************************/

do vdata = vdti to vdtf:
for each serial where serial.etbcod = estab.etbcod and
                      serial.serdat = vdata        and
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
                  
    
    
    
    put stream sarq unformatted 
        vlannum  at 1 ",".    /* 1 */

    put stream sarq  unformatted             /* 2 */
        serial.etbcod ",". 
    
    put stream sarq
        trim(string(year(serial.serdat),"9999") +
             string(month(serial.serdat),"99")  +
             string(day(serial.serdat),"99"))     ",".  /* 3 */
    
        put stream sarq  unformatted                   /* 4 */
        /*c*/       chr(34) "Z" string(serial.redcod)
                    chr(34) ",".
        put stream sarq  unformatted                  /* 5 */
        /*c*/       chr(34) "Z" string(serial.redcod)
                    chr(34) ",".

    put stream sarq unformatted                    /* 6 */
        chr(34) "ECF"
        chr(34) ",".

    put stream sarq unformatted                   /* 7 */
        chr(34)
        "CF"
        chr(34) ",".

    put stream sarq
        serial.icm17 format ">>>>9.99"      ",".    /* 8 */
    
    put stream sarq unformatted                     /* 9 */
        chr(34) ""
        chr(34) ",".
    
    put stream sarq unformatted                     /* 10 */
        chr(34) "5.102"
        chr(34) ",".

    put stream sarq                                /* 11 */
        ((serial.icm17 - val07) + (val07 * 0.41177))
         format ">>>>9.99"  ",".

    put stream sarq                    /* 12 */
        0 ",".  
            
    put stream sarq unformatted                    /* 13 */
       /*n*/  outras-icms  format ">>>>>9.99"     ",".

        
    put stream sarq unformatted                    /* 14 */
        "17.00"  ",".
    
    put stream sarq                                /* 15 */
        ( ((serial.icm17 - val07) * 0.17) 
           + (val07 * 0.07) ) format ">>>>9.99"    ",".
    
    put stream sarq unformatted                    /* 16 */
        0       ",".
    
    put stream sarq unformatted                    /* 17 */
        0       ",".
    
    put stream sarq unformatted                    /* 18 */
        0       ",".
    
    put stream sarq unformatted                    /* 19 */
        0       ",".
    
    put stream sarq unformatted                    /* 20 */
        0       ",".
    
    put stream sarq unformatted                   /* 21 */
        0       ",".
    
    put stream sarq unformatted                   /* 22 */
        0       ",".
    
    put stream sarq unformatted                   /* 23 */
        0       ",".

    put stream sarq unformatted                   /* 24 */
       chr(34)  " " 
       chr(34)  ",".
    
    put stream sarq unformatted                   /* 25 */
       0        ",".
    
    put stream sarq unformatted                   /* 26 */
       chr(34)
       " "
       chr(34) ",".
    
    put stream sarq unformatted                    /* 27 */
       chr(34) "P"
       chr(34) ",".
    
    put stream sarq unformatted                    /* 28 */
       chr(34) 99 
       chr(34) ",".

    put stream sarq unformatted                    /* 29 */
       chr(34) "N"
       chr(34) ",".

    put stream sarq unformatted                    /* 30 */
       chr(34) serial.cxacod format ">>>9"
       chr(34) ",".

    put stream sarq unformatted                    /* 31 */
       chr(34) serial.cxacod format ">>>>>9"
       chr(34) ",".

    put stream sarq unformatted                    /* 32 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 33 */
       chr(34) 0  
       chr(34) ",".

    put stream sarq unformatted                    /* 34 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 35 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 36 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 37 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 38 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 39 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 40 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 41 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 42 */
       chr(34) "N"
       chr(34).
    vlannum = vlannum + 1.
end.


/***********************   I C M S  12  ********************************/

for each serial where serial.etbcod = estab.etbcod and
                      serial.serdat = vdata        and
                      serial.icm12 > 0 no-lock:
    
    put stream sarq unformatted 
        vlannum  at 1 ",".    /* 1 */

    put stream sarq  unformatted             /* 2 */
        serial.etbcod ",". 
    
    put stream sarq
        trim(string(year(serial.serdat),"9999") +
             string(month(serial.serdat),"99")  +
             string(day(serial.serdat),"99"))     ",".  /* 3 */
    
        put stream sarq  unformatted                   /* 4 */
        /*c*/       chr(34) "Z" string(serial.redcod)
                    chr(34) ",".
        put stream sarq  unformatted                  /* 5 */
        /*c*/       chr(34) "Z" string(serial.redcod)
                    chr(34) ",".

    put stream sarq unformatted                    /* 6 */
        chr(34) "ECF"
        chr(34) ",".

    put stream sarq unformatted                   /* 7 */
        chr(34)
        "CF"
        chr(34) ",".

    put stream sarq
        serial.icm12  format ">>>>9.99"      ",".   /* 8 */

    
    put stream sarq unformatted                     /* 9 */
        chr(34) ""
        chr(34) ",".
    
    put stream sarq unformatted                     /* 10 */
        chr(34) "5.102"
        chr(34) ",".

    
    put stream sarq                                /* 11 */
        (serial.icm12 * 0.705889)  format ">>>>9.99"  ",".


    vise = serial.icm12 - (serial.icm12 * 0.705889).
    
    put stream sarq                                /* 12 */
        vise format ">>>>9.99"  ",". 
    
    put stream sarq unformatted                    /* 13 */
        0     ",".
    
    put stream sarq unformatted                    /* 14 */
        "17.00"  ",".
    
    put stream sarq                                /* 15 */
        ((serial.icm12 * 0.705889) * 0.17) format ">>>>9.99"    ",".
    
    put stream sarq unformatted                    /* 16 */
        0       ",".
    
    put stream sarq unformatted                    /* 17 */
        0       ",".
    
    put stream sarq unformatted                    /* 18 */
        0       ",".
    
    put stream sarq unformatted                    /* 19 */
        0       ",".
    
    put stream sarq unformatted                    /* 20 */
        0       ",".
    
    put stream sarq unformatted                   /* 21 */
        0       ",".
    
    put stream sarq unformatted                   /* 22 */
        0       ",".
    
    put stream sarq unformatted                   /* 23 */
        0       ",".

    put stream sarq unformatted                   /* 24 */
       chr(34)  " " 
       chr(34)  ",".
    
    put stream sarq unformatted                   /* 25 */
       0        ",".
    
    put stream sarq unformatted                   /* 26 */
       chr(34)
       " "
       chr(34) ",".
    
    put stream sarq unformatted                    /* 27 */
       chr(34) "P"
       chr(34) ",".
    
    put stream sarq unformatted                    /* 28 */
       chr(34) 99 
       chr(34) ",".

    put stream sarq unformatted                    /* 29 */
       chr(34) "N"
       chr(34) ",".

    put stream sarq unformatted                    /* 30 */
       chr(34) serial.cxacod format ">>>9"
       chr(34) ",".

    put stream sarq unformatted                    /* 31 */
       chr(34) serial.cxacod format ">>>>>9"
       chr(34) ",".


    put stream sarq unformatted                    /* 32 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 33 */
       chr(34) 0  
       chr(34) ",".

    put stream sarq unformatted                    /* 34 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 35 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 36 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 37 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 38 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 39 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 40 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 41 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 42 */
       chr(34) "N"
       chr(34).
    vlannum = vlannum + 1.
end.


/***********  S U B S T I T U I C A O   T R I B U T A R I A  **************


for each serial where serial.etbcod = estab.etbcod and
                      serial.serdat = vdata        and
                      serial.sersub  > 0 no-lock:
    put stream sarq unformatted 
        vlannum  at 1 ",".    /* 1 */

    put stream sarq  unformatted             /* 2 */
        serial.etbcod ",". 
    
    put stream sarq
        trim(string(year(serial.serdat),"9999") +
             string(month(serial.serdat),"99")  +
             string(day(serial.serdat),"99"))     ",".  /* 3 */
    
        put stream sarq  unformatted                   /* 4 */
        /*c*/       chr(34) "Z" string(serial.redcod)
                    chr(34) ",".
        put stream sarq  unformatted                  /* 5 */
        /*c*/       chr(34) "Z" string(serial.redcod)
                    chr(34) ",".

    put stream sarq unformatted                    /* 6 */
        chr(34) "ECF"
        chr(34) ",".

    put stream sarq unformatted                   /* 7 */
        chr(34)
        "CF"
        chr(34) ",".

    put stream sarq
        serial.sersub  format ">>>>9.99"      ",".    /* 8 */
    
    put stream sarq unformatted                     /* 9 */
        chr(34) ""
        chr(34) ",".
    
    put stream sarq unformatted                     /* 10 */
        chr(34) "5.102"
        chr(34) ",".

    put stream sarq                                /* 11 */
        0  format ">>>>9.99" ",".
    
    put stream sarq                    /* 12 */
        0  format ">>>>9.99"  ",". 
    
    put stream sarq unformatted                    /* 13 */
        0 format ">>>>9.99"     ",".
    
    put stream sarq unformatted                    /* 14 */
        "00.00"  ",".
    
    put stream sarq                                /* 15 */
        0 format ">>>>9.99"   ",".
    
    put stream sarq unformatted                    /* 16 */
        0       ",".
    
    put stream sarq unformatted                    /* 17 */
        0       ",".
    
    put stream sarq unformatted                    /* 18 */
        0       ",".
    
    put stream sarq unformatted                    /* 19 */
        0       ",".
    
    put stream sarq unformatted                    /* 20 */
        0       ",".
    
    put stream sarq unformatted                   /* 21 */
        0       ",".
    
    put stream sarq unformatted                   /* 22 */
        0       ",".
    
    put stream sarq unformatted                   /* 23 */
        0       ",".

    put stream sarq unformatted                   /* 24 */
       chr(34)  " " 
       chr(34)  ",".
    
    put stream sarq unformatted                   /* 25 */
       0        ",".
    
    put stream sarq unformatted                   /* 26 */
       chr(34)
       " "
       chr(34) ",".
    
    put stream sarq unformatted                    /* 27 */
       chr(34) "P"
       chr(34) ",".
    
    put stream sarq unformatted                    /* 28 */
       chr(34) 99 
       chr(34) ",".

    put stream sarq unformatted                    /* 29 */
       chr(34) "N"
       chr(34) ",".

    put stream sarq unformatted                    /* 30 */
       chr(34) serial.cxacod format ">>>9"
       chr(34) ",".

    put stream sarq unformatted                    /* 31 */
       chr(34) serial.cxacod format ">>>>>9"
       chr(34) ",".


    
    put stream sarq
        serial.sersub  format ">>>>9.99"      ",".    /* 32 */


    put stream sarq unformatted                    /* 33 */
       chr(34) 0  
       chr(34) ",".

    put stream sarq unformatted                    /* 34 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 35 */
       chr(34) 0
       chr(34) ",".

    put stream sarq
        chr(34) 0
        chr(34) ",".                               /* 36 */
     

    put stream sarq unformatted                    /* 37 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 38 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 39 */
       chr(34) 0
       chr(34) ",".

    put stream sarq unformatted                    /* 40 */
       chr(34) 0
       chr(34) ",".

       
    put stream sarq unformatted                    /* 41 */
       chr(34) 0
       chr(34) ",".

     
    put stream sarq unformatted                    /* 42 */
       chr(34) "S"
       chr(34).
    vlannum = vlannum + 1.
end.
*/
end.

output stream sarq close.
