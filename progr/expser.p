{admcab.i}
def var vdata as date format "99/99/9999".
def var vise like plani.platot.
def var vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     as date format "99/99/9999".
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.
def stream sarq.

update vetbcod with frame f1.
find estab where estab.etbcod = vetbcod no-lock.
display estab.etbnom no-label with frame f1.
update vdti label "Data Inicial" colon 16
       vdtf label "Data Final" with frame f1 side-label width 80.

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


output stream sarq  to m:\livros\lf.txt .
/************************  I C M S  17  *****************************/

do vdata = vdti to vdtf:
for each serial where serial.etbcod = estab.etbcod and
                      serial.serdat = vdata        and
                      serial.icm17 > 0 no-lock:
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
        serial.icm17  format ">>>>9.99"      ",".    /* 8 */
    
    put stream sarq unformatted                     /* 9 */
        chr(34) ""
        chr(34) ",".
    
    put stream sarq unformatted                     /* 10 */
        chr(34) "5.12"
        chr(34) ",".

    put stream sarq                                /* 11 */
        serial.icm17
        format ">>>>9.99"  ",".

    put stream sarq                    /* 12 */
        0 ",".  
            
    put stream sarq unformatted                    /* 13 */
        0     ",".
    
    put stream sarq unformatted                    /* 14 */
        "17.00"  ",".
    
    put stream sarq                                /* 15 */
        (serial.icm17 * 0.17) format ">>>>9.99"    ",".
    
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
        chr(34) "5.12"
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


/***********  S U B S T I T U I C A O   T R I B U T A R I A  ***************/

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
        chr(34) "5.12"
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
end.

output stream sarq close.
