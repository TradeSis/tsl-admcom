/* #1 - helio 05.18 - erro vinculo */

/* Gestao de Boletos   - processo batch
   bol/enviaboleto_v1701.p
   gera arquivo em format CSV
   
*/

def var par-banco as int.
def var vdtenvio as date.
def var vhrenvio as int.
def var vdelimiter as char init ";".

def var vcep as char.


def var varqsai as char.

message today string(time,"HH:MM:SS") "gerando arquivos...".

for each bancarteira no-lock.

    find first banboleto where banboleto.bancod = bancarteira.bancod and
                         banboleto.agencia = bancarteira.agencia and
                         banboleto.contacor = bancarteira.contacor and
                         banboleto.bancart  = bancarteira.bancart and
        banboleto.dtenvio = ? and
        banboleto.situacao = "V"  /* #1 */
        no-lock no-error.

    if not avail banboleto
    then next.

    pause 1 no-message.
    
    vdtenvio = today.
    vhrenvio = time.
    varqsai = "envio" + string(bancarteira.banco,"999") + "_" +
            string(vdtenvio,"999999") + "_" + string(vhrenvio,"99999")
            + ".csv".

    varqsai = "/admcom/tmp/boleto/access/" +
              string(year(vdtenvio),"9999") +
              string(month(vdtenvio),"99") +
              string(day(vdtenvio),"99")   +
              "_" + 
              replace(string(vhrenvio,"HH:MM:SS"),":","") +
              "_" +
              "boleto_remessa.csv".
              
                                           
    message today string(time,"HH:MM:SS") "gerando " varqsai.

    output to value(varqsai).
    put unformatted 
         "Banco"
         vdelimiter
         "Agencia"
         vdelimiter
         "Conta"
         vdelimiter
         "Carteira"
         vdelimiter
         "cpf_cnpj"
         vdelimiter
         "Sacado"
         vdelimiter
         "Endereco"
         vdelimiter
         "Cidade"
         vdelimiter
         "Estado"
         vdelimiter
         "CEP"
         vdelimiter
         "NossoNumero"
         vdelimiter
         "DvNossoNumero"
         vdelimiter
         "NumeroDocumento"
         vdelimiter
         "Vencimento"
         vdelimiter
         "Valor"
         vdelimiter
         "Emissao"
         vdelimiter
         "LinhaDigitavel"
         vdelimiter
         "CodigoBarras"
         skip.
    
    for each banboleto  where
                         banboleto.agencia = bancarteira.agencia and
                         banboleto.contacor = bancarteira.contacor and
                         banboleto.bancart  = bancarteira.bancart and
        banboleto.dtenvio = ? and
        banboleto.situacao = "V"  /* #1 */
        
        exclusive.
        find banco of banboleto no-lock.
        find clien where clien.clicod = banboleto.clifor no-lock.

        vcep  = replace(clien.cep[1],".","").
        vcep  = replace(vcep,"-","").
        
    vcep = "92990000". /* CORONA 24/03/2020 */
    put unformatted 
         banco.numban
         vdelimiter
         banboleto.agencia
         vdelimiter
         banboleto.conta
         vdelimiter
         banboleto.bancart
         vdelimiter
         clien.ciccgc
         vdelimiter
         clien.clinom
         vdelimiter
         clien.endereco[1]
         vdelimiter
         clien.cidade[1]
         vdelimiter
         clien.ufecod[1]
         vdelimiter
         vcep
         vdelimiter
         banboleto.nossonumero
         vdelimiter
         banboleto.dvnossonumero
         vdelimiter
         string(int(banboleto.nossonumero))
         vdelimiter
         banboleto.dtvencimento format "99/99/9999"
         vdelimiter
         trim(string(banboleto.vlcobrado,">>>>>>>>>>>>9.99"))
         vdelimiter
         banboleto.dtemissao format "99/99/9999"
         vdelimiter
         banboleto.linhadigitavel
         vdelimiter
         banboleto.codigoBarras
         
         skip.
        banboleto.situacao = "P". /** Enviado */
        banboleto.dtenvio = vdtenvio.
        banboleto.hrenvio = vhrenvio.
    end.    
    output close.    

    message today string(time,"HH:MM:SS") "fechado" varqsai.


    
end.
    
message today string(time,"HH:MM:SS") "processo encerrado.".

