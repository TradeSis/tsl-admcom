/*VERSAO 2 23062021.1*/

/* helio 15/06/2021 Aciona Motor Neurotech via REST */
def input parameter par_props  as char.
def input parameter par_arqlog as char.

{/admcom/progr/api/acentos.i} /* helio 04/11/2021 */

def var vhostname as char.
input through hostname.
import vhostname.
input close.

def var hEntrada as handle.
def var hSaida   as handle.

def var vcurl as char.
def var vlcentrada as longchar.
def var vlcsaida as longchar.

def var vct as int.
def var vtag as char.
def var vchave as char.
def var vvalor as char.

def temp-table ttdados  no-undo serialize-name "dados"
    field ambiente      as char
    field politica      as char 
    field id            as char.

def temp-table ttparametros  no-undo serialize-name "parametros"
    field nome      as char serialize-name "Name"
    field valor     as char serialize-name "Value". 

def shared temp-table ttretornodados no-undo serialize-name "dados"
    field IdOperacao as char format "x(30)"
    field CdOperacao as char
    field DsMensagem as char
    field Resultado  as char.

def shared temp-table ttretornoparametros no-undo serialize-name "parametros"
    field NmParametro as char
    field VlParametro as char format "x(40)".
    
                                                            
DEFINE DATASET dadosEntrada FOR ttdados, ttparametros.

hentrada = DATASET dadosEntrada:HANDLE.

DEFINE DATASET dadosSaida FOR ttretornodados, ttretornoparametros.

hsaida = DATASET dadosSaida:HANDLE.



create ttdados.
ttdados.ambiente       = if vhostname = "SV-CA-DB-DEV" or vhostname = "SV-CA-DB-QA" then "HML" else "PRD".

do vct = 1 to num-entries(par_props, "&").
    vtag = entry(vct, par_props, "&").

    if num-entries(vtag, "=") = 2
    then do.
        vchave = entry(1, vtag, "=").
        vvalor = entry(2, vtag, "=").
        if vchave = "PROP_CPFCLI"
        then do:
            ttdados.id = vvalor.
        end.   
        if vchave = "POLITICA"
        then do:
            ttdados.politica = vvalor.
        end.
        else do.
            create ttparametros.
            ttparametros.nome   = vchave.
            ttparametros.valor  = if vchave = "PROP_FLXPOLITICA" 
                                  then vvalor 
                                  else removeacento(vvalor).
        end.
    end.
end.


hEntrada:WRITE-JSON("longchar",vLCEntrada, false).


def var vsaida as char.
def var vresposta as char.
DEFINE VARIABLE process-id AS CHARACTER NO-UNDO.

INPUT THROUGH echo $$  NO-ECHO.
import process-id.
INPUT CLOSE.

vsaida  = par_arqlog + "_chamaneurotech" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + string(process-id) + ".json". 

/*output to value(vsaida) append.
put unformatted skip "ENTRADA" skip
    string(vLCEntrada).
output close.
*/

vcurl = "curl -s \"http://localhost/bsweb/api/limites/acionaNeurotech" + "\" " + 
        " -H \"Content-Type: application/json\" " +
        " -m 240 ".
                 
run log ("EXECUTA " + vcurl).
run log ("JSON    " + vsaida).

output to value(vsaida + ".sh").
put unformatted skip vcurl + " -o " + vsaida + "  -d '" + string(vLCEntrada) + "'".
output close.

unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
run log ("SH").

unix silent value("echo \"\n\">>"+ vsaida).

run log ("INPUT").

vresposta = "".
input from value(vsaida) no-echo.
/*
input THROUGH value(vcurl + " -d '" + string(vLCEntrada) + "'" ) no-error.
*/
import unformatted vresposta.        
input close.

run log ("FIM").

/*
output to value(vsaida) append.
put unformatted skip(1) "RESPOSTA" skip
    vresposta.
output close.
*/



vLCsaida = vresposta.
output to value(par_arqlog + ".log") append.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY") no-error.

put unformatted skip string(time, "hh:mm:ss") " Resposta: " vsaida skip.
for each ttretornodados.
    export ttretornodados.    
end.
for each ttretornoparametros.
    export ttretornoparametros.
end.    
output close.

    
find first ttretornodados no-error.
    if avail ttretornodados
    then do:
            unix silent value("rm -f " + vsaida). 
            unix silent value("rm -f " + vsaida + ".erro"). 
            unix silent value("rm -f " + vsaida + ".sh"). 
    end.        




procedure log.
    def input parameter p_mensagem as char.

    output to value(par_arqlog + ".log") append.
    put unformatted "     ---- " string(time, "hh:mm:ss") " api/chamaneurotech " p_mensagem skip.
    output close.

end procedure.


