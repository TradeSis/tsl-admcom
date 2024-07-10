DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hsaldosEntrada     as handle.
def var hsaldossaida       as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttSaldosEntrada NO-UNDO SERIALIZE-NAME "calculoSaldosEntrada"
    FIELD codigoCliente as char
    index x is unique primary codigoCliente asc.

DEFINE TEMP-TABLE ttcredito NO-UNDO       serialize-name 'credito'
    field codigoCliente    as char serialize-hidden
    field limite           as char 
    field vctoLimite       as char 
    index cli is unique primary codigoCliente asc.

DEFINE TEMP-TABLE ttmodal NO-UNDO   serialize-name 'comportamentoModalidade'
    field codigoCliente  as char serialize-hidden
    field modcod        as char serialize-name  'modcod'
    field comprometido  as char
    field dcomprometido  as dec  serialize-hidden
    index cli is unique primary codigoCliente asc modcod asc .

DEFINE TEMP-TABLE ttcomportamento NO-UNDO   serialize-name 'comportamentoCliente'
    field codigoCliente as char serialize-hidden
    field atributo      as char format "x(20)"     
    field valorAtributo as char format "x(30)"     
    index cli is unique primary codigoCliente asc atributo asc.

DEFINE TEMP-TABLE ttprofin NO-UNDO       serialize-name 'parametrosProdutosFinanceiros'
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

    
DEFINE DATASET conteudoEntrada FOR ttSaldosEntrada, ttcredito, ttmodal ,ttcomportamento, ttprofin, ttprofinparam , ttprofincond , ttprofintaxa
  DATA-RELATION cli FOR ttsaldosEntrada, ttcredito  
        RELATION-FIELDS(ttSaldosEntrada.codigoCliente,ttcredito.codigoCliente) NESTED
  DATA-RELATION climodal FOR ttsaldosEntrada, ttmodal 
        RELATION-FIELDS(ttsaldosEntrada.codigoCliente,ttmodal.codigoCliente) NESTED
  DATA-RELATION clicomp FOR ttsaldosEntrada, ttComportamento 
        RELATION-FIELDS(ttsaldosEntrada.codigoCliente,ttComportamento.codigoCliente) NESTED
  DATA-RELATION cliprofin FOR ttsaldosEntrada, ttprofin 
        RELATION-FIELDS(ttsaldosEntrada.codigoCliente,ttprofin.chave) NESTED
  DATA-RELATION cliparam FOR ttprofin, ttprofinparam
        RELATION-FIELDS(ttprofin.chave,ttprofinparam.chave) NESTED
  DATA-RELATION finplan FOR ttprofin, ttprofincond
        RELATION-FIELDS(ttprofin.fincod,ttprofincond.pfincod) NESTED
  DATA-RELATION fintaxa FOR ttprofin, ttprofintaxa
        RELATION-FIELDS(ttprofin.fincod,ttprofintaxa.fincod) NESTED.

hsaldosEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'calculoSaldosSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    field codigoCliente as char
    index cli is unique primary situacao asc.

DEFINE TEMP-TABLE ttcreditoSaldo NO-UNDO   serialize-name 'creditoCliente'
    field chave       as char format "x(12)" serialize-hidden
    field limite      as char format "x(20)"    
    field vctoLimite  as char format "x(30)"  
    field comprometido as char format "x(30)"
    field saldoLimite  as char format "x(30)"
    index cli is unique primary chave asc.

DEFINE TEMP-TABLE ttsaldoProfin NO-UNDO   serialize-name 'saldoProdutosFinanceiros'
    field chave       as char format "x(12)" serialize-hidden
    field codigoProFin    as char format "x(20)"    
    field nomeProFin  as char format "x(30)"  
    field limite as char format "x(30)"
    field saldoDisponivel  as char format "x(30)"
    index cli is unique primary chave asc codigoProFin asc.

 DEFINE TEMP-TABLE ttprofincondSAIDA no-undo  serialize-name 'condicoes'
    FIELD chave as char     serialize-hidden  
    field pfincod    as char  serialize-hidden      
    FIELD fincod    as char  serialize-name  'codPlano'
    field finnom    as char   serialize-name  'descricaoPlano'
    field finnpc    as char  serialize-name  'qtdParcelas'
    field finfat    as char   serialize-name  'fatorJuros'
    field txjurosmes   as char   serialize-name  'taxaJuros'
    field favorito  as char
    index cli is unique primary chave asc pfincod asc fincod asc.


    
DEFINE DATASET conteudoSaida FOR ttstatus, ttcreditoSaldo, ttsaldoprofin, ttprofincondSAIDA
  DATA-RELATION sitcli FOR ttstatus, ttcreditoSaldo
        RELATION-FIELDS(ttstatus.chave,ttcreditoSaldo.chave) NESTED
  DATA-RELATION cliprofin FOR ttstatus, ttsaldoprofin
        RELATION-FIELDS(ttstatus.chave,ttsaldoprofin.chave) NESTED
  DATA-RELATION finplan FOR ttsaldoprofin, ttprofincondSAIDA
        RELATION-FIELDS(ttsaldoprofin.codigoproFin,ttprofincondSAIDA.pfincod) NESTED.

hsaldosSaida = DATASET conteudoSaida:HANDLE.

