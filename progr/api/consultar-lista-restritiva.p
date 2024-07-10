def input param pcpf            as char init "07068093868".
def input param pnomePessoa     as char.
def output param plistares       as char.

def var vlcentrada as longchar.
def var vlcsaida as longchar.

{/admcom/progr/api/acentos.i} /* helio 14/09/2021 */

def temp-table ttpessoa serialize-name "pessoa"
    field cpfCnpj       as char
    field nomePessoa    as char.

def temp-table ttreturn no-undo serialize-name "return"
    field pstatus as char serialize-name "status".

def temp-table ttlistares no-undo serialize-name "EGUARDIAN" 
    field DE_LISTADO      as char 
    field DE_TP_LISTA     as char .

def var hSaida   as handle.
def var hEntrada as handle.

create ttpessoa.
ttpessoa.cpfcnpj       = string(pcpf).
ttpessoa.nomePessoa    = pnomePessoa.

hEntrada = temp-table ttpessoa:handle.

hEntrada:WRITE-JSON("longchar",vLCEntrada, false).

def var vsaida as char.
def var vresposta as char.

vsaida  = "/ws/works/consultar-listas-restritivas_" + string(pcpf) + "_" +
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

output to value(vsaida + ".sh").
put unformatted
    "curl -s \"http://localhost/bsweb/api/cliente/consultar-listas-restritivas" + "\" " +
    " -H \"Content-Type: application/json\" " +
    " -d '" + string(vLCEntrada) + "' " + 
    " -o "  + vsaida.
output close.

unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo \"\n\">>"+ vsaida).

input from value(vsaida) no-echo.
import unformatted vresposta.
input close.

vLCsaida = vresposta.

hSaida = temp-table ttreturn:handle.
hSaida:READ-JSON("longchar",vLCSaida, "EMPTY") no-error.

for each ttreturn where ttreturn.pstatus = "".
    delete ttreturn.
end.

    find first ttreturn no-error.    
    if avail ttreturn
    then do:
    end.        
    else do:    
        hSaida = temp-table ttlistares:handle.
        hSaida:READ-JSON("longchar",vLCSaida, "EMPTY") no-error.

        find first ttlistares where ttlistares.de_listado <> "" no-error.
        if avail ttlistares
        then do:
            for each ttlistares where ttlistares.de_listado <> ""  .
            
                create clienlista.
                ASSIGN
                clienlista.CpfCnpj    = dec(pcpf).
                clienlista.dtConsulta = today.
                clienlista.hrConsulta = time.
                clienlista.lista      = ttlistares.DE_TP_LISTA.
                clienlista.historico  = "".
                
                plistares             = plistares + (if plistares = "" then "" else ",") + clienlista.lista.
                

            end.    
        end.            
    end.        



