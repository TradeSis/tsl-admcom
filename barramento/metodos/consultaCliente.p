/* 10 - DESATIVO A ESCRITA NO DIRETORIO MONTADO DO AC DEVIDO A TRAVAMENTOS */ 

DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.


pause 0 before-hide.
    
def var vdec as dec.    
{/admcom/barramento/metodos/consultaCliente.i}

/* LE ENTRADA */
lokJSON = hclienteEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").


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
        ttstatus.codigo_cpfcnpj  = ttclienteEntrada.codigo_cpfcnpj.

        /**24.07 - pesquisa apenas por cpf 
        find clien where clien.clicod = int(ttclienteEntrada.codigo_cpfcnpj) no-lock no-error.
        if not avail clien
        then do:
        **/
            find neuclien where neuclien.cpfcnpj = dec(ttclienteEntrada.codigo_cpfcnpj) no-lock no-error.
            if avail neuclien
            then find clien where clien.clicod = neuclien.clicod no-lock. 
        /**24.07 end.    */
        if not avail neuclien and not avail clien
        then do:
            ttstatus.situacao = "CLIENTE NAO CADASTRADO".
        end.    
    end.
end.    
if ttstatus.situacao = "" and avail ttclienteEntrada
then do:
    create ttclien.
    ttclien.codigocpfcnpj = ttclienteentrada.codigo_cpfcnpj.

 
    if avail clien
    then do:
        ttclien.nomecliente = clien.clinom. 
        ttclien.codigo_cliente = string(clien.clicod). 
        ttclien.cpf_cnpj = if avail neuclien then string(neuclien.cpfcnpj) else clien.ciccgc.  
        find cpclien where cpclien.clicod =  clien.clicod no-lock no-error.  
        ttclien.celular = string(clien.fax). 
        ttclien.telefone_profissional = string(clien.protel[1]).  
        ttclien.tipo = if clien.tippes then "J" else "F".  
        ttclien.rua = clien.endereco[1]. 
        ttclien.bairro = clien.bairro[1]. 
        ttclien.cidade = clien.cidade[1]. 
        ttclien.estado = clien.ufecod[1]. 
        if clien.numero[1] <> ? 
        then ttclien.numero = string(clien.numero[1]). 
        else ttclien.numero = "". 
        ttclien.cep = clien.cep[1]. 
        ttclien.email = lc(clien.zona).
                                                                        
        message ttclienteentrada.codigo_cpfcnpj ttclien.codigocpfcnpj clien.clinom clien.fax  ttclien.celular.
    end.
    else do:
        ttstatus.situacao = "CLIEN NAO ENCONTRADO".
    end.

end.     
else do:
    message ttstatus.situacao.
end.


lokJson = hClienteSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE).
/*
hClienteSaida:WRITE-JSON("FILE","helio.json", true).
*/
