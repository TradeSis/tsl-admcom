{/admcom/progr/admcab-batch.i new}

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1037 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO nao cadastrado ou desativado".
    pause 0.
    return.
end.

def var vdti as date.
def var vdtf as date.
def var vcor-fundo as char.

def var vcont as integer.
def var venvmail as logical.

def var v-env-mail as char.
def var v-texto as char.
def var dd      as int.

def var vdt-aux as date.

def var v-ok-email as logical.

def var vtexto1 as char.
def var vtexto2 as char.

def stream str-txt.

def stream str-relat.
                                                        
def output parameter varquivo as character.                                    
/*
def var varquivo as char.
*/
if opsys = "UNIX"
then varquivo = "/admcom/relat/not_ent_s_chave_danfe.html".
else varquivo = "l:\relat\not_ent_s_chave_danfe.html".
    
def buffer bprodu for produ.

def var vaspas as char format "x(1)".
vaspas = chr(34).

if weekday(today) = 2
then dd = 2.
else dd = 1.

assign venvmail = no
       vcor-fundo = "cinza".

output to value(varquivo).

put "<html>" skip
               "<body>" skip
               "<br><br>"
               skip
               "<table border='1' cellpadding='4' summary= >"
               "<tr border-bottom-width:5px;>" skip
               "<td colspan='9' align='center'>"
               
               
               "<table border='0' bordercolor='red' width='100%' >"
               "<tr>"
               "<td>"
              "<IMG SRC='http://www.lebes.com.br/logo_lebes.jpg'> </IMG>"
              "</td>"
              "<td valign='middle' width='650' colspan='4'>"
           "<font size='4' face='verdana'><b> NOTAS LANÇADAS SEM BIPAR CHAVE DO DANFE EM"                         skip.
               put
               (today - dd) format "99/99/9999" skip.
               put
               "</b> </font></td><td width='170'></td></tr>"
               
               "</table>"
               
               
               "</td>" skip
               "</tr>" skip
               skip
               "<tr>" skip
               "</tr>"    skip
               "<tr>" skip
               "<td width=50 align='center'><b>Filial</b></td>" skip
               "<td width=120 align='center'><b>Data Entrada</b></td>" skip
               "<td width=120 align='center'><b>Hora Entrada</b></td>" skip
               "<td           align='center'><b>Cod. For</b></td>" skip
               "<td nowrap    align='center'><b>Fornecedor</b></td>" skip
               "<td width=100 align='center'><b>Usuário</b></td>" skip
               "<td nowrap    align='center'><b>Nome</b></td>" skip
               "<td nowrap    align='center'><b>Numero Nota</b></td>" skip
               "<td nowrap    align='center'><b>Serie</b></td>" skip
               "</tr>" skip.

for each estab where estab.etbcod >= 900  no-lock,

    each tipmov where tipmov.movtdc = 4
                   or tipmov.movtdc = 28
                   or tipmov.movtdc = 12
                   or tipmov.movtdc = 6
                   or tipmov.movtdc = 9
                   or tipmov.movtdc = 22 no-lock,

    each plani where plani.etbcod = estab.etbcod
                 and plani.movtdc = tipmov.movtdc
                 and plani.datexp >= today - dd
                 and length(plani.ufdes) <> 44   no-lock by estab.etbcod
                                                         by plani.datexp
                                                         by plani.horincl.
    release forne.             
    find first forne where forne.forcod = plani.emite no-lock no-error.
       
    release func.
    if plani.usercod <> ""
    then
    find first func where func.etbcod = estab.etbcod
                      and func.funcod = integer(plani.usercod) no-lock no-error.
    
    if not avail func
    then
    find first func where func.etbcod = 999
                      and func.funcod = integer(plani.usercod) no-lock no-error.
    
    if not venvmail
    then assign venvmail = yes.
    
    put unformatted
        "<tr bgcolor='" if vcor-fundo = "claro"
                         then "#f8f8f8"
                            else "#e1e1e1" "'>"
                            
          skip
                    "<td align='center'>" plani.etbcod
                    "</td>"
                    skip
                   "<td align='center'>" plani.datexp format "99/99/9999"                     "</td>"
                    skip
                   "<td align='center'>" string(plani.HorIncl,"HH:MM:SS")
                    "</td>"
                    skip
                    "<td align='center'>" plani.emite
                    "</td>"
                    skip
                    "<td align='left' nowrap>" if avail forne then forne.fornom
                                            else "-"     format "x(30)"
                    "</td>"
                    skip
                    "<td nowrap align='center'>" if plani.usercod <> ""
                                          then plani.usercod
                                          else "-"
                    "</td>"
                    skip
                    "<td align='center' nowrap >" if avail func
                                          then func.funnom
                                          else "-"
                    "</td>"
                    skip
                    "<td align='center'>" plani.numero
                    "</td>"
                    skip
                     "<td align='center'>" if plani.serie <> ""
                                           then plani.serie
                                           else "-" "</td>" skip
                    "<td align='center'>" tipmov.movtnom "</td>" skip.
                     
                     if vcor-fundo = "claro"
                     then assign vcor-fundo = "cinza".
                     else assign vcor-fundo = "claro".

end.
put "</table>" skip
               "</body>"  skip
                              "</html>".
                              


output close.
                  
if not venvmail 
then varquivo = "?".
