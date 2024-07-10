/* 03032023 helio - Orquestra 473879 - Relatório PMTs */
{admcab.i}     
def var tipo-atualiza as char format "x(70)" extent 10
    initial["01- Renegociacoes de Novacoes",
            "02- Contratos com Carteiras Trocadas (Rejeitados e outros)", 
            "03- Extracao de CSV - Relatorios PMT",
            ""].    
        
            display tipo-atualiza no-label with frame 
                      f-atualiza centered.
            choose field tipo-atualiza with frame f-atualiza.
            hide frame f-atualiza no-pause.
            if frame-index = 1
            then run finct/relnegnov.p.
            if frame-index = 2
            then run finct/trocarini.p.

            /* helio 09032023 */
            if frame-index = 3
            then run finct/rexppmt.p.
            /**/
            
