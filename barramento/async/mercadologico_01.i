DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hmercadologicoEntrada          as handle.
def var hmercadologicoSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttmercadologico NO-UNDO SERIALIZE-NAME "mercadologico"    
    field chave as char serialize-hidden initial ?
    index x is unique primary chave asc.

DEFINE TEMP-TABLE ttarvore NO-UNDO SERIALIZE-NAME "arvore"
    field chave as char serialize-hidden initial ?
       field nivel as char 
       field descricaoNivel as char
       field codigo as char
       field descricao as char
       field ativo as char
       field dataCadastro as char
       field codigoSuperior as char
        index x is unique primary chave asc nivel asc.
    
DEFINE DATASET mercadologicoEntrada FOR ttmercadologico, ttarvore
/*  DATA-RELATION for1 FOR ttmercadologico, ttarvore
        RELATION-FIELDS(ttmercadologico.chave,ttarvore.chave) NESTED*/ .

hmercadologicoEntrada = DATASET mercadologicoEntrada:HANDLE.

/*
/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'mercadologicoSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE DATASET conteudoSaida FOR ttstatus.

hmercadologicoSaida = DATASET conteudoSaida:HANDLE.
*/

