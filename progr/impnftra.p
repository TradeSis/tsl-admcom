{admcab.i}
def temp-table wmovim
    field placod like plani.placod
    field etbcod like plani.etbcod
    field pronom like produ.pronom
    field procod like produ.procod.

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
find estab where estab.etbcod = plani.desti no-lock no-error.
find bestab where bestab.etbcod = plani.etbcod no-lock no-error.

find tofis where tofis.tofcod = 522 no-lock no-error.

ASSIGN vlinha   = 0
  vimp_cab = YES.

for each wmovim.
    delete wmovim.
end.

FOR EACH movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod no-lock:
    find produ where produ.procod = movim.procod no-lock no-error.

    create wmovim.
    assign wmovim.etbcod = plani.etbcod
           wmovim.placod = plani.placod
           wmovim.pronom = produ.pronom
           wmovim.procod = movim.procod.
end.


for each wmovim break by wmovim.pronom:
    find movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.procod = wmovim.procod no-lock.
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
        estab.etbnom    at 2
        estab.etbcgc    at 108
        plani.pladat    at 145 skip(1)
        estab.endereco  at 2
        /*clifor.cep      at 123*/
        /* plani.pladat    at 145 */ skip
        estab.munic     at 2
        estab.etbtofne  at 75
        estab.ufecod    at 94
        estab.etbinsc   at 108
        /* string(time,"hh:mm") format "x(5)" at 145 */ skip(2).
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

  IF ( vlinha = 25 ) AND ( NOT LAST( wmovim.pronom ) )
  THEN DO:

    put unformatted skip(6)
        "PROPRIO"           at 2
        "1"                 at 102
        vplaca              at 106.

    page.

  END.

  IF LAST( wmovim.pronom )
    THEN
  DO:
    IF vlinha <> 25
    THEN PUT SKIP( 25 - vlinha).
    put unformatted skip(3)
        plani.bicms         at 20 format "zz,zz9.99"
        "DIFERIDO" /* plani.icms */         at 45 /* format "zz,zz9.99" */
        plani.bsubst        at 85 format "zz,zz9.99"
        plani.icmssubst     at 115 format "zz,zz9.99"
        plani.protot        at 140 format "zz,zz9.99" skip
        plani.frete         at 20 format "zz,zz9.99"
        plani.seguro        at 50 format "zz,zz9.99"
        plani.ipi           at 115 format "zz,zz9.99"
        plani.platot        at 140 format "zz,zz9.99" skip(1)
        "PROPRIO"           at 2
        "1"                 at 102
        vplaca              at 106 SKIP(5)
        "ICMS DIFERIDO CFE. PREVISAO LEGAL LIVRO I," AT 4
        "ART. 53, INC. 1 DO DECRETO N. 37.699/97" AT 4.
    page.
  END.
END.
output close.
