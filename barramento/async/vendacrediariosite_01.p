/* 10/2021 moving sicred - chamada api json */

DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     verro as char no-undo.
verro = "".

def var psicred as recid.

DEFINE var lcJsonsaida      AS LONGCHAR.

{/admcom/progr/api/sicredsimular.i new} /* 10/2021 moving sicred - chamada api json */

{/admcom/barramento/functions.i}

{/admcom/barramento/async/efetivavendacrediariosite_01.i}
def new shared temp-table ttcancela no-undo
    field prec as recid
    field operacao as char    
    field qtddevol as int
    field valordevol as dec.


def var vcontnum like geranum.contnum.
def var vtitpar     as int.
def var vdtvenc      as date.
def var vdia as int.
def var vdiax as int.
def var vmes as int.
def var vano as int.
 def var vd as int.

def var par-rec as recid.
/*
def var vetbcod as int.
def var vLoja         as integer.
def var vProduto      as integer init 1.
def var vPlano        as integer init 326.
def var vTaxa         as dec.
def var vSeguro       as dec.

def var vPrazo        as int.
def var vValorCompra  as decimal.
def var vValorPMT     as decimal.
def var vDiasParaPgto as integer.
*/

/* LE ENTRADA */
lokJSON = hefetivavendacrediariositeEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

def var vsaida as char.
find first ttefetivavendacrediariosite no-error.

if avail ttefetivavendacrediariosite
then do:
    /**    
    vsaida = "./json/site/" +  trim(dataTransacao) + "_"
                           + trim(cpfCliente) + "_"
                           + trim(idOperacaoMotor) + "_"
                           + "efetivavendacrediariosite.json".

    hefetivavendacrediariositeEntrada:WRITE-JSON("FILE",vsaida, true).
    **/
end.

par-rec = ?.
        
    find first ttefetivavendacrediariosite no-error.
    if avail ttefetivavendacrediariosite
    then do on error undo:    

        find estab where estab.etbcod = int(codigoLoja) no-lock.
            message ttefetivavendacrediariosite.codigoPedido.
                
            find first contrSite where contrSite.etbcod = estab.etbcod and
                                       contrSite.codigoPedido = ttefetivavendacrediariosite.codigoPedido
                                   no-error.
            if not avail contrSite
            then do:
                create contrSite.
                contrSite.etbcod        = estab.etbcod.
                contrSite.codigoPedido  = ttefetivavendacrediariosite.codigoPedido.
            end.    
            
            par-rec  = recid(contrSite).
             

            contrSite.sequencial    = ttefetivavendacrediariosite.sequencial.
            contrSite.dataTransacao = aaaa-mm-dd_todate(ttefetivavendacrediariosite.dataTransacao).
            contrSite.horaTransacao = ttefetivavendacrediariosite.horaTransacao.
            contrSite.dtinc         = today.
            contrSite.hrinc         = time.
            contrSite.cpfCliente    = dec(ttefetivavendacrediariosite.cpfCliente).
            contrSite.idOperacaoMotor   = ttefetivavendacrediariosite.idOperacaoMotor.         
            find neuclien where neuclien.cpf = contrSite.cpfCliente no-lock no-error.
            if avail neuclien
            then do:
                contrSite.clicod = neuclien.clicod.
            end.    
            else do:
                find first clien where clien.ciccgc = ttefetivavendacrediariosite.cpfCliente no-lock no-error.
                if avail clien
                then do:
                    contrSite.clicod = clien.clicod.
                end.
            end.
                
            find first ttcondicao no-error.
            /*
            field valorEntrada  as char /*":"0.00",*/ 
            field valorTfc      as char /*":null,*/ 
            field valorTotalSeguro  as char /*":null,*/ 
            field codigoSeguro  as char /*":null,*/ 
            field coeficiente   as char /*":null,*/ 
            field valorIrr  as char. /*":null,*/
            */
            if avail ttcondicao
            then do:
                contrSite.codPlano  = int(ttcondicao.codPlano).
                contrSite.taxaJuros = dec(ttcondicao.taxaJuros).
                contrSite.primeiroVencimento = aaaa-mm-dd_todate(ttcondicao.primeiroVencimento) no-error.
                if contrsite.primeirovencimento = ? then contrsite.primeirovencimento = today.
                contrSite.valorEntrada = dec(ttcondicao.valorEntrada).            
                if contrSite.valorEntrada = ? then contrSite.valorEntrada = 0.
                contrSite.qtdParcelas   = int(ttcondicao.qtdParcelas).          /* vprazo */
                contrSite.valorTotalPrazo = dec(ttcondicao.valorTotalPrazo).    /* vValorCompra */
                contrSite.valorPMT        = dec(ttcondicao.valorParcela).
                /*contrSite.DiasParaPgto    = contrSite.primeiroVencimento - contrSite.dataTransacao */ /* vdiasparaPgto */
                            
                contrSite.valorTotal    = dec(ttcondicao.valorTotalPrazo) - dec(ttcondicao.acrescimoTotal) .
                contrSite.valorFrete    = dec(ttefetivavendacrediariosite.valorFrete) .
                if contrSite.valorFrete = ? then contrSite.valorFrete = 0.
                

                /*
                vetbcod = contrSite.etbcod.
                vloja   = contrSite.etbcod .
                
                vplano  = contrSite.codPlano. /* 12032021 */
                
                vPrazo  = contrSite.qtdParcelas.
                vvalorCompra = contrSite.valorTotal.
                vvalorPMT  = contrSite.valorPMT.
                vdiasparaPgto = int(contrSite.primeiroVencimento - contrSite.dataTransacao).
                
                {/admcom/progr/crd/chama-cal-tx-wssicred.i} ANTIGO FORMATO*/

                    /* 10/2021 moving sicred - chamada api json */
                    create ttdados.
                        ttdados.loja = string(contrSite.etbcod,"9999").
