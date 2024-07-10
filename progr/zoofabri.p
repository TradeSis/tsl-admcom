/*----------------------------------------------------------------------------*/
/* /usr/admcom/zfabri.p                                   Zoom de Fabricantes */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
/*{zoomesq.i fabri fabcod fabfant 35 Fabricantes true}*/
/*
{zoomfab.i fabri fabcod fabnom 60 Fabricante true}
*/

form with frame f-linha down row 10  
          title " Fabricantes " color yellow/blue overlay. 

{setbrw.i}
{sklcls.i
    &help       = "ENTER=Seleciona F4=Retorna"
    &file       = fabri
    &cfield     = fabri.fabnom
    &ofield     = "fabri.fabcod"
    &where      = "true use-index ifabnom"
    &locktype   = "no-lock"
    &color      = yellow
    &color1     = blue
    &naoexiste1 = "message ""Nenhum registro encontrado"" view-as alert-box.
                   leave keys-loop."
    &aftselect1 = "frame-value = string(fabri.fabcod).
                   leave keys-loop." 
    &form       = "frame f-linha"}

hide frame f-linha no-pause.

