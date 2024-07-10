{admcab.i}
def var vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     as date format "99/99/9999".
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def stream sarq.
def var vemp like estab.etbcod.
def var valor-icms as dec.
def var alicota-icms as dec.



update vetbcod with frame f1.

find estab where estab.etbcod = vetbcod no-lock.


display estab.etbnom no-label with frame f1.


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


update vdti label "Data Inicial" colon 16
       vdtf label "Data Final" with frame f1 side-label width 80.

def temp-table wnota
    field desti    like plani.desti
    field sequen    as   int    format ">>>9"
    field serie     like plani.serie
    field numini    like plani.numero
    field numfin    like plani.numero
    field valor     like plani.platot
    field movtdc    like plani.movtdc.
def var vtot like wnota.valor.
def var vtotcre like wnota.valor.
def var d-dtini     as   date init today                            no-undo.
def var i-nota      like plani.numero                               no-undo.
def var i-seq       as   int format ">>>9"                          no-undo.
def var outras-icms as dec format "->>>,>>9.99".



output stream sarq to value("m:\livros\saida" + 
                             string(estab.etbcod,">>9") + ".txt").

               /*
put stream sarq skip(1).
               */
do vdt = vdti to vdtf:
    display vdt with 1 down. pause 0.
    for each tipmov where tipmov.movtdc = 14 no-lock,
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
        

   
        nu = nu + 1.
        
        if plani.movtdc = 6
        then do:
            vemp = plani.desti.
            
            
            if plani.desti = 1
            then vemp = 50.
            if plani.desti = 996
            then vemp = 54.
            if plani.desti = 997
            then vemp = 51.
            
            if plani.desti = 998 or
               plani.desti = 995
            then vemp = 122.
            
            if plani.desti = 999
            then vemp = 52.
        end.
        else do:
            find forne where forne.forcod = plani.desti no-lock no-error.
        end.

        put stream sarq unformatted
            nu  at 1                                    ",".
        put stream sarq  unformatted
            vemp ",".
        put stream sarq
        /*d*/       trim(string(year(vdt),"9999") +
                         string(month(vdt),"99")  +
                         string(day(vdt),"99"))        ",".
        put stream sarq  unformatted
        /*c*/       chr(34) string(plani.numero)
                    chr(34) ",".
        put stream sarq  unformatted
        /*c*/       chr(34) string(plani.numero)
                    chr(34) ",".
        put stream sarq unformatted
        /*c*/      chr(34) plani.serie
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
        

        if plani.movtdc = 16 
        then do:
            put stream sarq unformatted
            /*c*/       chr(34)
            if forne.ufecod = "RS"
            then "5.915"
            else "6.949" chr(34) ",".
        end.
        
        if plani.movtdc = 14 
        then do:
            if avail forne
            then do:
                put stream sarq unformatted
                /*c*/       chr(34)
                if forne.ufecod = "RS"
                then "5.901"
                else "6.901" chr(34) ",".
            end.
            else put stream sarq unformatted chr(34) "5.901" chr(34) ",".
                
        end.
        
        
        
        
        if plani.movtdc = 13 
        then do:
            put stream sarq unformatted
            /*c*/       chr(34)
            if forne.ufecod = "RS"
            then "5.202"
            else "6.202" chr(34) ",".
        end.
        

        
        if plani.movtdc = 6
        then do:
            put stream sarq unformatted
            /*c*/       chr(34)
                        "5.152"
                        chr(34) ",".
        end.
        
        
        put stream sarq
        /*n*/    plani.bicms  format ">>>>>9.99"      ",".
        put stream sarq unformatted
        /*n*/      0                                  ",".
        put stream sarq unformatted
        /*n*/      outras-icms  format ">>>>>9.99"     ",".
        put stream sarq unformatted
        alicota-icms  format  "99.99"              ",".
        put stream sarq
        valor-icms    format ">>>>9.99"            ",".
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
        /*c*/       chr(34)
                    " "
                    chr(34) ",".
        put stream sarq unformatted
        /*c*/       chr(34) " "
                    chr(34).

    end.
    
end.
output stream sarq close.
