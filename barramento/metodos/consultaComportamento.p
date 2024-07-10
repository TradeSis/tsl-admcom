/* 10 - DESATIVO A ESCRITA NO DIRETORIO MONTADO DO AC DEVIDO A TRAVAMENTOS */ 
DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.


{neuro/achahash.i}
{neuro/varcomportamento.i}

pause 0 before-hide.
    
def var vdec as dec.    
{/admcom/barramento/metodos/consultaComportamento.i}

/* LE ENTRADA */
lokJSON = hcomportamentoEntrada:READ-JSON("longchar", lcJsonEntrada, "EMPTY").

create ttstatus.
ttstatus.situacao = "".


find first ttComportamentoEntrada no-error.
if not avail ttcomportamentoEntrada
then do:
    ttstatus.situacao = "SEM INFORMACAO DE ENTRADA".
end.
else do:
    vdec = dec(ttcomportamentoEntrada.codigo_cpfcnpj) no-error.
    if vdec = ? or vdec = 0 
    then do:
        ttstatus.situacao = "CPF INVALIDO " + ttcomportamentoEntrada.codigo_cpfcnpj.
    end.
    else do:
        ttstatus.chave  = ttcomportamentoEntrada.codigo_cpfcnpj.
        find clien where clien.clicod = int(ttcomportamentoEntrada.codigo_cpfcnpj) no-lock no-error.
        if not avail clien
        then do:
            find neuclien where neuclien.cpfcnpj = dec(ttcomportamentoEntrada.codigo_cpfcnpj) no-lock no-error.
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
    ttclien.chave   = ttcomportamentoEntrada.codigo_cpfcnpj.  
    
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

    ttclien.tempoRelacionamento = string(today - clien.dtcad).
    

    def var c1 as char.
    def var r1 as char format "x(30)".
    def var il as int.
    def var vcampo as char format "x(20)". 

    var-propriedades = "".
    run neuro/comportamento.p (clien.clicod,?,output var-propriedades).

    do il = 1 to num-entries(var-propriedades,"#") with down.
    
        vcampo = entry(1,entry(il,var-propriedades,"#"),"=").
        if vcampo = "FIM"
        then next.
        r1 = pega_prop(vcampo).

        create ttcomportamento.
        ttcomportamento.clicod = ttclien.clicod.
        ttcomportamento.atributo        = vcampo.
        ttcomportamento.valoratributo   = r1.

    end.
    

end.     
else do:
    message ttstatus.situacao.
end.


lokJson = hcomportamentoCliente:WRITE-JSON("LONGCHAR",  lcJsonSaida, TRUE).
/* 10          
hcomportamentoCliente:WRITE-JSON("FILE", "consultaComportamento.json", true).
*/

