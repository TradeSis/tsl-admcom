{admcab.i}
def input parameter vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def input parameter vnumi    as int.
def input parameter vnumf    as int.
def stream sarq.
def var vemp like estab.etbcod.

find estab where estab.etbcod = vetbcod no-lock.


vemp = estab.etbcod.
if estab.etbcod = 1
then vemp = 50.
if estab.etbcod = 996
then vemp = 54.
if estab.etbcod = 997
then vemp = 51.
if estab.etbcod = 998
then vemp = 53.
if estab.etbcod = 999
then vemp = 52.

def temp-table wnota
    field desti    like placon.desti
    field sequen    as   int    format ">>>9"
    field serie     like placon.serie
    field data      like placon.pladat
    field numini    like placon.numero
    field numfin    like placon.numero
    field valor     like placon.platot
    field movtdc    like placon.movtdc.
def var vtot like wnota.valor.
def var vtotcre like wnota.valor.
def var d-dtini     as   date init today                            no-undo.
def var i-nota      like placon.numero                               no-undo.
def var i-seq       as   int format ">>>9"                          no-undo.


output stream sarq to value("m:\livros\saida" + 
                             string(estab.etbcod,">>9") + ".txt") append.

    for each placon where placon.etbcod = estab.etbcod and
                          placon.emite  = estab.etbcod and
                          placon.movtdc = 06           and
                          placon.serie  = "U"          and
                          placon.numero >= vnumi       and
                          placon.numero <= vnumf no-lock:
         
          
        if  placon.numero <> i-nota + 1 then
        assign i-seq = i-seq + 1.

        find first wnota where wnota.desti = placon.desti and
                               wnota.sequen = i-seq no-lock no-error.
        if  not avail wnota
        then do:
            create wnota.
            assign wnota.desti  = placon.desti
                   wnota.sequen = i-seq
                   wnota.data   = placon.pladat
                   wnota.serie  = placon.serie
                   wnota.numini = placon.numero
                   wnota.movtdc = placon.movtdc.
        end.
        assign wnota.valor  = wnota.valor + (if placon.outras > 0
                                             then placon.outras
                                             else placon.platot)
               wnota.numfin = placon.numero
               i-nota       = placon.numero.

    end.
    
    for each wnota by wnota.data:

        if wnota.movtdc = 6
        then do:
            vemp = wnota.desti.
            
            
            if wnota.desti = 1
            then vemp = 50.
            if wnota.desti = 996
            then vemp = 54.
            if wnota.desti = 997
            then vemp = 51.
            
            if wnota.desti = 998 or
               wnota.desti = 995
            then vemp = 122.
            
            if wnota.desti = 999
            then vemp = 52.
        end.
        else do:
            find forne where forne.forcod = wnota.desti no-lock no-error.
        end.

        put stream sarq unformatted
            nu  at 1                                    ",".
        put stream sarq  unformatted
            vemp ",".
        put stream sarq
        /*d*/       trim(string(year(data),"9999") +
                         string(month(data),"99")  +
                         string(day(data),"99"))        ",".
        put stream sarq  unformatted
        /*c*/       chr(34) string(wnota.numini)
                    chr(34) ",".
        put stream sarq  unformatted
        /*c*/       chr(34) string(wnota.numfin)
                    chr(34) ",".
        put stream sarq unformatted
        /*c*/      chr(34) wnota.serie
            chr(34) ",".
        put stream sarq unformatted
        /*c*/       chr(34)
                    "NF"
                    chr(34) ",".
        put stream sarq
        /*n*/       wnota.valor  format ">>>>9.99"      ",".
        put stream sarq unformatted
        /*c*/       chr(34)
                    "  "
                    chr(34) ",".
        
        if wnota.movtdc = 16 or
           wnota.movtdc = 13
        then do:
            put stream sarq unformatted
            /*c*/       chr(34)
            if forne.ufecod = "RS"
            then "5.99"
            else "6.99" chr(34) ",".
        end.
        else do:
            put stream sarq unformatted
            /*c*/       chr(34)
                        "5.22"
                        chr(34) ",".
        end.
        
        
        put stream sarq
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      wnota.valor  format ">>>>9.99"     ",".
        put stream sarq unformatted
        /*n*/      "00.00"                            ",".
        put stream sarq
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*c*/       chr(34)
                    " " /*  NFS canceladas */
                    chr(34) ",".
        put stream sarq unformatted
        /*n*/      0                                             ",".
        put stream sarq unformatted
        /*c*/       chr(34)
                    " "
                    chr(34) ",".
        put stream sarq unformatted
        /*c*/       chr(34) " "
                    chr(34).

            nu = nu + 1.
    end.
    for each wnota:
        delete wnota.
    end.
output stream sarq close.
