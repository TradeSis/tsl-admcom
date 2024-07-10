def input param vmetodo    as char.
def input param vLCEntrada as longchar.
def output param vLCSaida   as longchar.

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def var vsaida as char.

def var ppid as char.
def var vchost as char.
def var vhostname as char.
def var wurl as char.

input through hostname.
import unformatted vhostname.
input close. 

INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

    vsaida  = "/u/bsweb/works/wciepro_" + vmetodo + "_"  
            + string(today,"999999") +  trim(ppid) + replace(string(time,"HH:MM:SS"),":","") +  ".json". 
    

    if vhostname = "SV-CA-DB-DEV" or 
       vhostname = "SV-CA-DB-QA"
    then do: 
        if vmetodo = "confirmacao" or
           vmetodo = "retorno"
        then wurl = "http://" + vhostname + "/bsweb/api/protesto/ieproBuscaArquivos".
        else wurl = "http://" + vhostname + "/bsweb/api/protesto/ieproEnviaRemessa".
        
    end.    
    else do:
        if vmetodo = "confirmacao" or
           vmetodo = "retorno"
        then wurl = "http://10.2.0.83/bsweb/api/protesto/ieproBuscaArquivos".
        else wurl = "http://10.2.0.83/bsweb/api/protesto/ieproEnviaRemessa".

    end.    

    

                    
    output to value(vsaida + ".sh").
    put unformatted
        "curl -X POST -s \"" + wURL + ""\" " +
        " -H \"Content-Type: application/json\" " +
        " -d '" + string(vLCEntrada) + "' " + 
        " -o "  + vsaida.
    output close.

    unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").

    COPY-LOB FILE vsaida  TO vlcsaida.
    /*
    unix silent value("rm -f " + vsaida). 
    unix silent value("rm -f " + vsaida + ".erro"). 
    unix silent value("rm -f " + vsaida + ".sh"). 
    */

     


 
