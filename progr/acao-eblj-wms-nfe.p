/*
Validacoes: maio/2017 e
            #1 set/2017
*/

{admcab.i}
{tpalcis-wms.i}

def input parameter par-arq as char.

def var vdiretorio-ant  as char.
def var vdiretorio-apos as char.
def var varquivo as char.
def var varq-dep as char.
def var varq-ant as char.
def var vcontlin as int.

vdiretorio-ant = "/admcom/tmp/alcis/INS/".
vdiretorio-apos = "/usr/ITF/dat/in/".
varquivo = alcis-diretorio + "/" + par-arq.
varq-ant = varquivo.
varq-dep = "/admcom/tmp/alcis/bkp/" + par-arq.

unix silent value("quoter " + varquivo + " > ./consulta-conf.arq" ). 
def temp-table ttheader
    field Remetente         as char format "x(10)"
    field NomeArquivo       as char format "x(4)"
    field NomeInterface     as char format "x(8)"
    field Site              as char format "x(3)"  
    field PROPRIETaRIO      as char format "x(12)"
    field NCarregamento     as char format "x(11)"     
    field NLoja             as char format "x(12)"     
    field DataREAL          as char format "xxxxxxxx"  
    field HoraREAL          as char format "xxxxxxx"  
    field Transportadora    as char format "x(12)"     
    field Placa             as char format "x(10)"
    field qtdelinhas        as char format "x(3)" /* #1 */.

def temp-table ttitem       
    field Remetente         as char format "x(10)"
    field NomeArquivo       as char format "x(4)"
    field NomeInterface     as char format "x(8)"
    field Site              as char format "x(3)"
    field PROPRIETaRIO      as char format "x(12)"
    field NCarregamento     as char format "x(11)"
    field NPedido           as char format "x(12)"
    field NLoja             as char format "x(12)"
    field Produto           as char format "x(40)"
    field Quantidade        as char format "x(18)"
    field Unidade           as char format "x(6)".

def var v as int.
def var vlinha as char.
input from ./consulta-conf.arq.
repeat.
    v = v + 1.
    import vlinha.
    if v = 1
    then do.
        create ttheader.
        ttheader.Remetente      = substr(vlinha, 1 , 10).
        ttheader.NomeArquivo    = substr(vlinha, 11, 4 ).
        ttheader.NomeInterface  = substr(vlinha, 15, 8 ).
        ttheader.Site           = substr(vlinha, 23, 3 ).
        ttheader.PROPRIETaRIO   = substr(vlinha, 26, 12).
        ttheader.NCarregamento  = substr(vlinha, 38, 11).
        ttheader.NLoja          = substr(vlinha, 49, 12).
        ttheader.Data           = substr(vlinha, 61, 8 ).
        ttheader.Hora           = substr(vlinha, 69, 5 ).
        ttheader.Transportadora = substr(vlinha, 74, 12).
        ttheader.Placa          = substr(vlinha, 86, 10).
        ttheader.qtdelinhas     = substr(vlinha, 96, 3). /* #1 */
        next.
    end.
    create ttitem.
    ttitem.Remetente        = substr(vlinha,  1 , 10).
    ttitem.NomeArquivo      = substr(vlinha,  11, 4 ).
    ttitem.NomeInterface    = substr(vlinha,  15, 8 ).
    ttitem.Site             = substr(vlinha,  23, 3 ).
    ttitem.PROPRIETaRIO     = substr(vlinha,  26, 12).
    ttitem.NCarregamento    = substr(vlinha,  38, 11).
    ttitem.NPedido          = substr(vlinha,  49, 12).
    ttitem.NLoja            = substr(vlinha,  61, 12).
    ttitem.Produto          = substr(vlinha,  73, 40).
    ttitem.Quantidade       = substr(vlinha, 113, 9 ).
    ttitem.Unidade          = substr(vlinha, 131, 6 ).
end.
input close.

/***
    VALIDACOES: maio/2017
***/
find first ttheader no-lock no-error.
if not avail ttheader
then do.
    message "Problema no arquivo" view-as alert-box.
    return.
end.

find first ttitem no-lock no-error.
if not avail ttitem
then do.
    message "Problema no arquivo" view-as alert-box.
    return.
end.

find ebljh where ebljh.Codigo_proprietario = dec(ttheader.PROPRIETaRIO)
             and ebljh.Numero_carregamento = dec(ttheader.NCarregamento)
             and ebljh.Numero_filial = int(ttheader.NLoja)
           no-lock no-error.
if avail ebljh
then do.
    if ebljh.hora <> ttheader.Hora or
       ebljh.situacao = "E"
    then do:
        message "Ja existe carregamento" ttheader.NCarregamento
            "para a filial" ttheader.NLoja
            view-as alert-box.
        return.
    end.
    else do on error undo:
        find current ebljh.
        for each eblji where 
                 eblji.Codigo_proprietario = ebljh.Codigo_proprietario
             and eblji.numero_carregamento = ebljh.Numero_carregamento
             and eblji.numero_filial       = ebljh.Numero_filial
             :
             delete eblji.
        end.   
        delete ebljh.     
    end.
