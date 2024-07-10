/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/ctmed.p        Calcula os custos medios iniciais em himov.  */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wdtlim as date label "Data Limite" initial today.
repeat with frame f1 width 80 side-labels 1 down:
    create parba.
    prompt-for estab.etbcod colon 18.
    find estab using etbcod.
    display space(4) etbnom no-label.
    parpar = string(estab.etbcod,"999").
    prompt-for produ.procod colon 18.
    if produ.procod entered
	then do:
	find produ using procod.
	display space(2) pronom no-label.
	parpar = parpar + string(produ.procod,"999999").
	end.
	else parpar = parpar + "      ".
    update wdtlim colon 18.
    {confir.i 1 "Atualizacao de Custo Medio"}
    parpar = parpar + string(wdtlim).
    assign parprog = "ctmedbt.p"
	   parhora = string(time,"hh:mm")
	   parsit  = "P".
    unix silent mbpro ../admcom/admcom -e 100 -d dmy -db ../admger/admger
					 -p ../admcom/es/ctmedbt.p > lixo &.
    message "Atualizacao de Custo Medio em processamento.".
end.
