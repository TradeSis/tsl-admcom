def input param par-operacao as char.

def var vretorno as char.

def var p-recmov as recid.
def var vMensagemPDV as char. 
def var vnsusafe     as char.
def var vTextoCupom as char.
def var vCartao as char.
def var vseq as int.
def var vi as int.

def buffer ori-cmon for cmon.
def buffer ori-pdvdoc for pdvdoc.
def  shared temp-table tp-plani like com.plani
    field devolver like plani.platot label "Devolver" column-label "Devolver"
    index ipladat-d pladat desc.


def new shared temp-table tt-EmissaoValeTroca93 no-undo       
        field cestabelecimento      as char 
        field ccodigoloja       as char  
        field cpdv              as char  
        field cvalortransacao   as char  
        field choralocal        as char  
        field cdatalocal        as char  
        field ctipocliente      as char  
        field cnomecliente      as char  
        field ccpfcnpj          as char  
        field crg               as char  
        field corgaoemissaorg   as char  
        field cdatanascimento   as char  
        field cnumerotelefone   as char  
        field cnumerocupomtroca as char 
        field cnumerocupomvale  as char 
        field cdatavenda        as char 
        field cnumerolojavenda  as char 
        field cnumeropdvvenda   as char 
        field cnsuvenda         as char 
        field cnumerocupomvenda as char 
        field cnumerooperadorvenda as char 
        field cnumerooperadoremissao as char
        field cnumeroFiscalEmissao as char 
        field cdataSensibilizacao as char 
        field clojaSensibilizacao  as char
        field cpdvSensibilizacao  as char 
        field cnsuSensibilizacao  as char 
        field coperadorSensibilizacao  as char
        field cfiscalSensibilizacao  as char 
        field cmac  as char 
        field cnsuSafe as char.


def new shared temp-table tt-p2k_cab_transacao no-undo       
        field CODIGO_LOJA             as char
        field DATA_TRANSACAO          as char
        field NUMERO_COMPONENTE       as char
        field NSU_TRANSACAO           as char
        field TIPO_VENDA              as char
        field NUMERO_CUPOM            as char
        field CODIGO_CLIENTE          as char
        field VALOR_TOTAL_VENDA       as char
        field VALOR_TROCO_VENDA       as char
        field HORA_TRANSACAO          as char
        field TIPO_TRANSACAO          as char
        field TIPO_DESCONTO_SUB_TOTAL as char
        field VALOR_DESCONTO_SUB_TOTAL as char
        field CODIGO_OPERADOR         as char
        field CHAVE_ACESSO_NFE        as char
        field NUMERO_NFE              as char
        field SERIE_NFE               as char
        field ORIG_CODIGO_LOJA as char
        field ORIG_DATA_TRANSACAO     as char
        field ORIG_NUMERO_COMPONENTE  as char
        field ORIG_NSU_TRANSACAO      as char
        field desc_observacao_pedido  as char
        field TIPO_PEDIDO             as char
        field NUMERO_PEDIDO           as char.

def new shared temp-table tt-p2k_item_transacao no-undo       
    field NUM_SEQ_PRODUTO        as char 
    field CODIGO_PRODUTO         as char 
    field CODIGO_VENDEDOR as char 
    field QTD_VENDIDA            as char 
    field VALOR_UNITARIO_PRODUTO as char 
    field VALOR_ACRESCIMO_ITEM   as char 
    field VALOR_DESCONTO         as char 
    field VALOR_ICMS             as char 
    field COD_TRIBUTACAO         as char 
    field CODIGO_IMEI            as char 
    field DATA_PREVISTA_ENTREGA  as char 
    field DATA_PEDIDO_ESPECIAL   as char 
    field VALOR_DESCONTO_CAMPANHA as char 
    field TIPO_DESCONTO as char 
    field status_item             as char init 'V'.

def new shared temp-table tt-p2k_recb_transacao no-undo       
    field NUM_SEQ_FORMA    as char 
    field CODIGO_FORMA     as char 
    field CODIGO_PLANO     as char 
    field VALOR_PAGO_FORMA as char 
    field VALOR_ACRESCIMO  as char.

def new shared temp-table tt-p2k_receb_cred_seg no-undo       
        field num_seq_forma as char 
        field numero_contrato as char 
        field valor_seguro as char 
        field num_apolice as char 
        field num_sorteio as char 
        field TIPO_SEGURO as char /* codigo do produto */ 
        field num_seq_seguro as char.


