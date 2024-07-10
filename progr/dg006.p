{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 6 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.
def var varquivo as char.

def var vaspas as char format "x(1)".
vaspas = chr(34).

def temp-table ttlj 
    field etbcod like estab.etbcod
    field funcod like func.funcod
    field valor as dec
    field data as date.
    
def temp-table ttloja
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field funcod like func.funcod
    field platot as dec
    field data as date.
    
def var vtotal as dec.
def var d as date .
def var vi as date.
def var vf as date.

def var vdia as char extent 7 initial ["DOMINGO","SEGUNDA","TERCA","QUARTA","QUINTA","SEXTA","SABADO"].

vi = today - 1 /*5*/.
vf = today - 1.

if search("/admcom/dg/rankven.ini") <> ? 
then do :
    input from /admcom/dg/rankven.ini.
    repeat :
        create ttlj.
        import ttlj.etbcod ttlj.funcod ttlj.valor ttlj.data.
    end.    
    input close.
end.
for each estab where estab.etbcod <= 900: 
    if {conv_igual.i estab.etbcod} then next.

    for each func where func.etbcod = estab.etbcod no-lock :
        find first ttlj where ttlj.etbcod = estab.etbcod no-lock no-error.
        if not avail ttlj
        then do :
            create ttlj.
            ttlj.etbcod = estab.etbcod.
            ttlj.funcod = func.funcod.
            ttlj.valor = 0.
        end.
    end.
end.

output to /admcom/work/dg006.log append.
    put "Criou as Lojas e Vendedores " skip.
output close.

run calc.

for each ttlj,
    each ttloja where ttloja.etbcod = ttlj.etbcod 
                  and ttloja.funcod = ttlj.funcod
                  break by ttloja.platot desc:

    output to /admcom/work/dg006.log append.
        put "Verificando Loja e Vendedor "  ttloja.etbcod 
            skip.
    output close.

    if first-of(ttloja.platot) 
    then do :
        if ttloja.platot > ttlj.valor  and
           ttlj.valor > 5000
        then do :
            find first func where func.funcod = ttloja.funcod 
                              and func.etbcod = ttloja.etbcod 
                            no-lock no-error.
                            
            varquivo = "/admcom/work/arquivodg006.htm".
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
                   "<td width=766 align=center><b><h2>RECORDE DO VENDEDOR"
                   "</h2></b></td>" skip
                   "</tr>" skip
                   "</table>" skip
                   "<table border=" vaspas "3
                   " vaspas "borderColor=green summary=>"
                   "<tr>"
                   "<td width=766 align=center><b>RECORDE</b></td>" skip
                   "</tr>" skip
                   "</table>" skip
                   "<table border=" vaspas "3" 
                   vaspas " borderColor=green>" skip.

                put "<tr>" skip
                    "<td width=140 align=left><b>Data Recorde :</b></td>"  skip
                    "<td width=620 align=left>" ttloja.data format "99/99/9999"
                    "</td>" skip
                    "</tr>" skip.

                put "<tr>" skip
                    "<td width=140 align=left><b>Valor Vendido :</b></td>" skip
                    "<td width=620 align=left>" ttloja.platot
                    "</td>" skip
                    "</tr>" skip.

                put "<tr>" skip
                    "<td width=140 align=left><b>Recorde Anterior :</b></td>"
                    skip 
                    "<td width=620 align=left>" ttlj.valor 
                    "</td>" skip 
                    "</tr>" skip.

                put "<tr>" skip
                    "<td width=140 align=left><b>Vendedor :</b></td>"  skip
                    "<td width=620 align=left>" func.funnom 
                    " ( " ttloja.funcod " ) "
                    "</td>" skip
                    "</tr>" skip.

                put "<tr>" skip
                    "<td width=140 align=left><b>Loja :</b></td>"  skip
                    "<td width=620 align=left>" ttloja.etbcod
                    "</td>" skip
                    "</tr>" skip
                    "</table>" skip
                    "</body>" skip
                    "</html>".

                    
            output close.
            
            ttlj.valor = ttloja.platot.
            ttlj.data = ttloja.data.

            run /admcom/progr/envia_dg.p("6",varquivo).
            
        end.
    end.
end.    

varquivo = "/admcom/work/arquivodg006.htm".
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
                ****/ skip
               
               "<table border=" vaspas "0" vaspas "summary=>" skip
               "<tr>" skip
               "<td width=756 align=center><b><h2>RECORDE DOS VENDEDORES EM TODA A REDE"
               "</h2></b></td>" skip
               "</tr>" skip
               "</table>" skip
               
               "<table border=" vaspas "3" vaspas "borderColor=green summary=>"
               "<tr>" skip
               "<td width=756 align=center><b>RECORDE</b></td>"
               "</tr>"    skip
               "</table>"
               "<table border=3 borderColor=green>" skip
               "<tr>" skip
                    
               "<td width=160 align=left><b>Data Recorde</b></td>" skip
               "<td width=110 align=right><b>Valor Vendido</b></td>" skip
               "<td width=340 align=left><b>Vendedor</b></td>" skip
               "<td width=150 align=left><b>Loja</b></td>" skip
               "</tr>" skip.

output close.
         

do d = vf to vi by -1:
    for each ttloja where ttloja.etbcod <> 0 
                      and ttloja.data = d break by ttloja.platot desc:
    
        if first(ttloja.platot)
        then do :
            find first func where func.funcod = ttloja.funcod
                              and func.etbcod = ttloja.etbcod
                            no-lock no-error.

            output to value(varquivo) append.

                put skip
                    "<tr>"
                    skip
                    "<td width=160 align=left>"
                    ttloja.data  format "99/99/9999"
                    " " 
                    vdia[weekday(ttloja.data)] format "x(10)" 
                    "</td>"
                    skip
                    "<td width=110 align=right> "
                    ttloja.platot
                    "</td>"
                    skip
                    "<td width=340 align=left>" 
                    func.funnom " ( " ttloja.funcod " ) "
                    "</td>"
                    skip
                    "<td width=150 align=left>" 
                    ttloja.etbcod " " ttloja.etbnom
                    "</b></td></tr>" skip.

            
            output close.
        end.
    end.
end.

output to value(varquivo) append.
   put "</table>" skip 
       "</body>"  skip 
       "</html>".
output close.
     run /admcom/progr/envia_dg.p("6",varquivo).

output to /admcom/dg/rankven.ini.
for each ttlj :
    export ttlj.etbcod ttlj.funcod ttlj.valor ttlj.data.
end.
output close.
     

PROCEDURE calc.
    for each ttloja.
        delete ttloja.
    end.
    
    do d = vi to vf :    
        for each estab where estab.etbcod < 90 no-lock :
           if {conv_igual.i estab.etbcod} then next.

            for each plani where plani.movtdc = 5
                             and plani.etbcod = estab.etbcod
                             and plani.pladat = d no-lock:

                if plani.vencod = 100 then next.  
                
                find first tipmov where tipmov.movtdc = 5 no-lock.
                find first ttloja where ttloja.etbcod = plani.etbcod 
                                    and ttloja.data = d 
                                    and ttloja.funcod = plani.vencod no-error.
                if not avail ttloja
                then do:
                    create ttloja.
                    assign ttloja.etbcod = plani.etbcod
                           ttloja.etbnom = estab.etbnom
                           ttloja.funcod = plani.vencod 
                           ttloja.data = d.
                end.
                /*
                if plani.biss > 0  
                then  ttloja.platot = ttloja.platot + plani.biss.
                else  ttloja.platot = ttloja.platot + 
                                      (plani.platot - plani.vlserv ).
                */

                if plani.biss <> 0
                then ttloja.platot = ttloja.platot + plani.biss.
                else ttloja.platot = ttloja.platot + plani.platot.

            end.
 
            for each plani where plani.movtdc = 12
                             and plani.etbcod = estab.etbcod
                             and plani.pladat = d no-lock:
                  
                find first tipmov where tipmov.movtdc = 12 no-lock.
                find first ttloja where ttloja.etbcod = plani.etbcod 
                                    and ttloja.data = d 
                                    and ttloja.funcod = plani.vencod no-error.
                if not avail ttloja
                then do:
                    create ttloja.
                    assign ttloja.etbcod = plani.etbcod
                           ttloja.etbnom = estab.etbnom
                           ttloja.funcod = plani.vencod 
                           ttloja.data = d.
                end.
                /*
                if plani.biss > 0  
                then  ttloja.platot = ttloja.platot + plani.biss.
                else  ttloja.platot = ttloja.platot + 
                                      (plani.platot - plani.vlserv ).
                */

                if plani.biss <> 0
                then ttloja.platot = ttloja.platot - plani.biss.
                else ttloja.platot = ttloja.platot - plani.platot.
            
            end.
        end.
    end.
end.
