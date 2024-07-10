/* Zoom de Grupos de Mix de Modas 
   05/09/2013
*/
form with frame f-linha down row 10  
          title " Grupos de Mix de Moda " color yellow/blue overlay. 

{setbrw.i}
{sklcls.i
    &help       = "ENTER=Seleciona F4=Retorna"
    &file       = mixmgrupo
    &cfield     = mixmgrupo.nome
    &ofield     = "mixmgrupo.codgrupo mixmgrupo.prioridade"
    &where      = "mixmgrupo.situacao use-index nome"
    &locktype   = "no-lock"
    &color      = yellow
    &color1     = blue
    &naoexiste1 = "message ""Nenhum registro encontrado"" view-as alert-box.
                   leave keys-loop."
    &aftselect1 = "frame-value = string(mixmgrupo.codgrupo).
                   leave keys-loop." 
    &form       = "frame f-linha"}

hide frame f-linha no-pause.

