/* helio 17/08/2021 HubSeguro */
/*VERSAO 1*/

def input  param pidSeguro as char.
def output param pativo    as log.

def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hsaida as handle.

{seg/defhubperfildin.i}

DEFINE DATASET seguroEntrada FOR ttseguro.

hsaida = DATASET seguroEntrada:HANDLE.
                                
def var vsaida as char.
def var vresposta as char.

vsaida  = "segbuscaseguro" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

output to value(vsaida + ".sh").
put unformatted
    "curl -X POST -s \"http://10.2.0.233/bsweb/api/seguro/buscaSeguros/" + string(pidseguro) + "\" " +
    " -H \"Content-Type: application/json\" " +
 /*   " -d '" + string(vLCEntrada) + "' " + */
    " -o "  + vsaida.
output close.

hide message no-pause.
message "Aguarde... Fazendo Validando Seguro " string(pidseguro)  "no HubSeg (via barramento)...".
pause 1 no-message.

unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo \"\n\">>"+ vsaida).

input from value(vsaida) no-echo.
import unformatted vresposta.
input close.

vLCsaida = vresposta.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").

    find first ttseguro no-error.    
    if avail ttseguro
    then do:
            pativo = ttseguro.ativo.
            unix silent value("rm -f " + vsaida). 
            unix silent value("rm -f " + vsaida + ".erro"). 
            unix silent value("rm -f " + vsaida + ".sh"). 
        hide message no-pause.
        
    end.     
    else do: 
        pativo = false.
        message "Ocorreu um problema".
        pause 1 no-message.
    end.





