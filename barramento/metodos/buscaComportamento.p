/* HUBSEG 19/10/2021 */

DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.


{neuro/achahash.i}
{neuro/varcomportamento.i}

pause 0 before-hide.
    
def var vdec as dec.    
{/admcom/barramento/metodos/buscaComportamento.i}

/* LE ENTRADA */
lokJSON = hcomportamentoEntrada:READ-JSON("longchar", lcJsonEntrada, "EMPTY").

def var vvlrlimite as dec.
def var vvctolimite as date.
def var vcomprometido as dec.
def var vcomprometidohubseg as dec.

def var vsaldoLimite as dec.
create ttstatus.
ttstatus.situacao = "".


find first ttComportamentoEntrada no-error.
if not avail ttcomportamentoEntrada
then do:
    ttstatus.situacao = "SEM INFORMACAO DE ENTRADA".
end.
else do:
    vdec = dec(ttcomportamentoEntrada.cpfcnpj) no-error.
    if vdec = ? or vdec = 0 
    then do:
        ttstatus.situacao = "CPF INVALIDO " + ttcomportamentoEntrada.cpfcnpj.
    end.
    else do:
        ttstatus.cpfcnpj  = ttcomportamentoEntrada.cpfcnpj.
        find clien where clien.clicod = int(ttcomportamentoEntrada.cpfcnpj) no-lock no-error.
        if not avail clien
        then do:
            find neuclien where neuclien.cpfcnpj = dec(ttcomportamentoEntrada.cpfcnpj) no-lock no-error.
            if avail neuclien
            then find clien where clien.clicod = neuclien.clicod no-lock. 
        end.    
        else do:
            find neuclien where neuclien.clicod = clien.clicod no-lock no-error. 
        end.
        if not avail neuclien and not avail clien
        then do:
            ttstatus.situacao = "CLIENTE NAO CADASTRADO".
        end.    
    end.
end.    
if ttstatus.situacao = "" and avail ttcomportamentoEntrada
then do:
    create ttclien.
    ttclien.clicod  = string(clien.clicod).
    ttclien.cpfcnpj = ttcomportamentoEntrada.cpfcnpj.  
    
    ttclien.clinom = clien.clinom.

    for each titulo where titulo.clifor = clien.clicod no-lock.
        if titulo.titsit = "LIB"
        then do:
            find first ttmodalcomportamento where 
                    ttmodalcomportamento.clicod = string(clien.clicod) and 
                    ttmodalcomportamento.modcod = titulo.modcod
                no-error.
            if not avail ttmodalcomportamento
            then do:          
                create ttmodalcomportamento. 
                ttmodalcomportamento.clicod = string(clien.clicod). 
                ttmodalcomportamento.modcod = titulo.modcod.
            end.
            ttmodalcomportamento.dcomprometido = ttmodalcomportamento.dcomprometido +
                            titulo.titvlcob.
            /* para json */
            ttmodalcomportamento.comprometido = trim(string(ttmodalcomportamento.dcomprometido,">>>>>>>>>>>9.99")).
        end.
    end.

    create ttcredito.
    ttcredito.clicod = ttclien.clicod.
    ttcredito.tempoRelacionamento = string(today - clien.dtcad).
    vvlrlimite = 0.
    vvctolimite = ?.
    vcomprometido = 0.
    vsaldoLimite = 0.
    
    if avail neuclien
    then do:
        vvlrlimite = neuclien.vlrlimite.
        vvctolimite = neuclien.vctolimite.
    end.
    

    def var c1 as char.
    def var r1 as char format "x(30)".
    def var il as int.
    def var vcampo as char format "x(20)". 

    var-propriedades = "".
    run neuro/comportamento.p (clien.clicod,?,output var-propriedades). /* hubseg */
    vcomprometidohubseg = 0.
    do il = 1 to num-entries(var-propriedades,"#") with down.
    
        vcampo = entry(1,entry(il,var-propriedades,"#"),"=").
        if vcampo = "FIM"
        then next.
        r1 = pega_prop(vcampo).

        create ttcomportamento.
        ttcomportamento.clicod = ttclien.clicod.
        ttcomportamento.atributo        = vcampo.
        ttcomportamento.valoratributo   = r1.
        if vcampo = "LIMITETOMPR" 
        then do:
            vcomprometido = dec(r1).
        end.    
        if vcampo = "LIMITETOMHUBSEG" 
        then do:
            vcomprometidohubseg = dec(r1).
        end.    
        

    end.
    vcomprometido = vcomprometido - vcomprometidohubseg.     
    vsaldoLimite = vvlrlimite - vcomprometido.
    
    if vvctolimite < today or vvctolimite = ? or
        vsaldoLimite < 0
    then vsaldoLimite = 0.

    ttcredito.limite        = trim(string(vvlrlimite,">>>>>>>>>>>9.99")).
    ttcredito.vctolimite    = string(vvctolimite,"99/99/9999").

    ttcredito.comprometido  = trim(string(vcomprometido,">>>>>>>>>>>9.99")).
    ttcredito.saldoLimite   = trim(string(vsaldoLimite,">>>>>>>>>>>9.99")).
    
     

/*    hcomportamentoCliente:WRITE-JSON("FILE", "heliox.json", true).*/
end.     
else do:
    message ttstatus.situacao.
end.


lokJson = hcomportamentoCliente:WRITE-JSON("LONGCHAR",  lcJsonSaida, TRUE).
/* 10
hcomportamentoCliente:WRITE-JSON("FILE", "helio.json", true).
*/
