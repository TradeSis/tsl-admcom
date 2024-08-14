DEFINE {1} shared TEMP-TABLE ttpedidoCartaoLebes NO-UNDO SERIALIZE-NAME "pedidoCartaoLebes"
    field id as char serialize-hidden
    FIELD   formatoTermo          as char 
    FIELD   tipoOperacao          as char 
    FIELD   codigoLoja          as char 
    FIELD   dataTransacao          as char 
    FIELD   codigoCliente          as char 
    FIELD   idBiometria as char 
    FIELD   neuroIdOperacao as char 
    FIELD   codigoProdutoFinanceiro as char 
    FIELD   valorEmprestimo as char 
    FIELD   codigoVendedor as char 
    FIELD   codigoOperador as char 
    FIELD   valorTotal as char. 

    
DEFINE {1} shared TEMP-TABLE ttrecebimentos NO-UNDO SERIALIZE-NAME "recebimentos"
    field idpai as char serialize-hidden
    field formaPagamento as char 
    field codigoPlano as char
    field valorPago as char
    field seqForma as char.

DEFINE {1} shared TEMP-TABLE ttcartaoLebes NO-UNDO SERIALIZE-NAME "cartaoLebes"
    field idpai as char serialize-hidden
    FIELD   seqForma as char
    FIELD   numeroContrato as char 
    FIELD   contratoFinanceira as char 
    FIELD   cet as char
    FIELD   cetAno as char 
    FIELD   taxaMes as char  
    field   valorIof as char
    field   qtdParcelas as char
    field   valorTFC as char
    field   valorAcrescimo as char.
            
            

DEFINE {1} shared TEMP-TABLE ttparcelas NO-UNDO SERIALIZE-NAME "parcelas"
    field idpai as char serialize-hidden
    field seqParcela as char 
    field valorParcela as char
    field dataVencimento as char.


DEFINE {1} shared TEMP-TABLE ttseguroprestamista NO-UNDO SERIALIZE-NAME "seguroprestamista"
    field idpai as char serialize-hidden
    field numeroApoliceSeguroPrestamista as char
    field numeroSorteioSeguroPrestamista as char
    field codigoSeguroPrestamista as char
    field valorSeguroPrestamista as char
    field dataInicioVigencia as char
    field dataFimVigencia as char.

DEFINE {1} shared TEMP-TABLE ttcontratosrenegociados NO-UNDO SERIALIZE-NAME "contratosrenegociados"
    field idpai as char serialize-hidden
    field contratoRenegociado as char
    field valorRenegociado as char.


DEFINE {1} shared TEMP-TABLE ttprodutos NO-UNDO SERIALIZE-NAME "produtos"
    field idpai as char serialize-hidden
    field codigoProduto as char
    field codigoMercadologico as char
    field quantidade as char
    field valorTotal as char 
    field valorUnitario as char 
    field valorTotalDesconto as char
    field tipoProduto as char.
    

DEFINE DATASET dadosEntrada FOR ttpedidoCartaoLebes, ttrecebimentos, ttcartaoLebes, ttparcelas, ttseguroprestamista, ttcontratosrenegociados, ttprodutos
    DATA-RELATION for1 FOR ttpedidoCartaoLebes, ttrecebimentos      RELATION-FIELDS(ttpedidoCartaoLebes.id,ttrecebimentos.idpai) NESTED
    DATA-RELATION for2 FOR ttpedidoCartaoLebes, ttcartaoLebes      RELATION-FIELDS(ttpedidoCartaoLebes.id,ttcartaoLebes.idpai) NESTED
    DATA-RELATION for3 FOR ttcartaoLebes, ttparcelas               RELATION-FIELDS(ttcartaoLebes.id,ttparcelas.idpai) NESTED
    DATA-RELATION for4 FOR ttcartaoLebes, ttseguroprestamista      RELATION-FIELDS(ttcartaoLebes.id,ttseguroprestamista.idpai) NESTED
    DATA-RELATION for5 FOR ttpedidoCartaoLebes, ttcontratosrenegociados RELATION-FIELDS(ttpedidoCartaoLebes.id,ttcontratosrenegociados.idpai) NESTED
    DATA-RELATION for6 FOR ttpedidoCartaoLebes, ttprodutos         RELATION-FIELDS(ttpedidoCartaoLebes.id,ttprodutos.idpai) NESTED.
                                
                    
def temp-table ttreturn no-undo serialize-name "return"
    field sequencial as char
    field tipo    as char
    field termoBase64 as char
    field quantidadeVias  as char
    field formato    as char.