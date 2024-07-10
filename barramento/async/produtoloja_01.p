/* helio 18072023 Preço promocional indevido no ADMCOM - Qualitor 35187 */
/* helio 08022023 - teste se modificou o mix, para nao precisar executar generico */
/* helio 07022023 - https://trello.com/c/uAKaPFHH/973-pre%C3%A7os-integrando-apenas-at%C3%A9-a-loja-141
    na interface produtoloja, enviado datain para procedure de carga 
    quando estoq.dtaltpreco for MENOR que pdatain (envio barramento) entao altera, se for maior NAO ALTERA PRECO
    */
/* helio 12/11/2021 novos campos fase 2 */

disable triggers for load of estoq.
disable triggers for load of produ.

DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def input param pdatain as date.
def var vmixmudou as log.


def    output param     vok as char no-undo.
vok = "".

DEFINE var lcJsonsaida      AS LONGCHAR.

def var vestvenda as dec.
def var vcst like estoq.cst.
def var valiquotaicms like estoq.aliquotaicms.

{/admcom/barramento/functions.i}

{/admcom/barramento/async/produtoloja_01.i}

/* LE ENTRADA */
lokJSON = hprodutoLojaEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

/***
pause 1.
*def var vsaida as char.
find first ttprodutoloja.        

vsaida = "./json/produtoloja/" + trim(ttprodutoloja.codigoProduto) + "_" + ttprodutoloja.codigoloja + "_" 
                           + trim(ttprodutoloja.ativo)  + "_" + string(time)
                           + "produtoloja.json".


**hprodutolojaEntrada:WRITE-JSON("FILE",vsaida, true).

**/

/*


*/

for each ttprodutoloja.
    /*        
    field ativo as char
    field mixLoja as char
    field tempoGarantia as char
    */

    /* find produ where produ.procod = int(codigoProduto) no-lock. //08122022 helio - erro quando nao existir produto */ 
    /* //08122022 helio erro quando nao existir produto */  
    find produ where produ.procod = int(codigoProduto) no-lock no-error.
    if not avail produ
    then do:
        vok = "SEM PRODU " + codigoProduto.
        next.
    end.
    /* //08122022 */

    find estoq where estoq.etbcod = int(codigoLoja) and
                     estoq.procod = int(codigoProduto)
        exclusive no-wait no-error.                      
    if not avail estoq
    then do:
        if locked estoq
        then do:
            vok = "locado".
            return. 
        end.    
        create estoq.
        estoq.etbcod = int(codigoLoja) .
        estoq.procod = int(codigoProduto).
        estoq.datexp = today.
    end. 
    vmixmudou = no.
    
    /* 25/08/2021 MIX - campo novo mixDistribuicaoLoja */
    if ttprodutoloja.mixDistribuicaoLoja = "true"
    then do:
        find abasgrade where 
                    abasgrade.etbcod = estoq.etbcod and
                    abasgrade.procod = estoq.procod
                    exclusive-lock no-error.
        if not avail abasgrade
        then do:
            create abasgrade. 
            abasgrade.etbcod = estoq.etbcod.
            abasgrade.procod = estoq.procod.
            vmixmudou = yes.
        end.
        if abasgrade.abgqtd <> int(ttprodutoloja.mixLoja)
        then do:
            abasgrade.abgqtd = int(ttprodutoloja.mixLoja).       
            vmixmudou = yes.
        end.
    end.    
    if ttprodutoloja.mixDistribuicaoLoja <> "true"
    then do:
        find abasgrade where 
                    abasgrade.etbcod = estoq.etbcod and
                    abasgrade.procod = estoq.procod
                    exclusive-lock no-error.
        if avail abasgrade
        then do:
            if int(ttprodutoloja.mixLoja) <> ? and
               int(ttprodutoloja.mixLoja) <> abasgrade.abgqtd
            then do:   
                abasgrade.abgqtd = int(ttprodutoloja.mixLoja).
                vmixmudou = yes.
            end.    
        end.    
    end.    

    for each ttpreco where ttpreco.idpai =  ttprodutoloja.id.
        /* 
        field precoRegular as char  
        field precoRemarcado as char  
        */
        estoq.estcusto = dec(precoCusto).
        vestvenda = dec(precoPraticado) no-error.
        if vestvenda <> ? 
        then do:
            if estoq.dtaltpreco = ? or estoq.dtaltpreco <= pdatain
            then do: 
                estoq.estvenda = vestvenda.
                estoq.datexp  = today.
                estoq.dtaltpreco = pdatain.
                
                if produ.tiposap = "SERV" and (estoq.etbcod = 1 or estoq.etbcod = 188)
                then do:
                    find medprodu where medprodu.procod = produ.procod exclusive no-wait no-error.
                    if avail medprodu
                    then do:
                        medprodu.valorServico = vestvenda.
                    end.
                end.
            end.        
            
        end.    
 
    /* helio 18072023 Preço promocional indevido no ADMCOM - Qualitor 35187 */
        /* zerar primeiro, pode pode nao vir registro algum */
        find first ttprecopromocional where ttprecopromocional.idpai = ttpreco.id no-error.
        if not avail ttprecopromocional 
        then do:
            estoq.estproper = 0.
            estoq.estbaldat  = ?.
            estoq.estprodat   = ?.
            estoq.dtaltprom = ?.
        end.
    /**/
            
        for each ttprecopromocional where ttprecopromocional.idpai = ttpreco.id.
            
            if dec(ttprecopromocional.precoPromocional) <> ? and
               dec(ttprecopromocional.precoPromocional) <> 0
            then do:
                if estoq.dtaltprom = ? or estoq.dtaltprom <= pdatain
                then do:
                    estoq.estproper = dec(ttprecopromocional.precoPromocional).
                    if aaaa-mm-dd_todate(ttprecopromocional.dataInicialPromocao) <> ?
                    then estoq.estbaldat = aaaa-mm-dd_todate(ttprecopromocional.dataInicialPromocao).
                    if aaaa-mm-dd_todate(ttprecopromocional.dataFinalPromocao) <>?
                    then estoq.estprodat = aaaa-mm-dd_todate(ttprecopromocional.dataFinalPromocao).
                    estoq.datexp    = today.
                    estoq.dtaltprom = pdatain.
                end.
            end.            
        end.
            
    end.            
    for each tttributacao where tttributacao.idpai =  ttprodutoloja.id.
        
        find produ of estoq exclusive no-wait no-error.
        if avail produ
        then do:
         
            produ.proipiper = dec(tttributacao.aliquotaIcms). 
            if produ.tipoSAP = "SERV"
            then produ.proipiper = 98.
            
            if int(tttributacao.cst) = 60
            then produ.proipiper = 99.  /* ST */ 

            valiquotaIcms       = estoq.aliquotaIcms.
            vcst                = estoq.cst.
            estoq.aliquotaIcms  =  dec(tttributacao.aliquotaIcms).
            estoq.cst           = int(tttributacao.cst).
            if estoq.aliquotaIcms <> valiquotaIcms or
               estoq.cst          <> vcst
            then estoq.datexp        = today.            
        end.
    end.     
    if vmixmudou
    then     run /admcom/progr/geraindicegenerico.p (estoq.procod, ?).
          
end.    



