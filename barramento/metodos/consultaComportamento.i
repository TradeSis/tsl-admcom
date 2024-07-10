DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hcomportamentoEntrada     as handle.
def var hcomportamentoCliente            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttComportamentoEntrada NO-UNDO SERIALIZE-NAME "clienteEntrada"
    FIELD codigo_cpfcnpj as char
    index x is unique primary codigo_cpfcnpj asc.
    
DEFINE DATASET conteudoEntrada FOR ttComportamentoEntrada.
hcomportamentoEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'comportamentoSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE TEMP-TABLE ttclien NO-UNDO       serialize-name 'Cliente'
    field chave    as char format "x(18)"   serialize-hidden
    field clicod    as char format "x(12)" serialize-name 'codigoCliente'
    field tempoRelacionamento as char
    index cli is unique primary clicod asc.

DEFINE TEMP-TABLE ttmodalComportamento NO-UNDO   serialize-name 'comportamentoModalidade'
    field clicod        as char format "x(12)" serialize-hidden
    field modcod        as char serialize-name  'modcod'
    field comprometido  as char
    field dcomprometido  as dec  serialize-hidden
    index cli is unique primary clicod asc modcod asc .
    
    
DEFINE TEMP-TABLE ttcomportamento NO-UNDO   serialize-name 'comportamentoCliente'
    field clicod        as char format "x(12)"
            serialize-hidden
    field atributo      as char format "x(20)"     
            serialize-name 'atributo' 
    field valorAtributo as char format "x(30)"     
            serialize-name 'valorAtributo' 
    index cli is unique primary clicod asc atributo asc.
    
DEFINE DATASET conteudoSaida FOR ttstatus, ttclien, ttmodalComportamento ,ttcomportamento
  DATA-RELATION sitcli FOR ttstatus, ttclien 
        RELATION-FIELDS(ttstatus.chave,ttclien.chave) NESTED
  DATA-RELATION cliprofin FOR ttclien, ttmodalComportamento 
        RELATION-FIELDS(ttclien.clicod,ttmodalComportamento.clicod) NESTED
  DATA-RELATION clicomp FOR ttclien, ttcomportamento 
        RELATION-FIELDS(ttclien.clicod,ttcomportamento.clicod) NESTED.

hcomportamentoCliente = DATASET conteudoSaida:HANDLE.

