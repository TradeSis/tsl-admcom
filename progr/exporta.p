/***************************************************************************
** Programa        : expmatb4.p
** Objetivo        : Exportacao de Dados da matriz para Loja
** Ultima Alteracao: 19/09/95
****************************************************************************/
{admcab.i}
def var x as int.
def var v-dtini as date init today                                 no-undo.
def var vd      as date init today                                 no-undo.
def var v-dtfin as date init today                                 no-undo.
def var i-cont   as int  init 0                                     no-undo.
def stream tela.

form
     v-dtini         colon 16 label "Data Inicial"
     v-dtfin         colon 35  label "Final"
     with overlay row 6 column 01 side-labels frame f-selecao centered.

update v-dtini
       v-dtfin
       with frame f-selecao.

    update sresp label "Confirma a Exportacao de Dados ? "
	with frame fresp
	    color messages centered side-labels.

if  not sresp then
    leave.

message "Exportando, Aguarde...".
output stream tela to terminal.

do vd = v-dtini to v-dtfin.
    x = x + 1.
    output to value("..\CPD\tit" + string(x,"999") + ".d").
    i-cont = 0.
    for each titulo where
	     titulo.datexp >= vd  and
	     titulo.datexp <= vd no-lock.
	export titulo.
	assign i-cont = i-cont + 1.
	disp stream tela i-cont label  "Titulo Exportados"
	     titulo.datexp
	     with side-label centered no-box frame ftit.
	pause 0.
    end.
    output close.
    i-cont = 0.
    output to value("..\CPD\cli" + string(x,"999") + ".d").
    for each clien where clien.datexp >= vd and
			 clien.datexp <= vd:
	export clien.
	assign i-cont = i-cont + 1.
	disp stream tela i-cont label  "Clientes Exportados"
	    clien.datexp
	    with side-label centered no-box frame fcli.
	pause 0.
    end.
    output close.
    i-cont = 0.
    output to value("..\CPD\ctr" + string(x,"999") + ".d").
    for each contrato where contrato.datexp >= vd and
			    contrato.datexp <= vd:
	export contrato.
	assign i-cont = i-cont + 1.
	disp stream tela i-cont label  "Contratos Exportados"
	    contrato.datexp
	     with side-label centered frame fcon no-box.
	pause 0.
    end.
    output close.
end.
pause 0.
quit.
