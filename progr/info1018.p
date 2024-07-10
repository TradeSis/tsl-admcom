/*
def output parameter varquivo as char.
*/

def var   varquivo as char.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1018 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO nao cadastrado ou desativado".
    pause 0.
    return.
end.
def var venvmail as log.
varquivo = "/admcom/work/informativo1018.html".

venvmail = yes.
def buffer npedid for pedid.
    
def var vped as int.
def var vpen as int.
def var vcomp as character.

def var vcont as integer.

output to value(varquivo).
put unformatted
"<HTML>" skip.

put unformatted
    "<TABLE border='2'" skip
    "          summary=~'DREBES & CIA LTDA~'> " skip
    "<tr>"          skip
    "    <td><b>LJ</b></td>" skip
    "    <td><b>COD</b></td>"     skip
    "    <td><b>PRODUTO</b></td>"     skip
    "    <td><b>ENT<br>ASSIST</b></td>"     skip
    "    <td><b>QTD DIAS<br>ASSIST</b></td>"     skip
    "</tr>".


assign vcont = 0.

for each estab no-lock,

    each asstec where asstec.etbcod = estab.etbcod
                  and asstec.dtenvass <= today - 30
                  and asstec.dtretass = ?
              /*  and asstec.dtentdep <= today - 30 */
              /*  and asstec.dtenvfil = ?           */
                             no-lock,
                             
    first produ where produ.procod = asstec.procod no-lock:
  
    assign vcont = vcont + 1.

    put unformatted
       "<tr> "                                                   skip
       "   <td>" asstec.etbcod                         "</td>"   skip
       "   <td>" produ.procod                          "</td>"   skip
       "   <td>" produ.pronom    format "x(30)"        "</td>"   skip
       "   <td>" asstec.dtenvass format "99/99/9999"   "</td>"   skip
       "   <td align='center'>" today - asstec.dtenvass               "</td>"   skip      
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
    run /admcom/progr/envia_info.p("1018", varquivo).
end.
    