/*                        ttdados.dataInicio = string(year(contrSite.dataTransacao),"9999")  + "-" +
                                             string(month(contrSite.dataTransacao),"99") + "-" +
                                             string(day(contrSite.dataTransacao),"99")   + " 00:00:00". */
                        ttdados.dataPrimeiroVencimento = ttcondicao.primeiroVencimento /*string(year(pprivenc),"9999")  + "-" +
                                             string(month(pprivenc),"99") + "-" +
                                             string(day(pprivenc),"99")   + " 00:00:00"*/ .
                        ttdados.plano   = string(contrSite.codPlano,"9999").
                        ttdados.prazo   = contrSite.qtdParcelas.
                        ttdados.valorSolicitado = contrSite.valorTotal.
                        ttdados.valorParcela    = ?.
                        ttdados.valorSeguro     = 0.
                        ttdados.taxa            = ?.
                        ttdados.prazoMin        = ?.
                        ttdados.prazoMax        = ?.
    

                    run /admcom/progr/api/sicredsimular.p. /* 10/2021 moving sicred - chamada api json */

                find first ttreturn no-error.
                if avail ttreturn
                then do:
                    assign contrSite.taxaCet    = ttreturn.cetMes.
                    assign contrSite.taxaCetAno = ttreturn.cetAno.
                    assign contrSite.valorIof   = ttreturn.valorIOF.
                    assign contrSite.taxaCalc   = ttreturn.taxaMes.
                    /* 10/2021 moving sicred - chamada api json */
                    
                end.
            end.    
            for each ttitens.
                find first contrsitem where  contrsitem.etbcod = contrsite.etbcod and
                                             contrsitem.codigoPedido     = contrSite.codigoPedido and 
                                             contrsitem.codigoProduto    = int(ttitens.codigoProduto)
                                                              no-error.
                if avail contrsitem then next.
                create contrsitem.
                contrsitem.etbcod = contrsite.etbcod.
                contrsitem.codigoPedido     = contrSite.codigoPedido.
                contrsitem.codigoProduto    = int(ttitens.codigoProduto).
                contrsitem.descricao        = ttitens.descricao.
                contrsitem.qtd              = INT(ttitens.qtd).
                contrsitem.valorUnitario    = dec(ttitens.valorUnitario).
                contrsitem.valorTotal      = DEC(ttitens.valorTotal).
                contrsitem.QTDDEVOL  = 0.
            end.
            
            
    end.        


find contrSite where recid(contrsite) = par-rec no-lock no-error.
if avail contrSite
then do:
    if contrSite.contnum = ?
    then do:
      do for geranum on error undo on endkey undo:
        find geranum where geranum.etbcod = 999 
            exclusive-lock 
            no-wait 
            no-error.
        if not avail geranum
        then do:
            if not locked geranum
            then do:
                create geranum.
                assign
                    geranum.etbcod  = 999
                    geranum.clicod  = 300000000
                    geranum.contnum = 300000000.
                vcontnum = geranum.contnum.    
                find current geranum no-lock.
            end.
            else do: /** LOCADO **/
            end.
        end.
        else do:
            geranum.contnum = geranum.contnum + 1. 
            find current geranum no-lock. 
            vcontnum = geranum.contnum.
        end.
      end.
    
        do on error undo.
            find current contrSite exclusive.
            contrSite.contnum = vcontnum.
        end.
        
    end.
    find current contrSite no-lock.
    if contrsite.contnum <> ?
    then
    do on error undo:     
            find contrato where contrato.contnum  = int(contrSite.contnum) exclusive no-error. 
            if not avail contrato
            then do:
                create contrato.
                contrato.contnum       = int(contrSite.contnum).
                contrato.dtinicial     = today. /* a partir de 26022021, a data de emissao do contrato sera a data de inclusão na base /*contrsite.dataTransacao.*/*/
            end.     
            ASSIGN
              contrato.clicod        = contrSite.clicod.
              contrato.etbcod        = contrSite.etbcod.
              contrato.vltotal       = dec(contrSite.valorTotalPrazo) + dec(contrSite.valorEntrada).
              contrato.vlentra       = dec(contrSite.valorEntrada).
              contrato.crecod        = contrSite.codPlano.
