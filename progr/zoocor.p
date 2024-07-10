/*----------------------------------------------------------------------------*/
/* /usr/admcom/zfabri.p                                   Zoom de Fabricantes */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
/*
{zoomesq.i cor corcod cornom 25 Cores true}
*/
form with frame f-linha down row 10  
          title " Cores " color yellow/blue overlay. 

{setbrw.i}
{sklcls.i
    &help       = "ENTER=Seleciona F4=Retorna"
    &file       = cor
    &cfield     = cor.cornom
    &ofield     = "cor.corcod cor.pantone"
    &where      = "true use-index icor2"
    &locktype   = "no-lock"
    &color      = yellow
    &color1     = blue
    &naoexiste1 = "message ""Nenhum registro encontrado"" view-as alert-box.
                   leave keys-loop."
    &aftselect1 = "frame-value = string(cor.corcod).
                   leave keys-loop." 
    &form       = "frame f-linha"}

hide frame f-linha no-pause.

