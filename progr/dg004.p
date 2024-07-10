def var vaspas as char format "x(1)".
vaspas = chr(34).

def var vlinha as char.
def var vlimite as dec.
def var assunto as char.
def var vjuro as dec.
def var vok as log.
def var p-clicod like clien.clicod.

def var vvalor  as dec.
def var varquivo as char.
{/admcom/progr/cntgendf.i}
/**
if search("/admcom/dg/valcliatraso.ini") <> ?
then do :
    input from /admcom/dg/valcliatraso.ini.
    
        set vlinha.
        /*import vvalor.*/
    input close.
end.
**/
find first tbcntgen where tbcntgen.etbcod = 4 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.
vlinha = tbcntgen.campo3[3].

def var vcon as int.
def var vdias as int.
def var a as char.
def var b as char.
def var prox as log init no.

do vcon = 1 to length(vlinha):

   if substring(vlinha,vcon,1) = ";"
   then prox = yes.

   if prox = no
   then  a = a + substring(vlinha,vcon,1).
   else if substring(vlinha,vcon,1) <> ";"
        then b = b + substring(vlinha,vcon,1).
   
end.

vvalor = int(a).
vdias = int(b).



if vvalor = 0
then vvalor = 1200.
if vdias = 0
then vdias = 10.

for each estab where estab.etbcod <= 900 no-lock :

   if  {conv_igual.i estab.etbcod} then next.

    for each plani where plani.movtdc = 5 
                     and plani.etbcod = estab.etbcod
                     and plani.pladat = today:

        if plani.biss <> 0
        then do:
            if plani.biss <= vvalor
            then next.
        end.
        else do:
            if plani.platot <= vvalor
            then next.
        end.

        if plani.nottran > 3 
        then next.

        if plani.desti = 1 
        then next.
    
        vok = yes.
        for each titulo where titulo.clifor = plani.desti no-lock :
            if titulo.titnat = yes 
            then next.
            if titulo.titdtven > (today - vdias) /*14)*/
            then next.
            if titulo.titsit <> "LIB" 
            then next.
            
            vok = no.
            leave.
        end.
        if vok = yes then next.

        find first clien where clien.clicod = plani.desti no-lock.
        
        find first func where func.funcod = plani.vencod no-lock no-error.
        find first finan where finan.fincod = plani.pedcod no-lock.
        find first contnf where contnf.etbcod = plani.etbcod
                            and contnf.placod = plani.placod  no-lock.

        p-clicod = clien.clicod.
        {hiscli00.i}.

        varquivo= "/admcom/work/arquivodg004.htm".
        
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
               "<td width=756 align=center><b><h2>VENDA PARA CLIENTE EM ATRASO"
               "</h2></b></td>" skip
               "</tr>" skip
               "</table>" skip
               
               "<table border=" vaspas "3" vaspas "borderColor=green summary=>"
               "<tr>"
               "<td width=756 align=center><b>DADOS DA VENDA</b></td>"
               "</tr>"
               "</table>"
            
               "<table border=" vaspas "3" vaspas " borderColor=green>" skip.

            put "<tr>" skip
                "<td width=150 align=left><b>Data da Venda :</b></td>"  skip
                "<td width=600 align=left>" plani.pladat format "99/99/9999"
                "</td>" skip
                "</tr>" skip.

            put "<tr>" skip
                "<td width=150 align=left><b>Contrato :</b></td>"  skip
                "<td width=600 align=left>" contnf.contnum format ">>>>>>>>9"
                "</td>" skip
                "</tr>" skip.
            
            put "<tr>" skip
                "<td width=150 align=left><b>Plano de Pagamento :</b></td>"
                skip
                "<td width=600 align=left>" finan.finnom
                "</td>" skip
                "</tr>" skip.
            
            put "<tr>" skip
                "<td width=150 align=left><b>Cliente :</b></td>"  skip
                "<td width=600 align=left>" clien.clinom 
                " ( " clien.clicod " ) "
                "</td>" skip
                "</tr>" skip
                "</table>" skip
                "<br><br>".

            put
               "<table border=3 borderColor=green summary=>" skip
               "<tr>" skip
               "<td width=756 align=center><B>ANALISE DO CLIENTE</B></td>" skip
               "</tr>" skip
               "</table>" skip
               "<table border=" vaspas "3" vaspas " borderColor=green>" skip
               "<tr>" skip
               "<td width=150 align=left><b>Limite:</b></td>" skip
               "<td width=560 align=left> " clien.limcrd "</td>" skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Saldo Aberto:</b></td>" skip
               "<td width=560 align=left> " sal-aberto "</td>"     skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Limite Calculado:</b></td>" skip
               "<td width=560 align=left> " lim-calculado "</td>" skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Ultima Compra:</b></td>" skip
               "<td width=560 align=left> " ult-compra "</td>" skip

               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Qtd. Contrato:</b></td>" skip
               "<td width=560 align=left> "  qtd-contrato "</td>"   skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Parcelas Pagas:</b></td>" skip
               "<td width=560 align=left> "  parcela-paga "</td>"    skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Parcelas Abertas:</b></td>" skip
               "<td width=560 align=left> "  parcela-aberta "</td>" skip
               "</tr>" skip
               "<tr>" skip
               "<td width=170 align=left><b>Atraso até 15 dias:</b></td>" skip
               "<td width=560 align=left>" qtd-15 " Dias " (qtd-15 * 100) / par~cela-paga     format ">>9.99%" "</td>" skip
               "</tr>" skip
               "<tr>" skip
               "<td width=170 align=left><b>Atraso de 15 a 45 dias:</b></td>"
               skip
               "<td width=560 align=left>" qtd-45 " Dias " (qtd-45 * 100) / par~cela-paga format ">>9.99%" 
               "</td>" skip
               "</tr>" skip
               "<tr>"  skip

               "<td width=170 align=left><b>Atraso acima de 46 dias: </b></td>"
               skip
               "<td width=580 align=left>" qtd-46  
               " Dias " (qtd-46 * 100) / parcela-paga  format ">>9.99%" 
               "</td>" skip
               "</tr>" skip
               "<tr>"  skip

               "<td width=150 align=left><b>Media Mensal:</b></td>" skip
               "<td width=560 align=left>" vtotal / vqtd "</td>" skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Prestacao Media:</b></td>" skip
               "<td width=560 align=left>" v-media "</td>" skip
               "</tr>" skip
               "<tr>" skip

               "<td width=150 align=left><b>Valor Proximo Mes:</b></td>" skip
               "<td width=560 align=left>" proximo-mes "</td>" skip
               "</tr>" skip
               "<tr>" skip
               "<td width=150 align=left><b>Maior Acumulo:</b></td>" skip
               "<td width=560 align=left>"  v-acum "</td>" skip
               "</tr>" skip
               "<tr>" skip
               "<td width=150 align=left><b>Mes/Ano:</b></td>" skip
               "<td width=560 align=left>" v-mes "/" v-ano "</td>" skip
               "</tr>" skip
               "<tr>" skip
               "<td width=150 align=left><b>Reparcelamento:</b></td>" skip
               "<td width=560 align=left>" vrepar  "</td>" skip
               "</tr>" skip
               "<tr>" skip

               "<td width=150 align=left><b>Maior Atraso:</b></td>" skip
               "<td width=560 align=left>" (today - maior-atraso) "</td>"
               skip
               "</tr>" skip
               "<tr>" skip
               "<td width=150 align=left><b>Vencidas:</b></td>" skip
               "<td width=560 align=left>" vencidas "</td>" skip
               "</tr>" skip
               "<tr>"  skip
               "<td width=150 align=left><b>Loja:</b></td>" skip
               "<td width=560 align=left>"  plani.etbcod "</td>" skip
               "</tr>" skip


               "<tr>"  skip
               "<td width=150 align=left><b>Valor Venda :</b></td>" skip.
               
               if plani.biss <> 0
               then put "<td width=560 align=left>" plani.biss
                        "</td>" skip.
               else put "<td width=560 align=left>" plani.platot
                        "</td>" skip.

               put
               "</tr>" skip

               "<tr>"  skip
               "<td width=150 align=left><b>Vendedor :</b></td>" skip
               "<td width=560 align=left>"  
               
               func.funnom " ( " func.funcod " ) "
               
               "</td>"    skip
               "</tr>"    skip
               "</table>" skip
               "</body>"  skip
               "</html>".
                
                
                
        output close.
    
        plani.nottran = 4.
        
        run /admcom/progr/envia_dg.p("4",varquivo).
        
        pause 3.
    end.
end.    
