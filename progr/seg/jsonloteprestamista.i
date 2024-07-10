/* helio 20012022 - [UNIFICAÇO ZURICH - FASE 2] NOVO CÁCULO PARA SEGURO PRESTAMISTA MÓEIS NA PRÉVENDA */

def var hEntrada     as handle.
def var hSAIDA            as handle.

DEFINE {1} shared TEMP-TABLE ttpedidoCartaoLebes NO-UNDO SERIALIZE-NAME "pedidoCartaoLebes"
    field id as char serialize-hidden
    FIELD   codigoLoja          as char 
    FIELD   valorTotal as char. 

DEFINE {1} shared TEMP-TABLE ttparcelas NO-UNDO SERIALIZE-NAME "parcelas"
    field idpai as char serialize-hidden
    field fincod    as char
    field qtdParcelas as char 
    FIELD valorEntrada as char
    field valorParcela as char
    field valorAcrescimo as char.

DEFINE {1} shared TEMP-TABLE ttprodutos NO-UNDO SERIALIZE-NAME "produtos"
    field idpai as char serialize-hidden
    field codigoProduto as char.
    

DEFINE DATASET dadosEntrada FOR ttpedidoCartaoLebes, ttparcelas, ttprodutos
    DATA-RELATION for2 FOR ttpedidoCartaoLebes, ttparcelas         RELATION-FIELDS(ttpedidoCartaoLebes.id,ttparcelas.idpai) NESTED
    DATA-RELATION for3 FOR ttpedidoCartaoLebes, ttprodutos         RELATION-FIELDS(ttpedidoCartaoLebes.id,ttprodutos.idpai) NESTED.


DEFINE {1} shared TEMP-TABLE ttsegprestpar NO-UNDO SERIALIZE-NAME "parametros"
    field id as char serialize-hidden
    field codigoSeguroPrestamista as char
    field valorTotalSeguroPrestamista as char
    field elegivel as char
    field campanhaGratis as char
    field valorSeguroPrestamistaEntrada as char .

DEFINE {1} shared TEMP-TABLE ttsaidaparcelas NO-UNDO SERIALIZE-NAME "parcelas"
    field idPai as char serialize-hidden
    field qtdParcelas as char 
    field valorParcela as char
    field valorSeguroRateado as char.

DEFINE DATASET dadosSaida FOR ttsegprestpar, ttsaidaparcelas
    DATA-RELATION for1 FOR ttsegprestpar, ttsaidaparcelas         RELATION-FIELDS(ttsegprestpar.id,ttsaidaparcelas.idpai) NESTED.

hentrada = DATASET dadosEntrada:HANDLE.
hsaida   = DATASET dadosSaida:HANDLE.

