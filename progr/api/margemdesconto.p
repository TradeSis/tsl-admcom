
def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hentrada as handle.

def var hsaida as handle.

{rest-cli/wc-consultamargemdesconto.i}

hentrada  = TEMP-TABLE ttconsultamargemdescontoEntrada:HANDLE.

hEntrada:WRITE-JSON("longchar",vLCEntrada, false).

DEFINE DATASET consultaMargemDescontoSaida
    FOR ttretornomargemdesconto, ttmargemDescontoProduto, ttmargemdesconto.
hsaida = DATASET consultamargemdescontoSaida:HANDLE.

def var vsaida as char.
def var vresposta as char.

vsaida  = "/ws/works/margemdesconto" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

output to value(vsaida + ".sh").
put unformatted
    "curl -X POST -s \"http://172.19.130.175:5555/gateway/pdvRestAPI/1.0/consultaMargemDescontoRestResource" + "\" " +
    " -H \"Content-Type: application/json\" " +
    " -d '" + string(vLCEntrada) + "' " + 
    " -o "  + vsaida.
output close.


hide message no-pause.
message "Aguarde... Buscando Margens desconto no Barramento...".
pause 1 no-message.
unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo \"\n\">>"+ vsaida).

input from value(vsaida) no-echo.
import unformatted vresposta.
input close.

vLCsaida = vresposta.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").

            unix silent value("rm -f " + vsaida). 
            unix silent value("rm -f " + vsaida + ".erro"). 
            unix silent value("rm -f " + vsaida + ".sh"). 

hide message no-pause.




    
