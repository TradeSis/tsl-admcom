/*----------------------------------------------------------------------------*/
/* /usr/admger/zempre.p                                       Zoom de Veiculo */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/

{admcab.i}

def var vprocura as char extent 3 format "x(12)"
        initial ["Fantasia","Razao Social","CPF/CGC."].
def var vzoom    as char extent 2 format "x(12)"
        initial [" Completo ","    Pai   "].
        
display vzoom        
    with frame fzoom no-labels row 4 column 53 overlay color yellow/black.
choose field vzoom with frame fzoom.
hide frame fzoom no-pause.
    
if frame-index = 1
then do:

    display vprocura
            with frame fprocura no-labels row 4 column 40 
                                overlay color yellow/black.
    choose field vprocura with frame fprocura.
    hide frame fprocura no-pause.

    if frame-index = 1
    then run zfant2.p.
    if frame-index = 2
    then run znome2.p.
    if frame-index = 3
    then run zcgc.p.
    
end.
else
if frame-index = 2
then do:

    display vprocura
            with frame fprocura no-labels row 4 column 40 
                                overlay color yellow/black.
    choose field vprocura with frame fprocura.
    hide frame fprocura no-pause.

    if frame-index = 1
    then run zfant2b.p.
    if frame-index = 2
    then run znome2b.p.
    if frame-index = 3
    then run zcgc9.p.
    

end.
