
/** #3 **/ /** 27.02.2018 Versionamento **/

def new global shared var cybversao as int. /*#3*/
cybversao = 2. /*#3 Inicio do Versionamento*/

def var p-today as date.
def var vpropath as char.
/*#3*/
if num-entries(SESSION:PARAMETER) = 2
then do:
    cybversao = int(entry(2,SESSION:PARAMETER)).
end.
p-today = date(entry(1,SESSION:PARAMETER)) no-error.

/*#3*/
if p-today = ?
then p-today = if time <= 25000 /** 07:00 **/
               then today - 1
               else today.
message "Versao " cybversao today "p-today" p-today.




input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.
propath = vpropath + ",\dlc".

message "VERSAO " cybversao " CYBER - Integracao " today p-today
        "INICIO:" string(time,"HH:MM:SS").

if cybversao <= 2
then do:
    run cyb/cybintegra_v2.p (p-today).
end.
if cybversao = 3
then do:
    run cyb/cybintegra_v3.p (p-today).
end.


