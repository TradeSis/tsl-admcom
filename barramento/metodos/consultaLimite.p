/* 10 - DESATIVO A ESCRITA NO DIRETORIO MONTADO DO AC DEVIDO A TRAVAMENTOS */ 

DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.


{neuro/achahash.i}
{neuro/varcomportamento.i}

pause 0 before-hide.
    
def var vdec as dec.    
{/admcom/barramento/metodos/consultaLimite.i}

/* LE ENTRADA */
lokJSON = hclienteEntrada:READ-JSON("longchar", lcJsonEntrada, "EMPTY").

def var vvlrlimite as dec.
def var vvctolimite as date.

create ttstatus.
ttstatus.situacao = "".


find first ttclienteEntrada no-error.
if not avail ttclienteEntrada
then do:
    ttstatus.situacao = "SEM INFORMACAO DE ENTRADA".
end.
else do:
    vdec = dec(ttclienteEntrada.codigo_cpfcnpj) no-error.
    if vdec = ? or vdec = 0 
    then do:
        ttstatus.situacao = "CPF INVALIDO " + ttclienteEntrada.codigo_cpfcnpj.
    end.
    else do:
        ttstatus.chave  = ttclienteEntrada.codigo_cpfcnpj.
        find clien where clien.clicod = int(ttclienteEntrada.codigo_cpfcnpj) no-lock no-error.
        if not avail clien
        then do:
            find neuclien where neuclien.cpfcnpj = dec(ttclienteEntrada.codigo_cpfcnpj) no-lock no-error.
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
if ttstatus.situacao = "" and avail ttclienteEntrada
then do:
    create ttclien.
    ttclien.chave   = ttstatus.chave.
    ttclien.clicod  = string(clien.clicod).

    vvlrlimite = 0.
    vvctolimite = ?.
    
    if avail neuclien
    then do:
        vvlrlimite = neuclien.vlrlimite.
        vvctolimite = neuclien.vctolimite.
    end.
    

    ttclien.limite        = trim(string(vvlrlimite,">>>>>>>>>>>9.99")).
    ttclien.vctolimite    = string(vvctolimite,"99/99/9999").

end.     
else do:
    message ttstatus.situacao.
end.


lokJson = hclienteSaida:WRITE-JSON("LONGCHAR",  lcJsonSaida, TRUE).
/* 10
hclienteSaida:WRITE-JSON("FILE", "consultaLimite.json", true).
*/
