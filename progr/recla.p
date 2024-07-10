/*----------------------------------------------------------------------------*/
/* /usr/admcom/cp/recla.p                                 Reajuste por Classe */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 26/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
repeat with side-labels 1 down width 80 title " Parametros " frame f1:
    prompt-for clase.clacod colon 18.
    find clase using clase.clacod.
    display clanom no-label at 30.
    if clatipo
	then do:
	message "Classe de tipo Superior, reajuste impossivel.".
	undo.
	end.
    prompt-for estab.etbcod validate(true,"")
	   help "Informe o Estabelecimento ou BRANCO para todos." colon 18.
    if input estab.etbcod <> ""
	then do:
	find estab using etbcod.
	display etbnom no-label at 30.
	end.
    {confir.i 1 "Reajuste por Classe"}
    pause 0 before-hide.
    for each produ of clase,
	each estoq of produ where estreaj = yes
	with down width 80 title " Estoques " frame f2:
	if input estab.etbcod <> "" and
	   input estab.etbcod <> estoq.etbcod
	    then next.
	assign estvenda =(estcusto * (estmgoper / 100 + 1)) *
			 (estmgluc / 100 + 1)
	       estdtven = today
	       estreaj = no
	       estimp = yes.
	display estoq.procod
		estoq.etbcod
		estoq.pronomc
		estoq.fabfant space(2)
		estoq.estcusto
		estoq.estvenda.
    end.
    pause before-hide.
    message "Reajuste para" clanom "encerrado.".
end.
