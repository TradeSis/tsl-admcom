def var vlimite as dec.
def var assunto as char.
def var vaspas as char format "x".
vaspas = chr(34).
def var varquivo as char.
{/admcom/progr/cntgendf.i}
/***
if search("/admcom/dg/lim001.ini") <> ?
then do :
    input from /admcom/dg/lim001.ini.
        import vlimite.
    input close.
end.
***/
find first tbcntgen where tbcntgen.etbcod = 1 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

vlimite = tbcntgen.valor.

if vlimite = 0
then vlimite = 3000.

def var vsaldo-lim as dec init 4000.

def var vtot as dec.
def var p-clicod as int.
def var vsaldo-cli as dec.
def buffer bplani for plani.

for each estab where estab.etbcod <= 900 no-lock:
    if {conv_igual.i estab.etbcod} then next.
    for each plani where plani.movtdc = 5
        and plani.pladat = today
        and plani.etbcod = estab.etbcod
        no-lock:
        find first clien where clien.clicod = plani.desti no-lock no-error.
        if not avail clien
        then next.

        find first func where func.funcod = plani.vencod no-lock no-error.
        if not avail func
        then next.

        vsaldo-cli = 0.
        if plani.crecod = 2
        then do:
            /*run dg027.*/
        end.
        
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

        p-clicod = clien.clicod.
        {hiscli00.i}.
        
        varquivo = "/admcom/work/arquivodg001.htm".
        
        output to value(varquivo).

           put "<html>" skip
               "<body>" skip
               /*****
               "<IMG SRC="
               vaspas
               "http://geocities.yahoo.com.br/morpheurgs/lebes.jpg" 
               vaspas 
               ">"
               "</IMG>" skip
               "<IMG SRC="
               vaspas
               "http://geocities.yahoo.com.br/morpheurgs/logo.jpg" 
               vaspas
               ">"
               "</IMG>" skip
               *******/    /*
               "<br><br>"*/ skip
               
               "<table border=" vaspas "0" vaspas "summary=>" skip
               "<tr>" skip
               "<td width=756 align=center><b><h2>VENDA MAIOR QUE R$ "
               vlimite
               "</h2></b></td>" skip
               "</tr>" skip
               "</table>" skip
               
               "<table border=" vaspas "3" vaspas "borderColor=green summary=>"
               "<tr>"
               "<td width=756 align=center><b>DADOS DA VENDA</b></td>"
               "</tr>"
               "</table>"
               
               
               "<table border=" vaspas "3" vaspas " borderColor=green>" skip
               "<tr>" skip

               "<td width=100 align=left><b>Numero :</b></td>" skip
               "<td width=650 align=left> " plani.numero format ">>>>>>9"
               "</td>" skip
               "</tr>" skip
               "<tr>"  skip

               "<td width=100 align=left><b>Serie :</b></td>" skip
               "<td width=650 align=left> " plani.serie  "</td>" skip
               "</tr>" skip
               "<tr>"  skip  
               "<td width=100 align=left><b>Data :</b></td>"  skip
               "<td width=650 align=left> " plani.pladat format "99/99/9999"
               "</td>"  skip
               "</tr>"  skip
               "<tr>"   skip
               "<td width=100 align=left><b>Valor :</b></td>" skip.
               
               if plani.biss <> 0
               then
                   put "<td width=650 align=left>R$&nbsp;" plani.biss
                       "</td>" skip.
               else
                   put "<td width=650 align=left>R$&nbsp;" plani.platot 
                       "</td>" skip.
               
               put
               "</tr>" skip
               "<tr>"  skip.

               put
               "<td width=100 align=left><b>Limite :</b></td>" skip
               "<td width=650 align=left>R$ " vlimite "</td>" skip
               "</tr>" skip
               "<tr>" skip
               "<td width=100 align=left><b>Vendedor :</b></td>" skip
               "<td width=650 align=left>" func.funnom  " (" func.funcod ") "
               "</td>"  skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=100 align=left><b>Cliente :</b></td>" skip
               "<td width=650 align=left>" clien.clinom " (" clien.clicod ") "
               "</td>" skip
               "</tr>" skip
               "<tr>" skip
               "<td width=100 align=left><b>Dt.Cadastro:</b></td>" skip
               "<td width=650 align=left>" clien.dtcad format "99/99/9999"
               "</td>" skip
               "</tr>" skip
               "</table>" skip
               "<br><br>" skip
               "<table border=3 borderColor=green summary=>" skip
               "<tr>" skip
               "<td width=756 align=center><B>ANALISE DO CLIENTE</B></td>" skip
               "</tr>" skip
               "</table>" skip
               "<table border=" vaspas "3" vaspas " borderColor=green>" skip
               "<tr>" skip
               "<td width=150 align=left><b>Limite:</b></td>" skip
               "<td width=600 align=left> " clien.limcrd "</td>" skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Saldo Aberto:</b></td>" skip
               "<td width=580 align=left> " sal-aberto "</td>"     skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Limite Calculado:</b></td>" skip
               "<td width=580 align=left> " lim-calculado "</td>" skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Ultima Compra:</b></td>" skip
               "<td width=580 align=left> " ult-compra "</td>" skip

               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Qtd. Contrato:</b></td>" skip
               "<td width=580 align=left> "  qtd-contrato "</td>"   skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Parcelas Pagas:</b></td>" skip
               "<td width=580 align=left> "  parcela-paga "</td>"    skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Parcelas Abertas:</b></td>" skip
               "<td width=580 align=left> "  parcela-aberta "</td>" skip
               "</tr>" skip
               "<tr>" skip
               "<td width=150 align=left><b>Atraso até 15 dias:</b></td>" skip
               "<td width=580 align=left>" qtd-15 " Dias " (qtd-15 * 100) / parcela-paga     format ">>9.99%" "</td>" skip
               "</tr>" skip
               "<tr>" skip
               "<td width=150 align=left><b>Atraso de 15 a 45 dias:</b></td>"
               skip
               "<td width=580 align=left>" qtd-45 " Dias " (qtd-45 * 100) / parcela-paga format ">>9.99%" 
               "</td>" skip
               "</tr>" skip
               "<tr>"  skip

               "<td width=150 align=left><b>Atraso acima de 46 dias: </b></td>"
               skip
               "<td width=580 align=left>" qtd-46  " Dias " (qtd-46 * 100) / parcela-paga  format ">>9.99%" 
               "</td>" skip
               "</tr>" skip
               "<tr>"  skip

               "<td width=150 align=left><b>Media Mensal:</b></td>" skip
               "<td width=580 align=left>" vtotal / vqtd "</td>" skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Prestacao Media:</b></td>" skip
               "<td width=580 align=left>" v-media "</td>" skip
               "</tr>" skip
               "<tr>" skip

               "<td width=150 align=left><b>Valor Proximo Mes:</b></td>" skip
               "<td width=580 align=left>" proximo-mes "</td>" skip
               "</tr>" skip
               "<tr>" skip
               "<td width=150 align=left><b>Maior Acumulo:</b></td>" skip
               "<td width=580 align=left>"  v-acum "</td>" skip
               "</tr>" skip
               "<tr>" skip
               "<td width=150 align=left><b>Mes/Ano:</b></td>" skip
               "<td width=580 align=left>" v-mes "/" v-ano "</td>" skip
               "</tr>" skip
               "<tr>" skip
               "<td width=150 align=left><b>Reparcelamento:</b></td>" skip
               "<td width=580 align=left>" vrepar  "</td>" skip
               "</tr>" skip
               "<tr>" skip

               "<td width=150 align=left><b>Maior Atraso:</b></td>" skip
               "<td width=580 align=left>" (today - maior-atraso) "</td>"
               skip
               "</tr>" skip
               "<tr>" skip
               "<td width=150 align=left><b>Vencidas:</b></td>" skip
               "<td width=580 align=left>" vencidas "</td>" skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Loja:</b></td>" skip
               "<td width=580 align=left>"  plani.etbcod "</td>" skip
               "</tr>" skip
               "</table>" skip
               "<br><br>" skip.
               put
               "<table border=" vaspas "3" vaspas "borderColor=green summary=>"
               "<tr>"
               "<td width=756 align=center><b>PRODUTOS</b></td>"
               "</tr>"
               "</table>"
               
               "<table border=3 borderColor=green>" skip
               "<tr>" skip
                    
               "<td width=100 align=left><b>Codigo</b></td>" skip
               "<td width=488 align=left><b>Descricao</b></td>" skip
               "<td width=50 align=rigth><b>Qtd</b></td>" skip
               "<td width=100 align=right><b>Preco</b></td>" skip
               "</tr>" skip.



            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod no-lock :
                find first produ where produ.procod = movim.procod no-lock.


                put skip
                    "<tr>"
                    skip
                    "<td width=100 align=left>" produ.procod format ">>>>>>>9"
                    "</td>"
                    skip
                    "<td width=488 align=left>" produ.pronom format "x(40)"
                    "</td>"
                    skip
                    "<td width=50 align=rigth>" movim.movqtm format ">>>9"
                    "</td>"
                    skip
                    "<td width=100 align=right>" movim.movpc format ">>,>>9.99"
                    "</b></td></tr>" skip.
           end.

           put "</table>" skip 
               "</body>"  skip
               "</html>".

        output close.
        find bplani where bplani.etbcod = plani.etbcod and
                          bplani.placod = plani.placod and
                          bplani.serie  = plani.serie
                          exclusive no-wait no-error.
        if avail bplani
        then bplani.nottran = 1.

        run /admcom/progr/envia_dg.p("1",varquivo).
        
    end.       
