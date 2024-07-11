def input param pcpf            as char.
def input param pnomePessoa     as char.
def output param plistapep       as char.

plistapep = "".

def var vlcentrada as longchar.
def var vlcsaida as longchar.

{/admcom/progr/api/acentos.i} /* helio 14/09/2021 */

def temp-table ttpessoa serialize-name "pessoa"
    field cpfCnpj       as char
    field nomePessoa    as char.

def temp-table ttreturn no-undo serialize-name "return"
    field pstatus as char serialize-name "status".

def temp-table ttlistapep no-undo serialize-name "pessoaPEP" 
    field cpfCpjStr       as char
    field nomePessoa       as char 
    field dsRelacionamento       as char 
    field cpfPep       as char 
    field pep       as char 
    field cdTpPep       as char 
    field dsTpPep       as char 
    field dtInicio       as char 
    field dtFim       as char 
    field dsCargo       as char 
    field seq       as char 
    field dsComplemento       as char.

def var hSaida   as handle.
def var hEntrada as handle.

create ttpessoa.
ttpessoa.cpfcnpj       = string(pcpf).
ttpessoa.nomePessoa    = pnomePessoa.

hEntrada = temp-table ttpessoa:handle.

hEntrada:WRITE-JSON("longchar",vLCEntrada, false).

def var vsaida as char.
def var vresposta as char.

vsaida  = "/ws/works/consultar-lista-pep_" + string(pcpf) + "_" +
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

output to value(vsaida + ".sh").
put unformatted
    "curl -s \"http://localhost/bsweb/api/cliente/consultar-lista-pep" + "\" " +
    " -H \"Content-Type: application/json\" " +
    " --connect-timeout 7  --max-time 7 " + /* helio 05072022 colocado timeout */
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
        hSaida = temp-table ttlistapep:handle.
        hSaida:READ-JSON("longchar",vLCSaida, "EMPTY") no-error.

        find first ttlistapep no-error.
        if avail ttlistapep
        then do:
            create clienlista.
            ASSIGN
                clienlista.CpfCnpj    = dec(pcpf).
                clienlista.dtConsulta = today.
                clienlista.hrConsulta = time.
                clienlista.lista      = "LISTA_PEP".
                clienlista.historico  = ttlistapep.dsTpPep.
                
                plistapep             = clienlista.lista.
                
        end.            
    end.        



