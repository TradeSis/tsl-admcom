/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/invli.p                         Emissao do Inventario       */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 26/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wtotal as de decimals 2 format ">>,>>>,>>>,>>9.99".
def var wlivro as i format "999" label "Livro".
def var wcopias as i format "99".
def var nomemes as character format "x(9)" extent 12
       initial ["Janeiro","Fevereiro","Marco","Abril","Maio","Junho",
		"Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
def var i as i.
repeat with row 4 1 down side-labels width 80 title " Dados para Inventario ":
    prompt-for estab.etbcod colon 18.
    find estab using etbcod.
    display etbnom no-label colon 27.
    update wlivro colon 18
	   wcopias validate(wcopias > 0,"Numero de Copias nao pode ser 0.")
		   label "Num.Copias" colon 18.
    {confir.i 1 "Emissao de Inventario"}
    output to livimp.liv page-size 65.
    {ini17cpp.i}

    find first estoq of estab.
    form header
	"R E G I S T R O    D E    I N V E N T A R I O" at 43 skip
	fill("-",130) format "x(130)" skip
	"RAZAO SOCIAL.......... :" wempre.emprazsoc
	"LIVRO :" at 103 wlivro
	"FOLHA :" at 118 (page-number + 1) format ">>>>9" skip
	"INCRICAO ESTADUAL..... :" etbinsc
	"CGC (MF) :" at 102 etbcgc skip
	"ESTOQUES EXISTENTES EM :" day(estinvdat) format "99" "de"
	nomemes[month(estinvdat)] "de" year(estinvdat) format "9999" skip
	fill("-",130) format "x(130)" skip(1)
	"CODIGO   DESCRICAO"
	"UV      QUANTIDADE   PC.UNIT. MEDIO    VALOR ESTOQUE" at 79 skip
	"------  "
	fill("-",66) format "x(66)" space(3)
	"--   -------------   --------------    -------------" skip(2)
	with width 135 frame fcab no-labels page-top no-box no-attr-space.
    view frame fcab.
    wtotal = 0.
    for each estoq of estab where estatual > 0
	     /* estinvqtd > 0 and estinvctm > 0 */
	     , produ of estoq by estoq.etbcod by estoq.procod:
	put produ.procod format "999999"
	    space(3)
	    pronom format "x(65)"
	    space(4)
	    prounven
	    space(4)
	    estatual
	 /* estinvqtd */
	    space(3)
	    estcusto
	 /* estinvctm */
	    space(3)
	    estatual * estcusto format ">>,>>>,>>9.99"
	 /* estinvqtd * estinvctm format ">>>,>>>,>>9.99" */
	    skip.
	wtotal = wtotal + (estatual * estcusto). /* (estinvqtd * estinvctm). */
    end.
    put skip(2)
	"TOTAL GERAL = " at 95
	wtotal.
    {fin17cpp.i}
    output close.
    do i = 1 to wcopias:
	dos silent type livimp.liv >prn.
    end.
end.
