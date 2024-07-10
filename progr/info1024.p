{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1024 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO nao cadastrado ou desativado".
    pause 0.
    return.
end.


def var varquivo    as char.
def var venvmail    as log.

def var vtem-produ  as log.


def var vcont       as integer.

def var vsp         as character.

def var vdti       as date.
def var vdtf       as date.

def var varqdg     as character.

def var varq-text  as character.

def buffer btitulo for titulo.

def temp-table tt-titluc
    field etbcod      like titluc.etbcod
    field titnum      like titluc.titnum
    field clifor      like titluc.clifor
    field fornom      like foraut.fornom
    field titdtven    as char           format "99/99/9999"
    field titvlcob    as char             format ">>>,>>9.99"
    field titsit      like titluc.titsit
    field autlp       like foraut.autlp
           index idx01 etbcod.

assign vsp = "&nbsp;". 

varquivo = "/admcom/work/informativo1024.html".
output to value(varquivo). 
put unformatted
"<html>" skip
"<body>" skip
"<table border='3' cellpadding='3' cellspacing='3' borderColor=green>" skip
"<tr><td colspan='8'><center><b>INCLUSAO DE DESPESAS " "SWAT</b></center></td></tr>"
skip(1)
. 

output close. 
 
venvmail = no.

/* 103849 - Fornecedor SWAT */

for each titluc where titluc.clifor = 103849
                  and titluc.datexp = today - 1  no-lock,
    
    first foraut where foraut.forcod = titluc.clifor no-lock:
    
    create tt-titluc.
    assign tt-titluc.etbcod    = titluc.etbcod
           tt-titluc.titnum    = titluc.titnum 
           tt-titluc.clifor    = titluc.clifor
           tt-titluc.fornom    = foraut.fornom
           tt-titluc.titdtven  = string(titluc.titdtven,"99/99/9999")
           tt-titluc.titvlcob  = string(titluc.titvlcob,">>>,>>9.99")
           tt-titluc.titsit    = titluc.titsit
           tt-titluc.autlp     = foraut.autlp.
    
    assign venvmail = yes.
                
end.                

output to value(varquivo) append.

put unformatted
    "<tr>"                   skip
    "   <td width='60' align='center'><b>Filial</b></td>"      skip  
    "   <td width='100' align='center'><b>Despesa</b></td>"    skip
    "   <td width='100' align='center'><b>Codigo</b></td>"     skip
    "   <td width='180' align='center'><b>Fornecedor</b></td>" skip   
    "   <td width='100' align='center'><b>Dt.Venc</b></td>"    skip
    "   <td width='100' align='center'><b>Valor</b></td>"      skip   
    "   <td width='100' align='center'><b>Sit</b></td>"        skip
    "   <td width='100' align='center'><b>LP</b></td>"         skip
    "</tr>"                  skip.
                
                
for each tt-titluc no-lock break by tt-titluc.etbcod:
               
 put unformatted
 "<tr>"                                     skip
 " <td align='center'>" tt-titluc.etbcod "</td>"         skip
 " <td align='center'>" tt-titluc.titnum "</td>"         skip
 " <td align='center'>" tt-titluc.clifor "</td>"         skip
 " <td align='center'>" tt-titluc.fornom "</td>"         skip
 " <td align='center'>" tt-titluc.titdtven  "</td>"       skip                    " <td align='right'>" tt-titluc.titvlcob  "</td>"      skip
 " <td align='center'>" tt-titluc.titsit   "</td>"       skip
 " <td align='center'>" tt-titluc.autlp  format "Sim/Nao"  "</td>"       skip
 "</tr>"                  skip.

               
end.

put unformatted
"</tr>" skip.

output close.

if venvmail = yes
then do:
    run /admcom/progr/envia_info.p("1024", varquivo).
end.

