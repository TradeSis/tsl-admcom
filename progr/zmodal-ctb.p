/*----------------------------------------------------------------------------*/
/* /usr/admfin/zmodal.p                               Zoom Modalidade         */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
def new global shared var sretorno      as char.
def temp-table tt-modal like modal.
for each lancactb where
         lancactb.id = 0 and
         lancactb.etbcod = 0 and
         lancactb.forcod = 0 no-lock:
    find modal where modal.modcod = lancactb.modcod no-lock no-error.
    if avail modal
    then do:
        create tt-modal.
        buffer-copy modal to tt-modal.
    end.
end.         
{zoomesq.i tt-modal tt-modal.modcod tt-modal.modnom 30 Modalidades true}

sretorno = frame-value.