def new shared temp-table tt-xmlretorno
    field child-num  as int
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)"
    /*index x is unique primary child-num asc root asc tag asc valor asc*/.

                                                            
def shared temp-table tt-devolver
    field procod like movim.procod
    field etbcod like movim.etbcod    
    field movtdc like plani.movtdc
    field placod like plani.placod
    field pladat like plani.pladat
    field movpc  like movim.movpc
    field movqtm like movim.movqtm
    field serie  like plani.serie
    field numero like plani.numero
    field notped like plani.notped
    field movdev like movim.movdev.

def  shared temp-table tt-titdev
    field marca as char format "x(1)"
    field empcod like titulo.empcod
    field titnat like titulo.titnat
    field modcod like titulo.modcod
    field etbcod like titulo.etbcod
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titvlcob like titulo.titvlcob
    field titvlpag like titulo.titvlpag
    field titsit   like titulo.titsit
    field titdtemi like titulo.titdtemi
    field tipdev     as   char
    index i-tit is primary unique empcod 
                                  titnat 
                                  modcod 
                                  etbcod 
                                  clifor 
                                  titnum 
                                  titpar.

find first tt-titdev where marca <> "" no-error.
if not avail tt-titdev
then do:
    message "TITDEV ERRO". pause.
    return.
end.    

find first tt-devolver no-error.
if not avail tt-devolver
then do:
    message "DEVOLVER ERRO".
    pause.
    return.
end.    


 
find tp-plani where 
        tp-plani.etbcod = tt-devolver.etbcod and
        tp-plani.placod = tt-devolver.placod
        no-lock no-error.
if not avail tp-plani
then do:
    message "Origem Nao encontrada".
    pause.
    return.
end.

find first plani where plani.etbcod = tp-plani.etbcod and
                 plani.placod = tp-plani.placod
                 no-lock.

def var pcpf as dec format "99999999999".

find neuclien where neuclien.clicod = tt-titdev.clifor no-lock no-error.
if not avail neuclien
then do:
    find clien where clien.clicod = tt-titdev.clifor no-lock.
    pcpf = dec(clien.ciccgc) no-error.
    if not avail clien or pcpf = ?
    then do:
        hide message no-pause.
        message "Cliente Sem Cadastro - Informe CPF: " update pcpf.
    end.
        
end.
else do:
    pcpf = neuclien.cpf.
end.


run hnc/hcsimulamov.p (string(20)).



        find cmon where cmon.etbcod = tt-titdev.etbcod and
                        cmon.cxacod = 20
                        no-lock no-error.
                                
    
    find cmon where
                cmon.etbcod = tt-titdev.etbcod and 
                cmon.cxacod = 20
                no-lock no-error. 
    if not avail cmon 
    then do on error undo: 
        create cmon. 
        assign 
            cmon.cmtcod = "PDV" 
            cmon.etbcod = tt-titdev.etbcod
            cmon.cxacod = 20
            cmon.cmocod = int(string(cmon.etbcod) + 
                              string(cmon.cxacod,"999")) 
            cmon.cxanom = "Lj " + string(cmon.etbcod) + " " + 
                          "Cx " + string(cmon.cxacod). 
    end.


    find first tt-titdev.
    find first tt-devolver.

    
    find plani where plani.etbcod = tt-devolver.etbcod and
                     plani.placod = tt-devolver.placod
                no-lock.
    find first ori-pdvdoc where ori-pdvdoc.etbcod = plani.etbcod and
                            ori-pdvdoc.placod = plani.placod
                            no-lock no-error.
        find ori-cmon of ori-pdvdoc no-lock.

        find cmon where cmon.etbcod = tt-titdev.etbcod and
                        cmon.cxacod = 20
                        no-lock.
                        
        find last pdvmov where
                pdvmov.etbcod = cmon.etbcod and
                pdvmov.cmocod = cmon.cmocod and
                pdvmov.datamov = today
                no-lock no-error.
        vseq = if avail pdvmov 
               then pdvmov.sequencia + 2
               else 1.


   create tt-p2k_cab_transacao.
   codigo_loja          = string(tt-titdev.etbcod).
   data_transacao       = string(year(tt-titdev.titdtemi),"9999") +
                          string(month(tt-titdev.titdtemi),"99")  +
                          string(day(tt-titdev.titdtemi),"99").
   numero_componente    = string(cmon.cxacod).
   nsu_transacao        = string(vseq). 
   tt-p2k_cab_transacao.tipo_venda           = "9". 
   numero_cupom         = string(plani.numero). 
   codigo_cliente       = string(tt-titdev.clifor). 
   valor_total_venda    = replace(string(tt-titdev.titvlcob,"999999999.99"),".",",").
   valor_troco_venda    = "0,00". 
   hora_transacao       = "1023". 
   tipo_transacao       = if par-operacao = "TROCA"
                          then "27"
                          else "81". 
   tipo_desconto_sub_total  = "1". 
   valor_desconto_sub_total = "0,00". 
   tt-p2k_cab_transacao.codigo_operador      = "100". 
   chave_acesso_nfe     = if plani.ufdes = ? then "" else plani.ufdes. 
   tt-p2k_cab_transacao.numero_nfe           = string(plani.numero). 
   tt-p2k_cab_transacao.serie_nfe            = "3". 
   orig_codigo_loja     = string(plani.etbcod). 
   orig_data_transacao  = string(day(plani.pladat),"99") + "/" +
                          string(month(plani.pladat),"99")  + "/" +
                          string(year(plani.pladat),"9999").
                          
   orig_numero_componente = string(ori-cmon.cxacod). 
   orig_nsu_transacao   = string(ori-pdvdoc.sequencia). 
   desc_observacao_pedido = "null". 
   tt-p2k_cab_transacao.tipo_pedido          = "1". 
   tt-p2k_cab_transacao.numero_pedido        = "0".