/*              contrato.vltaxa        = dec(contrSite.valorTFC). */
              contrato.modcod        = "CRE" /*contrSite.modalidade*/ .
              contrato.DtEfetiva     = today.
              contrato.VlIof         = dec(contrSite.valorIof).
              contrato.Cet           = dec(contrSite.taxaCet).
              contrato.TxJuros       = dec(contrSite.taxaCalc).
              contrato.vlf_acrescimo = dec(contrSite.valorTotalPrazo - contrSite.valorTotal).
              contrato.vlf_principal = dec(contrSite.valorTotal).
              contrato.nro_parcelas  = int(contrSite.qtdParcelas).

              /* helio 22122021 - mudanca contrato ecommerce para carteira Lebes
              *contrato.banco = 10.
              *
              *  run fin/sicrecontr_create.p (?,
              *                               contrato.contnum,
              *                               output psicred).
              *
              *  find sicred_contrato where recid(sicred_contrato) = psicred no-lock no-error.
              */

              /* helio 22122021 - mudanca contrato ecommerce para carteira Lebes */
              contrato.banco = 1. 
              /***/

            vdtvenc = contrSite.primeiroVencimento no-error.
            if vdtvenc = ? or vdtvenc < today then vdtvenc = today.
            vdia = day(contrSite.primeiroVencimento).
            
            do vtitpar = 1 to contrSite.qtdParcelas.      
                find first titulo where titulo.contnum = contrato.contnum and
                                  titulo.titpar  = vtitpar  
                        no-error.
                if not avail titulo
                then do:
                    find first titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = contrato.modcod and
                    titulo.etbcod     = contrato.etbcod and
                    titulo.clifor     = contrato.clicod and
                    titulo.titnum     = string(contrato.contnum) and 
                    titulo.titpar     = vtitpar and
                    titulo.titdtemi   = contrato.dtinicial
                    no-error.
                    if not avail titulo
                    then do:
                        create titulo. 
                    end.           
                    titulo.contnum  = contrato.contnum. 
                    
                    assign            
                    titulo.empcod     = 19
                    titulo.titnat     = no
                    titulo.modcod     = contrato.modcod 
                    titulo.etbcod     = contrato.etbcod 
                    titulo.clifor     = contrato.clicod 
                    titulo.titnum     = string(contrato.contnum )
                    titulo.titpar     = vtitpar 
                    titulo.titdtemi   = contrato.dtinicial
                    titulo.titdtven   = vdtvenc.
                    titulo.titsit     = "LIB".
                end.        
                assign
                    titulo.titvlcob   = contrSite.valorPMT.

                assign
                    titulo.vlf_acrescimo = contrato.vlf_acrescimo / contrSite.qtdParcelas.
                    titulo.vlf_principal = contrato.vlf_principal / contrSite.qtdParcelas.

                /* helio 22122021 - mudanca contrato ecommerce para carteira Lebes
                *titulo.cobcod = if avail sicred_contrato
                *                then sicred_contrato.cobcod
                *                else 1.
                */

                /* helio 22122021 - mudanca contrato ecommerce para carteira Lebes */
                titulo.cobco = 1.
                /**/

                vmes = month(vdtvenc).
                vano = year (vdtvenc).
                vmes = vmes + 1.
                if vmes = 13
                then do:
                    vmes = 1.
                    vano = vano + 1.
                end.    
                vdtvenc = ?.
                vdtvenc = date(vmes,vdia,vano) no-error.
                vdiax = vdia.
                if vdtvenc = ?
                then do vd = 1 to 7:
                    vdiax = vdiax - 1.
                    vdtvenc = ?.
                    vdtvenc = date(vmes,vdiax, vano) no-error.
                    if vdtvenc <> ?
                    then leave.
                end.
            end.

        run /admcom/progr/crd/acertacontrsitemov.p (recid(contrsite)).

        run /admcom/progr/crd/contratositeimp.p (recid(contrsite)).
        
        

    end.              
end.    
        







    

