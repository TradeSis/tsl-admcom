{admcab.i}


def var recimp as recid. 
def var fila as char format "x(20)".

def var vfre  as int format "9" initial 1.

def var vtofcod as char format "x(05)".
def input parameter par-rec as recid.

def var varquivo as char.
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


    if opsys = "UNIX"
    then do:
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do:
            run acha_imp.p (input recid(impress), 
                            output recimp).
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp). 
        end.
    end.    
    else fila = "".
 
if opsys = "unix"
then varquivo = "/admcom/relat/cons" + string(time).
else varquivo = "l:\relat\cons" + string(time).

vfre = 2.
update 
      vfre  label "Frete por Conta" 
      vplaca   with frame f-placa centered side-label color blue/cyan.

output to value(varquivo) page-size 66.
put unformatted chr(27) + "M" + chr(15).
/*put control chr(15).*/

find plani where recid(plani) = par-rec no-lock.
find forne where forne.forcod = plani.desti no-lock no-error.
find bestab where bestab.etbcod = plani.etbcod no-lock no-error.

vtofcod = "5915".

if forne.ufecod <> "RS"
then vtofcod = "6915".

find opcom where opcom.opccod = vtofcod no-lock no-error.

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
        "   Filial- " 
        bestab.etbcod 
        bestab.etbcgc   at 102 skip
        opcom.opcnom    at 2
        vtofcod    at 59
        bestab.etbinsc  at 102 skip(1)
        forne.fornom    at 2
        forne.forcgc    at 108
        plani.pladat    at 145 skip(1)
        forne.forrua  at 2
        /*clifor.cep      at 123*/
        /* plani.pladat    at 145 */ skip
        forne.formunic     at 2
        forne.forfone  at 75
        forne.ufecod    at 94
        forne.forinest   at 108
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

  IF ( vlinha = 25 ) AND ( NOT LAST( movim.procod ) )
  THEN DO:

    put unformatted skip(6)
        "PROPRIO"           at 2
         vfre               at 102
        vplaca              at 106.

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
        plani.protot        at 140 format "zzz,zz9.99" skip
        plani.frete         at 20 format "zz,zz9.99"
        plani.seguro        at 50 format "zz,zz9.99"
        plani.ipi           at 115 format "zz,zz9.99"
        plani.platot        at 140 format "zzz,zz9.99" skip(1)
        "PROPRIO"           at 2
        vfre                 at 102
        vplaca              at 106 SKIP(5)
        "ICMS DIF. CFE. LIVRO III, ART. 1, COMBINADO" AT 4
        "COM APENDICE II, SECAO I, ITEM 1, DO REGULAM." AT 4
        "DO ICMS (DECRETO 37.699/97)" AT 4.

    put "EMITENTE DISPENSADO DE EMISSAO DE NOTA FISCAL ELETRONICA " at 4 skip
        "CONFORME HOMOLOGACAO DEFERIDA EM __/__/__"  at 4 skip.

    page.
  END.
END.
output close.

if opsys = "unix"
then os-command silent lpr value(" " + fila + " " + varquivo).
else os-command silent type value(varquivo) > prn.

