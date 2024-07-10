/***********************************************************************
* Programa.....: infrepd2.p
* Funcao.......: Informativo de reposicao de produtos semana anterior II
* Data.........: 30/07/2007
* Autor........: Gerson L S Mathias
********************************************************************* */
pause 0 no-message.
def temp-table tt-proemail
    field procod like produ.procod.

def var i_diasem   as inte                    init 0.
def var t_dtasem   as date form "99/99/9999".
def var c_dia      as char form "99"          init "".
def var c_mes      as char form "99"          init "".
def var i_hoje     as inte form "9999"        init 0.
def var lVaz       as logi init no.

def var v-assunto as char format "x(25)".
def var varqmail  as char format "x(25)".
def var v-mail    as char format "x(25)".


assign i_diasem = 2                                 /* Segunda feira */
       t_dtasem = today.                            /* Hoje */

assign c_dia  = string(day(t_dtasem),"99")
       c_mes  = string(month(t_dtasem),"99")
       i_hoje = inte(c_dia + c_mes).

/* SE SEGUNDA FEIRA */
if weekday(today) = i_diasem
then do:
        find first cadmetasfunc where
                   cadmetasfunc.codmeta > 0 and
                   cadmetasfunc.etbcod  = 0 no-lock no-error.
        if avail cadmetasfunc
        then do:
                if substring(string(cadmetasfunc.funcod,"9999"),1,02) < 
                   string(day(today))
                then do:
                        assign lVaz = no.                  
                end.
        end.
        else do:
                assign lVaz = yes.
        end.
          
end.  /* Final do if dia da semana */  
             
if lVaz = yes
then do:
        find first cadmetasfunc where
                   cadmetasfunc.codmeta = 0 and
                   cadmetasfunc.etbcod  = 0 exclusive-lock no-error.
        if avail cadmetasfunc
        then do:
                if substring(string(cadmetasfunc.funcod,"9999"),1,02) < 
                   string(day(today))
                then do:
                        run pi-email.
                        assign cadmetasfunc.funcod = i_hoje.
                end.       
        end.
end.

if lVaz = no
then do:
        run infrepd0.p. /* Gerson */
end.
             
procedure pi-email:

def var vaspas as char format "x(1)".
vaspas = chr(34).

def var vtotal as dec.
def var d as date .
def var vi as date.
def var vf as date.

&scoped-define cam01 /admcom/work/entcomdg.htm

output to /admcom/work/entcomdgvaz.log.
    put "Nao teve nenhuma reposicao de produtos no periodo" skip.
output close.

output to /admcom/work/entcomdg.htm.
    
           put "<html>" skip
               "<body>" skip
               skip
               "<table border=" vaspas "0" vaspas "summary=>" skip
               "<tr>" skip
               "<td width=820 align=center><b><h2>REPOSICAO DE PRODUTOS"
               "</h2></b></td>" skip
               "</tr>" skip
               "</table>" skip
               "<table border=" vaspas "3" vaspas "borderColor=green summary=>"
               "<tr>" skip
               "<td width=820 align=center><b>PRODUTOS</b></td>"
               "</tr>"    skip
               "</table>"
               "<table border=3 borderColor=green>" skip
               "<tr>" skip
               "<td width=70 align=left><b>Produto</b></td>"     skip
               "<td width=400 align=left><b>Descrição</b></td>"  skip
               "<td width=250 align=left><b>Fabricante</b></td>" skip
               "<td width=80 align=left><b>Dt.Entrada</b></td>" skip
               "</tr>" skip.

        put skip 
            "<tr>" 
            skip 
            "<td width=70 align=left>"    "</td>"  skip
            "<td width=400 align=left> Sem reposicao produtos no periodo</td>"             skip
            "<td width=250 align=left>"    "</td>" skip
            "<td width=80 align=right>" today format "99/99/9999" "</td>"  skip
            "</tr>" skip.

    put "</table>" skip
        "</body>" skip
        "</html>".
    
output close.
        
        /* Antonio - Servico Novo */
        assign v-assunto = "Reposicao_de_Produto"
               varqmail  = "/admcom/work/entcomdg.htm".
               v-mail     = "rafael@lebes.com.br".
 
        unix silent value("/admcom/progr/mail.sh " 
            + "~"" + v-assunto + "~"" + " ~"" 
            + varqmail + "~"" + " ~"" 
            + v-mail + "~"" 
            + " ~"informativo@lebes.com.br>~"" 
            + " ~"text/html~""). 
 
        assign v-mail = "masiero@custombs.com.br".
        unix silent value("/admcom/progr/mail.sh " 
            + "~"" + v-assunto + "~"" + " ~"" 
            + varqmail + "~"" + " ~"" 
            + v-mail + "~"" 
            + " ~"informativo@lebes.com.br>~"" 
            + " ~"text/html~""). 
        
        
        assign v-mail = "filiais@lebes.com.br".
        unix silent value("/admcom/progr/mail.sh " 
            + "~"" + v-assunto + "~"" + " ~"" 
            + varqmail + "~"" + " ~"" 
            + v-mail + "~"" 
            + " ~"informativo@lebes.com.br>~"" 
            + " ~"text/html~""). 

        assign v-mail = "brocca@lebes.com.br".
        unix silent value("/admcom/progr/mail.sh " 
            + "~"" + v-assunto + "~"" + " ~"" 
            + varqmail + "~"" + " ~"" 
            + v-mail + "~"" 
            + " ~"informativo@lebes.com.br>~"" 
            + " ~"text/html~""). 

        assign v-mail = "moveis@lebes.com.br".
        unix silent value("/admcom/progr/mail.sh " 
            + "~"" + v-assunto + "~"" + " ~"" 
            + varqmail + "~"" + " ~"" 
            + v-mail + "~"" 
            + " ~"informativo@lebes.com.br>~"" 
            + " ~"text/html~""). 
 
        
        /**/

        /************** Servico antigo *******************

        unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F guardian@~lebes.com.br -f /admcom/work/entcomdg.htm -m text/html -t julio@custombs.com.br.

        unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F informati~vo@lebes.com.br -f /admcom/work/entcomdg.htm -m text/html -t rafael@lebes.com.br
.

        unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F guardian@~le~bes.com.br -f /admcom/work/entcomdg.htm -m text/html -t masiero@custombs.com~.br.

        unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F informati~vo@lebes.com.br -f /admcom/work/entcomdg.htm -m text/html -t /filiais@lebes.com~.br.

        unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F informati~vo@lebes.com.br -f /admcom/work/entcomdg.htm -m text/html -t brocca@lebes.com.b~r.

    unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F informativo@l~ebes.com.br -f /admcom/work/entcomdg.htm -m text/html -t moveis@lebes.com.br.
  
    unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F informativo@l~ebes.com.br -f /admcom/work/entcomdg.htm -m text/html -t gerson@custombs.com.br.
         ******************************/

end procedure.             
