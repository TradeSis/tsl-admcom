def var vaspas as char format "x(1)".
vaspas = chr(34).
                                                  
def var vlimite as dec.
def var assunto as char.
def var vpreco  as dec.
def var vvalor  as dec.

{/admcom/progr/cntgendf.i}
/**
if search("/admcom/dg/pro-menor.ini") <> ?
then do :
    input from /admcom/dg/pro-menor.ini.
        set vvalor.
    input close.
end.
**/
def var varquivo as char.
find first tbcntgen where tbcntgen.etbcod = 3 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.
vvalor = tbcntgen.valor.

if vvalor = 0
then vvalor = 300.

for each estab where estab.etbcod <= 900 no-lock :
    
    if {conv_igual.i estab.etbcod} then next.
    
    for each movim where movim.movdat = today 
                    and movim.etbcod = estab.etbcod
                    and movim.movtdc = 5 
                    use-index movdat  : 
                    
        find first produ where produ.procod = movim.procod no-lock no-error.
        find first estoq where estoq.etbcod = movim.etbcod
                           and estoq.procod = movim.procod no-lock.
        
        vpreco = 0.
        if estoq.estprodat >= today and estoq.estproper > 0
        then do :
            if movim.movpc >= estoq.estproper
            then next.
            vpreco = estoq.estproper.
        end.
        else do :
            if movim.movpc >= estoq.estvenda 
                         then next.
            vpreco = estoq.estvenda.
        end.
        
        if (vpreco - movim.movpc) <= (vpreco * (vvalor / 100))
        then next.
                  
        if movim.ocnum[1] > 1 then next.
                
        find first plani where plani.etbcod = movim.etbcod
                           and plani.placod = movim.placod
                           and plani.pladat = movim.movdat
                         use-index plani no-lock.
                         
        find first clien where clien.clicod = plani.desti no-lock.
        find first func where func.funcod = plani.vencod no-lock no-error.
        if not avail func then next.

        varquivo = "/admcom/work/arquivodg003.htm".
        output to value(varquivo).
        
            put "<html>" skip
                "<body>" skip
               /****
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
               "<br><br>"
               ****/
               skip
               
               "<table border=" vaspas "0" vaspas "summary=>" skip
               "<tr>" skip
               "<td width=766 align=center><b><h2>Produto_Vendido_a_Menor"
               "</h2></b></td>" skip
               "</tr>" skip
               "</table>" skip
               
               "<table border=" vaspas "3" vaspas "borderColor=green summary=>"
               "<tr>"
               "<td width=766 align=center><b>DADOS DO PAGAMENTO</b></td>"
               "</tr>"
               "</table>"
            
               "<table border=" vaspas "3" vaspas " borderColor=green>" skip.

            put "<tr>" skip
                "<td width=100 align=left><b>Produto :</b></td>"  skip
                "<td width=650 align=left>" 
                produ.pronom " ( " produ.procod " ) "
                "</td>" skip
                "</tr>" skip.
             
            put "<tr>" skip
                "<td width=110 align=left><b>Preco Original :</b></td>"  skip
                "<td width=650 align=left>" "R$ " vpreco format ">>,>>9.99"
                "</td>" skip
                "</tr>" skip.
            
            put "<tr>" skip
                "<td width=110 align=left><b>Preco Vendido :</b></td>"  skip
                "<td width=650 align=left>" "R$ " movim.movpc format ">>,>>9.99"
                "</td>" skip
                "</tr>" skip.

            put "<tr>" skip
                "<td width=100 align=left><b>Numero :</b></td>"  skip
                "<td width=650 align=left>" plani.numero format ">>>>>>>>9"
                "</td>" skip
                "</tr>" skip.

            put "<tr>" skip
                "<td width=100 align=left><b>Loja :</b></td>"  skip
                "<td width=650 align=left>" plani.etbcod
                "</td>" skip
                "</tr>" skip.

            put "<tr>" skip
                "<td width=100 align=left><b>Cliente :</b></td>"  skip
                "<td width=650 align=left>" clien.clinom
                "</td>" skip
                "</tr>" skip.

            put "<tr>" skip
                "<td width=100 align=left><b>Vendedor :</b></td>"  skip
                "<td width=650 align=left>" func.funnom
                "</td>" skip
                "</tr>" skip.

            put "</table>" skip
                "</body>" skip
                "</html>".


        output close.

        run /admcom/progr/envia_dg.p("3",varquivo).

        pause 3.   
        movim.ocnum[1] = 2.
    end.
end.