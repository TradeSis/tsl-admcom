/* Gestao de Boletos   - batchs
   bol/envianextboleto_v1701.p
    Envia para o CYBER as proximo vencimento de Boleto
*/



{cyb/cybcab.i}

def shared var v-today as date.
def shared var v-time as int.


def var vqtdreg as int.

def var par-tabelaorigem as char.
def var par-chaveorigem as char.
def var par-dadosorigem as char.
def var par-valorOrigem  as dec.


def var vstatus as char.
def var vmensagem_erro as char.

def var par-recid-boleto as recid.

message v-today string(time,"HH:MM:SS") "Verifica Parcelas de Acordo".

find first cybacparcela where cybacparcela.situacao =  "ENVIARBOLETO" 
    no-lock no-error.

if not avail cybacparcela then return.    


    /** retirado 24.10
    vdtenvio = today.
    vhrenvio = time.
    
    varqsai = "/admcom/tmp/boleto/cyber/" + 
              string(year(vdtenvio),"9999") +
              string(month(vdtenvio),"99") +
              string(day(vdtenvio),"99")   +
              "_" + 
              replace(string(vhrenvio,"HH:MM:SS"),":","") +
              "_" +
              "boleto_in.txt".
              /**"boleto_out.txt".**/
    **/          
        
        
{cyb/arquivo.i ""boleto""}


message v-today string(v-time,"HH:MM:SS") "Gerando" varq.

output to value(varq).

    put unformatted 
    "H"                     format "x(01)"
    "CYBER"                 format "x(08)"
    "BOLETO"   format "x(30)"
    string(month(v-today),"99") +
     string(day(v-today),"99")   +
      string(year(v-today),"9999") format "x(08)"
    "0000000000"            format "x(10)"
    " "                     forma "x(18)"
    skip.

    vqtdreg = 1.


for each cybacparcela where cybacparcela.situacao  =  "ENVIARBOLETO".

    find cybacordo of cybacparcela no-lock.

            
    find first banbolOrigem  where 
        banbolorigem.tabelaOrigem = "cybacparcela" and 
        banbolorigem.chaveOrigem  = "idacordo,parcela" and         
        banbolorigem.dadosOrigem  = string(cybacparcela.idacordo) + "," +
                                    string(cybacparcela.parcela)
            no-lock no-error.
    if not avail banbolorigem
    then do:
        run bol/geradadosboleto_v1701.p (
                        input ?, /* Banco do Boleto */
                    input ?,      /* Bancarteira especifico */
                    input "CyberProximo",
                    input cybacordo.clifor,
                    input string(cybacordo.idacordo) + "/" +
                            string(cybacparcela.parcela),
                    input cybacparcela.dtvencimento,
                    input cybacparcela.vlcobrado,
                    output par-recid-boleto,
                    output vstatus,
                    output vmensagem_erro).



        find banBoleto where recid(banBoleto) = par-recid-boleto no-lock
            no-error.
        if vstatus = "S" and avail banBoleto
        then do: 
            par-tabelaorigem = "cybacparcela".
            par-chaveOrigem  = "idacordo,parcela".
            par-dadosOrigem  = string(cybacordo.idacordo) + "," +
                               string(cybacparcela.parcela).
            par-valorOrigem  = cybacparcela.vlcobrado.
         
            run bol/vinculaboleto_v1701.p (
                        input recid(banBoleto),
                        input par-tabelaorigem,
                        input par-chaveorigem,
                        input par-dadosorigem,
                        input par-valorOrigem,
                        output vstatus,
                        output vmensagem_erro).
        end.
    end.
    
    find first banbolOrigem  where 
        banbolorigem.tabelaOrigem = "cybacparcela" and 
        banbolorigem.chaveOrigem  = "idacordo,parcela" and         
        banbolorigem.dadosOrigem  = string(cybacparcela.idacordo) + "," +
                                    string(cybacparcela.parcela)
            no-lock no-error.
    if not avail banbolorigem
    then next.

    find banboleto of banbolorigem no-lock.

    find clien where clien.clicod = cybacordo.clifor no-lock.
    
    put unformatted
        cybacparcela.idacordo format "9999999999999"
        "CEDENTE"   format "x(150)"
        string(banboleto.nossonumero,"99999999") format "x(24)"  /** alterado em 270917 de impnoss~ onumero*/ 
        banboleto.dvnossonumero format "9"
        
    string(month(banboleto.dtVencimento),"99") +
     string(day(banboleto.dtVencimento),"99")   +
      string(year(banboleto.dtVencimento),"9999") format "x(08)"

        banboleto.vlCobrado * 100 format "9999999999999999"   
        string(month(today),"99") +
         string(day(today),"99")   +
          string(year(today),"9999") format "x(08)"

        string(cybacparcela.idacordo) + "/" + 
        string(cybacparcela.parcela) format "x(25)"
        string(month(today),"99") +
         string(day(today),"99")   +
          string(year(today),"9999") format "x(08)"
        
        banboleto.linhadigitavel format "x(80)"
        banboleto.codigobarras format "x(80)"
        cybacparcela.parcela format "99999"
        clien.clinom format "x(80)"
        clien.endereco[1] format "x(80)"
        "BAIRRO" format "x(80)"
        clien.cep[1] format "x(10)"
        "CIDADE" format "x(50)"
        clien.ufecod[1] format "x(5)"
        string(banboleto.agencia) format "x(20)"
        string(banboleto.conta)   format "x(20)"
        "" format "x(1)"
        1 format "99999"
        "" format "x(80)"
        "" format "x(80)"
        "" format "x(80)"
        "" format "x(80)"
        "" format "x(80)"
        "" format "x(80)"
        "" format "x(60)"
        skip. 
        
    cybacparcela.situacao = "E".
    vqtdreg = vqtdreg + 1.
    
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



