/*
Validacoes: maio/2017 e
            #1 set/2017
#2 - 12/12/2019 - Claudir - Sequencia alfabetic dos itens    
*/
{admcab.i}
{tpalcis-wms.i}

def input parameter par-rec as recid.

find abasintegracao where recid(abasintegracao) = par-rec no-lock.

def var vcontlin as int.

find ebljh where ebljh.codigo_proprietario  = dec(abasintegracao.etbcd)
             and ebljh.Numero_carregamento  = abasintegracao.NCarga
             and ebljh.Numero_filial        = abasintegracao.etbcod
           no-lock no-error.
if avail ebljh
then do.
    if ebljh.hora <> string(abasintegracao.Hora,"HH:MM") or
       ebljh.situacao = "E"
    then do:
        message "Ja existe carregamento" abasintegracao.NCarga
            "para a filial" abasintegracao.etbcod
            view-as alert-box.
        return.
    end.
    else do on error undo:
        find current ebljh.
        for each eblji where 
                 eblji.codigo_proprietario = ebljh.codigo_proprietario
             and eblji.numero_carregamento = ebljh.Numero_carregamento
             and eblji.numero_filial       = ebljh.Numero_filial
             :
             delete eblji.
        end.   
        delete ebljh.     
    end.
end.

for each abasCARGAprod of abasintegracao no-lock.
    vcontlin = vcontlin + 1.
    find eblji where eblji.codigo_proprietario = dec(abasIntegracao.etbcd)
                 and eblji.numero_carregamento = dec(abasIntegracao.NCarga)
                 and eblji.numero_pedido       = abasCARGAprod.dcbcod
                 and eblji.numero_filial       = abasIntegracao.etbcod 
                 and eblji.procod              = abasCARGAprod.procod
                 no-lock no-error.
    if avail eblji
    then do.
        message "Ja existe carregamento" abasintegracao.NCarga
                "para a filial" abasintegracao.etbcod
                "para o item" abasCARGAprod.procod
                view-as alert-box.
        return.
    end.

    find produ where produ.procod = int(abasCARGAprod.procod) no-lock no-error.
    if not avail produ
    then do.
        message "Produto nao cadastrado:" abasCARGAprod.procod view-as alert-box.
        return.
    end.

    if dec(abasCARGAprod.qtdcarga) <= 0
    then do.
        message "Quantidade invalida" abasCARGAprod.qtdcarga
                "para o produto:" abasCARGAprod.procod
                view-as alert-box.
        return.
    end.
end.

if vcontlin <> abasintegracao.qtdlinhas /* #1 */
then do.
    message "Quantidade de linhas: header=" abasintegracao.qtdlinhas
            "Arquivo=" vcontlin view-as alert-box.
    return.
end.

/***
    Fim das validacoes
***/
disp dec(abasintegracao.NCarga) label "Carregamento"  format ">>>>>>>>9"
     int(abasintegracao.etbcod)       label "Filial destino"
     abasintegracao.Data             label "Data Carga"
     abasintegracao.Hora             label "Hora Carga"
     abasintegracao.codigo_transp     label "Tranportador"
     abasintegracao.Placa_veiculo            label "Placa"
     with frame f-eminf 1 down centered color message
                    side-label 1 column overlay width 80 row 8.

message "Confirma a emissao da NFE de Tranferencia?" update sresp.
if not sresp 
then return.

do transaction:
    create ebljh.
    assign
        ebljh.codigo_proprietario = dec(abasintegracao.etbcd).
        ebljh.numero_carregamento = dec(abasintegracao.NCarga).
        ebljh.numero_filial       = abasintegracao.etbcod.
        ebljh.data                = abasintegracao.Data.
        ebljh.hora                = string(abasintegracao.Hora,"HH:MM").
        ebljh.codigo_transp       = abasintegracao.codigo_transp.
        ebljh.placa_veiculo       = abasintegracao.Placa_veiculo .
        ebljh.nome_arquivo        = abasintegracao.arquivo.
        ebljh.situacao            = "F".
end.
 
for each abasCARGAprod of abasintegracao no-lock.
    create eblji.
    assign
        eblji.codigo_proprietario = dec(abasIntegracao.etbcd)     .
        eblji.numero_carregamento = dec(abasIntegracao.NCarga).
        eblji.numero_pedido       = abasCARGAprod.dcbcod.
        eblji.numero_filial       = abasIntegracao.etbcod.
        eblji.procod              = abasCARGAprod.procod. 
        eblji.quantidade            = abasCARGAprod.qtdcarga.
/*        eblji.unidade             = abasCARGAprod.Unidade  */
        eblji.situacao            = "F".
end.                        


def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimimp like movimimp.

def new shared temp-table tt-sel
    field rec    as   recid
    field desti  like tdocbase.etbdes.
 
def temp-table tt-mov
    field procod like produ.procod
    field qtdcont like tdocbpro.qtdcont
    index i-procod is primary unique procod.

for each tt-sel. delete tt-sel. end.    
create tt-sel. 
assign tt-sel.rec = recid(ebljh)
       tt-sel.desti  = ebljh.numero_filial.
                    
find first tt-sel no-lock no-error.
/***
if not avail tt-sel
then do:
    message "Nenhum movimento selecionado.".
    pause 2 no-message.
    return.
end.
disp ebljh.numero_carregamento label "Carregamento"  format ">>>>>>>>9"
             ebljh.numero_filial       label "Filial destino"
             ebljh.data                label "Data Carga"
             ebljh.hora                label "Hora Carga"
             ebljh.codigo_transp       label "Tranportador"
             ebljh.placa_veiculo       label "Placa"
             with frame f-eminf 1 down centered color message
                    side-label 1 column overlay width 80 row 8.
***/

