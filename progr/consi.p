/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/consi.p                 Consiste quantidades do Balanco.    */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wetbcod like estab.etbcod.
def var wclacod like clase.clacod.
def var west like himestfim extent 0 label "Qtd.Calculada"
	       format "->,>>>,>>9.99".
def var wclanom like clase.clanom.
def new shared var wrecid as recid.
repeat with row 4 frame f1 width 80 side-labels 1 down:
    update wetbcod colon 18.
    find estab where estab.etbcod = wetbcod.
    display space(2) etbnom no-label.
    update wclacod colon 18.
    if wclacod <> 0
	then do:
	find clase where clase.clacod = wclacod.
	display space(2) clanom no-label.
	end.
    {confir.i 1 "Consistencia do Balanco"}
    output to printer page-size 60.
    put unformatted chr(30) "3".
    if wclacod <> 0
    then do:
	if 25 - length(clanom) > 1
	    then substr(wclanom,25 - length(clanom) + 1) = clanom.
	    else wclanom = clanom.
	form header
	    wempre.emprazsoc format "x(30)"
	    "CONSISTENCIA DO BALANCO" at 38
	    today at 85
	    page-number format ">>9" at 94 skip
	    etbnom
	    wclanom to 96 skip
	    fill("-",96) format "x(96)" skip
	    "Codigo Descricao"
	    "UV Data" at 43
	    "Qtd.Calculada  Qtd.Informada   Dif.Estoque" at 55 skip(1)
	    with frame fcab page-top no-box no-attr-space width 96.
	{consi.i 1
	 "if line-counter = 1 then display with frame fcab. view frame fcab"}
    end.
    else do:
	form header
	    wempre.emprazsoc format "x(30)"
	    "CONSISTENCIA DO BALANCO" at 38
	    today at 85
	    page-number format ">>9" at 94 skip
	    etbnom skip
	    fill("-",96) format "x(96)" skip
	    with frame fcab1 page-top no-box no-attr-space width 96.
	for each clase break by clase.clacod:
	    if line-counter = 1
		then display with frame fcab1.
	    view frame fcab1.
	    form header skip(1) " Classe: "
		clase.clacod "-" clase.clanom skip
		fill("-",40) format "x(40)" skip
		"Codigo Descricao"
		"UV Data" at 43
		"Qtd.Calculada  Qtd.Informada   Dif.Estoque" at 55 skip
		with frame fclase width 96 no-box no-label.
	    {consi.i 2 "if first(produ.clacod) then view frame fclase"}
	end.
    end.
    put unformatted chr(30) "1".
    output close.
    message "Consistencia de Balanco encerrada.".
end.
