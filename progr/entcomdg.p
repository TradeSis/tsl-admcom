/***
def var vaspas as char format "x(1)".
vaspas = chr(34).

def var vtotal as dec.
def var d as date .
def var vi as date.
def var vf as date.

vi = today  - 1.

def shared temp-table tt-proemail
    field procod like produ.procod.

output to /admcom/work/entcomdg.log.
    put "Processo Iniciado de Busca de Produtos com estoque zerado" skip.
output close.

find first tt-proemail no-error.
if avail tt-proemail
then do:

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

    for each tt-proemail no-lock:
        find produ where produ.procod = tt-proemail.procod no-lock no-error.
        if produ.catcod <> 31 then next.
        find first fabri where fabri.fabcod = produ.fabcod no-lock.

        put skip 
            "<tr>" 
            skip 
            "<td width=70 align=left>"  produ.procod   "</td>"  skip
            "<td width=400 align=left>"  produ.pronom   "</td>" skip
            "<td width=250 align=left>"  fabri.fabnom   "</td>" skip
            "<td width=80 align=right>" today format "99/99/9999" "</td>"  skip
            "</tr>" skip.

    end.

    put "</table>" skip
        "</body>" skip
        "</html>".
    
output close.

        unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F guardian@lebes.com.br -f /admcom/work/entcomdg.htm -m text/html -t julio@custombs.com.br.

        unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F informativo@lebes.com.br -f /admcom/work/entcomdg.htm -m text/html -t rafael@lebes.com.br.

        unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F guardian@lebes.com.br -f /admcom/work/entcomdg.htm -m text/html -t masiero@custombs.com.br.

        unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F informativo@lebes.com.br -f /admcom/work/entcomdg.htm -m text/html -t filiais@lebes.com.br.

        unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F informativo@lebes.com.br -f /admcom/work/entcomdg.htm -m text/html -t brocca@lebes.com.br.

    unix silent /usr/bin/metasend -b -s "Reposicao_de_Produto" -F informativo@lebes.com.br -f /admcom/work/entcomdg.htm -m text/html -t moveis@lebes.com.br.
end.
***/
