{admcab.i}

def var vnome as char format "x(30)".
def var vqtd  as dec.
def var vesp  as char.
def var vfre  as int format "9" initial 1.
def var vuf   as char format "x(02)" initial "RS".
DEF VAR vtot as int.
DEF VAR vcont as int.
DEF VAR vpag as int extent 50.
def var vnota as int.
def temp-table wmovim
    field placod like plani.placod
    field etbcod like plani.etbcod
    field pronom like produ.pronom
    field procod like produ.procod.

def input parameter  par-rec as recid.

DEF VAR vlinha      AS INT FORMAT "99" INITIAL 0.
DEF VAR vimp_cab    AS LOG INITIAL YES.
def var i as i.
def var vsub-total  like plani.platot no-undo.
def var recatu2             as recid.
def var vserviss            as dec format "zz,z99.99".
def var vrespfre            as int format "9".
def var vtitnum             as char extent 4 initial 0.
def var vtitpar             as int format "99" extent 4 initial 0.
def var vtitdtven           like plani.pladat extent 4.
def var vtitvlcob           like plani.platot extent 4 initial 0.
def var vplaca              as char label "Placa".
def var c                   as int.
def buffer bplani for plani.
def buffer bestab for estab.

find plani where recid(plani) = par-rec no-lock.
find estab where estab.etbcod = plani.desti no-lock no-error.
find bestab where bestab.etbcod = plani.etbcod no-lock no-error.

ASSIGN vlinha   = 0
  vimp_cab = YES.

for each wmovim.
    delete wmovim.
end.


create wmovim.
assign wmovim.pronom = "ACRESCIMO S/ VENDA REF. AO MES " +
                       string(month(plani.pladat),"99").


output to printer page-size 66.
put unformatted chr(27) + "M" + chr(15).


if int(vcont / 24) <> (vcont / 24)
then vtot = truncate((vcont / 24),0) + 1.
else vtot = (vcont / 24).


    put unformatted
        plani.numero    at 145 skip(8)
        "X"             at 101
        plani.numero    at 145 skip(1)
        bestab.endereco at 50 skip
        bestab.munic    at 50 space(2)
        bestab.ufecod
        bestab.etbcgc   at 102 skip
        "VENDA"         at 2
        "512"           at 59
        bestab.etbinsc  at 102 skip(1)
        estab.etbnom    at 2
        estab.etbcgc    at 108
        plani.pladat    at 145 skip(1)
        estab.endereco  at 2  skip
        estab.munic     at 2
        estab.etbtofne  at 75
        estab.ufecod    at 94
        estab.etbinsc   at 108
        /* string(time,"hh:mm") format "x(5)" at 145 */ skip(2).

  for each wmovim:
     put unformatted
         ""     at 4
         wmovim.pronom at 20
         plani.platot  to 145 format ">,>>>,>>9.99" skip.

        PUT SKIP(24).
        put unformatted skip(2)
            plani.platot    at 20  format ">,>>>,>>9.99"
            plani.icms      at 45  format ">>,>>9.99"
            ""         at 85 
            ""         at 115 
            ""         at 140  skip
            ""         at 20 
            ""         at 50 
            ""         at 115 
            plani.platot        at 140 format ">,>>>,>>9.99" skip(1)
            skip(2)
            SKIP(1).

  end.
output close.
