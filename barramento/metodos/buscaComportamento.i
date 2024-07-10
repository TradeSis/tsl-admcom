DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hcomportamentoEntrada     as handle.
def var hcomportamentoCliente            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttComportamentoEntrada NO-UNDO SERIALIZE-NAME "comportamentoEntrada"
    FIELD cpfCNPJ as char
    index x is unique primary cpfCNPJ asc.
    
DEFINE DATASET conteudoEntrada FOR ttComportamentoEntrada.
hcomportamentoEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'comportamentoSaida'
    FIELD cpfCNPJ as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE TEMP-TABLE ttclien NO-UNDO       serialize-name 'Cliente'
    field cpfCNPJ    as char format "x(18)"    serialize-name 'cpfCNPJ'
    field clinom    as char format "x(40)" serialize-name 'nomeCliente'
    field clicod    as char format "x(12)" serialize-name 'codigoCliente'
    index cli is unique primary clicod asc.

DEFINE TEMP-TABLE ttcredito NO-UNDO   serialize-name 'creditoCliente'
    field clicod        as char format "x(12)" serialize-hidden
    field limite      as char format "x(20)"    
    field vctoLimite  as char format "x(30)"  
    field comprometido as char format "x(30)"
    field saldoLimite  as char format "x(30)"
    field tempoRelacionamento as char
    index cli is unique primary clicod asc .
    
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
    
DEFINE DATASET conteudoSaida FOR ttstatus, ttclien, ttcredito, ttmodalComportamento ,ttcomportamento
  DATA-RELATION sitcli FOR ttstatus, ttclien 
        RELATION-FIELDS(ttstatus.cpfcnpj,ttclien.cpfcnpj) NESTED
  DATA-RELATION clicred FOR ttclien, ttcredito 
        RELATION-FIELDS(ttclien.clicod,ttcredito.clicod) NESTED
  DATA-RELATION cliprofin FOR ttclien, ttmodalComportamento 
        RELATION-FIELDS(ttclien.clicod,ttmodalComportamento.clicod) NESTED
        
  DATA-RELATION clicomp FOR ttclien, ttcomportamento 
        RELATION-FIELDS(ttclien.clicod,ttcomportamento.clicod) NESTED.

hcomportamentoCliente = DATASET conteudoSaida:HANDLE.

