{admcab.i}

def var recimp as recid.
def var vnumero like plani.numero.
def var vtofcod as char format "x(5)".
def var fila as char.
def var varquivo as char.
def var vicms like movim.movalicms.
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
def var vdata like plani.pladat.
def var vnome as char format "x(30)".
def var vqtd  as dec.
def var vesp  as char.
def var vfre  as int format "9" initial 1.
def var vuf   as char format "x(02)" initial "RS".


def var c                   as int.
def buffer bplani for plani.
def buffer bestab for estab.

/*
if opsys = "unix"
   then do:
   find first impress where impress.codimp = setbcod no-lock no-error.
   if avail impress
      then assign fila = string(impress.dfimp). 
   end.                    
     else assign fila = "". 
*/
 
if opsys = "unix"
then do:
     find first impress where impress.codimp = setbcod no-lock no-error.
     if avail impress
     then do: 
        run acha_imp.p (input recid(impress), output recimp). 
        find impress where recid(impress) = recimp  no-lock no-error.
        assign fila = string(impress.dfimp).
     end. 
end. 
else fila = "".
            
if opsys = "unix"
then varquivo = "/admcom/relat/devfor" + string(time).
else varquivo = "l:\relat\devfor" + string(time).

find plani where recid(plani) = par-rec.
find forne where forne.forcod = plani.desti no-lock no-error.
find bestab where bestab.etbcod = plani.etbcod no-lock no-error.

find tofis where tofis.tofcod = plani.hiccod no-lock no-error.
vtofcod = string(tofis.tofcod).
/*
if forne.ufecod = "rs"
then vtofcod = "5.202".
else vtofcod = "6.202".
*/

vqtd = 0.
for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat no-lock:

    find produ where produ.procod = movim.procod no-lock no-error.
    
    vqtd  = vqtd  + (movim.movqtm * (if produ.procvcom > 0
                                     then produ.procvcom
                                     else 1)).


end.
vfre = 2.
update  vqtd  label "Volumes"        colon 16
        vesp  label "Especie"        colon 16
        vfre  label "Frete por Conta" colon 16
        vplaca                       colon 16
        vuf   label "UF"             colon 16
            with frame f-placa centered side-label color blue/cyan.

vdata = plani.pladat.
update vdata label "Data Impressao" 
        with frame fdata side-label centered.

hide frame fdata no-pause.



output to value(varquivo) page-size 66.
put unformatted chr(27) + "M" + chr(15).

ASSIGN vlinha   = 1
  vimp_cab = YES.

/**
for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat no-lock
                               break by movim.procod:
  IF ( vlinha = 0 ) OR ( vlinha = 25 )
    THEN
  DO:
    ASSIGN vimp_cab = YES
      vlinha   = 1.
  END.
**/
  IF vimp_cab
    THEN
  DO:
    vimp_cab = NO.
    put unformatted
        plani.numero    at 145 skip(8)
        "  X"             at 100
        plani.numero    at 145 skip
        bestab.endereco at 50 
        bestab.munic    at 50 space(2)
        bestab.ufecod
        "   Filial- " 
        bestab.etbcod   
        bestab.etbcgc   at 107 skip(1)
        tofis.tofnom    at 2
        vtofcod    at 59
        bestab.etbinsc  at 107 skip(1)
        .
    if avail forne
    then put forne.fornom    at 2
             forne.forcgc    at 108
             vdata    at 145 skip
             trim(forne.forrua + " " + string(forne.fornum) 
                    + " " + forne.forcomp) format "x(40)" at 2
             forne.forbairro at 90
             forne.forcep    at 125 skip(1)
             forne.formunic  at 2
             forne.forfone  at 75
             forne.ufecod    at 95
             forne.forinest   at 108 skip(2)
             .
    else put bestab.etbnom    at 2
             bestab.etbcgc    at 108
             vdata    at 145 skip
             bestab.endereco at 2 format "x(40)"
             "     " at 90
             "     " at 125 skip(1)
             bestab.munic at 2
             "     " at 75
             bestab.ufecod    at 95
             bestab.etbinsc   at 108 skip(2)
             .
             
    
  END.
  /**
  find produ of movim no-lock.
  vlinha = vlinha + 1.
  put unformatted
      produ.procod    at 4
      produ.pronom    at 20
      produ.prounven  at 93
      movim.movqtm    at 104
      movim.movpc     to 125   format ">>,>>9.99"
      movim.movqtm * movim.movpc  to 145 format "zzz,zz9.99"
      .
  if movim.movalicms > 0
  then put movim.movalicms at 156 format ">9%" .
  put skip.
  
  vicms = movim.movalicms.

  IF ( vlinha = 25 ) AND ( NOT LAST( movim.procod ) )
  THEN DO:

    put unformatted skip(6)
        "PROPRIO"           at 2
        vfre                at 97
        vplaca              at 106
        vuf                 at 120 skip(2)
        vqtd                at 4
        vesp                at 35.
    page.

  END.

  IF LAST( movim.procod )
    THEN
  ***/  
  DO:
    IF vlinha <> 25
    THEN PUT SKIP( 25 - vlinha).
    
    if plani.descprod > 0
    then do:
        put skip.
        put "Desconto: " at 20 
        plani.descprod at 140 format ">>>,>>9.99".
        put skip(1).
    end.
    else put skip(2).
    plani.bicms = 0. 
    put unformatted 
        /*plani.bicms         at 20 format "zzz,zz9.99"*/
        plani.icms          at 45 format "zz,zz9.99"
        /*plani.bsubst        at 85 format "zz,zz9.99"*/
        plani.icmssubst     at 115 format "zz,zz9.99"
        /*plani.protot        at 140 format "zz,zz9.99" skip(1)
        plani.frete         at 20 format "zz,zz9.99"
        plani.seguro        at 50 format "zz,zz9.99"*/
        /* plani.ipi           at 115 format "zz,zz9.99" */
        0.00                at 115
        plani.platot        at 140 format "zz,zz9.99" skip(1)
        "PROPRIO"           at 4
        vfre                at 97
        vplaca              at 106
        vuf                 at 120 skip(2)
        vqtd                at 4
        vesp                at 35 SKIP(5)
        plani.notobs[1] at 4
        plani.notobs[2] at 4
        plani.notobs[3] at 4.
    page.
  END.
/*END.*/
output close.



if opsys = "unix"
then os-command silent lpr value(fila + " " + varquivo).
else os-command silent type value(varquivo) > prn.



