def var vlimite as dec.
def var assunto as char.
def var vaspas as char format "x".
vaspas = chr(34).

if search("/admcom/dg/lim001.ini") <> ?
then do :
    input from /admcom/dg/lim001.ini.
        set vlimite.
    input close.
end.

if vlimite = 0
then vlimite = 1000.

def var vtot as dec.
def var p-clicod as int.

for each estab where estab.etbcod <= 900 no-lock:

    if {conv_igual.i estab.etbcod} then next.

    for each plani where plani.movtdc = 5
        and plani.pladat = today
        and plani.etbcod = estab.etbcod:

        if plani.biss <> 0
        then do:
            if plani.biss < vlimite
            then next.
        end.
        else do:
            if plani.platot < vlimite
            then next.
        end.

        if plani.desti = 1
        then next.

        vtot = 0.
        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod no-lock:
            vtot = vtot + (movim.movpc * movim.movqtm).
        end.
        
        if plani.biss <> 0
        then do:
            if vtot <> plani.biss then next.
        end.
        else do:
            if vtot <> plani.platot then next.
        end.            
        
        if plani.nottran > 0 then next.

        find first clien where clien.clicod = plani.desti no-lock no-error.
        if not avail clien
        then next.

        find first func where func.funcod = plani.vencod no-lock no-error.
        if not avail func
        then next.

        p-clicod = clien.clicod.
        {hiscli00.i}.
        
        output to /admcom/work/arquivodg001.txt.

           put "VENDA MAIOR QUE R$ "
               vlimite skip
               "DADOS DA VENDA" skip
               "Numero : " 
               plani.numero format ">>>>>>9"
               skip(3)

               "Serie : " skip
               plani.serie skip
               skip
               skip  
               "Data :  "  skip
               plani.pladat format "99/99/9999"
               skip
               skip
               skip
               "Valor : " skip.
               
               if plani.biss <> 0
               then
                   put "R$ " plani.biss
                       skip.
               else
                   put "R$ " plani.platot 
                       skip.
               
               put
               "Limite : " 
               " R$ " 
               vlimite  skip
               skip
               "Vendedor : " skip
               func.funnom  
               skip
               "Cliente :  " skip
               clien.clinom  
               skip
               skip
               skip
               "Dt.Cadastro: " skip
               clien.dtcad format "99/99/9999"
               skip
               skip
               skip
               skip
               skip
               skip
               "ANALISE DO CLIENTE" skip
               skip
               skip
               skip
               skip
               "Limite: " skip
               clien.limcrd  skip
               skip
               skip
               "Saldo Aberto: " skip
               sal-aberto       skip
               "Limite Calculado: " skip
               lim-calculado  skip
               "Ultima Compra: " 
               ult-compra  skip
               "Qtd. Contrato: " 
               qtd-contrato    skip
               "Parcelas Pagas: " 
               parcela-paga   skip
               "Parcelas Abertas: " 
               parcela-aberta  skip
               "Atraso até 15 dias: " 
               qtd-15  " Dias "  (qtd-15 * 100) / parcela-paga format ">>9.99%"                skip
               "Atraso de 15 a 45 dias: "
               qtd-45  " Dias "  (qtd-45 * 100) / parcela-paga format ">>9.99%" 
               skip
               "Atraso acima de 46 dias: "
               qtd-46  " Dias " (qtd-46 * 100) / parcela-paga  format ">>9.99%"                skip
               "Media Mensal: " skip
               vtotal / vqtd  
               skip
               "Prestacao Media: " 
               v-media  skip
               "Valor Proximo Mes: " 
               proximo-mes  skip
               "Maior Acumulo: " 
               v-acum  skip
               "Mes/Ano: " 
               v-mes "/" v-ano  skip
               "Reparcelamento: " 
               vrepar   skip
               "Maior Atraso: " skip
               (today - maior-atraso) 
               skip
               "Vencidas: " 
               vencidas  skip
               "Loja: " 
               plani.etbcod  skip
               skip.

               put
               "PRODUTOS"
               skip
               "Codigo" 
               "Descricao" skip
               "Qtd" skip
               "Preco" 
               skip.



            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod no-lock :
                find first produ where produ.procod = movim.procod no-lock.


                put produ.procod format ">>>>>>>9"
                    produ.pronom format "x(40)"
                    movim.movqtm format ">>>9"
                    movim.movpc format ">>,>>9.99"
                    skip.
           end.

        output close.
        
        plani.nottran = 1.

/*****
 unix silent /usr/bin/metasend -b -s "Venda_Maior_que" -F guardian@lebes.com.br -f /admcom/work/arquivodg001.txt -m text/html -t claudir@custombs.com.br.
****/

    /*
        unix silent /usr/bin/metasend -b -s "Venda_Maior_que" -F guardian@lebes.com.br -f /admcom/work/arquivodg001.htm -m text/html -t julio@custombs.com.br.
        unix silent /usr/bin/metasend -b -s "Venda_Maior_que" -F informativo@lebes.com.br -f /admcom/work/arquivodg001.htm -m text/html -t rafael@lebes.com.br.

        unix silent /usr/bin/metasend -b -s "Venda_Maior_que" -F guardian@lebes.com.br -f /admcom/work/arquivodg001.htm -m text/html -t masiero@custombs.com.br.

        unix silent /usr/bin/metasend -b -s "Venda_Maior_que" -F informativo@lebes.com.br -f /admcom/work/arquivodg001.htm -m text/html -t henrique@lebes.com.br.
  */
    end.       
end.

