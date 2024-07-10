/***
    Set/2017 - Nova novacao
***/
{acha.i}

def input  parameter par-recid      as recid.
def input  parameter par-operacao   as char.
def output parameter par-vlrfinanc  as dec.
def output parameter par-vlrttcontr as dec.
def output parameter par-qtdparcela as int.
def output parameter par-txjuros    as dec init 0.

def var vvlrentrada as dec.
def var vvenda as log.
def var vcombo as char.
def var vmovpc as dec.

find contrato where recid(contrato) = par-recid no-lock no-error.
if not avail contrato
then return.

for each titulo where titulo.empcod = 19
                  and titulo.titnat = no
                  and titulo.modcod = contrato.modcod
                  and titulo.etbcod = contrato.etbcod                  
                  and titulo.clifor = contrato.clicod
                  and titulo.titnum = string(contrato.contnum)
                no-lock:
    if titulo.titpar = 0
    then vvlrentrada = titulo.titvlcob.
    else assign
            par-qtdparcela = par-qtdparcela + 1
            par-vlrttcontr = par-vlrttcontr + titulo.titvlcob.
end.

for each contnf where contnf.etbcod  = contrato.etbcod
                  and contnf.contnum = contrato.contnum
                no-lock.
    vvenda = yes.
    find first plani where plani.etbcod = contnf.etbcod
                       and plani.placod = contnf.placod
                       and plani.pladat = contrato.dtinicial
                     no-lock no-error.
    if avail plani
    then do:
        if acha("COMBO",plani.notobs[1]) = ?
        then par-vlrfinanc = plani.platot.
        else
            for each movim where movim.placod = plani.placod
                             and movim.etbcod = plani.etbcod
                             and movim.movdat = plani.pladat
                           no-lock:
                vcombo = acha("COMBO-" + String(movim.procod),plani.notobs[1]).
                if vcombo <> ? /* produtos afetados pelo combo */
                then vmovpc = dec(vcombo) no-error.
                else vmovpc = movim.movpc. /* demais produtos da NF */
                par-vlrfinanc = par-vlrfinanc + (vmovpc * movim.movqtm).
            end.

        /*Solicitacao pelo Airton para considerar entrada no financiado mas nao
          contabilizar a mesma na contagem de parcelas*/
        /* vvlrfinanc = vvlrfinanc - vvlrentrada. */
        
        leave.
    end.
end.

if not vvenda
then do.
    for each tit_novacao where tit_novacao.ger_contnum = contrato.contnum
                           and tit_novacao.etbnova     = contrato.etbcod
                         no-lock:
        find titulo where titulo.empcod = tit_novacao.ori_empcod
                      and titulo.titnat = tit_novacao.ori_titnat
                      and titulo.modcod = tit_novacao.ori_modcod
                      and titulo.etbcod = tit_novacao.ori_etbcod
                      and titulo.clifor = tit_novacao.ori_clifor
                      and titulo.titnum = tit_novacao.ori_titnum
                      and titulo.titpar = tit_novacao.ori_titpar
                      and titulo.titdtemi = tit_novacao.ori_titdtemi
                    no-lock no-error.
        if avail titulo
        then par-vlrfinanc = par-vlrfinanc + titulo.titvlpag.
        else par-vlrfinanc = par-vlrfinanc + tit_novacao.ori_titvlcob.
    end.
/*    vvlrfinanc = vvlrfinanc - vvlrentrada.*/
end.

if par-vlrfinanc > 0
then /* calcula taxa */
    run credtxjuros.p (input par-vlrfinanc,
                       input par-vlrttcontr,
                       input par-qtdparcela,
                       output par-txjuros).

if par-operacao = "Grava" and
   par-txjuros > 0
then do on error undo.
    find current contrato exclusive no-wait no-error.
    if avail contrato
    then assign
            contrato.txjuros    = par-txjuros.
            
end.

