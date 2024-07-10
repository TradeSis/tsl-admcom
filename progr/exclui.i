/*----------------------------------------------------------------------------*/
/* /usr/admger/exclui.i                      Confirmacao de exclusao generica */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
define variable rsp{1} as logical format "Sim/Nao" initial yes.
rsp{1} = yes.
message "Confirma exclusao de {2} ?" update rsp{1}.
if not rsp{1}
    then do:
    message "Exclusao de {2} nao confirmada.".
    undo.
    end.
