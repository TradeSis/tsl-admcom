/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/balli.p                 Livro Balanco    - Disparo          */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 06/07/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
define new shared variable wcopias as integer.
define new shared variable wetbcod like estab.etbcod.
define new shared variable wetbnom like estab.etbnom.
define new shared variable wclacod like clase.clacod.
repeat with row 4 1 down side-labels width 80 title " Dados para Balanco ":
    set wetbcod colon 18.
    find estab where estab.etbcod = wetbcod.
    display etbnom no-label colon 27.
    set wclacod validate(true,"") colon 18.
    if wclacod <> 0
	then do:
	find clase where clase.clacod = wclacod.
	display clanom no-label colon 27.
	if clatipo
	    then do:
	    message "Classe Superior, deve ser do tipo Associavel.".
	    undo.
	    end.
	end.
	else display "TODAS" @ clanom.
    set wcopias validate(wcopias > 0,"Numero de Copias nao pode ser 0.")
		label "Num.Copias" colon 18.
    {confir.i 1 "Emissao de Livro Balanco"}
    if wclacod = 0
	then for each setor of estab,
		 each atend of setor,
		 clase of atend break by setor.setcod by clanom:
	    if first-of(setor.setcod) or
	       first-of(clanom)
		then do:
		assign wetbcod = estab.etbcod
		       wetbnom = etbnom
		       wclacod = clase.clacod.
		run es/balimp.p.
		end.
	end.
	else do:
	assign wetbcod = estab.etbcod
	       wetbnom = etbnom.
	run es/balimp.p.
	end.
end.
