/* helio 05042023 - complementos */
/* helio 28032023 - projeto cashback pagamentos */
def input param par-etbcriacao  as int.
def input param par-origemcriacao as char.

def buffer bcupomb2b for cupomb2b.
def var pidCupom as int.
def var pcodigo as int.
def var pdigito as int.
def var pnovoidcupom as int.
def var psequencia          like cupomb2b.sequencia.
def var pdataCriacao        like cupomb2b.dataCriacao.
def var phoraCriacao        like cupomb2b.horaCriacao.
def var pquantidadeTotal as int.
def var vok as log.

def SHARED temp-table ttcashback no-undo
    field titulo-rec as recid.

def temp-table ttselecao no-undo
    field clicod    like titulo.clifor
    field contnum   like contrato.contnum 
    field titpar    like titulo.titpar
    field titulo-rec as recid
    field titvlcob  like titulo.titvlcob
    field titdtpag  like titulo.titdtpag.

def temp-table ttcupom no-undo
    field clicod    like titulo.clifor
    field contnum   like contrato.contnum  
    field qtdParcelas   as int
    field titvlcob  like titulo.titvlcob
    field valorDesconto as dec
    field percDesconto  as dec
    field dataValidade as date.
    
    
find first cupomcashparam where cupomcashparam.tipoCupom = "CASHB" no-lock no-error.
if not avail cupomcashparam
then do:
    for each ttcashback.
        delete ttcashback.
    end.
    return.
end.
if cupomcashparam.ativo = no
then do:
    for each ttcashback.
        delete ttcashback.
    end.
    return.
end.


    for each ttcashback.
        find titulo where recid(titulo) = ttcashback.titulo-rec no-lock.
        if titulo.titsit = "PAG"
        then do:
            if titulo.titdtven - today >= cupomcashparam.diasAntecipado
            then do:
                if NOT cupomcashparam.ParcelasMesmoContrato
                then do:
                    find first ttcupom where ttcupom.clicod = titulo.clifor no-error.
                    if not avail ttcupom
                    then do:
                        create ttcupom.
                        ttcupom.clicod = titulo.clifor.
                        ttcupom.contnum = ?.
                    end.    
                end.
                else do:
                    find first ttcupom where ttcupom.clicod = titulo.clifor and
                                             ttcupom.contnum = int(titulo.titnum) no-error.
                    if not avail ttcupom
                    then do:
                        create ttcupom.
                        ttcupom.clicod = titulo.clifor.
                        ttcupom.contnum = int(titulo.titnum).
                    end.    
                end.
                
                create ttselecao.
                ttselecao.clicod    = titulo.clifor.
                ttselecao.contnum   = int(titulo.titnum).
                ttselecao.titpar    = titulo.titpar.
                ttselecao.titulo-rec = ttcashback.titulo-rec.
                ttselecao.titvlcob  = titulo.titvlcob.
                ttselecao.titdtpag  = if titulo.titdtpag = ? then today else titulo.titdtpag.
                ttcupom.qtdParcelas = ttcupom.qtdParcelas + 1.
                ttcupom.titvlcob    = ttcupom.titvlcob    + ttselecao.titvlcob.
                
            end.
        end.
    end.
    
        for each ttcupom.
            vOK = no.
            if ttcupom.qtdParcelas >= cupomcashparam.ParcelasQuantidadeMin
            then do:
                if cupomcashparam.percParcelasPagas > 0
                then do:
                    ttcupom.valorDesconto = ttcupom.titvlcob * cupomcashparam.percParcelasPagas / 100.   
                end.    
                else do:
                    if cupomcashparam.vlrParcelasPagas > 0
                    then do:
                        ttcupom.valorDesconto = cupomcashparam.vlrParcelasPagas.
                    end.
                    else do:
                        if cupomcashparam.percDescontoProxCmp > 0
                        then do:
                            ttcupom.percDesconto = cupomcashparam.percDescontoProxCmp.
                        end.
                        else do:
                           ttcupom.valorDesconto = cupomcashparam.vlrDescontoProxCmp .
                        end.
                    end.
                end.

                ttcupom.dataValidade = today + cupomcashparam.diasValidade  .
                Vok = YES.                
            end.

            if not VOK
            then delete ttcupom.
            
        end.
        
pquantidadeTotal = 0.
for each ttcupom.
    pquantidadeTotal = pquantidadeTotal + 1.
end.        
pdataCriacao    = today.
phoraCriacao    = time.

for each ttcupom.

            psequencia = psequencia + 1.
            
                pcodigo = next-value(idcupomb2b).
                run /admcom/progr/dvmod11.p (pcodigo , output pdigito).

                pnovoidcupom = int(string(pcodigo) + string(pdigito)).

                create cupomb2b.
                cupomb2b.tipoCupom          = "CASHB". /* helio 28032023 - cashback */
                cupomb2b.idCupom            = pnovoidcupom.
                cupomb2b.catcod             = 0.
                cupomb2b.clacod             = 0.
                cupomb2b.valorDesconto      = ttcupom.valorDesconto.
                cupomb2b.percentualDesconto = ttcupom.percDesconto.
                cupomb2b.dataValidade       = ttcupom.dataValidade.
                cupomb2b.etbcod             = 0. /* do uso */
                cupomb2b.dataTransacao      = ?.
                cupomb2b.numeroComponente   = ?.
                cupomb2b.nsuTransacao       = ?.
                cupomb2b.dataCriacao        = pdataCriacao.
                cupomb2b.horaCriacao        = phoraCriacao.
                cupomb2b.sequencia          = psequencia.
                cupomb2b.quantidadeTotal    = pquantidadeTotal.
                cupomb2b.clicod             = ttcupom.clicod.
                
                cupomb2b.etbCriacao         = par-etbCriacao.
                cupomb2b.origemCriacao      = par-origemCriacao.
                cupomb2b.dataCsv            = ?.

    for each ttselecao where ttselecao.clicod   = ttcupom.clicod and
                             ttselecao.contnum = ttcupom.contnum.

        create cupomcashtit.
        cupomcashtit.idCupom  = cupomb2b.idCupom.
        cupomcashtit.clicod   = ttcupom.clicod.
        cupomcashtit.contnum  = ttselecao.contnum.
        cupomcashtit.titpar   = ttselecao.titpar.
        cupomcashtit.titvlcob = ttselecao.titvlcob.
        cupomcashtit.titdtpag = ttselecao.titdtpag.
        
    end.
end.        
