/* helio 17/08/2021 Hubperfil */
/*VERSAO 1*/

def output param pativo    as log.
def var vlcsaida as longchar.
def var hsaida as handle.

{seg/defhubperfildin.i}

find first ttsegprodu where ttsegprodu.procod = pprocod no-lock.
find first ttseguro   where ttseguro.id       = ttsegprodu.idseguro.
        
        
DEFINE DATASET perfilEntrada FOR ttperfil , ttcampos , ttatributos , ttopcoes
/*    DATA-RELATION forx FOR ttperfil, ttcampos
                   RELATION-FIELDS(ttperfil.id,ttcampos.idpai) NESTED     */      
    DATA-RELATION for0 FOR ttcampos, ttatributos
                   RELATION-FIELDS(ttcampos.id,ttatributos.idpai) NESTED         
    DATA-RELATION for1 FOR ttcampos, ttopcoes
                   RELATION-FIELDS(ttcampos.id,ttopcoes.idpai) NESTED .
                                         
                                         
hsaida = DATASET perfilEntrada:HANDLE.
                                
def var vsaida as char.
def var vresposta as char.

vsaida  = "segbuscaperfil" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

output to value(vsaida + ".sh").
put unformatted
    "curl -X POST -s \"http://10.2.0.233/bsweb/api/seguro/buscaPerfil/" + string(ttseguro.PerfilTitularId) + "\" " +
    " -H \"Content-Type: application/json\" " +
 /*   " -d '" + string(vLCEntrada) + "' " + */
    " -o "  + vsaida.
output close.

hide message no-pause.
message "Aguarde... Buscando campos do Perfil  " string(ttseguro.PerfilTitularId) "no HubSeg (via barramento)...".
pause 1 no-message.

unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo \"\n\">>"+ vsaida).

input from value(vsaida) no-echo.
import unformatted vresposta.
input close.

vLCsaida = vresposta.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY") no-error.
/*
for each ttperfil.
    disp ttperfil.
    for each ttcampos where ttcampos.idpai = string(ttperfil.id).
    disp ttcampos.
    for each ttatributos where ttatributos.idpai = ttcampos.id.
        disp ttatributos.
    end.
    for each ttopcoes  where ttopcoes.idpai = ttcampos.id.
        disp ttopcoes.
    end.    
    end.
end.    
*/
    find first ttperfil where ttperfil.id = ttseguro.PerfilTitularId no-error.
    if avail ttperfil
    then do:
            pativo = ttperfil.ativo.
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



