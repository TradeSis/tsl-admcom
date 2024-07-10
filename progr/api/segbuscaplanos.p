/* helio 17/08/2021 HubSeguro */
/*VERSAO 1*/

def input param pprocod as int.
def input param setbcod as int.

def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hentrada as handle.

def var hsaida as handle.

def temp-table ttentrada  no-undo serialize-name "planos"    
    field produto       as char 
    field filial        as char.

def temp-table ttwsplanos  no-undo serialize-name "planos"    
    field fincod        as char serialize-name "codigoPlano" 
    field finnom        as char serialize-name "nomePlano"
    field qtdvezes      as char. 
    
def shared temp-table ttplanos  no-undo serialize-name "planos"    
    field fincod        like finan.fincod
    field finnom        like finan.finnom
    field qtdvezes      as int.
    
create ttentrada.
ttentrada.produto = string(pprocod).
ttentrada.filial  = string(setbcod).

hentrada = TEMP-TABLE ttentrada:HANDLE.                      

hEntrada:WRITE-JSON("longchar",vLCEntrada, false).

hsaida = TEMP-TABLE ttwsplanos:HANDLE.                      

def var vsaida as char.
def var vresposta as char.

vsaida  = "segbuscaplanos" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

output to value(vsaida + ".sh").
put unformatted
    "curl -X POST -s \"http://10.2.0.233/bsweb/api/seguro/buscaPlanos" + "\" " +
    " -H \"Content-Type: application/json\" " +
    " -d '" + string(vLCEntrada) + "' " + 
    " -o "  + vsaida.
output close.


hide message no-pause.
message "Aguarde... Fazendo Buscando Planos no Matriz...".
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


for each ttwsplanos.
    
    
    
    create ttplanos.
    ttplanos.fincod = int(ttwsplanos.fincod).
    ttplanos.finnom = ttwsplanos.finnom.
    ttplanos.qtdvezes = int(ttwsplanos.qtdvezes). 
    
    
    
end.


    
