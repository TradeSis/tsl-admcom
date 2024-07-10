/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/baldi.p                               Balanco - digitacao   */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wbaldat like estoq.estbaldat initial today.
repeat with row 4 width 80 side-labels:
    prompt-for estab.etbcod colon 18.
    find estab using estab.etbcod.
    display etbnom no-label at 30.
    repeat with width 80 title " Produtos / Quantidades ":
	prompt-for produ.procod column-label "Produ.".
	find produ using procod.
	find fabri of produ.
	find estoq of produ where estoq.etbcod = estab.etbcod.
	display produ.pronomc + "-" + fabri.fabfant + "/" + produ.prorefter
			     format "x(33)"
			     column-label "Descricao"
		prounven
		estbaldat column-label "Ult.Bal."
		wbaldat
		estbalqtd.
	set wbaldat.
	if estbalqtd <> ?
	    then message color normal "Digite 'E' para excluir a quantidade".
	set estbalqtd editing:
	    readkey.
	    if lastkey = keycode("e") or
	       lastkey = keycode("E")
		then do:
		estbalqtd = ?.
		display estbalqtd.
		leave.
		end.
	    apply lastkey.
	end.
	estbaldat = wbaldat.
    end.
end.
