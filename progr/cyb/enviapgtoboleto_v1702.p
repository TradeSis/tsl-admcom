/* Gestao de Boletos   - batchs
   cyb/enviapgtoboleto_v1701.p
    Envia para o CYBER as efetivacoes/pagamentos por Boleto
*/


{cyb/cybcab.i}

def shared var v-today as date.
def shared var v-time as int.


def var vqtdreg as int.

message v-today string(time,"HH:MM:SS") "Verifica Parcelas de Acordo".

find first cybacparcela where cybacparcela.situacao = "B" and
                              cybacparcela.dtenvio  = ?
    no-lock no-error.

if not avail cybacparcela then return.    

    
    /** retirado 24.10
        varqsai = "/admcom/tmp/boleto/cyber/" +
              string(year(vdtenvio),"9999") +
              string(month(vdtenvio),"99") +
              string(day(vdtenvio),"99")   +
              "_" + 
              replace(string(vhrenvio,"HH:MM:SS"),":","") +
              "_" +
              "pagboleto_in.txt".
              /** "pagamento_boleto_out.txt". **/
        **/

        
{cyb/arquivo.i ""pagboleto""}

message today string(time,"HH:MM:SS") "Gerando" varq.

              

output to value(varq).

    put unformatted 
    "H"                     format "x(01)"
    "CYBER"                 format "x(08)"
    "PAGAMENTO_DE_BOLETO"   format "x(30)"
    string(month(v-today),"99") +
     string(day(v-today),"99")   +
      string(year(v-today),"9999") format "x(08)"
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
    string(month(v-today),"99") +
     string(day(v-today),"99")   +
      string(year(v-today),"9999") format "x(08)"
    vqtdreg                 format "9999999999"
    "0000000000"            format "x(10)"
    " "                     forma "x(46)"
    skip.


output close.

message v-today string(time,"HH:MM:SS") "Processo encerrado.".


