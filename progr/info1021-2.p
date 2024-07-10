/*
def output parameter varquivo as char.
*/

def var   varquivo as char.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1021 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO nao cadastrado ou desativado".
    pause 0.
    return.
end.
def var venvmail as log.
varquivo = "/admcom/work/informativo1021-1.html".

venvmail = yes.
def buffer npedid for pedid.
    
def var vped as int.
def var vpen as int.
def var vcomp as character.
def var vdti as date.
def var vdtf as date.

def var vcont as integer.
def var vqtd-vend as integer.

if day(today) <> 1
then return.

assign vdtf = today - 1.

assign vdti = date(month(vdtf),01,year(vdtf)).

output to value(varquivo).
put unformatted
"<HTML>" skip.

find first fabri where fabri.fabcod = 103729 no-lock no-error.

put unformatted
    "<TABLE border='2'" skip
    "          summary=~'DREBES & CIA LTDA~'> " skip
    "<tr><td colspan='4'><b><p align='center'>" 
    "LISTAGEM DE VENDAS DO FORNECEDOR "
                fabri.fabcod " - " fabri.fabnom "</p></b></td></tr>"
    "<tr>"          skip
    "    <td><b>FIL</b></td>" skip
    "    <td><b>CONSULTOR</b></td>"     skip
    "    <td><b>PRODUTO</b></td>"     skip
    "    <td><b>QTD</b></td>"     skip
    "</tr>".


assign vcont = 0.

for each estab no-lock,

    each func where func.etbcod = estab.etbcod no-lock,
    
    each plani where plani.etbcod = func.etbcod
                 and plani.movtdc = 5
                 and plani.pladat >= vdti
                 and plani.pladat <= vdtf
                 and plani.vencod = func.funcod no-lock,
    
    each movim where movim.etbcod = plani.etbcod
                 and movim.placod = plani.placod no-lock,

    first produ where produ.procod = movim.procod
                  and produ.fabcod = fabri.fabcod /*Semp Toshiba - Forn 103729*/
                   no-lock break by estab.etbcod
                                 by func.funcod
                                 by movim.procod:
                   
    if first-of(movim.procod)
    then assign vqtd-vend = 0.               
                   
    assign vcont = vcont + 1
           vqtd-vend = vqtd-vend + movim.movqtm .

    if last-of (movim.procod)
    then
    put unformatted
       "<tr> "                                                   skip
       "   <td>" estab.etbcod " - " estab.munic        "</td>"   skip
       "   <td>" func.funcod  " - " func.funnom        "</td>"   skip
       "   <td>" produ.procod    format ">>>>>>>>>9"   "</td>"   skip
       "   <td>" vqtd-vend       format ">>>9.99"      "</td>"   skip
 skip      
       "</tr>"                                                   skip.             /*
      if vcont = 50 then leave.                           
    */     
end.

put unformatted
   "</table>" skip
   "</html>"  skip.  


output close.

if venvmail = yes
then do:
    run /admcom/progr/envia_info.p("1021", varquivo).
end.
    
