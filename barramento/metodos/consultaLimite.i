DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hclienteEntrada     as handle.
def var hclienteSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttclienteEntrada NO-UNDO SERIALIZE-NAME "clienteEntrada"
    FIELD codigo_cpfcnpj as char
    index x is unique primary codigo_cpfcnpj asc.
    
DEFINE DATASET conteudoEntrada FOR ttclienteEntrada.
hclienteEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'creditoCliente'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE TEMP-TABLE ttclien NO-UNDO       serialize-name 'cliente'
    field chave    as char format "x(18)"  serialize-hidden
    field clicod    as char format "x(12)" serialize-name 'codigoCliente'
    field limite      as char format "x(20)"    
    field vctoLimite  as char format "x(30)"  
    index cli is unique primary clicod asc.

DEFINE DATASET conteudoSaida FOR ttstatus, ttclien
  DATA-RELATION sitcli FOR ttstatus, ttclien 
        RELATION-FIELDS(ttstatus.chave,ttclien.chave) NESTED.

hclienteSaida = DATASET conteudoSaida:HANDLE.

