DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hreEnviaBoletosEntrada     as handle.
def var hreEnviaBoletosSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttreEnviaBoletosEntrada NO-UNDO SERIALIZE-NAME "reEnviaBoletosEntrada"
    FIELD codigo_cpfcnpj    as char
    field banco             as char
    field nossonumero       as char
    index x is unique primary codigo_cpfcnpj asc.
          
DEFINE DATASET conteudoEntrada FOR ttreEnviaBoletosEntrada.

hreEnviaBoletosEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'reEnviaBoletosSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE TEMP-TABLE ttboleto NO-UNDO       serialize-name 'boleto'
    FIELD chave as char     serialize-hidden  
    field Banco as char  
    field Agencia as char  
    field codigoCedente as char  
    field contaCorrente as char  
    field Carteira as char  
    field nossoNumero as char  
    field DVnossoNumero as char  
    field dtEmissao as char  
    field dtVencimento as char  
    field fatorVencimento as char  
    field numeroDocumento as char  
    field sacadoNome as char  
    field sacadoEndereco as char  
    field sacadoCEP as char  
    field linhaDigitavel as char  
    field codigoBarras as char  
    field VlPrincipal as char  
    index cli is unique primary chave asc nossonumero asc.

DEFINE DATASET conteudoSaida FOR ttstatus, ttboleto
  DATA-RELATION sitcli FOR ttstatus, ttboleto
        RELATION-FIELDS(ttstatus.chave,ttboleto.chave) NESTED.



hreEnviaBoletosSaida = DATASET conteudoSaida:HANDLE.

