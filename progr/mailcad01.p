/* *********************************************************************
*  Programa......: mailcad01.p
*  Funcao........: Enviar e-mail de boas vindas lebes
*  Data..........: 26/04/2007
*  Autor.........: Gerson Luis Soares Mathias
********************************************************************* */   

def input param c_cliente   as char.
def input param c_mail      as char.

def var c_cliente   as char.
def var c_mail      as char.

assign c_cliente = "Gerson L.S. Mathias"
       c_mail    = "gerson@custombs.com.br". 

output to value("/admcom/export/log/mailcad01.htm").

put '<html>' skip
    '   <head>' skip
    '    <title>LOJAS LEBES</title>' skip
    '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"> ' skip
    ' </head>' skip
    ' <body>' skip
    ' <p><font face="Arial, Helvetica, sans-serif">Prezado(a) '
    c_cliente form "x(50)" ' </font></p>' skip
    ' <p><font face="Arial, Helvetica, sans-serif"><br>' skip
    ' Obrigado por se cadastrar na Loja Lebes. A partir de agora voc&ecirc;' skip
    ' &eacute;' skip 
    '  um cliente preferencial e passar&aacute; a receber ' skip    'informa&ccedil;&otilde;es ' skip
    'sobre lan&ccedil;amentos e ofertas especiais.<br>' skip
    '  <br> ' skip
    '        Acesse o site <a href="www.lebes.com.br">www.lebes.com.br</a><br>' skip
    '      <br>' skip
    '    Lojas Lebes </font> </p>' skip
    '   </body>' skip
    '   </html>' skip.
output close.


procedure pi-email:
            
             /*** Servico Antigo
unix silent /usr/bin/metasend -b -s "Lojas Lebes" -F informativo@lebes.com.br -f /admcom/export/log/mailcad01.htm -m text/html -t value(c_mail).
            ****/
            
            /* antonio Novo Servico */
            
unix silent /admcom/progr/mail.sh "Lojas Lebes" /admcom/export/log/mailcad01.htm value(c_mail) "informativo@lebes.com.br" text/html .   

           /**/
           
end procedure.