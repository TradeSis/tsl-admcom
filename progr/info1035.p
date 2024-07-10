{/admcom/progr/admcab-batch.i}

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1035 no-lock no-error.
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

def var vcont as integer.

def var v-env-mail as char.
def var v-texto as char.

def var vdt-aux as date.

def var v-ok-email as logical.

def var vtexto1 as char.
def var vtexto2 as char.

def stream str-txt.

def stream str-relat.
                                                        
def output parameter varquivo as character.                                    

if opsys = "UNIX"
then varquivo = "/admcom/relat/prosubst." + string(time) + ".txt".
else varquivo = "l:\relat\prosubst." + string(time) + ".txt".
    
def buffer bprodu for produ.

def var vaspas as char format "x(1)".
vaspas = chr(34).


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
               "<td width=756 align=center><b><h2> " today - 1
               "</h2></b></td>" skip
               "</tr>" skip
               "</table>" skip
               "<table border=" vaspas "3" vaspas "borderColor=green summary=>"
               "<tr>" skip
               "<td width=810 align=center><b>"
               "PRODUTOS SUBSTITUIDOS NO PEDIDO AUTOMATICO"
               "</b></td>"
               "</tr>"    skip
               "</table>"
               "<table border=3 borderColor=green>" skip
               "<tr>" skip
               "<td width=100 align=left><b>Filial</b></td>" skip
               "<td width=100 align=left><b>Substituido</b></td>" skip
               "<td width=200 align=left><b> </b></td>" skip
               "<td width=100 align=left><b>Substituto</b></td>" skip
               "<td width=200 align=left><b> </b></td>" skip
               "<td width=100 align=left><b>Pedido</b></td>" skip
               "</tr>" skip.

def var vqtd as int.
for each pedaxnfv where pedaxnfv.datgera = today - 1 and
                        pedaxnfv.prosub > 0          
                        no-lock:
    find estab where estab.etbcod = pedaxnfv.etbcod no-lock no-error.
    if not avail estab then next.
    find produ where produ.procod = pedaxnfv.procod no-lock no-error.
    if not avail produ then next.
    find bprodu where bprodu.procod = pedaxnfv.prosub no-lock no-error.
    if not avail bprodu then next.

    put skip
                    "<tr>"
                    skip
                    "<td width=100 align=right>" pedaxnfv.etbcod
                    "</td>"
                    skip
                    "<td width=100 align=right>" produ.procod 
                    "</td>"
                    skip
                    "<td width=200 align=right>" produ.pronom
                    "</td>"
                    skip
                    "<td width=100 align=right>" bprodu.procod
                    "</td>"
                    skip
                    "<td width=200 align=right>" bprodu.pronom
                    "</td>"
                    skip
                    "<td width=100 align=right>" pedaxnfv.pednum
                    "</td>"
                    skip
                     .

end.
put "</table>" skip
               "</body>"  skip
                              "</html>".
                              

output close.
def var varqdg as char.
def var i as int.

def var e-mail as char extent 10.

find first tbcntgen where
           tbcntgen.tipcon = 1 and
           tbcntgen.etbcod = 1035 and
           tbcntgen.numini = "INFORMATIVO"
           no-lock no-error.
if avail tbcntgen
then do:
    assign
        e-mail[1] = acha("email1",tbcntgen.campo3[1]) 
        e-mail[2] = acha("email2",tbcntgen.campo3[1])
        e-mail[3] = acha("email3",tbcntgen.campo3[1])
        e-mail[4] = acha("email4",tbcntgen.campo3[1])
        e-mail[5] = acha("email5",tbcntgen.campo3[1])
        e-mail[6] = acha("email6",tbcntgen.campo3[1])
        .
    do i = 1 to 6:
        if e-mail[i] <> "" and
           e-mail[i] <> "?"
        then do:   
 
            varqdg = "/admcom/progr/mail.sh " 
            + "~"" + "Produtos substituidos" + "~"" + " ~"" 
            + varquivo + "~"" + " ~"" 
            + e-mail[i] + "~"" 
            + " ~"informativo@lebes.com.br~"" 
            + " ~"text/html~"". 
            
            unix silent value(varqdg).
        end.
    end.
end.            
