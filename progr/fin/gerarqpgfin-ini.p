{admcab.i}     
def var tipo-atualiza as char format "x(50)" extent 2
    initial[/*1*/ "GERA ARQUIVO DE PAGAMENTOS - CONTRATO",
            /*2*/ "GERA ARQUIVO DE PAGAMENTOS - PARCELA"
            ].    
        
            display tipo-atualiza no-label with frame 
                      f-atualiza centered
                      title "  ".
            choose field tipo-atualiza with frame f-atualiza.
            hide frame f-atualiza no-pause.
            
            if frame-index = 1 /*1*/
            then run gerarqpgfin_v23.p.

            if frame-index = 2 /*2*/
            then run gerarqpgfin-vtit.p.
            
            