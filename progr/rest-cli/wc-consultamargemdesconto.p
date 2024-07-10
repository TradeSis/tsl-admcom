    
def var vcJSON as longchar.

def var vcMetodo as char.
def var vLCEntrada as longchar.
def var vLCSaida   as longchar.
def var vcsaida    as char.

vcMetodo = "consultaMargemDescontoRestResource".

DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hconsultamargemdescontoEntrada          as handle.
def var hconsultamargemdescontoSaida            as handle.
def var hretorno                         as handle.


{rest-cli/wc-consultamargemdesconto.i}

hconsultamargemdescontoEntrada = TEMP-TABLE ttconsultamargemdescontoEntrada:HANDLE.

    
DEFINE DATASET consultaMargemDescontoSaida
    FOR ttretornomargemdesconto, ttmargemDescontoProduto, ttmargemdesconto.
hconsultamargemdescontoSaida = DATASET consultamargemdescontoSaida:HANDLE.

lokJSON = hconsultamargemdescontoEntrada:WRITE-JSON("longchar",vLCEntrada, TRUE).

run rest-cli/rest-barramento.p 
                 ( input  vcMetodo, 
                   input  vLCEntrada,  
                   output vLCSaida).


lokJSON = hconsultamargemdescontoSaida:READ-JSON("longchar",vLCSaida, "EMPTY").

/**
find first ttmargemdesconto no-error.
if not avail ttmargemdesconto
then do:
    /*
    vcsaida  = string(vLCSaida).
    vcSaida  = replace(vcsaida,"\"margemdesconto\":[],",""). 
    vcSaida  = replace(vcsaida,"\"statusRetorno\":","\"statusRetorno\":[").
    vcSaida  = replace(vcsaida,"\}\}\}","\}]\}\}").
    vlcsaida = vcSaida.
    */
    hretorno:READ-JSON("longchar",vLCSaida, "EMPTY").
    
    /*
    find first ttretornomargemdesconto no-error.
    if avail ttretornomargemdesconto
    then do:
        hide message no-pause.
        message ttretornomargemdesconto.descricao.
        pause 1 no-message.
    end.
    */
end.
**/


output to hsv.sai.
 put unformatted string(vlcSaida).
 output close.


 
