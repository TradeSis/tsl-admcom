DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hParcelasEntrada     as handle.
def var hParcelasSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttParcelasEntrada NO-UNDO SERIALIZE-NAME "ParcelasEntrada"
    FIELD codigo_cpfcnpj     as char
    field numero_contrato    as char
    index x is unique primary codigo_cpfcnpj asc.
    
DEFINE DATASET conteudoEntrada FOR ttParcelasEntrada.
hParcelasEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'parcelasSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE TEMP-TABLE ttclien NO-UNDO       serialize-name 'cliente'
    FIELD chave as char     serialize-hidden  
    field cpf_cnpj     as char format "x(18)" 
    field clinom       as char format "x(40)"  serialize-name 'nome'
    field clicod       as char format "x(12)"  serialize-name 'codigo_cliente'
    field situacao_cliente    as char
    index cli is unique primary clicod asc.
    
DEFINE TEMP-TABLE ttContratos NO-UNDO   serialize-name 'contratosCliente'
    FIELD chave as char     serialize-hidden  
    field clicod                as char format "x(12)" serialize-hidden 
    field etbcod                as char serialize-name 'filial_contrato'
    field modcod                as char serialize-name 'modalidade'
    field contnum               as char serialize-name 'numero_contrato'
    field titdtemi              as char serialize-name 'data_emissao_contrato'
    field vlrNominal            as char serialize-name 'valor_contrato'
    field vlrPago               as char serialize-name 'valor_total_pago'
    field vlrAberto             as char serialize-name 'valor_total_pendente'
    field vlrEncargos           as char serialize-name 'valor_total_encargo'
    field tpcontrato            as char
    index cli is unique primary contnum asc.
    
DEFINE TEMP-TABLE ttParcelas NO-UNDO   serialize-name 'parcelas'
    FIELD chave as char     serialize-hidden  
    field contnum               as char  serialize-hidden  
    field seq_parcela           as char
    field venc_parcela          as char
    field vlr_parcela           as char
    field valor_encargos        as char
    field possui_boleto         as char
    field possui_ted            as char
    index cli is unique primary contnum asc seq_parcela asc.
                                                                                          

DEFINE DATASET conteudoSaida FOR ttstatus, ttclien, ttContratos, ttparcelas
  DATA-RELATION sitcli FOR ttstatus, ttclien 
        RELATION-FIELDS(ttstatus.chave,ttclien.chave) NESTED
  DATA-RELATION clicomp FOR ttclien, ttContratos 
        RELATION-FIELDS(ttclien.clicod,ttContratos.clicod) NESTED
  DATA-RELATION contpar FOR  ttContratos, ttParcelas 
        RELATION-FIELDS(ttcontratos.contnum,ttparcelas.contnum) NESTED.

hParcelasSaida = DATASET conteudoSaida:HANDLE.

