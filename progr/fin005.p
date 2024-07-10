/***************************************************************************
** Programa        : fin005.p
** Objetivo        : Consulta de Titulos por Filial e por Data
** Ultima Alteracao:
**
****************************************************************************/
{admcab.i}

def var i-nrotit    as int  init 0                              no-undo.
def var da-dtini    as date format "99/99/9999" init today  no-undo.
def var da-dtfin    as date format "99/99/9999" init today  no-undo.
def var i-filial    like titulo.etbcod                          no-undo.
/*
form
     "Filial       :"  i-filial         colon 16 skip
     "Data         :"  da-dtini         colon 16
                       da-dtfin         colon 35 skip
     header "                Inicial      Final " skip
     with overlay row 14 column 01 no-labels frame f-selecao. */

update i-filial colon 16
       da-dtini colon 16    label "Periodo "
       " a "
       da-dtfin          no-label
       with frame f-selecao with centered row 4 side-label
                    color blue/white.

for each titulo where
         titulo.empcod      = 19       and
         titulo.titnat      = no       and
         titulo.modcod      = "CRE"    and
         titulo.titdtven   >= da-dtini and
         titulo.titdtven   <= da-dtfin and
         titulo.etbcod      = i-filial and
         titulo.titsit = "LIB"  no-lock
         use-index titdtven:

    find first contnf where contnf.contnum = integer(titulo.titnum) no-error.

    disp titulo.titnum
         titulo.clifor
         titulo.titdtven
         titulo.titvlcob with frame f1 centered color white/cyan down.

    if avail contnf
    then display contnf.notanum
                 contnf.notaser with frame f1.
end.
pause.
