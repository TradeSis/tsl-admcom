{admcab.i}                      /*********** novo explan5.p **********/
def var xx as int.
def var outras-icms as dec format "->>>,>>9.99".
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


find estab where estab.etbcod = vetbcod no-lock.


def temp-table westab
    field wetbcod like estab.etbcod
    field wetbnom like estab.etbnom
    field wetbcgc like estab.etbcgc.

def temp-table wnota
    field crecod    like placon.crecod
    field sequen    as   int    format ">>>9"
    field serie     like placon.serie
    field data      like placon.pladat
    field numini    like placon.numero
    field numfin    like placon.numero
    field valor     like placon.platot.
def var vtot like wnota.valor.
def var vtotcre like wnota.valor.
def var d-dtini     as   date init today                            no-undo.
def var i-nota      like placon.numero                               no-undo.
def var i-seq       as   int format ">>>9"                          no-undo.
def var vcgc as char format "xx.xxx.xxx/xxxx-xx".
def var vemp as int.
def buffer bestab for estab.

for each westab.
    delete westab.
end.


    
    for each placon where placon.movtdc = 6            and
                          placon.desti  = estab.etbcod and
                          placon.serie  = "U"          and
                          placon.numero >= vnumi       and
                          placon.numero <= vnumf no-lock:
        

        find bestab where bestab.etbcod = placon.emite no-lock no-error.
        if not avail bestab
        then next.
        
        vcgc = bestab.etbcgc.
        vemp = placon.desti.

        if estab.etbcod = 1
        then vemp = 50.
        if estab.etbcod = 996
        then vemp = 54.
        if estab.etbcod = 997
        then vemp = 51.
        if estab.etbcod = 98
        then vemp = 53.
        if estab.etbcod = 999
        then vemp = 52.


        find first lfcad where lfcad.cgc = vcgc and
                               lfcad.empcod = vemp no-error.
        if not avail lfcad or vcgc = ""
        then do:
            find first westab where westab.wetbcod = bestab.etbcod no-error.
            if not avail westab
            then create westab.
            assign westab.wetbcod = bestab.etbcod
                   westab.wetbnom = bestab.etbnom
                   westab.wetbcgc = bestab.etbcgc.
        end.
    end.

find first westab no-error.
if avail westab
then do:
    output to printer.
    for each westab by wetbnom.
        disp westab.
    end.
    output close.
end.
    

find first westab no-error.
if avail westab
then do:
    message "Existem filiais nao cadastradas".
    undo, retry.
end.


output stream sarq to value("m:\livros\entra" + 
                             string(estab.etbcod,">>9") + ".txt") append.



    for each placon where placon.movtdc = 6            and
                          placon.desti  = estab.etbcod and
                          placon.serie  = "u"          and
                          placon.numero >= vnumi       and
                          placon.numero <= vnumf  no-lock:
        
        

        outras-icms = 0.

        vemp = placon.desti.
        find bestab where bestab.etbcod = placon.emite no-lock no-error.
        if not avail bestab
        then next.
        vcgc = string(bestab.etbcgc,"xx.xxx.xxx/xxxx-xx").
        vcgc = bestab.etbcgc.
        if estab.etbcod = 1
        then vemp = 50.
        if estab.etbcod = 996
        then vemp = 54.
        if estab.etbcod = 997
        then vemp = 51.
        if estab.etbcod = 98
        then vemp = 53.
        if estab.etbcod = 999
        then vemp = 52.
        
        find first lfcad where lfcad.cgc = vcgc and
                               lfcad.empcod = vemp no-error.

        if placon.ipi > 0
        then do:
            if (placon.platot - placon.bicms) > placon.ipi
            then outras-icms = placon.platot - placon.bicms - placon.ipi.
        end.
        else outras-icms = placon.platot - placon.bicms.

        nu = nu + 1.
        put stream sarq unformatted
            nu  at 1                                    ",".
        put stream sarq  unformatted
            lfcad.codigo /* vemp */ /* placon.emite */ ",".

        put stream sarq
        /*d*/       trim(string(year(placon.pladat),"9999") +
                         string(month(placon.pladat),"99")  +
                         string(day(placon.pladat),"99"))        ",".

        put stream sarq
        /*d*/       trim(string(year(placon.dtinclu),"9999") +
                         string(month(placon.dtinclu),"99")  +
                         string(day(placon.dtinclu),"99"))        ",".

        put stream sarq  unformatted
        /*c*/       placon.numero ",".
        put stream sarq unformatted
        /*c*/       chr(34) placon.serie
            chr(34) ",".
        put stream sarq unformatted
        /*c*/       chr(34)
                    "NF"
                    chr(34) ",".
        put stream sarq
        /*n*/       placon.platot  format ">>>>9.99"      ",".

        put stream sarq unformatted
        /*c*/       chr(34)
                    "  "
                    chr(34) ",".
        put stream sarq unformatted
        /*c*/       chr(34)
         "1.22" chr(34) ",".

        put stream sarq
        /*n*/      0  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      outras-icms format "->>>>9.99"      ",".
        put stream sarq unformatted
        /*n*/
        "00.00" ",".
        put stream sarq
        /*n*/      0   ",".
        put stream sarq unformatted
        /*n*/      0                                ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      placon.ipi    format ">>>>9.99"    ",".
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
                    0   ",".
        put stream sarq unformatted
        /*c*/       chr(34) " "
                    chr(34).

    end.
    for each wnota:
        delete wnota.
    end.
output stream sarq close.
