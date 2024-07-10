def input parameter p-rec as recid.
def input parameter p-mail as char format "x(50)". 
def input-output parameter p-enviados as int.
def shared var var-mail as char extent 10 .
def var varquivo as char. 
def var varqmail as char.
def var venvia as log.
def var vi as int.
def var vassunto as char format "x(40)".
def var vclinom like clien.clinom.
def var vcad as log.
find plani where recid(plani) = p-rec no-lock no-error.
find clien where clien.clicod = plani.desti no-lock no-error.

if avail plani  and avail clien 
    and clien.clicod <> 1 and clien.zona <> ""
then do:
    venvia = no.
    find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
    if not avail cpclien or
        cpclien.tememail = yes and
        cpclien.emailpromocional = yes
    then do:    
    
    varquivo = "/admcom/relat/mailvenda" + string(plani.numero)
            + ".htm".
    
    if p-mail = ""
    then p-mail = clien.zona.
    if var-mail[1] = ""
    then var-mail[1] = p-mail.
    vcad = no.
    if clien.dtcad >= today - 1
    then do:
        vclinom = entry(1,clien.clinom," ").
        output to value(varquivo).
        put
        "<html>" skip
        "<head>" skip
        "<meta http-equiv=~"Content-Languag~" content=~"pt-br~">" skip
        "<meta name=~"GENERATOR~" content=~"Microsoft FrontPage 5.0~">" skip
        "<meta name=~"ProgId~" content=~"FrontPage.Editor.Document~">" skip
        "<meta http-equiv=~"Content-Type~" content=~"text/html; ".         put 
        "charset=windows-1252~">" skip
        "<title>Nova pagina 1</title>" skip
        "</head>" skip
        "<body>" skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 10.8pt; margin-bottom: ".
        put "0pt~">".
        put "<span style=~"font-family: Arial; color: black~">Olá </span> ".
        put "<span style=~"font-family: Arial; color: black; font-weight: ".
        put "bold~">" vclinom "!</span></p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 10.8pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; color: ".
        put "black~">Seja Bem-Vindo(a)!</span></p> " skip.
        put 
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 10.8pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: ".
        put "embed; vertical-align: baseline; margin-top: 10.8pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 10.8pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; color: ".
        put "black~">O crediário das Lojas Lebes ".
        put "registrou sua primeira compra a prazo conosco.</span></p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".            put "vertical-align: baseline; margin-top: 10.8pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; ".
        put "color: black~">Nossa equipe tem a satisfação de ".
        put "tê-lo como cliente e agradece a preferência!</span></p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 10.8pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 10.8pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<table border=~"0~" cellpadding=~"0~" ".
        put "cellspacing=~"0~" style=~"border-collapse: collapse~" ".
        put "bordercolor=~"#111111~" width=~"62%~"> " skip.
        put "<tr>" skip.                                    
        put "<td width=~"47%~">" skip .
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 0pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; ".
        put "color: black~">Lojas Lebes </span></p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 0pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; color: ".
        put "black~">lebes@lebes.com.br</span></p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 0pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; color: ".
        put "black~">Visite também nosso site.</span></p> " skip.
        put  "<p>&nbsp;</td> " skip.
        put "<td width=~"53%~"><span style=~"font-size: 14.0pt; ".
        put "font-family: Arial; color: black~"> <img border=~"0~" ".
        put "src=~"http://lebes.net.br/arquivos/logolebesatual.png~" ".
        put "width=~"158~" height=~"116~"></span></td> " skip.
        put "</tr>" skip.
        put "</table> " skip.
        put 
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: ".
        put "embed; vertical-align: baseline; margin-top: 0pt; ".
        put "margin-bottom: 0pt~"> " .
        put "<span style=~"font-size: 14.0pt; font-family: Arial; color: ".
        put "black~">&nbsp;</span></p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 8.4pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 8.4pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 8.4pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 8.4pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 6.0pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-size: 10.0pt; font-family: Arial; ".
        put "color: black~">Caso não ".
        put "queira mais receber e-mail das Lojas Lebes clique ".
        put "<font size=~'2~'> <a href=~'mailto:".
        put "crm@lebes.com.br?Subject=" trim(vclinom) " -".
        put  string(clien.clicod,">>>>>>>>9") "&body=".
        put "Solicito não receber próximas edições das promoções ".
        put "Lebes por e-mail.~'>aqui</a>.</font></span></p> " skip.
        put "</body>" skip.
        put "</html>" skip.
        output close.
        venvia = yes.
        vcad = yes.
    end.
    else do:
        vclinom = entry(1,clien.clinom," ").
        output to value(varquivo).
        put
        "<html>" skip
        "<head>" skip
        "<meta http-equiv=~"Content-Languag~" content=~"pt-br~">" skip
        "<meta name=~"GENERATOR~" content=~"Microsoft FrontPage 5.0~">" skip
        "<meta name=~"ProgId~" content=~"FrontPage.Editor.Document~">" skip
        "<meta http-equiv=~"Content-Type~" content=~"text/html; ".         put 
        "charset=windows-1252~">" skip
        "<title>Nova pagina 1</title>" skip
        "</head>" skip
        "<body>" skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 10.8pt; margin-bottom: ".
        put "0pt~">".
        put "<span style=~"font-family: Arial; color: black~">Olá </span> ".
        put "<span style=~"font-family: Arial; color: black; font-weight: ".
        put "bold~">" vclinom "!</span></p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 10.8pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; color: ".
        put "black~"> </span></p> " skip.
        put 
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 10.8pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: ".
        put "embed; vertical-align: baseline; margin-top: 10.8pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 10.8pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; color: ".
        put "black~">Agradecemos sua preferência pela Lojas Lebes!".
        put "</span></p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".            put "vertical-align: baseline; margin-top: 10.8pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; ".
        put "color: black~">É um prazer tê-lo como cliente! ".
        put "</span></p> " skip.