vi = 0.
for each tt-devolver.

    create tt-p2k_item_transacao.
    vi = vi + 1.
   
    find produ where produ.procod = tt-devolver.procod no-lock.
    if produ.proipiper = 98
    then next.
    
            num_seq_produto = string(vi). 
            codigo_produto = string(tt-devolver.procod). 
            codigo_vendedor = "100". 
            qtd_vendida = string(tt-devolver.movqtm). 
            valor_unitario_produto = replace(string(tt-devolver.movpc,"9999999999.99"),".",",") . 
            valor_acrescimo_item = "0,00".
            valor_desconto = "0,00". 
            valor_icms = "0,00". 
            
            cod_tributacao = if produ.proipiper = 99 
                             then "60"
                             else "00".
                              
            codigo_imei = "". 
            data_prevista_entrega = "null".  
            data_pedido_especial = "null". 
            valor_desconto_campanha = "0". 
            tipo_desconto = "null".
            
end.

create tt-p2k_receb_cred_seg.

/**
find first contnf where contnf.etbcod = plani.etbcod and
                        contnf.placod = plani.placod
    no-lock no-error.
if avail contnf
then do:
    find contrato were contrato.contnum = contnf.contnum no-lock no-error.
    if avail contrato
    then do:
        find vndseguro where vndseguro.contnum = contrato.contnum no-lock no-error.
        if avail vndseguro
        then do:
        end.
    end.
end.
                            
**/



create tt-p2k_recb_transacao.

        tt-p2k_recb_transacao.num_seq_forma = "1". 
        codigo_forma = if par-operacao = "TROCA" 
                       then "102"
                       else "1". 
        codigo_plano = if par-operacao = "TROCA"
                       then "2"
                       else "0". 
        valor_pago_forma = tt-p2k_cab_transacao.valor_total_venda.
        valor_acrescimo = "00,00".

if par-operacao = "TROCA"
then do:
    hide message no-pause.
    message "Chamando SAFE...".
    
    run hnc/wcsafe.p (input int(tt-p2k_cab_transacao.codigo_loja),      /* ETB */
                    input tt-titdev.titvlcob,   /* VALOR */
                    input if avail neuclien
                          then neuclien.clicod
                          else 1,
                    input pcpf, /* CPF */
                    input plani.pladat, /* */ 
                    input plani.etbcod,
                    input ori-cmon.cxacod,
                    input ori-pdvdoc.sequencia,
                    input vseq, 
                    output vMensagemPDV,
                    output vNSUSafe,
                    output vTextoCupom, 
                    output vCartao).

        /*
        message "NSUSafe=" vNSUSafe "Cartao=" vCartao. 
        message vmensagemPdv.
        */
        hide message no-pause.
        message "Retorno SAFE...".

        if vmensagemPdv = "TRANSAC APROVADA" 
        then do:
            message vTextoCupom view-as alert-box.
        end. 
        else do:
            message vmensagemPdv view-as alert-box.
        end.
        
