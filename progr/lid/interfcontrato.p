/** #092022 - novos campos para BI
contrato
codigoLoja
dataTransacao
numeroComponente
nsuTransacao

parcelas
emCartorio
tpContrato
**/


def var vemCartorio as log.

/* helio 26042022 - integrar DataPagamento Admcom no Staging */
def var hsaida   as handle.
def var lokJson as log.

def input param par-tabela as char.
def input param par-rec as recid.
def output param vlcsaida as longchar.

DEFINE TEMP-TABLE ttcontrato NO-UNDO SERIALIZE-NAME "contrato"
        field cpfCNPJ       as char
        field codigoCliente as char
        field codigoLoja as char 
        field numeroContrato as char 
        field dataInicial as char 
        field valorTotal as char 
        field planoCredito as char 
        field contratoFinanceira as char 
        field tipoOperacao as char 
        field dataEfetivacao as char 
        field valorEntrada as char 
        field primeiroVencimento as char 
        field qtdParcelas as char 
        field taxaMes as char 
        field valorAcrescimo as char 
        field valorIof as char 
        field valorTFC as char 
        field taxaCetAno as char 
        field taxaCet as char 
        field tipoContrato as char 
        field valorPrincipal as char 
        field modalidade as char 
        field codigoEmpresa as char 
        field valorSeguro   as char

        /* #092022 */
        field dataTransacao as char
        field numeroComponente as char
        field nsuTransacao as char
        /* #092022 */
                
index x is unique primary numeroContrato asc.


DEFINE TEMP-TABLE ttparcelas NO-UNDO SERIALIZE-NAME "parcelas"
        field cpfCNPJ       as char
        field codigoCliente as char
        field codigoLoja as char 
        field numeroContrato as char 
        field sequencial as char 
        field valorParcela as char 
        field dataVencimento as char 
        field dataEmissao as char 
        field codigoCobranca as char 
        field valorPrincipal as char 
        field valorFinanceiroAcrescimo as char 
        field valorSeguro as char 
        field situacao as char
        field saldo as char
        field dataPagamento as char
        field emCartorio as char
        field tpContrato as char
        
index x is unique primary numeroContrato asc sequencial asc.  


DEFINE TEMP-TABLE ttmovimento NO-UNDO SERIALIZE-NAME "movimentacoes"
        field cpfCNPJ       as char
        field codigoCliente as char
        field codigoLoja as char 
        field numeroContrato as char 
        field sequencial as char 
        field codigoLojaMovim as char
        field dataHoraBaixa     as char /*": "yyyy-MM-dd HH:mm:ss", */
        field sequencialMovim   as char /*": "1", */
        field tipoBaixa         as char /*": "BOL", //[Boleto, Juridico, Dinheiro] */
        field valorBaixaPrincipal   as char /*": "0.0", */
        field valorBaixaJurosAtraso as char /*": "0.0", */
        field valorBaixaTotal       as char /*": "0.0" */
index x is unique primary numeroContrato asc sequencial asc sequencialMovim asc.  



DEFINE DATASET Crediario FOR ttcontrato, ttparcelas , ttmovimento
  DATA-RELATION for1  FOR ttcontrato, ttparcelas         
                RELATION-FIELDS(ttcontrato.numeroContrato, ttparcelas.numeroContrato) NESTED
  DATA-RELATION for12 FOR ttparcelas,  ttmovimento       
                RELATION-FIELDS(ttparcelas.numeroContrato, ttmovimento.numeroContrato,
                                ttparcelas.sequencial,     ttmovimento.sequencial) NESTED.
  
hSaida = DATASET Crediario:HANDLE.



if par-tabela = "Titulo"
then do:
    find titulo where recid(titulo) = par-rec no-lock no-error.
    if not avail titulo
    then return.
    find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
    if not avail contrato
    then return.
    find neuclien where neuclien.clicod = contrato.clicod no-lock no-error.
    run create_contrato.
    run create_titulo.
end.    


if par-tabela = "Contrato"
then do:
    find contrato where recid(contrato) = par-rec no-lock no-error.
    if not avail contrato
    then return.
    find neuclien where neuclien.clicod = contrato.clicod no-lock no-error.
    
    run create_contrato.
    
    for each titulo where titulo.empcod = 19 and titulo.titnat = no and
        titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
        titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum)
        no-lock. 

        run create_titulo.

    end.

end.


find first ttcontrato no-error.
if avail ttcontrato
then do: 
    lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
   /* 
    lokJson = hSaida:WRITE-JSON("FILE","Crediario.json", true).
   */ 


end.




