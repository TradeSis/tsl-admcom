/*
  #v1802 Motor de Credito Pacote 01
         Versionamento
*/

def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.

def new global shared var versao as char. /*#3*/

versao = "1701". /*Inicio do Versionamento*/
versao = "1802". /* #1 */

if SESSION:PARAMETER <> "" and
   SESSION:PARAMETER <> ?
then do:
    versao = trim(entry(1,SESSION:PARAMETER)).
end.


message "VERSAO " versao " MOTOR - Comportamento " today
        "INICIO:" string(time,"HH:MM:SS").

if versao = "1701"
then do:
    run /admcom/progr/neuro/enviacomp_v1701.p.
end.
if versao = "1802"
then do:
    run /admcom/progr/neuro/enviacomp_v1802.p.
end.


quit.

