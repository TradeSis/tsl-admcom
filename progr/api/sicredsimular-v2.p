/* helio 06/10/2021 Moving Sicred */
/*VERSAO 1*/

def var vhostname as char.
input through hostname.
import vhostname.
input close.
def var vtoken as char.
def var vusername as char.

def var vhost as char.

vhost = "10.2.0.83".
vusername = "ADMCOM".
if vhostname = "SV-CA-DB-DEV" 
then do:
    vhost = "10.145.0.233".
    vusername = "ADMCOM-V2".
end.    
if vhostname = "SV-CA-DB-QA" 
then do:
    vhost = "10.145.0.44".
    vusername = "ADMCOM-V2".
end.    


def var hEntrada as handle.
def var hSaida   as handle.

def var vcurl as char.
def var vlcentrada as longchar.
def var vlcsaida as longchar.

{/admcom/progr/api/sicredsimular.i} 

for each ttreturn.
    delete ttreturn.
end.
    
hentrada = TEMP-TABLE ttdados:HANDLE.

hsaida   = dataset retorno:HANDLE.

hEntrada:WRITE-JSON("longchar",vLCEntrada, false).


def var vsaida as char.
def var vresposta as char.
DEFINE VARIABLE process-id AS CHARACTER NO-UNDO.

INPUT THROUGH echo $$  NO-ECHO.
import process-id.
INPUT CLOSE.

vtoken = "".
find first sicred_token where sicred_token.username = vusername no-lock no-error.
if avail sicred_token
then do:
    if sicred_token.data_in = today 
    then do:
        if time - sicred_token.time_in < (sicred_token.expires_in - 300)
        then do.
            vtoken = "/" + sicred_token.access_token.
            
        end.
    end.                       
end.
vsaida  = "/ws/works/sicredsimular" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + string(process-id) + ".json". 

vcurl = "curl -s \"http://" + vhost + "/bsweb/api/sicred/simular-v2" + vtoken + "\" " + 
        " -H \"Content-Type: application/json\" " +
        " -m 30 ".
                 
output to value(vsaida + ".sh").
put unformatted skip vcurl + " -o " + vsaida + "  -d '" + string(vLCEntrada) + "'".
output close.

unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo \"\n\">>"+ vsaida).

vresposta = "".
input from value(vsaida) no-echo.
import unformatted vresposta.        
input close.

vLCsaida = vresposta.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY") no-error.


find first tttoken where tttoken.username = vusername no-error.
if avail tttoken
then do on error undo:
    find first sicred_token where sicred_token.username = tttoken.username
            exclusive no-wait no-error.
    if not avail sicred_token and not locked sicred_token
    then do:
        create sicred_token.
        sicred_token.username = vusername.
    end.
    if avail sicred_token 
    then do:
        sicred_token.data_in = today.
        sicred_token.time_in = time.
        sicred_token.expires_in = tttoken.expires_in.
        sicred_token.access_token = tttoken.access_token.
    end.
            
end.


find first ttreturn no-error.

if avail ttreturn
then do: 
    /* unix silent value("rm -f " + vsaida).  */
       unix silent value("rm -f " + vsaida + ".erro"). 
    /* unix silent value("rm -f " + vsaida + ".sh"). */
end.

