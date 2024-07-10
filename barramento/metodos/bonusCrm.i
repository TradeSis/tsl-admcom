DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hBonusCrmEntrada     as handle.
def var hBonusCrmSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttBonusCrmEntrada NO-UNDO SERIALIZE-NAME "BonusCrm"
    FIELD numero          as char
    field codigoCliente   as char
    field CPF        as char
    field codigoLoja      as char
    field dataEmisao      as char
    field descricao       as char
    field valor           as char
    field vencimento      as char
    field pstatus          as char serialize-name 'status'
    field dataUtilizacao  as char   
    index x is unique primary codigoCliente asc.
    
DEFINE DATASET conteudoEntrada FOR ttBonusCrmEntrada.
hBonusCrmEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttbonus NO-UNDO serialize-name 'BonusCrmSaida'
    FIELD numero          as char
    field codigoCliente   as char
    field CPF        as char

    field codigoLoja      as char
    field dataEmisao      as char
    field descricao       as char
    field valor           as char
    field vencimento      as char
    field pstatus          as char serialize-name 'status'
    field dataUtilizacao  as char   
    index cli is unique primary numero asc.



DEFINE DATASET conteudoSaida FOR ttbonus.

hBonusCrmSaida = DATASET conteudoSaida:HANDLE.

