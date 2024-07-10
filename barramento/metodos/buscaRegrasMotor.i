    
DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hRegrasMotorEntrada     as handle.
def var hRegrasMotor            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttRegrasMotorEntrada NO-UNDO SERIALIZE-NAME "RegrasMotorEntrada"
    FIELD codigoFilial as char
    index x is unique primary codigoFilial asc.
    
DEFINE DATASET conteudoEntrada FOR ttRegrasMotorEntrada.
hRegrasMotorEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'RegrasMotorSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    field motorAtivo as char  serialize-name 'motorAtivo'
    index inx is unique primary situacao asc.

DEFINE TEMP-TABLE ttfilial NO-UNDO       serialize-name 'Filiais'
    FIELD chave as char     serialize-hidden  
    field codigoFilial  as char format "x(40)" serialize-name 'codigoFilial'
    field grupo  as char format "x(40)" serialize-name 'grupo'
    index inx is unique primary chave asc codigoFilial asc.
    
DEFINE TEMP-TABLE ttgrupos NO-UNDO       serialize-name 'Grupos'
    FIELD chave as char     serialize-hidden  
    field grupo   as char format "x(40)" serialize-name 'grupo'
    field grupoNome   as char format "x(40)" serialize-name 'grupoNome'
    index inx is unique primary chave asc grupo.

DEFINE TEMP-TABLE ttgruposregras NO-UNDO       serialize-name 'Regras'
    FIELD chave as char     serialize-hidden  
    field grupo   as char format "x(40)" serialize-hidden  
    field politica      as char format "x(40)" serialize-name 'politica'
    field politicaNome  as char format "x(40)" serialize-name 'politicaNome'
    
    index inx is unique primary chave asc grupo asc politica asc.
    

DEFINE TEMP-TABLE ttgrupospolitica NO-UNDO       serialize-name 'Parametros'
    FIELD chave as char     serialize-hidden  
    field grupo   as char format "x(40)" serialize-hidden  
    field politica      as char format "x(40)" serialize-hidden  
    field Parametro     as char format "x(40)" serialize-name 'parametro'
    field atributo      as char format "x(40)" serialize-name 'atributo'
    field condicao      as char format "x(40)" serialize-name 'condicao'
    field Valor         as char format "x(40)" serialize-name 'valor'
    field Submete       as char format "x(40)" serialize-name 'submete'
    index inx is unique primary chave asc grupo asc politica asc Parametro asc.
    

DEFINE DATASET conteudoSaida FOR ttstatus, ttfilial, ttgrupos, ttgruposregras, ttgruposPolitica
  DATA-RELATION sitfil FOR ttstatus, ttfilial 
        RELATION-FIELDS(ttstatus.chave,ttfilial.chave) NESTED
  DATA-RELATION filreg FOR ttstatus, ttgrupos 
        RELATION-FIELDS(ttstatus.chave,ttgrupos.chave) NESTED
  DATA-RELATION filreg FOR ttgrupos, ttgruposregras 
        RELATION-FIELDS(ttgrupos.chave,ttgruposregras.chave,
                        ttgrupos.grupo,ttgruposregras.grupo) NESTED
  DATA-RELATION regpol FOR ttgruposregras, ttgrupospolitica 
        RELATION-FIELDS(ttgruposregras.chave,ttgrupospolitica.chave,
                        ttgruposregras.grupo,ttgrupospolitica.grupo,
                        ttgruposregras.politica,ttgrupospolitica.politica)
                        NESTED.

hRegrasMotor = DATASET conteudoSaida:HANDLE.


