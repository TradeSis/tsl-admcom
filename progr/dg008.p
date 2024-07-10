{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 8 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

def var varquivo as char.
def var vaspas as char format "x(1)".
vaspas = chr(34).

def var vtotal as dec.
def var d as date.
def var vi as date.
def var vf as date.

vi = today  - 1.

output to /admcom/work/dg008.log.
    put "Processo Iniciado de Busca de Novos Fornecedor" skip.
output close.

find first forne where forne.fordtcad >= vi no-lock no-error.
if avail forne
then do:

    varquivo = "/admcom/work/arquivodg008.htm".
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
               "<td width=756 align=center><b><h2>FORNECEDORES NOVOS"
               "</h2></b></td>" skip
               "</tr>" skip
               "</table>" skip
               "<table border=" vaspas "3" vaspas "borderColor=green summary=>"
               "<tr>" skip
               "<td width=756 align=center><b>FORNECEDOR</b></td>"
               "</tr>"    skip
               "</table>"
               "<table border=3 borderColor=green>" skip
               "<tr>" skip
               "<td width=100 align=left><b>Código</b></td>" skip
               "<td width=544 align=left><b>Fornecedor</b></td>" skip
               "<td width=100 align=left><b>Data Cadastro</b></td>" skip
               "</tr>" skip.

    for each forne where forne.fordtcad >= vi /*today - 1*/ no-lock:
    
                put skip
                    "<tr>"
                    skip
                    "<td width=100 align=left>" forne.forcod
                    "</td>"
                    skip
                    "<td width=544 align=left>" forne.fornom
                    "</td>"
                    skip
                    "<td width=100 align=right>" forne.fordtcad
                    "</td>"
                    "</tr>" skip.

    end.        
    
    put "</table>" skip  
        "</body>"  skip  
        "</html>".
    
    output close.

    run /admcom/progr/envia_dg.p("8",varquivo).

end.
