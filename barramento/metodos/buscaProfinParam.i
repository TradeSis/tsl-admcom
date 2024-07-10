DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hconteudoEntrada        as handle.
def var hconteudoSaida           as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttbuscaProfinParamEntrada NO-UNDO SERIALIZE-NAME "buscaProfinParamEntrada"
    FIELD codigoFilial   as char
    index x is unique primary codigofilial asc.
          
DEFINE DATASET conteudoEntrada FOR ttbuscaProfinParamEntrada.

hconteudoEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'buscaProfinParamSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE TEMP-TABLE ttprofin NO-UNDO       serialize-name 'produtosFinanceiros'
    FIELD chave as char     serialize-hidden  
    field fincod    as char serialize-name  'codigoProfin'
    field findesc   as char serialize-name 'nomeProfin'
    field procod    as char serialize-name 'procod' 
    field modCod    as char serialize-name 'modcod'
    field obrigaDeposito as char   
    field limiteToken as char
    field procodSeguro as char
    field codigoSicred as char
    index cli is unique primary chave asc fincod asc.

DEFINE TEMP-TABLE ttprofinparam NO-UNDO       serialize-name 'parametros'
    FIELD chave as char     serialize-hidden  
    field fincod    as char  serialize-hidden  
    field etbcod    as char serialize-name  'codigoFilial'
    field DtInicial as char serialize-name 'dtInicial'
    field DtFinal as char serialize-name 'dtFinal'
    field VlMinimo as char serialize-name 'vlMinimo'
    field VlMaximo as char serialize-name 'vlMaximo'
    field PercLimite as char serialize-name 'percLimite'
    field TempoRelac as char serialize-name 'tempoRelac'
    field ParcPagas as char serialize-name 'parcPagas'
    index cli is unique primary chave asc fincod asc etbcod asc.

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

DEFINE TEMP-TABLE ttprofintaxa no-undo  serialize-name 'taxaTFC'
    FIELD chave as char     serialize-hidden  
    field fincod    as char  serialize-hidden      
    FIELD VlMinimo  AS CHAR  
    FIELD VlMaximo  as char
    FIELD VlTaxa   as char
    index cli is unique primary chave asc fincod asc vlMinimo asc.

DEFINE DATASET conteudoSaida FOR ttstatus, ttprofin, ttprofinparam, ttprofincond, ttprofintaxa
  DATA-RELATION sitcli FOR ttstatus, ttprofin
        RELATION-FIELDS(ttstatus.chave,ttprofin.chave) NESTED
  DATA-RELATION finpar FOR ttprofin, ttprofinparam
        RELATION-FIELDS(ttprofin.fincod,ttprofinparam.fincod) NESTED
  DATA-RELATION finplan FOR ttprofin, ttprofincond
        RELATION-FIELDS(ttprofin.fincod,ttprofincond.pfincod) NESTED
  DATA-RELATION fintaxa FOR ttprofin, ttprofintaxa
        RELATION-FIELDS(ttprofin.fincod,ttprofintaxa.fincod) NESTED.
        
        


hconteudoSaida = DATASET conteudoSaida:HANDLE.

