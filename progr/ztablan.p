/*----------------------------------------------------------------------------*/
/* /usr/admger/zempre.p                                       Zoom de Veiculo */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var vdeb like tablan.landeb.
def var vcre like tablan.lancre.
def var vprocura as char extent 2 format "x(12)"
        initial ["Nome","Codigo"].
display vprocura
    with frame fprocura no-labels row 4 column 40 overlay color yellow/black.
choose field vprocura
    with frame fprocura.
hide frame fprocura no-pause.

if frame-index = 1
then run ztab.p.
if frame-index = 2
then do:
    vdeb = 0.
    vcre = 0.
    update vdeb label "Cta Debito"
           vcre label "Cta Credito" 
                with frame f-procura side-label centered.
    find first tablan where tablan.landeb = vdeb and 
                            tablan.lancre = vcre no-lock no-error.
    if not avail tablan
    then do:
        message "Lancamento nao Cadastrado".
        undo, leave.
    end.
    display tablan.lancod
            tablan.landes no-label with frame f-disp side-label centered.
    pause.
end.