end.
else do:
    vmensagemPdv = "TRANSAC APROVADA".
end.


if vmensagemPdv = "TRANSAC APROVADA" 
then do:
     hide message no-pause.
     message "Gravando Movimento...".
     run hnc/hcgeramov.p (string(cmon.cxacod), output p-recmov).

     hide message no-pause.
     message "Emitindo NFE...".
     
     run hnc/gera-devol_v1806.p (p-recmov). 

     /* copia sem messages de   run /u/bsip2k/progr/ileb/gera-devol_v1806.p (p-recmov).*/
         
         
     vretorno = "ERRO".
     find first pdvmov where recid(pdvmov) = p-recmov no-lock no-error.
     if avail pdvmov
     then do:
        find first pdvdoc of pdvmov no-lock no-error.
        if avail pdvdoc
        then do:
            if pdvdoc.placod <> 0 and
               pdvdoc.placod <> ?
            then do:   
                find first plani where plani.etbcod = pdvdoc.etbcod and
                                       plani.placod = pdvdoc.placod
                                       no-lock no-error.
                if avail plani
                then do:
                    vretorno = "SUCESSO".
                end.
            end.
        end.
     end.
     
     hide message no-pause.
     message "Retorno..." vretorno.
      
    if vretorno = "SUCESSO"
    then do:
        def var vmovseq as int. 
        for each tt-devolver.
            find first devmovim where
                devmovim.etbcod = tt-devolver.etbcod and
                devmovim.placod = tt-devolver.placod and
                devmovim.procod = tt-devolver.procod
                no-lock no-error.
            if not avail devmovim
            then do:
                find plani where plani.etbcod = tt-devolver.etbcod and
                                 plani.placod = tt-devolver.placod
                                 no-lock.
                find last devmovim where devmovim.etbcod = plani.etbcod and
                                         devmovim.placod = plani.placod and
                                         devmovim.movtdc = plani.movtdc
                                  no-lock no-error.
                if avail devmovim
                then vmovseq = devmovim.movseq + 1.
                else vmovseq = 1.

                /* to na duvida
                create devmovim.
                assign devmovim.etbcod = plani.etbcod 
                       devmovim.placod = plani.placod
                       devmovim.procod = tt-devolver.procod
                       devmovim.movseq = vmovseq
                       devmovim.movtdc = plani.movtdc
                       devmovim.movdat  = today.
                **/
                       
            end.
        end.
 
        for each tt-xmlretorno. delete tt-xmlretorno. end.
        hide message no-pause.
        message "Autorizando SAFE...".
        run hnc/wssafe.p ("ConfirmaDesfazGenerico").
        
    end.
    
    hide message no-pause.
    
    if par-operacao = "TROCA" or
       vretorno <> "SUCESSO"
    then do:
        message vretorno
            view-as alert-box.
    end.
    else do:
         find first pdvmov where recid(pdvmov) = p-recmov no-lock no-error.
         if avail pdvmov
         then do:
            find first pdvdoc of pdvmov no-lock no-error.
            if avail pdvdoc
            then do:
                if pdvdoc.placod <> 0 and
                   pdvdoc.placod <> ?
                then do:   
                    find first plani where plani.etbcod = pdvdoc.etbcod and
                                           plani.placod = pdvdoc.placod
                                           no-lock no-error.
                    if avail plani
                    then do:
                    end.
                end.
            end.
         end.
         if avail plani
         then do:
             message
                    vretorno
                    skip
                    "NF DEVOLUCAO " plani.numero skip
                    "ENTRAR EM CONTATO COM SETOR FACILITA" skip
                    "PARA ESTORNO FINANCEIRO DO CLIENTE"
                    view-as alert-box.
                    
            end.
            else
            message vretorno 
                skip
                "VALOR A DEVOLVER: R$ "
                trim(string(tp-plani.devolver,">>>>>>>>9.99"))
                    view-as alert-box.
                            
    end.

end.
