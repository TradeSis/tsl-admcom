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
def var vdt     as date format "99/99/9999".
def input parameter vdti    as date format "99/99/9999".
def input parameter vdtf    as date format "99/99/9999".
def stream sarq.

/*
update vetbcod with frame f1.
*/

find estab where estab.etbcod = vetbcod no-lock.

/*
display estab.etbnom no-label with frame f1.

update vdti label "Data Inicial" colon 16
       vdtf label "Data Final" with frame f1 side-label width 80.

update vlannum label "Lancamento" with frame f1.
*/


def temp-table westab
    field wetbcod like estab.etbcod
    field wetbnom like estab.etbnom
    field wetbcgc like estab.etbcgc.

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
def var vcgc as char format "xx.xxx.xxx/xxxx-xx".
def var vemp as int.
def buffer bestab for estab.

for each westab.
    delete westab.
end.


do vdt = vdti - 30 to vdtf + 30:
    
    for each plani where plani.movtdc = 6            and
                         plani.desti  = estab.etbcod and
                         plani.pladat = vdt no-lock:
        
        if plani.datexp >= vdti and
           plani.datexp <= vdtf
        then.
        else next.

        find bestab where bestab.etbcod = plani.emite no-lock no-error.
        if not avail bestab
        then next.
        
        vcgc = bestab.etbcgc.
        vemp = plani.desti.

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
end.

output to printer.
for each westab by wetbnom.
    disp westab.
end.
output close.

find first westab no-error.
if avail westab
then do:
    message "Existem filiais nao cadastradas".
    undo, retry.
end.


output stream sarq to value("m:\livros\entra" + 
                             string(estab.etbcod,">>9") + ".txt") append.


put stream sarq skip.

 
xx = 0.
do vdt = vdti - 30 to vdtf + 30:
    xx = xx + 1.
    display xx with 1 down. pause 0.

    for each plani where plani.movtdc = 6       and
                         plani.desti  = estab.etbcod and
                         plani.pladat = vdt no-lock:
        
        
        if plani.datexp >= vdti and
           plani.datexp <= vdtf
        then.
        else next.


        outras-icms = 0.

        vemp = plani.desti.
        find bestab where bestab.etbcod = plani.emite no-lock no-error.
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

        if plani.ipi > 0
        then do:
            if (plani.platot - plani.bicms) > plani.ipi
            then outras-icms = plani.platot - plani.bicms - plani.ipi.
        end.
        else outras-icms = plani.platot - plani.bicms.

        nu = nu + 1.

        

        put stream sarq unformatted
            nu  at 1                                    ",".
        put stream sarq  unformatted
            lfcad.codigo /* vemp */ /* plani.emite */ ",".

        put stream sarq
        /*d*/       trim(string(year(plani.pladat),"9999") +
                         string(month(plani.pladat),"99")  +
                         string(day(plani.pladat),"99"))        ",".

        put stream sarq
        /*d*/       trim(string(year(plani.dtinclu),"9999") +
                         string(month(plani.dtinclu),"99")  +
                         string(day(plani.dtinclu),"99"))        ",".

        put stream sarq  unformatted
        /*c*/       plani.numero ",".
        put stream sarq unformatted
        /*c*/       chr(34) plani.serie
            chr(34) ",".
        put stream sarq unformatted
        /*c*/       chr(34)
                    "NF"
                    chr(34) ",".
        put stream sarq
        /*n*/       plani.platot  format ">>>>>9.99"      ",".

        put stream sarq unformatted
        /*c*/       chr(34)
                    "  "
                    chr(34) ",".
        put stream sarq unformatted
        /*c*/       chr(34)
         "1.152" chr(34) ",".

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
        /*n*/      plani.ipi    format ">>>>9.99"    ",".
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
end.
output stream sarq close.
