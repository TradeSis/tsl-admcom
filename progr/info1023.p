{/admcom/progr/admcab-batch.i}

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1023 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO nao cadastrado ou desativado".
    pause 0.
    return.
end.

FUNCTION mesfim returns date(input par-data as date).

  return ((DATE(MONTH(par-data),28,YEAR(par-data)) + 4) -     DAY(DATE(MONTH(par-data),28,YEAR(par-data)) + 4)).

end function.

if day(today) <> 1
    and day(today) <> 10
    and day(today) <> 20
    and day(today) <> 28
then return.

def var varquivo    as char.
def var venvmail    as log.

def var vtem-produ  as log.

def stream str-arq-mail.

def var vcont       as integer.

def var vsp         as character.

def var vdti       as date.
def var vdtf       as date.

def var varqdg     as character.

def var varq-mail  as character.

def buffer btitulo for titulo.

assign vdti = date(month(today),01,year(today))
       vdtf = mesfim(today).

def var vdata-aux  as date.

def var vassunto    as char.

assign vassunto = "Lojas Lebes - Clube BI$".

def temp-table tt-cli
    field etbcod as integer 
    field clicod as integer   format ">>>>>>>>>>>9"
    field clinom as character format "x(25)"
    field email  as character format "x(25)"
    field dtvenc as date      format "99/99/9999"      
    index idx01 clicod.

assign vsp = "&nbsp;". 

assign vdata-aux = date(month(today),01,year(today)).

varquivo = "/admcom/work/informativo1023.html".
output to value(varquivo). 
put unformatted
"<html>" skip
"<body>" skip
"Lojas Lebes - Clube Bi$<br>"
skip(1)
. 

output close. 
 
venvmail = no.

for each estab no-lock,

    each tbclube where tbclube.nomclube = "ClubeBis"
                   and tbclube.etbcod = estab.etbcod
                               no-lock,
                               
    first clien where tbclube.clicod = clien.clicod no-lock,                                                  
    each contrato where contrato.clicod = tbclube.clicod no-lock,
                              
    each titulo where titulo.empcod = 19
                  and titulo.titnat = no
                  and titulo.modcod = "CRE"
                  and titulo.titnum = string(contrato.contnum)
                  and titulo.etbcod = contrato.etbcod
                  and titulo.clifor = tbclube.clicod
                  and titulo.titdtven >= (today)
                  and titulo.titdtven <= (vdtf)
                  and not can-find(first btitulo
                                   where btitulo.titnat = no
                                     and btitulo.modcod = "CRE"
                                     and btitulo.clifor = tbclube.clicod
                                     and btitulo.titdtven > vdtf)
                        no-lock:
                            
    create tt-cli.
    assign tt-cli.etbcod = tbclube.etbcod
           tt-cli.clicod = titulo.clifor
           tt-cli.clinom = clien.clinom
           tt-cli.email  = tbclube.email
           tt-cli.dtvenc = titulo.titdtven.
                                 
end.

for each tt-cli exclusive-lock:

    assign varq-mail = "/admcom/relat-auto/info1023.tmp.txt".

    output stream str-arq-mail to value(varq-mail).

    put stream str-arq-mail unformatted
        "<html>"
        "<body>"
        "<h3>Prezado " tt-cli.clinom  ",</h3>"
        "<h4>Informamos que a sua última parcela de compra "
        " feita no plano Bi$ vence no dia "
        string(tt-cli.dtvenc,"99/99/9999")
        ",<br>E para se manter sócio do Clube Bi$ será "                                " necessária uma nova compra no Plano Bi$. <br><br>"
        "<br> Atenciosamente, "
        "<br><br>Clube Bi$<br><br></h4></body></html>".
        
    output stream str-arq-mail close.

    /*
    /* antonio Novo Servico */
    varqdg = "/admcom/progr/mail.sh "
               + "~"" + tbcntgen.campo1[3] + "~"" + " ~""
               + varquivo + "~"" + " ~""
               + e-mail[i] + "~""
               + " ~"informativo@lebes.com.br~""
               + " ~"text/html~"".
               unix silent value(varqdg).
    */
    
    varqdg = "/admcom/progr/mail.sh "
               + "~"" + vassunto + "~"" + " ~""
               + varq-mail + "~"" + " ~""
               + tt-cli.email + "~""
               + " ~"informativo@lebes.com.br~""
               + " ~"text/html~"".
    unix silent value(varqdg).
    
end.

output to value(varquivo) append.
                
output close.
/*
if venvmail = yes
then do:
    run /admcom/progr/envia_info.p("1023", varquivo).
end.
*/
