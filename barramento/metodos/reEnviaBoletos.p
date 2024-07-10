/* 10 - DESATIVO A ESCRITA NO DIRETORIO MONTADO DO AC DEVIDO A TRAVAMENTOS */
DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.


pause 0 before-hide.
def var vnossonumero as int.
    
def var vdec as dec.    
{/admcom/barramento/metodos/reEnviaBoletos.i}

/* LE ENTRADA */
lokJSON = hreEnviaBoletosEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

create ttstatus.
ttstatus.situacao = "".


find first ttreEnviaBoletosEntrada no-error.
if not avail ttreEnviaBoletosEntrada
then do:
    ttstatus.situacao = "SEM INFORMACAO DE ENTRADA".
end.
else do:
    vdec = dec(ttreEnviaBoletosEntrada.codigo_cpfcnpj) no-error.
    if vdec = ? or vdec = 0 
    then do:
        ttstatus.situacao = "CPF INVALIDO " + ttreEnviaBoletosEntrada.codigo_cpfcnpj.
    end.
    else do:
        ttstatus.chave  = ttreEnviaBoletosEntrada.codigo_cpfcnpj.

        find clien where clien.clicod = int(ttreEnviaBoletosEntrada.codigo_cpfcnpj) no-lock no-error.
        if not avail clien
        then do:
            find neuclien where neuclien.cpfcnpj = dec(ttreEnviaBoletosEntrada.codigo_cpfcnpj) no-lock no-error.
            if avail neuclien
            then find clien where clien.clicod = neuclien.clicod no-lock. 
        end.    
        if not avail neuclien and not avail clien
        then do:
            ttstatus.situacao = "CLIENTE NAO CADASTRADO".
        end.    
    end.
end.    
if ttstatus.situacao = "" and avail ttreEnviaBoletosEntrada
then do:

    ttstatus.situacao = "Boleto nao Encontrado".
        
    for each banboleto where
        banboleto.clifor = clien.clicod and
        banboleto.dtpagamento = ?
        no-lock.

        vnossonumero = int(ttreenviaboletosentrada.nossonumero) no-error.
         if vnossonumero <> ? and vnossonumero <> 0
         then do:
            if vnossonumero <> banboleto.nossonumero
            then next.
         end.
        find banco where banco.bancod = banboleto.bancod no-lock.
        find banCarteira of banBoleto no-lock.
 
        create ttboleto.
        ttboleto.chave = ttstatus.chave.
        
            ttboleto.Banco          =   string(banco.numban,"999").
            ttboleto.Agencia        =   string(banboleto.agencia).
            ttboleto.codigoCedente  =   banCarteira.banCedente.
            ttboleto.contaCorrente  =   string(banboleto.contacor).
            ttboleto.Carteira       =   banboleto.banCart.
            ttboleto.nossoNumero    =   string(banBoleto.nossonumero,"99999999").
            ttboleto.DVnossoNumero  =   string(banBoleto.DvNossoNumero).
            ttboleto.dtEmissao      =   string(banboleto.dtemissao).
            ttboleto.dtVencimento   =   string(banboleto.dtvencimento).
            ttboleto.fatorVencimento =  string(banboleto.fatorVencimento,"9999").
            ttboleto.numeroDocumento =  banboleto.Documento.
            ttboleto.sacadoNome     =   clien.clinom.
            ttboleto.sacadoEndereco =   clien.endereco[1].
            ttboleto.sacadoCEP      =   string(clien.cep[1],"99999999").
            ttboleto.linhaDigitavel =   banboleto.linhaDigitavel.
            ttboleto.codigoBarras   =   banboleto.codigoBarras.
            ttboleto.VlPrincipal    =   trim(string(banboleto.vlCobrado,">>>>>>>9.99")).
        
        ttstatus.situacao = "Sucesso".
    end.

 
 
end.     
else do:
    message ttstatus.situacao.
end.


lokJson = hreEnviaBoletosSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE).
/* 10
hreEnviaBoletosSaida:WRITE-JSON("FILE","helio_rebol.json", true).
*/
