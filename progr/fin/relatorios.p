{admcab.i}     
def var tipo-atualiza as char format "x(50)" extent 10
    initial[/*1*/ " 1-Relatorio de Credito Pessoal",
            /*2*/ " 2-esumo Mensal de Caixa",
            /*3*/ " 3-Resumo das Liquidacoes",
            /*4*/ " 4-Exporta CSV pagamentos boleto",
            /*5*/ " 5-Relatorio de Pagamentos Parciais",
            /*6*/ " 6-Relatorio de divergencia de juros",              
            /*7*/ " 7-Exporta CSV Duplicidade Pgto Boletos",
            /*8*/ " 8-Exporta CSV Limites de Clientes",
            /*9*/ " 9-Relatorio de Trocas de Carteiras",
            /*10*/ ""
            ].    
        
            display tipo-atualiza no-label with frame 
                      f-atualiza centered
                      title " RELATORIOS ".
            choose field tipo-atualiza with frame f-atualiza.
            hide frame f-atualiza no-pause.
            if frame-index = 1 /*1*/
            then run rel_cp_0119.p.

            if frame-index = 2 /*2*/
            then run cre02.p.

            if frame-index = 3 /*3*/
            then run resliq.p.
            
            if frame-index = 4 /*4*/
            then run fin/exppgmoeda.p.         
            
            if frame-index = 5 /*5*/
            then run fin/relparcial.p.

            if frame-index = 6 /*6*/
            then run  fin/reldivjur.p (no,no).
                
            if frame-index = 7 /*7*/
            then run fin/rboldiverg.p (input tipo-atualiza[frame-index]).         

            if frame-index = 8 /*8*/
            then run fin/gercli316878.p (input tipo-atualiza[frame-index]).
            
            if frame-index = 9 /*8*/
            then run finct/trocarini.p.
            