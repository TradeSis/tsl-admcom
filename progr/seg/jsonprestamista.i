/* helio 20012022 - [UNIFICAÇO ZURICH - FASE 2] NOVO CÁCULO PARA SEGURO PRESTAMISTA MÓEIS NA PRÉVENDA */

def var hEntrada     as handle.
def var hSAIDA            as handle.

DEFINE {1} shared TEMP-TABLE ttpedidoCartaoLebes NO-UNDO SERIALIZE-NAME "pedidoCartaoLebes"
    field id as char serialize-hidden
    FIELD   codigoLoja          as char 
    FIELD   dataTransacao as char 
    FIELD   numeroComponente as char 
    FIELD   codigoVendedor as char 
    FIELD   codigoOperador as char 
    FIELD   valorTotal as char 
    FIELD   codigoCliente as char 
    FIELD   cpfCnpjCliente as char.

DEFINE {1} shared TEMP-TABLE ttcartaoLebes NO-UNDO SERIALIZE-NAME "cartaoLebes"
    field idpai as char serialize-hidden
    FIELD   cartaoLebes as char 
    FIELD   qtdParcelas as char
    FIELD   valorEntrada as char 
    FIELD   valorAcrescimo as char 
    FIELD   dataPrimeiroVencimento as char
    FIELD   dataUltimoVencimento as char 
    FIELD   vendaTerceiros as char.

DEFINE {1} shared TEMP-TABLE ttparcelas NO-UNDO SERIALIZE-NAME "parcelas"
    field idpai as char serialize-hidden
    field seqParcela as char 
    field valorParcela as char
    field dataVencimento as char.

DEFINE {1} shared TEMP-TABLE ttprodutos NO-UNDO SERIALIZE-NAME "produtos"
    field idpai as char serialize-hidden
    field codigoProduto as char
    field codigoMercadologico as char
    field quantidade as char
    field valorTotal as char 
    field valorUnitario as char 
    field valorTotalDesconto as char.
    

DEFINE DATASET dadosEntrada FOR ttpedidoCartaoLebes, ttcartaoLebes, ttparcelas, ttprodutos
    DATA-RELATION for1 FOR ttpedidoCartaoLebes, ttcartaoLebes      RELATION-FIELDS(ttpedidoCartaoLebes.id,ttcartaoLebes.idpai) NESTED
    DATA-RELATION for2 FOR ttpedidoCartaoLebes, ttparcelas         RELATION-FIELDS(ttpedidoCartaoLebes.id,ttparcelas.idpai) NESTED
    DATA-RELATION for3 FOR ttpedidoCartaoLebes, ttprodutos         RELATION-FIELDS(ttpedidoCartaoLebes.id,ttprodutos.idpai) NESTED.


DEFINE {1} shared TEMP-TABLE ttsegprestpar NO-UNDO SERIALIZE-NAME "parametros"
    field id as char serialize-hidden
    field codigoSeguroPrestamista as char
    field valorTotalSeguroPrestamista as char
    field elegivel as char
    field campanhaGratis    as char
    field valorSeguroPrestamistaEntrada as char .

DEFINE {1} shared TEMP-TABLE ttsaidaparcelas NO-UNDO SERIALIZE-NAME "parcelas"
    field idPai as char serialize-hidden
    field seqParcela as char 
    field valorParcela as char
    field dataVencimento as char
    field valorSeguroRateado as char.

DEFINE DATASET dadosSaida FOR ttsegprestpar, ttsaidaparcelas
    DATA-RELATION for1 FOR ttsegprestpar, ttsaidaparcelas         RELATION-FIELDS(ttsegprestpar.id,ttsaidaparcelas.idpai) NESTED.

hentrada = DATASET dadosEntrada:HANDLE.
hsaida   = DATASET dadosSaida:HANDLE.