end.

procedure dg027:
    def var valvenda as dec.
    vsaldo-cli = 0.
    for each titulo where titulo.clifor = plani.desti no-lock:
        if titulo.titsit = "LIB"
        then vsaldo-cli = vsaldo-cli + titulo.titvlcob.
    end.
    if vsaldo-cli > vsaldo-lim
    then do:
        if plani.biss <> 0
        then valvenda =  plani.biss.
        else valvenda = plani.platot.

        varquivo = "/admcom/work/arquivodg027.txt".
        
        output to value(varquivo).
        
        put unformatted
        "COMPROU FICOU SALDO > " vsaldo-lim " <BR>" skip
        "---------------------------------------------- <BR>" skip
        "__Filial: " plani.etbcod  "<BR>" skip
        "_Cliente:" clien.clinom + " (" + string(clien.clicod) + "( <BR>" skip
        "Vl.Saldo:" vsaldo-cli "<BR>" skip
        "NF.Venda:" plani.numero "<BR>" skip
        "Dt.Venda:" plani.pladat "<BR>" skip
        "Vl.Venda:" valvenda     "<BR>" skip
        "Vendedor:" func.funnom "<BR>" skip
        "---------------------------------------------- <BR>" skip
        .        
        output close.
        
        run /admcom/progr/envia_dg.p("27",varquivo).
    end.
end procedure.
