/* helio 17/08/2021 HubSeguro */
/*VERSAO 1*/

def output param pidPropostaAdesaoLebes as char.

def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hsaida as handle.
def var hEntrada as handle.

{seg/defhubperfildin.i}

DEFINE DATASET adesaoEntrada FOR ttadesao, ttrespostas
    DATA-RELATION for0 FOR 
        ttadesao , ttrespostas RELATION-FIELDS(ttadesao.id,ttrespostas.idpai) NESTED .

hEntrada = DATASET adesaoEntrada:HANDLE.
hEntrada:WRITE-JSON("longchar",vLCEntrada, false).
                                
def var vsaida as char.
def var vresposta as char.

vsaida  = "segbuscaadesao" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

output to value(vsaida + ".sh").
put unformatted
    "curl -X POST -s \"http://10.2.0.233/bsweb/api/seguro/buscaAdesao/" + "\" " +
    " -H \"Content-Type: application/json\" " +
    " -d '" + string(vLCEntrada) + "' " + 
    " -o "  + vsaida.
output close.

hide message no-pause.
message "Aguarde... buscado adesao " string(pcpf)  "no Barramento...".
pause 1 no-message.

unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo \"\n\">>"+ vsaida).

input from value(vsaida) no-echo.
import unformatted vresposta.
input close.

hsaida = temp-table ttproposta:handle.
vLCsaida = vresposta.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").

    find first ttproposta no-error.    
    if avail ttproposta
    then do:
            pidPropostaAdesaoLebes = ttproposta.idPropostaAdesaoLebes.
            unix silent value("rm -f " + vsaida). 
            unix silent value("rm -f " + vsaida + ".erro"). 
            unix silent value("rm -f " + vsaida + ".sh"). 
        hide message no-pause.
        
    end.     
    else do: 
        pidPropostaAdesaoLebes = ?.
        message "Ocorreu um problema".
        pause 1 no-message.
    end.
