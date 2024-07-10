{admcab.i}
def var vtofcod as char format "x(05)".
def input parameter par-rec as recid.

DEF VAR vlinha      AS INT FORMAT "99" INITIAL 0.
DEF VAR vimp_cab    AS LOG INITIAL YES.
def var i as i.
def var vsub-total  like titulo.titvlcob no-undo.
def var recatu2             as recid.
def var vserviss            as dec format "zz,z99.99".
def var vrespfre            as int format "9".
def var vtitnum             like titulo.titnum extent 4 initial 0.
def var vtitpar             like titulo.titpar extent 4 initial 0.
def var vtitdtven           like titulo.titdtven extent 4.
def var vtitvlcob           like titulo.titvlcob extent 4 initial 0.
def var vplaca              as char label "Placa".
def var c                   as int.
def buffer bplani for plani.
def buffer bestab for estab.


update vplaca   with frame f-placa centered side-label color blue/cyan.

output to printer page-size 66.
put unformatted chr(27) + "M" + chr(15).
/*put control chr(15).*/

find plani where recid(plani) = par-rec no-lock.
find clien where clien.clicod = plani.desti no-lock no-error.
find bestab where bestab.etbcod = plani.etbcod no-lock no-error.

find tofis where tofis.tofcod = 532 no-lock no-error.
vtofcod = string(tofis.tofcod).
if today >= 01/01/2003
then vtofcod = "5.202".


ASSIGN vlinha   = 0
  vimp_cab = YES.

FOR EACH movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod no-lock
               BREAK BY movim.procod:
  IF ( vlinha = 0 ) OR ( vlinha = 25 )
    THEN
  DO:
    ASSIGN vimp_cab = YES
      vlinha   = 1.
  END.

  IF vimp_cab
    THEN
  DO:
    vimp_cab = NO.
    put unformatted
        plani.numero    at 145 skip(8)
        "X"             at 119
        plani.numero    at 145 skip(1)
        bestab.endereco at 50 skip
        bestab.munic    at 50 space(2)
        bestab.ufecod
        bestab.etbcgc   at 102 skip
        tofis.tofnom    at 2
        vtofcod         at 59
        bestab.etbinsc  at 102 skip(1)
        clien.clinom    at 2
        clien.ciccgc    at 108
        plani.pladat    at 145 skip(1)
        clien.endereco[1]  at 2
        plani.pladat    at 145 skip
        clien.cidade[1]     at 2
        clien.fone  at 75
        clien.ufecod    at 94
        string(time,"hh:mm") format "x(5)" at 145 skip(2).
  END.

  find produ of movim no-lock.
  vlinha = vlinha + 1.
  put unformatted
      produ.procod    at 4
      produ.pronom    at 20
      produ.prounven  at 92
      movim.movqtm    at 104
      movim.movpc     to 125   format ">>,>>9.99"
      movim.movqtm * movim.movpc  to 145 format "zz,zz9.99"
      movim.movalicms at 153 format ">9%" skip.

  IF ( vlinha = 25 ) AND ( NOT LAST( movim.procod ) )
  THEN DO:

    put unformatted skip(6)
        "PROPRIO"           at 2
        "1"                 at 102.

    page.

  END.

  IF LAST( movim.procod )
    THEN
  DO:
    IF vlinha <> 25
    THEN PUT SKIP( 25 - vlinha).
    put unformatted skip(3)
        plani.bicms         at 20 format "zz,zz9.99"
        plani.icms          at 50 format "zz,zz9.99"
        plani.bsubst        at 85 format "zz,zz9.99"
        plani.icmssubst     at 115 format "zz,zz9.99"
        plani.protot        at 140 format "zz,zz9.99" skip
        plani.frete         at 20 format "zz,zz9.99"
        plani.seguro        at 50 format "zz,zz9.99"
        plani.ipi           at 115 format "zz,zz9.99"
        plani.platot        at 140 format "zz,zz9.99" skip(1)
        "PROPRIO"           at 2
        "1"                 at 102 SKIP(5).
    page.
  END.
END.
output close.
