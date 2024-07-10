/* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Seleção de moeda a vista na Pré-Venda  */

/* helio 23022022 ajuste menu */
{admcab.i}     
def var tipo-atualiza as char format "x(60)" extent 11
    initial["-", /*"Parametros Novacao de Campanha", */
            "-", /*"Parametros Limites por Area",*/
            "Parametros De boletos",
            "parametros de Validacao Sicred",
            "Planos para HubSeg",
            "Parametros Zurich Seguro Prestamista",
            "Parametros de Promocao a Vista na PreVenda - pede moeda ",
            "Parametros Acordo Online", /*8*/
            "Parametros Define Carteira", /*9*/
            ""].    
        
            display tipo-atualiza no-label with frame 
                      f-atualiza centered 1 col.
            choose field tipo-atualiza with frame f-atualiza.
            hide frame f-atualiza no-pause.
            /*if frame-index = 1    retirado em 26/10/2021 ID 94590 
            then run fin/novcamp.p. */ 
            /* if frame-index = 2
            then run fin/limarea.p. projeto nao foi para frente */
            
            if frame-index = 3
            then run fin/estboleto.p.
            if frame-index = 4
            then run fin/opesicparam.p.
            if frame-index = 5
            then run seg/segplanprodu.p.
            
            if frame-index = 6
             then run seg/segprespar.p.

            if frame-index = 7
            then run pdv/promavista.p.
            
            if frame-index = 8
            then run aco/acoparamini.p.
            
            if frame-index = 9 then run  fin/cobparam.p            .
