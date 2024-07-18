
def input param pcontnum as int.

def var vip as char.
def var vhostname as char.
input through hostname.
import vhostname.
input close. 

def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hentrada as handle.

def var hsaida as handle.

def temp-table ttentrada  no-undo serialize-name "dadosEntrada"    
    field numeroContrato as char .
def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field pstatus   as int serialize-name "status"
    field descricaoStatus as char.
    
create ttentrada.
ttentrada.numeroContrato = string(pcontnum).

hentrada = TEMP-TABLE ttentrada:HANDLE.                      

hEntrada:WRITE-JSON("longchar",vLCEntrada, false).

hsaida = TEMP-TABLE ttsaida:HANDLE.                      

def var vsaida as char.
def var vresposta as char.

vsaida  = "/ws/works/crdassinatura" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

output to value(vsaida + ".sh").

    if vhostname = "SV-CA-DB-DEV" or 
       vhostname = "SV-CA-DB-QA"
    then do: 
        vip = "10.145.0.60".
    end.    
    else do:
        vip = "10.2.0.221".
    end.    

 
put unformatted
    "curl -X POST -s \"http://" + vip + "/tslebes/api/crediario/assinaContrato" + "\" " +
    " -H \"Content-Type: application/json\" " +
    " -d '" + string(vLCEntrada) + "' " + 
    " -o "  + vsaida.
output close.


hide message no-pause.
message "Aguarde... Processando assinatura " pcontnum "...".
pause 1 no-message.
unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
/*unix silent value("echo \"\n\">>"+ vsaida).*/

input from value(vsaida) no-echo.
repeat.
    import unformatted vresposta.
    if vresposta = "" then next.
end.    
input close.
vLCsaida = vresposta.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").
            unix silent value("rm -f " + vsaida). 
            unix silent value("rm -f " + vsaida + ".erro"). 
            unix silent value("rm -f " + vsaida + ".sh"). 
hide message no-pause.



    
