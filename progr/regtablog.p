{admcab.i}
def input parameter p-recid as recid.

find first tablog where recid(tablog) = p-recid no-lock no-error.
if not avail tablog
then return.

def temp-table ctpromoc like ctpromoc.
def temp-table tt-tabmix like tabmix
index i1 etbcod.
if tablog.tabela = "tabmix"
then do:
    create tt-tabmix.
    raw-transfer tablog.antes to tt-tabmix.

    create tt-tabmix.
    raw-transfer tablog.depois to tt-tabmix.
    find first tt-tabmix no-lock no-error.
    if avail tt-tabmix
    then run consulta-tabmix.
     
end.
if tablog.tabela = "ctpromoc"
then do:
    if substr(string(tablog.acao),1,6) = "ALTERA" or
       substr(string(tablog.acao),1,6) = "INCLUI"
    then do:
        create ctpromoc.
        raw-transfer tablog.depois to ctpromoc.
    end.
    else do:
        create ctpromoc.
        raw-transfer tablog.antes to ctpromoc.
    end.
    find first ctpromoc no-lock no-error.
    if avail ctpromoc
    then run consulta-ctpromoc.
end.
def var vtitle as char.
form ctpromoc.promocod   at 4 label "Promocao"
     tbpromoc.descricao no-label     
     /*tipo-promoc label "Tipo"  */
     ctpromoc.dtinicio at 1  
                  label "Data Inicio" format "99/99/9999"
     ctpromoc.dtfim    
                label "Data Fim"    format "99/99/9999"
     ctpromoc.descricao[1] at 3 label "Descricao" format "x(65)"
     ctpromoc.descricao[2] at 14 no-label    format "x(65)"
     ctpromoc.precoliberado at 1 label "Liberar  preco"
     ctpromoc.liberavenda   at 33   label "Libera plano"
     ctpromoc.precosugerido at 1 label "Preco sugerido"
     ctpromoc.vendaacimade label "Venda acima de R$"
     ctpromoc.campodec2[3] label "Ate R$"
     ctpromoc.campodec2[4] format ">9" label "Qtd Venda"
     ctpromoc.campodec2[5] format ">9" label "a"
     ctpromoc.campolog3    label "Valor a vista? " format "Sim/Nao" to 49
     ctpromoc.campolog4    label "Unitario?" format "Sim/Nao" to 70  
     /*skip(1)*/
     ctpromoc.bonusvalor      at 1 label "Bonus ->Valor  "
                format ">>>9.99"
     ctpromoc.cartaovalor     at 26  label "Cartao ->Valor  "
                format ">>>9.99"     
     ctpromoc.descontovalor   at 52  label "Desconto ->Valor "
                format ">>>9.99"
     ctpromoc.bonusparcela    at 1 label "      ->Parcela"
     ctpromoc.cartaoparcela   at 24  label "         ->Parcela"
     ctpromoc.descontopercentual   at 52  label "        ->Percent"
     ctpromoc.bonuspercentual at 1 label   "      ->Percent"
     ctpromoc.cartaopercentual at 26 label "       ->Percent"
     /*skip(1)*/
     ctpromoc.valvendedor     at 1 label "Vendedor->Valor"
            format ">>>9.99"
     ctpromoc.valgerente           label "Gerente -> Valor"
            format ">>>9.99"
     ctpromoc.valsupervisor        label "Supervisor->Valor"
            format ">>>9.99"
     ctpromoc.pctvendedor     at 1 label "      ->Percent"
     ctpromoc.pctgerente           label "      -> Percent"
     ctpromoc.pctsupervisor        label "       -> Percent"
     ctpromoc.campodec2[1]    at 1 label "Promotor->Valor"
            format ">>>9.99"
     ctpromoc.campodec2[2]    at 1 label "      ->Percent"   
            format ">>9.99%"
     /*skip(1)*/  
     ctpromoc.perguntaprodutousado at 1 label "Exigir produto usado"
     ctpromoc.campolog1    at 40 format "Sim/Nao"  label "Mensagem na tela"
     ctpromoc.geradespesa at 1 label "Gerar Despesa Financeira"
     ctpromoc.recibo      at 40 label "Emitir Recibo da Despesa"
     with frame f-add1 1 down side-label width 80 row 4
                title vtitle overlay.
 
procedure consulta-tabmix:
    for each tt-tabmix:
    disp tt-tabmix.etbcod 
         tt-tabmix.promix
         tt-tabmix.campolog2.
    end.
end procedure.
procedure consulta-ctpromoc.
    vtitle = "    C O N S U L T A      Promocao: " + 
            string(ctpromoc.sequencia) + "   ".
    do:
        find tbpromoc where
             tbpromoc.promocod = ctpromoc.promocod no-lock .
        disp    ctpromoc.promocod
                tbpromoc.descricao      
                ctpromoc.dtinicio
                ctpromoc.dtfim 
                ctpromoc.descricao[1]
                ctpromoc.descricao[2]
                with frame f-add1 .
        disp  
                ctpromoc.precoliberado 
                ctpromoc.liberavenda
                ctpromoc.precosugerido 
                ctpromoc.vendaacimade 
                ctpromoc.campodec2[3]
                ctpromoc.campodec2[4] 
                ctpromoc.campodec2[5] 
                ctpromoc.campolog3
                ctpromoc.campolog4
                with frame f-add1.
        disp  
                ctpromoc.bonusvalor      
                ctpromoc.bonusparcela    
                ctpromoc.bonuspercentual 
                ctpromoc.cartaovalor      
                ctpromoc.cartaoparcela   
                ctpromoc.cartaopercentual 
                ctpromoc.descontovalor
                ctpromoc.descontopercentual
                ctpromoc.valvendedor      
                ctpromoc.pctvendedor    
                ctpromoc.valgerente 
                ctpromoc.pctgerente      
                ctpromoc.valsupervisor   
                ctpromoc.pctsupervisor 
                ctpromoc.campodec2[1]
                ctpromoc.campodec2[2]
                ctpromoc.perguntaprodutousado 
                ctpromoc.campolog1
                ctpromoc.geradespesa 
                ctpromoc.recibo
                with frame f-add1 . 
        pause.
    end. 
end procedure.
