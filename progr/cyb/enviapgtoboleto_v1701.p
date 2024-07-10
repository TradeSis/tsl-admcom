/* Gestao de Boletos   - batchs
   cyb/enviapgtoboleto_v1701.p
    Envia para o CYBER as efetivacoes/pagamentos por Boleto
*/


{cabec.i new}

def var vqtdreg as int.
def var vdtenvio as date.
def var vhrenvio as int.

message today string(time,"HH:MM:SS") "Verifica Parcelas de Acordo".

find first cybacparcela where cybacparcela.situacao = "B" and
                              cybacparcela.dtenvio  = ?
    no-lock no-error.

if not avail cybacparcela then return.    

    vdtenvio = today.
    vhrenvio = time.
    
    varqsai = "/admcom/tmp/boleto/cyber/" +
              string(year(vdtenvio),"9999") +
              string(month(vdtenvio),"99") +
              string(day(vdtenvio),"99")   +
              "_" + 
              replace(string(vhrenvio,"HH:MM:SS"),":","") +
              "_" +
              "pagboleto_in.txt".
              /** "pagamento_boleto_out.txt". **/
              

message today string(time,"HH:MM:SS") "Gerando" varqsai.

              

output to value(varqsai).

    put unformatted 
    "H"                     format "x(01)"
    "CYBER"                 format "x(08)"
    "PAGAMENTO_DE_BOLETO"   format "x(30)"
    string(month(vdtenvio),"99") +
     string(day(vdtenvio),"99")   +
      string(year(vdtenvio),"9999") format "x(08)"
    "0000000000"            format "x(10)"
    " "                     forma "x(18)"
    skip.

    vqtdreg = 1.

for each cybacparcela where cybacparcela.situacao = "B" and
                            cybacparcela.dtenvio  = ?.


    find first banbolOrigem  where 
        banbolorigem.tabelaOrigem = "cybacparcela" and 
        banbolorigem.chaveOrigem  = "idacordo,parcela" and         
        banbolorigem.dadosOrigem  = string(cybacparcela.idacordo) + "," +
                                    string(cybacparcela.parcela)
            no-lock no-error.
    if not avail banbolorigem
    then next.

    find banboleto of banbolorigem no-lock.
    if banboleto.dtpagamento = ?
    then next.
    
    put unformatted
        cybacparcela.idacordo format "9999999999999"
        string(banboleto.nossonumero,"99999999") format "x(24)"  /** alterado em 270917 de impnoss~ onumero* x(25) */ 
        banboleto.dvnossonumero format "9"
        
    string(month(banboleto.dtPagamento),"99") +
     string(day(banboleto.dtPagamento),"99")   +
      string(year(banboleto.dtPagamento),"9999") format "x(08)"

    string(month(cybacparcela.dtbaixa),"99") +
     string(day(cybacparcela.dtbaixa),"99")   +
      string(year(cybacparcela.dtbaixa),"9999") format "x(08)"
        
        cybacparcela.vlCobrado * 100 format "9999999999999999" 
        cybacparcela.parcela format "99999"
    skip.
    
    vqtdreg = vqtdreg + 1.

    cybacparcela.dtenvio = today.

    
end.    

    put unformatted 
    "T"                     format "x(01)"
    string(month(vdtenvio),"99") +
     string(day(vdtenvio),"99")   +
      string(year(vdtenvio),"9999") format "x(08)"
    vqtdreg                 format "9999999999"
    "0000000000"            format "x(10)"
    " "                     forma "x(46)"
    skip.


output close.

message today string(time,"HH:MM:SS") "Processo encerrado.".


