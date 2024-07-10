DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var havisopagamentotedEntrada     as handle.
def var havisopagamentotedSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttavisopagamentotedEntrada NO-UNDO SERIALIZE-NAME "avisoPagamentoTedEntrada"
    FIELD codigo_cpfcnpj    as char
    field banco             as char
    field idted             as char
    index x is unique primary codigo_cpfcnpj asc.

DEFINE TEMP-TABLE ttparcelasEntrada NO-UNDO SERIALIZE-NAME "parcelas"
    FIELD codigo_cpfcnpj    as char
    field numero_contrato   as char
    field seq_parcela       as char
    field venc_parcela      as char
    field vlr_parcela_pago  as char
    index x is unique primary codigo_cpfcnpj asc numero_contrato asc seq_parcela asc.

    
DEFINE DATASET conteudoEntrada FOR ttavisopagamentotedEntrada, ttparcelasEntrada
  DATA-RELATION boletoPar FOR ttavisopagamentotedEntrada, ttparcelasEntrada
        RELATION-FIELDS(ttavisopagamentotedEntrada.codigo_cpfcnpj,ttparcelasEntrada.codigo_cpfcnpj) NESTED.

havisopagamentotedEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'avisoPagamentoTedSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE DATASET conteudoSaida FOR ttstatus.

havisopagamentotedSaida = DATASET conteudoSaida:HANDLE.

