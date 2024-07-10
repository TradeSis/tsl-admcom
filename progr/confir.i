/*----------------------------------------------------------------------------*/
/* /usr/admger/confir.i                                  Confirmacao generica */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
define variable crsp{1} as logical format "Sim/Nao" initial yes.
message "Confirma {2} ?" update crsp{1}.
if not crsp{1}
    then do:
    message "{2} nao confirmada.".
    undo {3}.
    end.