end.

for each ttitem no-lock.
    vcontlin = vcontlin + 1.
    find eblji where eblji.Codigo_proprietario = dec(ttitem.PROPRIETaRIO)
                 and eblji.numero_carregamento = dec(ttitem.NCarregamento)
                 and eblji.numero_pedido       = int(substr(ttitem.NPedido,4,9))
                 and eblji.numero_filial       = int(ttitem.NLoja) 
                 and eblji.procod              = int(ttitem.Produto) 
                 no-lock no-error.
    if avail eblji
    then do.
        message "Ja existe carregamento" ttheader.NCarregamento
                "para a filial" ttheader.NLoja
                "para o item" ttitem.Produto
                view-as alert-box.
        return.
    end.

    find produ where produ.procod = int(ttitem.Produto) no-lock no-error.
    if not avail produ
    then do.
        message "Produto nao cadastrado:" ttitem.Produto view-as alert-box.
        return.
    end.

    if dec(ttitem.Quantidade) <= 0
    then do.
        message "Quantidade invalida" ttitem.Quantidade
                "para o produto:" ttitem.Produto
                view-as alert-box.
        return.
    end.
end.

if vcontlin <> int(ttheader.qtdelinhas) /* #1 */
then do.
    message "Quantidade de linhas: header=" ttheader.qtdelinhas
            "Arquivo=" vcontlin view-as alert-box.
    return.
end.

/***
    Fim das validacoes
***/
disp dec(ttheader.NCarregamento) label "Carregamento"  format ">>>>>>>>9"
     int(ttheader.NLoja)       label "Filial destino"
     ttheader.Data             label "Data Carga"
     ttheader.Hora             label "Hora Carga"
     ttheader.Transportadora   label "Tranportador"
     ttheader.Placa            label "Placa"
     with frame f-eminf 1 down centered color message
                    side-label 1 column overlay width 80 row 8.

message "Confirma a emissao da NFE de Tranferencia?" update sresp.
if not sresp 
then return.

do transaction:
    find first ttheader no-lock.
    
    create ebljh.
    assign
        ebljh.codigo_proprietario = dec(ttheader.PROPRIETaRIO)
        ebljh.numero_carregamento = dec(ttheader.NCarregamento)
        ebljh.numero_filial       = int(ttheader.NLoja)
        ebljh.data                = if trim(ttheader.Data) <> "0"
                                    then date(ttheader.Data)
                                    else ?
        ebljh.hora                = ttheader.Hora
        ebljh.codigo_transp       = ttheader.Transportadora
        ebljh.placa_veiculo       = ttheader.Placa 
        ebljh.nome_arquivo        = par-arq
        ebljh.situacao            = "F".
end.
 
for each ttitem.
    create eblji.
    assign
        eblji.codigo_proprietario = dec(ttitem.PROPRIETaRIO)     
        eblji.numero_carregamento = dec(ttitem.NCarregamento)
        eblji.numero_pedido       = int(substr(ttitem.NPedido,4,9))
        eblji.numero_filial       = int(ttitem.NLoja) 
        eblji.procod              = int(ttitem.Produto) 
        eblji.quantidade          = dec(ttitem.Quantidade)
        eblji.unidade             = ttitem.Unidade  
        eblji.situacao            = "F".
end.                        


def new shared temp-table tt-plani like com.plani.
def new shared temp-table tt-movim like com.movim.
def new shared temp-table tt-movimimp like movimimp.
def new shared temp-table tt-sel
    field rec    as   recid
    field desti  like tdocbase.etbdes.
 
def temp-table tt-mov
    field procod like com.produ.procod
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

/***output to erro.rr.***/
unix silent value("cp -n " + varq-ant + " " + varq-dep).
unix silent value("rm -rf " + varq-ant).
/***output close.***/

 
procedure emissao-NFe:
    def var vmovseq like com.movim.movseq.
    def buffer xestab for ger.estab.
    def buffer bplani for com.plani.
    def var vplacod like com.plani.placod.
    def var vnumero like com.plani.numero.
    def var vctotransf as dec.
    def buffer etb-orig for estab.
    def buffer etb-dest for estab.
    
    for each tt-mov.        delete tt-mov.      end.
    
    find first tt-sel no-lock no-error.
 
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    for each tt-movimimp. delete tt-movimimp. end.

    def var vserie like com.plani.serie.
    
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
        first produ where produ.procod = tt-mov.procod
                    no-lock by produ.pronom:
                    
        find com.estoq where estoq.etbcod = setbcod
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
        run manager_nfe.p (input "wms_ebljh_5152", input ?, output sresp).
    end.

    for each tt-sel. delete tt-sel. end.

end procedure.

