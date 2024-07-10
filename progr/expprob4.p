/***************************************************************************
** Programa        : Impmatb4.p
** Objetivo        : Importacao de Dados da Loja
** Ultima Alteracao: 01/11/96
** Programador     : Cristiano Borges Brasil
** Chama Programa  : ImpMatLj.p
****************************************************************************/
{admcab.i}

def var vfilial like estoq.etbcod.
def var vprocod like estoq.procod.
def var vdata   as cha.
def var vpreven like estoq.estvenda.
def var vprecus like estoq.estcusto.
def var vprevei like estoq.estpedven.

def var vunidade    as char initial "A:".


def var vclacod as char format "999".

def var vpronom like produ.pronom.
def var vuni like produ.prouncom.
def var vdep as i format "99". /* like produ.catcod. */
def var vproclafis like produ.proclafis.
def var vproipiper like produ.proipiper.
/*
def var vproipival /* like produ.proipival. */
*/
def var vgrupo as int format "99".
def var vsubgrupo as i. /* as int format "9". */
def var vdigito   as int format "9" no-undo.

def stream tela.

output stream tela to terminal.

update sresp label "Confirma Exprotacao de Dados Para Disquete ? "
	with row 19 column 13 color white/red side-labels frame f1.
if  not sresp then quit.

    update vunidade label "Unidade"
	   help "Informe a unidade de Disquete ==>  A:  ou  B: "
	   with frame funidade row 19 column 52 overlay color white/red
			side-label.
    if vunidade = "A:"
    then do:
	dos silent "del  a:\cespro01.txt".
	dos silent "del  a:\cespre01.txt".

	dos silent "copy h:\txt\cespro01.txt a:".
	dos silent "copy h:\txt\cespre01.txt a:".
    end.
    else
	if vunidade = "b:"
	then do:
	    dos silent "del  b:\cespro01.txt".
	    dos silent "del  b:\cespre01.txt".

	    dos silent "copy h:\txt\cespro01.txt b:".
	    dos silent "copy h:\txt\cespre01.txt b:".
	end.
	else do:
	    message "Unidade Invalida". undo.
	end.
