DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hconteudoEntrada        as handle.
def var hconteudoSaida           as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttprofinCondicoesEntrada NO-UNDO SERIALIZE-NAME "profinCondicoesEntrada"
    FIELD codigoFilial   as char
    field codigoProfin   as char
    index x is unique primary codigofilial asc codigoProfin.
          
DEFINE DATASET conteudoEntrada FOR ttprofinCondicoesEntrada.

hconteudoEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'profinCondicoesSaida'
    FIELD chave as char     serialize-hidden  
    field codigoProfin   as char
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE TEMP-TABLE ttprofincond no-undo  serialize-name 'condicoes'
    FIELD chave as char     serialize-hidden  
    field pfincod    as char  serialize-hidden      
    FIELD fincod    as char  serialize-name  'codPlano'
    field finnom    as char   serialize-name  'descricaoPlano'
    field finnpc    as char  serialize-name  'qtdParcelas'
    field finfat    as char   serialize-name  'fatorJuros'
    field txjurosmes   as char   serialize-name  'taxaJuros'
    field favorito  as char
    index cli is unique primary chave asc pfincod asc fincod asc.

DEFINE DATASET conteudoSaida FOR ttstatus, ttprofincond
  DATA-RELATION finplan FOR ttstatus, ttprofincond
        RELATION-FIELDS(ttstatus.chave,ttprofincond.chave) NESTED.
        

hconteudoSaida = DATASET conteudoSaida:HANDLE.

