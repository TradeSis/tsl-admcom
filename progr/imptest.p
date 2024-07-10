{admcab.i}
def var vicms like movim.movalicms.
def input parameter par-rec as recid.
def var vqtd as dec.
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

output to "i:\admcom\work9\nftest". /*  printer page-size 66. */
put unformatted chr(27) + "M" + chr(15).
/*put control chr(15).*/

find plani where recid(plani) = par-rec no-lock.
find forne where forne.forcod = plani.desti no-lock no-error.
find bestab where bestab.etbcod = plani.etbcod no-lock no-error.

find tofis where tofis.tofcod = plani.hiccod no-lock no-error.
vqtd = 0.
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
        "X"             at 101
        plani.numero    at 145 skip(1)
        bestab.endereco at 50 skip
        bestab.munic    at 50 space(2)
        bestab.ufecod
        bestab.etbcgc   at 102 skip
        tofis.tofnom    at 2
        tofis.tofcod    at 59
        bestab.etbinsc  at 102 skip(1)
        forne.fornom    at 2
        forne.forcgc    at 108
        plani.pladat    at 145 skip(1)
        forne.forrua  at 2
        "" /* plani.pladat */   at 145 skip
        forne.formunic     at 2
        forne.forfone  at 75
        forne.ufecod    at 94
        forne.forinest   at 108
        "" /* string(time,"hh:mm") format "x(5)" */ at 145 skip(2).
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
      vqtd = vqtd + movim.movqtm.
  vicms = movim.movalicms.
  IF ( vlinha = 25 ) AND ( NOT LAST( movim.procod ) )
  THEN DO:

    put unformatted skip(6)
        "PROPRIO"           at 2
        "1"                 at 102
        vplaca              at 106.
    put unformatted  skip(2)
        vqtd                at 4.
    page.

  END.

  IF LAST( movim.procod )
    THEN
  DO:
    IF vlinha <> 25
    THEN PUT SKIP( 25 - vlinha).
    put unformatted skip(3)
        plani.protot        at 20 format "zz,zz9.99"
       (plani.protot * (vicms / 100))  at 50 format "zz,zz9.99"
        plani.bsubst        at 85 format "zz,zz9.99"
        plani.icmssubst     at 115 format "zz,zz9.99"
        plani.protot        at 140 format "zz,zz9.99" skip
        plani.frete         at 20 format "zz,zz9.99"
        plani.seguro        at 50 format "zz,zz9.99"
        plani.ipi           at 115 format "zz,zz9.99"
        plani.platot        at 140 format "zz,zz9.99" skip(1)
        "PROPRIO"           at 2
        "1"                 at 102
        vplaca              at 106 SKIP(2)
        vqtd                at 4   skip(2)
        "REF: NF. " at 4 plani.notobs[1] format "x(60)" skip
                "  DATA REF. " at 4 plani.dtinclu.
    page.
  END.
END.
output close.
