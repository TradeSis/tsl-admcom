

def {1} shared temp-table ttdados  no-undo serialize-name "dados"
      field empresa as char init "01" 
      field agencia as char init "0001" 
      field lojista as char init "000001" 
      field loja as char
/*      field dataInicio as char /*"2021-10-05 16:21:41", */ */
      field dataPrimeiroVencimento as char /*"2021-11-05 20:21:41.306", */
      field produto as char init "000001" 
      field plano as char
      field prazo as int
      field valorSolicitado as dec
      field valorParcela as dec
      field valorSeguro as dec
      field taxa as dec
      field valorTfc as dec
      field prazoMin as dec init 0 
      field prazoMax as dec init 0
      field numeroContrato  as char.
                                
def {1} shared temp-table ttreturn  no-undo serialize-name "return"
    field prazo as int
    field valorSolicitado as dec
    field valorParcela as dec
    field valorTAC as dec
    field valorTFC as dec
    field valorPST as dec
    field valorSeguro as dec
    field valorIOF as dec
    field valorIOFNormal as dec
    field valorIOFAdicional as dec
    field valorFinanciadoTotal as dec
    field taxaMes as dec
    field taxaAno as dec
    field cetMes as dec
    field cetAno as dec
    field dataEmissao as char   /*"2021-10-06T00:00:00", */
    field dataPrimeiroVencimento as char /*"2021-11-06T00:00:00" */ 
    field valorTotalAPrazo as dec.
                    
def {1} shared temp-table tttoken no-undo serialize-name "token"
    field username as char
    field access_token as char
    field expires_in as int.
                    
    
DEFINE DATASET retorno FOR tttoken, ttreturn.    