run emissao-NFe.

for each tt-sel. delete tt-sel. end.
for each tt-mov. delete tt-mov. end.

procedure emissao-NFe:
    def var vmovseq like movim.movseq.
    def buffer xestab for estab.
    def buffer bplani for plani.
    def var vplacod like plani.placod.
    def var vnumero like plani.numero.
    def var vctotransf as dec.
    def buffer etb-orig for estab.
    def buffer etb-dest for estab.
    
    for each tt-mov.        delete tt-mov.      end.
    
    find first tt-sel no-lock no-error.
 
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.

    def var vserie like plani.serie.
    
    vplacod = ?.
    vnumero = ?.
    vserie = "1".
    vmovseq = 0.

    find etb-orig where etb-orig.etbcod = setbcod no-lock.
    find etb-dest where etb-dest.etbcod = tt-sel.desti no-lock.
    
    create tt-plani. 
    assign tt-plani.etbcod   = setbcod
           tt-plani.placod   = vplacod 
           tt-plani.emite    = setbcod
           tt-plani.plaufemi = etb-orig.ufecod
           tt-plani.serie    = vserie
           tt-plani.numero   = vnumero 
           tt-plani.movtdc   = 6 
           tt-plani.desti    = tt-sel.desti
           tt-plani.plaufdes = etb-dest.ufecod
           tt-plani.pladat   = today 
           tt-plani.notfat   = tt-sel.desti
           tt-plani.dtinclu  = today 
           tt-plani.horincl  = time 
           tt-plani.notsit   = no 
           tt-plani.hiccod   = 5152 
           tt-plani.opccod   = 5152 
           tt-plani.datexp   = today
           tt-plani.notped   = ebljh.placa_veiculo.
    
    /* criar movim */

    for each tt-sel:
        for each ebljh where recid(ebljh) = tt-sel.rec no-lock:
            for each eblji of ebljh no-lock:
                if length(string(int(eblji.procod))) = 8 and
                   (substr(string(eblji.procod,"99999999"),1,2) = "10" or
                    substr(string(eblji.procod,"99999999"),1,2) = "20" or
                    substr(string(eblji.procod,"99999999"),1,2) = "30")
                then next.
                find first tt-mov where 
                            tt-mov.procod = eblji.procod no-error.
                if not avail tt-mov
                then do:
                    create tt-mov.
                    assign tt-mov.procod = eblji.procod.
                end.
                tt-mov.qtdcont = tt-mov.qtdcont + eblji.quantidade.
            end.
        end.
            
    end.
    
    vmovseq = 0.
    for each tt-mov,
    /*#2*/    first produ where produ.procod = tt-mov.procod
                            no-lock by produ.pronom:
                            
        
        find estoq where estoq.etbcod = setbcod
                         and estoq.procod = tt-mov.procod
                       no-lock no-error.
        if not avail estoq
        then 
            find first estoq where 
                       estoq.procod = tt-mov.procod no-lock no-error.
        
        if tt-mov.qtdcont = 0 
        then do.
            delete tt-mov.
            next.
        end. 
        if avail estoq
        then vctotransf = estoq.estcusto.
        else vctotransf = 1.
        /***
        if today >= 09/01/2016
        then do:
            find last mvcusto where mvcusto.procod = tt-mov.procod
                no-lock no-error.
            if avail mvcusto and
                     mvcusto.valctotransf > 0
            then vctotransf = mvcusto.valctotransf.         
        end.
        ***/
        find first tt-plani exclusive-lock.
                            
        vmovseq = vmovseq + 1.
        create tt-movim. 
        assign tt-movim.movtdc = tt-plani.movtdc 
               tt-movim.PlaCod = tt-plani.placod 
               tt-movim.etbcod = tt-plani.etbcod 
               tt-movim.movseq = vmovseq 
               tt-movim.procod = tt-mov.procod 
               tt-movim.movqtm = tt-mov.qtdcont 
               tt-movim.movpc  = vctotransf /*if avail estoq
                                 then estoq.estcusto else 1*/
               tt-movim.movdat = tt-plani.pladat 
               tt-movim.MovHr  = int(time) 
               tt-movim.emite  = tt-plani.emite 
               tt-movim.desti  = tt-plani.desti 
               tt-movim.datexp = tt-plani.datexp.    
        /*                           
        if avail estoq and estoq.estcusto = 0 
        then tt-movim.movpc = 1.
        */                    
        tt-plani.platot = tt-plani.platot + (tt-movim.movpc * tt-movim.movqtm).
        tt-plani.protot = tt-plani.protot + (tt-movim.movpc * tt-movim.movqtm).
                        
        delete tt-mov.
    end.

    find first tt-plani no-lock.
    find first tt-movim
         where tt-movim.etbcod = tt-plani.etbcod and
               tt-movim.placod = tt-plani.placod and
               tt-movim.movtdc = tt-plani.movtdc and
               tt-movim.movdat = tt-plani.pladat
                       no-lock no-error.
    if not avail tt-movim
    then do:
        message "Movimentacao sem itens. NFe nao sera gerada"
            view-as alert-box.
    end.
    else do:    
    
    
        run manager_nfe.p (input "wms_ebljh_5152",
                           input ?,
                           output sresp).

                                
        do on error undo:
            
            find current abasintegracao exclusive.
            find current tt-plani.
            
            abasintegracao.placod = tt-plani.placod.
            
        end. 

        find current abasintegracao no-lock.
        
        run abas/transffecha.p (recid(abasintegracao)).

    end.

    for each tt-sel. delete tt-sel. end.

end procedure.

