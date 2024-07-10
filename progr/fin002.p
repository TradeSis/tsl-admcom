/***************************************************************************
** Programa        : fin002.p
** Objetivo        : Contador de carnes a ser impressos
** Ultima Alteracao:
**
****************************************************************************/
{admcab.i}

def var i-nrotit    as int  init 0                              no-undo.


for each titulo where
	 titulo.empcod = 19     and
	 titulo.titnat = no     and
	 titulo.modcod = "CRE"  and
	 titulo.titsit = "IMP"  no-lock
	 use-index titsit:
    assign i-nrotit = i-nrotit + 1.
    disp i-nrotit label "Titulos a Imprimir:"
	 with side-label frame f1.
    pause 0.
end.
bell. bell.
disp i-nrotit label "Titulos a Imprimir:"
     with side-label frame f2.
pause.