procedure create_contrato.
def var vtitdtven as date.
def buffer btitulo for titulo.
        
    find first btitulo where btitulo.empcod = 19 and btitulo.titnat = no and
        btitulo.etbcod = contrato.etbcod and btitulo.modcod = contrato.modcod and
        btitulo.clifor = contrato.clicod and btitulo.titnum = string(contrato.contnum)
        no-lock no-error.         
    vtitdtven = if avail btitulo then btitulo.titdtven else ?.
    
    create ttcontrato.
    ttcontrato.cpfCNPJ          = if avail neuclien and neuclien.cpf <> ? then string(neuclien.cpf,"99999999999999") else ""  .
    ttcontrato.codigoCliente    = string(contrato.clicod)  .
    ttcontrato.codigoLoja       = string(contrato.etbcod).
    ttcontrato.numeroContrato   = string(contrato.contnum).
    ttcontrato.dataInicial      =  if contrato.dtinicial = ? then ""
                                       else string(year(contrato.dtinicial),"9999") + "-" + 
                                            string(month(contrato.dtinicial),"99")   + "-" + 
                                            string(day(contrato.dtinicial),"99"). 
    ttcontrato.valorTotal       = trim(string(contrato.vltota,"->>>>>>>>>>>>>9.99")).
    ttcontrato.planoCredito     = string(contrato.crecod).
    ttcontrato.contratoFinanceira   = if avail btitulo and btitulo.cobcod = 10 then "true" else "false".
    ttcontrato.tipoOperacao     = "".
    ttcontrato.dataEfetivacao   = ttcontrato.dataInicial.
    ttcontrato.valorEntrada     = trim(string(contrato.vlentra,"->>>>>>>>>>>>>9.99")).
    ttcontrato.primeiroVencimento   =  if vtitdtven = ? then ""
                                       else  string(year(vtitdtven),"9999") + "-" + string(month(vtitdtven),"99")   + "-" + string(day(vtitdtven),"99"). 
    ttcontrato.qtdParcelas      = string(contrato.nro_parcelas).
    ttcontrato.taxaMes          = trim(string(contrato.txjuros,"->>>>>>>>>>>>>9.99")).
    ttcontrato.valorAcrescimo   = trim(string(contrato.vlf_acrescimo,"->>>>>>>>>>>>>9.99")).
    ttcontrato.valorIof         = trim(string(contrato.vliof,"->>>>>>>>>>>>>9.99")).
    ttcontrato.valorTFC         = trim(string(contrato.vltaxa,"->>>>>>>>>>>>>9.99")).
    ttcontrato.taxaCetAno       = "".
    ttcontrato.taxaCet          = trim(string(contrato.cet,"->>>>>>>>>>>>>9.99")).
    ttcontrato.tipoContrato     = contrato.tpcontrato.
    ttcontrato.valorPrincipal   = trim(string(contrato.vlf_principal,"->>>>>>>>>>>>>9.99")).
    ttcontrato.modalidade       = contrato.modcod.
    ttcontrato.codigoEmpresa    = "19".
    ttcontrato.valorSeguro      = trim(string(contrato.vlseguro,"->>>>>>>>>>>>>9.99")).


    /* #092022 */
    find first pdvmoe where pdvmoe.modcod   = contrato.modcod and
                      pdvmoe.titnum         = string(contrato.contnum)
                      no-lock no-error.
    if avail pdvmoe
    then do:
        find pdvmov of pdvmoe no-lock.
        find cmon of pdvmov no-lock.
        ttcontrato.dataTransacao = ttcontrato.dataInicial.
        ttcontrato.numeroComponente = string(cmon.cxacod).
        ttcontrato.nsuTransacao     = string(pdvmov.sequencia).
    end.
    /* #092022 */

end procedure.