put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
         put "vertical-align: baseline; margin-top: 10.8pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; ".
        put "color: black~">Você já tem o Super Cartão Lebes? ".
        put "Aproveite! Use-o sempre para fazer compras. <br> Se ainda não possui, vá ate uma de nossas Lojas e solicite o seu Cartão. <br> Volte sempre!</span></p> " skip.     




        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 10.8pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 10.8pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<table border=~"0~" cellpadding=~"0~" ".
        put "cellspacing=~"0~" style=~"border-collapse: collapse~" ".
        put "bordercolor=~"#111111~" width=~"62%~"> " skip.
        put "<tr>" skip.                                    
        put "<td width=~"47%~">" skip .
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 0pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; ".
        put "color: black~">Lojas Lebes </span></p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 0pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; color: ".
        put "black~">lebes@lebes.com.br</span></p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 0pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-family: Arial; color: ".
        put "black~">Visite também nosso site.</span></p> " skip.
        put  "<p>&nbsp;</td> " skip.
        put "<td width=~"53%~"><span style=~"font-size: 14.0pt; ".
        put "font-family: Arial; color: black~"> <img border=~"0~" ".
        put "src=~"http://www.lebes.com.br/crm/logoemail.jpg~" ".
        put "width=~"158~" height=~"93~"></span></td> " skip.
        put "</tr>" skip.
        put "</table> " skip.
        put 
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: ".
        put "embed; vertical-align: baseline; margin-top: 0pt; ".
        put "margin-bottom: 0pt~"> " .
        put "<span style=~"font-size: 14.0pt; font-family: Arial; color: ".
        put "black~">&nbsp;</span></p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 8.4pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 8.4pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 8.4pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 8.4pt; ".
        put "margin-bottom: 0pt~">&nbsp;</p> " skip.
        put
        "<p style=~"text-align: left; direction: ltr; unicode-bidi: embed; ".
        put "vertical-align: baseline; margin-top: 6.0pt; margin-bottom: ".
        put "0pt~"> <span style=~"font-size: 10.0pt; font-family: Arial; ".
        put "color: black~">Caso não ".
        put "queira mais receber e-mail das Lojas Lebes clique ".
        put "<font size=~'2~'> <a href=~'mailto:".
        put "crm@lebes.com.br?Subject=" trim(vclinom) " -".
        put string(clien.clicod,">>>>>>>>9") "&body=".
        put "Solicito não receber próximas edições das promoções ".
        put "Lebes por e-mail.~'>aqui</a>.</font></span></p> " skip.
        put "</body>" skip.
        put "</html>" skip.
        output close.
        venvia = yes.
     end.
     end.    
     if venvia = yes and 
        p-mail <> ""
     then do:
        do vi = 1 to 10:
            if var-mail[vi] = ""
            then next.
            /**** servico antigo 
            if vcad
            then  varqmail = "/usr/bin/metasend -b -s ~"Seja Bem Vindo!~"" +
                    " -F ~"Lojas Lebes <crm@lebes.com.br>~" -f " + varquivo +
                       " -m text/html -t " + var-mail[vi] .   
                                          
            else varqmail = "/usr/bin/metasend -b -s 
                            ~"Obrigado pela preferencia!~"" +
                    " -F ~"Lojas Lebes <crm@lebes.com.br>~" -f " + varquivo +
                       " -m text/html -t " + var-mail[vi] .   
            ******/
                                          
            /* Antonio Servico Novo */
            
            if vcad
            then    assign  vassunto = "Seja Bem Vindo!"
                    varqmail = "/admcom/progr/mail.sh " 
            + "~"" + vassunto + "~"" + " ~"" 
            + varquivo + "~"" + " ~"" 
            + var-mail[vi] + "~"" 
            + " ~"Lojas Lebes <crm@lebes.com.br>~"" 
            + " ~"text/html~"". 
            else
            assign  vassunto = "Obrigado pela preferencia!"
                    varqmail = "/admcom/progr/mail.sh " 
            + "~"" + vassunto + "~"" + " ~"" 
            + varquivo + "~"" + " ~"" 
            + var-mail[vi] + "~"" 
            + " ~"Lojas Lebes <crm@lebes.com.br>~"" 
            + " ~"text/html~"". 

            /**/

            unix silent value(varqmail).
        end.
        p-enviados = p-enviados + 1.
        output to value("/admcom/relat/email_venda_" +
         string(day(today),"99") +
         string(month(today),"99") +
         string(year(today),"9999") + ".log" ) append.
         put plani.desti format "99999999999".
         put var-mail[1] format "x(30)".
        output close. 
     end.
     if p-mail = var-mail[1]
     then var-mail[1] = "".
end.
                     
