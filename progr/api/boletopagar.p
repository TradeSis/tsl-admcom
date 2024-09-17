/* helio 24082024 - proj boletagem */
/* faz chama com api bsweb, para transformação dos json e bsweb faz chamada ao barramento */

def input param par-rec as recid.
def output parameter mensagem_erro as char.

def var vvalor_movimento as dec.
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
    field etbcod        as char
    field nsu           as INT
    FIELD dtPagamento   AS char
    field valor_movimento   as dec
    field cod_forma_pagamento   as int
    field data_vencimento as char
    field cpf_cnpj_pagador_final   as char
    field nome_pagador_final as char.

def temp-table ttboletopagar no-undo serialize-name "boletopagamento"
    field retorno               as char 
    field id_requisicao         as int64
    field codigo_barras          as char 
    field numero_banrisul       as char 
    field cod_forma_pagamento        as char 
    field id_rastreabilidade    as char.

def new shared temp-table ttboletoconsulta no-undo serialize-name "boletoconsulta"
    field retorno               as char 
    field id_requisicao         as int64
    field codigo_barra          as char 
    field situacao_boleto       as char 
    field ind_bloq_pagto        as char 
    field vlr_orig_boleto       as dec
    field valor_calculado_total as dec.

def var vnsu as int64.

    find first boletagbol where boletagbol.situacao = "P" and boletagbol.dtpagamento = today no-lock no-error.
    if not avail boletagbol
    then do:
        vnsu = 1.       /* primeiro pagamento do dia */
        current-value(banrisulnsu) = vnsu.    
    end.    
    else do:
        vnsu = next-value(banrisulnsu).
    end.

find    boletagbol  where   recid(boletagbol) = par-rec no-lock.
find clien where clien.clicod = boletagbol.clifor no-lock.
create ttentrada. 
ttentrada.codigo_barras = boletagbol.codigobarras.
ttentrada.etbcod       = STRING(boletagbol.etbpag).
ttentrada.dtPagamento = string(TODAY,"99/99/9999").
ttentrada.nsu           = vnsu.
ttentrada.cod_forma_pagamento = 19.
ttentrada.data_vencimento = string(boletagbol.dtvencimento,"99/99/9999").
vvalor_movimento = boletagbol.vlcobrado.

if boletagbol.dtvencimento < today
then do:
    run api/boletagconsultar.p (input recid(boletagbol), output mensagem_erro).
    find first ttboletoconsulta no-error.
    if  avail ttboletoconsulta
    then do:
        vvalor_movimento = ttboletoconsulta.valor_calculado_total.  
    end.
end.
ttentrada.valor_movimento = vvalor_movimento.
ttentrada.cpf_cnpj_pagador_final = clien.ciccgc.
ttentrada.nome_pagador_final = clien.clinom.

hEntrada = TEMP-TABLE ttentrada:handle.

hEntrada:WRITE-JSON("longchar",vLCEntrada, false).

def var vsaida as char.
def var vresposta as char.
message "         api/boletopagar Chamando bsweb/api/boleto/boletopagar" .


if OPSYS = "UNIX" then do:
    vsaida  = "/ws/works/boletopagar" + string(boletagbol.bolcod) + "_" +
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

    output to value(vsaida + ".sh").
    put unformatted
        "curl -X POST -s ~"http://" + vhost + "/bsweb/api/boleto/boletopagar" + "~" " +
        " -H ~"Content-Type: application/json~" " +
        " -d '" + string(vLCEntrada) + "' " + 
        " -o "  + vsaida.
    output close.
    message "         api/boletopagar Chamando bsweb/api/boleto/boletopagar " vsaida .

    unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
    unix silent value("echo ~"\n~">>"+ vsaida).

    input from value(vsaida) no-echo.
    import unformatted vresposta.
    input close.

    vLCsaida = vresposta.

    hSaida = temp-table ttboletopagar:handle.

    hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").
end.
ELSE DO:
    CREATE ttboletopagar.
    ttboletopagar.retorno               = "ok".
    ttboletopagar.id_requisicao         = 21321321.
    ttboletopagar.codigo_barra          = boletagbol.codigobarras.
    ttboletopagar.numero_banrisul       = "sdfdsdfsdf".
    ttboletopagar.cod_forma_pagamento   = "19".
    ttboletopagar.id_rastreabilidade    = "xzcdsfdfdfdfdf" .

END.
    find first ttboletopagar no-error.    
    if avail ttboletopagar
    then do:
        if  ttboletopagar.numero_banrisul <> ?  then DO ON ERROR UNDO:
            FIND CURRENT boletagbol EXCLUSIVE NO-WAIT NO-ERROR.
            if AVAIL boletagbol 
            THEN DO:
                boletagbol.nsu               = vnsu.
                boletagbol.numero_pgto_banco =    ttboletopagar.numero_banrisul .
                boletagbol.obs_pgto_banco    =    ttboletopagar.id_rastreabilidade.
                boletagbol.dtpagamento       =    TODAY.
                unix silent value("rm -f " + vsaida). 
                unix silent value("rm -f " + vsaida + ".erro"). 
                unix silent value("rm -f " + vsaida + ".sh"). 
                
            END.
        END.
    End. 
    ELSE do:
            mensagem_erro = "SEM RETORNO".
    end.
    




