    
DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hconteudoEntrada     as handle.
def var hconteudoSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttRegrasCyberEntrada NO-UNDO  SERIALIZE-NAME "regrasCyberEntrada"
    FIELD codigoFilial as char
    index x is unique primary codigoFilial asc.
    
DEFINE DATASET conteudoEntrada FOR ttRegrasCyberEntrada.
hconteudoEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'regrasCyberSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    field cyberAtivo as char  serialize-name 'cyberAtivo'
    index inx is unique primary situacao asc.

DEFINE TEMP-TABLE ttregras NO-UNDO       serialize-name 'regras'
    FIELD chave as char     serialize-hidden  
    field regra   as char format "x(40)" serialize-name 'regra'
    index inx is unique primary chave asc regra.


DEFINE TEMP-TABLE ttregrasfilial NO-UNDO       serialize-name 'filiais'
    FIELD chave as char     serialize-hidden  
    field regra   as char format "x(40)" serialize-hidden  
    field filial  as char format "x(40)" serialize-name 'filial'
    index inx is unique primary chave asc regra asc filial asc.

DEFINE TEMP-TABLE ttparametros NO-UNDO       serialize-name 'parametros'
    FIELD chave as char     serialize-hidden  
    field regra   as char format "x(40)" serialize-hidden  
    field atributo as char format "x(40)" serialize-name 'atributo'
    field valor    as char format "x(40)" serialize-name 'valor'
    field parametroADMCOM  as char format "x(40)" serialize-name 'parametroAdmcom'
    index inx is unique primary chave asc regra asc atributo asc.

DEFINE TEMP-TABLE ttparametrosfilial NO-UNDO       serialize-name 'parametrosFilial'
    FIELD chave as char     serialize-hidden  
    field regra   as char format "x(40)" serialize-hidden  
    field atributo as char format "x(40)" serialize-hidden
    field filial  as char format "x(40)" serialize-name 'filial'
    field valor    as char format "x(40)" serialize-name 'valor'
    index inx is unique primary chave asc regra asc atributo asc filial asc.

DEFINE DATASET conteudoSaida FOR ttstatus, ttregras , ttregrasfilial, ttparametros , ttparametrosfilial
  DATA-RELATION relreg FOR ttstatus, ttregras 
        RELATION-FIELDS(ttstatus.chave,ttregras.chave) NESTED
  DATA-RELATION relfil FOR ttregras , ttregrasfilial
        RELATION-FIELDS(ttregras.chave   ,ttregrasfilial.chave,
                        ttregras.regra   ,ttregrasfilial.regra) NESTED
        
  DATA-RELATION relpard FOR ttregras, ttparametros 
        RELATION-FIELDS(ttregras.chave,ttparametros.chave,
                        ttregras.regra,ttparametros.regra) NESTED
  DATA-RELATION relparfil FOR ttparametros , ttparametrosfilial
        RELATION-FIELDS(ttparametros.chave   ,ttparametrosfilial.chave,
                        ttparametros.regra   ,ttparametrosfilial.regra,
                        ttparametros.atributo,ttparametrosfilial.atributo) NESTED
                        .

hconteudosaida = DATASET conteudosaida:HANDLE.

