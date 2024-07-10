/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/poses.p                                  Posicao de Estoque */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
define new shared variable wcop as integer format ">9" label "Num. de Copias".
define new shared buffer wfabri for fabri.
define new shared variable wetb like estoq.etbcod.
l1:
do with side-labels width 80 title " Dados para Emissao " frame f1 1 down
	on error undo, retry l1:
    prompt-for skip(1) wfabri.fabcod colon 21.
    find wfabri using wfabri.fabcod.
    display wfabri.fabnom no-label.
    prompt-for skip(1) estab.etbcod colon 21.
    find estab using etbcod.
    display etbnom no-label at 30 skip(1).
    prompt-for wcop colon 21 skip(1).
    assign wetb = estab.etbcod
	   wcop.
end.
{confir.i 1 "Impressao da Posicao de Estoque"}
message "Emitindo Posicao de estoque.".
run es/posesli.p.
hide message no-pause.
message "Emissao de Posicao de Estoque encerrada.".
