def input parameter par-recid-pdvmov   as recid.

find pdvmov where recid(pdvmov) = par-recid-pdvmov no-lock.

def var mmenu as char extent 10 format "x(42)" init
    ["Mov      -> p2k_cab transacao e pagamento",
     "Doc      -> p2k_info_pagamento",
     "Forma    -> p2k_recb_transacao",
     "Moeda    -> p2k_recb_cartao, cred e cheque",
     "Itens    -> p2k_item_transacao",
     "Campanha -> p2k_item_campanha",
     "Garantia -> p2k_item_garantia",
     "Credseg  -> p2k_receb_cred_seg",
     "Pedidos  -> p2k_cab_pedido",
     "Generico -> p2k_campo_generico"].
pause 0.
repeat.
    disp mmenu with frame f-menu 1 col no-label col 35 row 11 overlay.
    choose field mmenu with frame f-menu.

    if frame-index > 0
    then
        disp
            pdvmov.etbcod
            pdvmov.datamov
            pdvmov.cmocod format ">>>,>>>"
            pdvmov.sequencia        
            pdvmov.ctmcod   
            with frame f-cab row 4 no-box side-label color message.

    if frame-index = 1
    then do.
        disp pdvmov with 2 col  with frame f-pdvmov.
        disp pdvmov.cmocod format ">>>,>>>" with frame f-pdvmov.
        pause.
        hide frame f-pdvmov.
    end.
    else if frame-index = 2
    then run dpdv/p2kdoc.p (recid(pdvmov)).

    else if frame-index = 3
    then run dpdv/p2kforma.p (recid(pdvmov)).

    else if frame-index = 4  /*trabalhando aqui*/
    then run dpdv/p2kmoeda.p (recid(pdvmov)).
     
    else if frame-index = 5
    then run dpdv/p2kitem.p (recid(pdvmov)).

    else if frame-index = 6
    then run dpdv/p2kitemcampanha.p (recid(pdvmov)).

    else if frame-index = 7
    then run dpdv/p2kgarantia.p (recid(pdvmov)).

    else if frame-index = 8
    then run dpdv/p2kcredseg.p (recid(pdvmov)).
    
    else if frame-index = 9
    then run dpdv/p2kpedido.p (recid(pdvmov)).
    
    else if frame-index = 10
    then run dpdv/p2kgenerico.p (recid(pdvmov)).
         
end.
hide frame f-menu no-pause.
hide frame f-cab no-pause.