procedure create_titulo. 
def var vtitdes as dec.
def var vsaldo  as dec.

    vtitdes = titulo.titdes. 
    if vtitdes = 0 and contrato.vlseguro > 0 
    then vtitdes = contrato.vlseguro / contrato.nro_parcela.  

    vsaldo = if titulo.titsit = "PAG"
             then 0
             else titulo.titvlcob.
                  
    find first ttcontrato no-lock. 
    create ttparcelas.
    ttparcelas.cpfCNPJ       = ttcontrato.cpfCNPJ.
    ttparcelas.codigoCliente = ttcontrato.codigoCliente.
    ttparcelas.codigoLoja    = ttcontrato.codigoLoja.
    ttparcelas.numeroContrato    = ttcontrato.numeroContrato.
    ttparcelas.sequencial    = string(titulo.titpar).
    ttparcelas.valorParcela  = trim(string(if titulo.titvltot > 0 then titulo.titvltot else titulo.titvlcob,"->>>>>>>>>>>>>9.99")).
    ttparcelas.dataVencimento    = string(year(titulo.titdtven),"9999") + "-" + string(month(titulo.titdtven),"99")   + "-" + string(day(titulo.titdtven),"99"). 
    ttparcelas.dataEmissao   = ttcontrato.datainicial.
    ttparcelas.codigoCobranca    = string(titulo.cobcod).
    ttparcelas.valorPrincipal  = trim(string(if titulo.vlf_principal > 0 then titulo.vlf_principal else titulo.titvlcob,"->>>>>>>>>>>>>9.99")).
    ttparcelas.valorFinanceiroAcrescimo  = trim(string(if titulo.vlf_acrescimo > 0 then titulo.vlf_acrescimo else 0,"->>>>>>>>>>>>>9.99")).
    ttparcelas.valorSeguro  = trim(string(if vtitdes > 0 then vtitdes else 0,"->>>>>>>>>>>>>9.99")).
    ttparcelas.situacao      = titulo.titsit. 
    ttparcelas.saldo         = trim(string(if vsaldo > 0 then vsaldo else 0,"->>>>>>>>>>>>>9.99")).
    ttparcelas.dataPagamento =  if titulo.titdtpag  = ? then ""
                                       else string(year(titulo.titdtpag),"9999") + "-" + 
                                            string(month(titulo.titdtpag),"99")   + "-" + 
                                            string(day(titulo.titdtpag),"99"). 
    


    /* helio #092022 - novos campos vi*/
    vemCartorio = no.       
      do on error undo:
        find first titprotparc where titprotparc.operacao = "IEPRO" and
                                     titprotparc.contnum  = int(titulo.titnum) and
                                     titprotparc.titpar   = titulo.titpar
            exclusive-lock no-wait no-error.
        if avail titprotparc
        then do:
            find titprotesto of titprotparc no-lock.
            if avail titprotesto
            then do:
                if titprotesto.ativo = "" or
                   titprotesto.ativo = "ATIVO"
                then do:
                    if titprotparc.SitCslog = ""
                    then do:
                        titprotparc.sitCslog = "EM PROTESTO".
                        titprotparc.sitDtCslog = ?.
                        vemCartorio = yes.
                    end.    
                end.   
                else do:
                     if titprotparc.SitCslog <> ""
                     then do:
                        titprotparc.sitCslog = "".
                        titprotparc.sitDtCslog = ?.
                        vemCartorio = no.
                     end.
                end.
            end.     
        end.

    end. 
    
    ttparcelas.emCartorio = string(vemCartorio,"true/false").
    ttparcelas.tpContrato = titulo.tpContrato.    
    
    /* #092022 */
    
    run create_movimento.        


end procedure.



procedure create_movimento.
def var vsequencialMovim as int.

    vsequencialMovim = 0.
    for each pdvdoc where pdvdoc.contnum = titulo.titnum and
                          pdvdoc.titpar = titulo.titpar and
                          pdvdoc.pstatus = yes        no-lock
        , first pdvmov of pdvdoc                      no-lock
        , first pdvtmov where pdvtmov.ctmcod = pdvdoc.ctmcod and pdvtmov.pagamento = yes no-lock /* helio 26042023 - 
                                                    VALOR DIVERGENTE DE PARCELA TABELA CREDIARIO_PARCELA_MOVIMENTO */
                            by pdvdoc.datamov
                        by pdvmov.horamov:
        vsequencialMovim = vsequencialMovim + 1.
        
        create ttmovimento.
        ttmovimento.cpfCNPJ         = ttparcelas.cpfCNPJ.
        ttmovimento.codigoCliente   = ttparcelas.codigoCliente.
        ttmovimento.codigoLoja      = ttparcelas.codigoLoja.
        ttmovimento.numeroContrato  = ttparcelas.numeroContrato.
        ttmovimento.sequencial      = ttparcelas.sequencial.
        ttmovimento.codigoLojaMovim = string(pdvdoc.etbcod).   
        ttmovimento.dataHoraBaixa   = string(year(pdvmov.datamov),"9999") + "-" + 
                                      string(month(pdvmov.datamov),"99")   + "-" + 
                                      string(day(pdvmov.datamov),"99") + " " +
                                      string(pdvmov.horamov,"HH:MM:SS").

        ttmovimento.sequencialMovim = string(vsequencialmovim).
        ttmovimento.tipoBaixa       = pdvdoc.ctmcod.
        ttmovimento.valorBaixaPrincipal     = trim(string(pdvdoc.titvlcob,"->>>>>>>>>>>>>9.99")).
        ttmovimento.valorBaixaJurosAtraso   = trim(string(pdvdoc.valor_encargo,"->>>>>>>>>>>>>9.99")).
        ttmovimento.valorBaixaTotal         = trim(string(pdvdoc.valor,"->>>>>>>>>>>>>9.99")).
    
    end.

end procedure.
