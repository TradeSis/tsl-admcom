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
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def stream sarq.
def var vemp like estab.etbcod.
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

update vlannum label "Lancamento" with frame f1.
/*
display "INSIRA O DISQUETE NO DRIVE" WITH FRAME F2 CENTERED ROW 10 .
PAUSE.
HIDE FRAME F2 NO-PAUSE.
*/
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

output stream sarq to value("m:\s" + string(estab.etbcod,">>9") + ".txt").

do vdt = vdti to vdtf:
    display vdt with 1 down. pause 0.
    for each plani where (plani.movtdc = 6            or
                          plani.movtdc = 13           or
                          plani.movtdc = 14           or
                          plani.movtdc = 16)          and
                          plani.etbcod = estab.etbcod and
                          plani.pladat = vdt no-lock:
        if  plani.numero <> i-nota + 1 then
        assign i-seq = i-seq + 1.

        find first wnota where wnota.desti = plani.desti and
                               wnota.sequen = i-seq no-lock no-error.
        if  not avail wnota
        then do:
            create wnota.
            assign wnota.desti  = plani.desti
                   wnota.sequen = i-seq
                   wnota.serie  = plani.serie
                   wnota.numini = plani.numero
                   wnota.movtdc = plani.movtdc.
        end.
        assign wnota.valor  = wnota.valor + (if plani.outras > 0
                                             then plani.outras
                                             else plani.platot)
               wnota.numfin = plani.numero
               i-nota       = plani.numero.

    end.
    
    for each wnota by wnota.serie with frame f2:

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
        /*d*/       trim(string(year(vdt),"9999") +
                         string(month(vdt),"99")  +
                         string(day(vdt),"99"))        ",".
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
        
        
        if wnota.movtdc = 16 
        then do:
            put stream sarq unformatted
            /*c*/       chr(34)
            if forne.ufecod = "RS"
            then "5.915"
            else "6.949" chr(34) ",".
        end.
        

        if wnota.movtdc = 13 
        then do:
            put stream sarq unformatted
            /*c*/       chr(34)
            if forne.ufecod = "RS"
            then "5.202"
            else "6.202" chr(34) ",".
        end.
        

        
        if wnota.movtdc = 6
        then do:
            put stream sarq unformatted
            /*c*/       chr(34)
                        "5.152"
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
end.
output stream sarq close.
