DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hGeraBoletoEntrada     as handle.
def var hGeraBoletoSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttgeraBoletoEntrada NO-UNDO SERIALIZE-NAME "geraBoletoContratoEntrada"
    FIELD codigo_cpfcnpj     as char
    field venc_boleto       as char
    field vlr_boleto        as char
    field vlr_servicos      as char
    index x is unique primary codigo_cpfcnpj asc.

DEFINE TEMP-TABLE ttparcelasEntrada NO-UNDO SERIALIZE-NAME "parcelas"
    FIELD codigo_cpfcnpj    as char
    field numero_contrato   as char
    field seq_parcela       as char
    field venc_parcela      as char
    field vlr_parcela_pago  as char
    index x is unique primary codigo_cpfcnpj asc numero_contrato asc seq_parcela asc.

    
DEFINE DATASET conteudoEntrada FOR ttgeraBoletoEntrada, ttparcelasEntrada
  DATA-RELATION boletoPar FOR ttgeraBoletoEntrada, ttparcelasEntrada
        RELATION-FIELDS(ttgeraBoletoEntrada.codigo_cpfcnpj,ttparcelasEntrada.codigo_cpfcnpj) NESTED.

hGeraBoletoEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'geraBoletoContratoSaida'
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
    index cli is unique primary chave asc.

DEFINE DATASET conteudoSaida FOR ttstatus, ttboleto
  DATA-RELATION sitcli FOR ttstatus, ttboleto
        RELATION-FIELDS(ttstatus.chave,ttboleto.chave) NESTED.

hGeraBoletoSaida = DATASET conteudoSaida:HANDLE.

