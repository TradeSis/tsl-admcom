def var vaspas as char format "x(1)".

vaspas = chr(34).

def var vlimite as dec.
def var assunto as char.
def var vjuro as dec.

def var varquivo as char.

{/admcom/progr/cntgendf.i}

find first tbcntgen where tbcntgen.etbcod = 2 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

for each modal where modal.modcod <> "CRE"  no-lock : 

    for each titulo where titulo.titnat = yes
                      and titulo.empcod = 19
                      and titulo.modcod = modal.modcod
                      and titulo.titdtpag >= today - 1:

        if titulo.titvljur = 0 or titulo.titvlpag <= titulo.titvlcob
        then next.

        if titulo.cxmhora = "2" 
        then next.

        vjuro = titulo.titvljur.
        
        if vjuro = 0 
        then do :
            if titulo.titvlpag > titulo.titvlcob 
            then do : 
                vjuro = titulo.titvlpag - titulo.titvlcob.
            end.
        end.
        find first forne where forne.forcod = titulo.clifor no-lock no-error.
        if not avail forne
        then next.
        varquivo = "/admcom/work/arquivodg002.htm".
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
               ********/
               skip
               
               "<table border=" vaspas "0" vaspas "summary=>" skip
               "<tr>" skip
               "<td width=756 align=center><b><h2>Pagamento_com_Juro"
               "</h2></b></td>" skip
               "</tr>" skip
               "</table>" skip
               
               "<table border=" vaspas "3" vaspas "borderColor=green summary=>"
               "<tr>"
               "<td width=756 align=center><b>DADOS DO PAGAMENTO</b></td>"
               "</tr>"
               "</table>"
            
               "<table border=" vaspas "3" vaspas " borderColor=green>" skip.

            put "<tr>" skip
                "<td width=100 align=left><b>Numero :</b></td>"  skip
                "<td width=650 align=left>" titulo.titnum "</td>" skip
                "</tr>" skip.
                
            put "<tr>" skip
                "<td width=100 align=left><b>Parcela :</b></td>"  skip
                "<td width=650 align=left>" titulo.titpar "</td>" skip
                "</tr>" skip.
                
            put "<tr>" skip
                "<td width=100 align=left><b>Dt.Venc :</b></td>"  skip
                "<td width=650 align=left>" titulo.titdtven "</td>" skip
                "</tr>" skip.
                
            put "<tr>" skip
                "<td width=100 align=left><b>Valor Parcela:</b></td>"  skip
                "<td width=650 align=left>" titulo.titvlcob "</td>" skip
                "</tr>" skip.
                
            put "<tr>" skip
                "<td width=100 align=left><b>Valor Pago :</b></td>"  skip
                "<td width=650 align=left>" titulo.titvlpag "</td>" skip
                "</tr>" skip.


            put "<tr>" skip
                "<td width=100 align=left><b>Juro :</b></td>"  skip
                "<td width=650 align=left>" vjuro "</td>" skip
                "</tr>" skip.
                
            put "<tr>" skip
                "<td width=100 align=left><b>Fornecedor :</b></td>"  skip
                "<td width=650 align=left>" forne.fornom  " (" forne.forcod ") "
                "</td>" skip
                "</tr>" skip.
            put "</table>" skip
                "</body>" skip
                "</html>".
                
        output close.
        
        titulo.cxmhora = "2".
        
        run /admcom/progr/envia_dg.p("2",varquivo).
        
        pause 3.              
    end.
end.    
