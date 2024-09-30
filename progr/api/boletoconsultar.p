/* helio 24082024 - proj boletagem */
/* faz chama com api bsweb, para transformação dos json e bsweb faz chamada ao barramento */

def input param par-rec as recid.

def output parameter mensagem_erro as char.

def var vhostname as char.
def var vhost as char.
input through hostname.
import vhostname.
input close. 
def var vhml as log.

vhml = no.
vhost = "10.2.0.83".

if vhostname = "SV-CA-DB-DEV" 
then do:
    vhml = yes.
    vhost = "10.145.0.233".
end.
if vhostname = "SV-CA-DB-QA"
then do: 
    vhml = yes.
    vhost = "10.145.0.44".  
end.

def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hEntrada as handle.
def var hSaida   as handle.


{api/acentos.i} /* helio 14/09/2021 */

def temp-table ttentrada no-undo serialize-name "dadosEntrada"
    field codigo_barras as char
    field etbcod       as char.

def shared temp-table ttboletoconsulta no-undo serialize-name "boletoconsulta"
    field retorno               as char 
    field id_requisicao         as int64
    field codigo_barra          as char 
    field situacao_boleto       as char 
    field ind_bloq_pagto        as char 
    field vlr_orig_boleto       as dec
    field valor_calculado_total as dec.



find    boletagbol  where   recid(boletagbol) = par-rec no-lock.
create ttentrada. 
ttentrada.codigo_barras = boletagbol.codigobarras.
ttentrada.etbcod       = STRING(boletagbol.etbcod).

hEntrada = TEMP-TABLE ttentrada:handle.

hEntrada:WRITE-JSON("longchar",vLCEntrada, false).

def var vsaida as char.
def var vresposta as char.
message "         api/boletoconsultar Chamando bsweb/api/boleto/boletoconsultar" .


if OPSYS = "UNIX" then do:
    vsaida  = "/ws/works/boletconsultar" + string(boletagbol.bolcod) + "_" +
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

    output to value(vsaida + ".sh").
    put unformatted
        "curl -s ~"http://" + vhost + "/bsweb/api/boleto/boletoconsultar" + "~" " +
        " -H ~"Content-Type: application/json~" " +
        " -d '" + string(vLCEntrada) + "' " + 
        " -o "  + vsaida.
    output close.
    message "         api/boletoconsultar Chamando bsweb/api/boleto/boletoconsultar " vsaida .

    unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
    unix silent value("echo ~"\n~">>"+ vsaida).

    input from value(vsaida) no-echo.
    import unformatted vresposta.
    input close.

    vLCsaida = vresposta.

    hSaida = temp-table ttboletoconsulta:handle.

    hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").
end.
ELSE DO:
    CREATE ttboletoconsulta.
    ttboletoconsulta.retorno               = "ok".
    ttboletoconsulta.id_requisicao         = 21321321.
    ttboletoconsulta.codigo_barra          = boletagbol.codigobarras.
    ttboletoconsulta.situacao_boleto       = "A".
    ttboletoconsulta.ind_bloq_pagto        = "N".
    ttboletoconsulta.vlr_orig_boleto       = boletagbol.vlCobrado.
    ttboletoconsulta.valor_calculado_total = boletagbol.vlCobrado.

END.
    find first ttboletoconsulta no-error.    
    if avail ttboletoconsulta
    then do:
                unix silent value("rm -f " + vsaida). 
                unix silent value("rm -f " + vsaida + ".erro"). 
                unix silent value("rm -f " + vsaida + ".sh"). 
    End. 
    ELSE do:
            mensagem_erro = "SEM RETORNO".
    end.
    




