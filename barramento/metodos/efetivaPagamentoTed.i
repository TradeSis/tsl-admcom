DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hefetivaPagamentoTedEntrada     as handle.
def var hefetivaPagamentoTedSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttefetivaPagamentoTedEntrada NO-UNDO SERIALIZE-NAME "efetivaPagamentoTedEntrada"
    FIELD codigo_cpfcnpj    as char
    field banco             as char
    field idted             as char
    field dtefetivacao      as char
    field statusted         as char
    index x is unique primary codigo_cpfcnpj asc.
          
DEFINE DATASET conteudoEntrada FOR ttefetivaPagamentoTedEntrada.

hefetivaPagamentoTedEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'efetivaPagamentoTedSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE DATASET conteudoSaida FOR ttstatus.

hefetivaPagamentoTedSaida = DATASET conteudoSaida:HANDLE.

