/* helio 17/05/2021 */
/** #3 **/ /** 27.02.2018 Versionamento **/
/** #6 **/ /** 02.2019 Helio.Neto - Versao 4 - Inlcui Elegiveis Feirao */

def new global shared var cybversao as int. /*#3*/

cybversao = 6. /* 24012023 - retirada de testes para envio, irão todos*/

def var p-today as date.
def var vpropath as char.
/*#3*/
/* 23012023 - retirei versionamento externo, ficou no programa
if num-entries(SESSION:PARAMETER) = 2
then do:
    cybversao = int(entry(2,SESSION:PARAMETER)).
end.
*/
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
/* #6 */
if cybversao = 4
then do:
    run cyb/cybintegra_v4.p (p-today).
end.
if cybversao = 5
then do:
    run csl/integra_v5.p (p-today).
end.
if cybversao = 6 /* 24012023 retirado os testes para envio, irao subir todos os contratos */
then do:
    run csl/integra_v6.p (p-today).
end.





