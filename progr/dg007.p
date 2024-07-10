{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 7 no-lock no-error.
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

def var d as date.
def var vi as date.
def var vf as date.
def var vok as log.

assign vi = today - 7 
       vf = today - 1.

def temp-table ttclase
    field clacod like clase.clacod
    field clanom like clase.clanom
    field data as date.

        for each clase where clase.clatipo = no : 
            find first produ where produ.clacod = clase.clacod no-lock no-error.
            if not avail produ 
            then next.
            
            vok = no.
            do d = vi to vf : 
            
                for each produ where produ.clacod = clase.clacod no-lock : 
                    
                    find first movim where movim.procod = produ.procod
                                       and movim.movtdc = 5
                                       and movim.movdat = d no-lock no-error.
                    if avail movim
                    then do :
                        vok = yes.
                        leave.
                    end.
                end.
                if vok = yes 
                then leave.
            end.
                                   
            if vok = no 
            then do:
            
                create ttclase.
                ttclase.clacod = clase.clacod.
                ttclase.clanom = clase.clanom.
                
            end.
        end.
    
        varquivo = "/admcom/work/arquivodg007.htm".
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
               "<td width=756 align=center><b><h2>CLASSES NÃO VENDIDAS"
               "</h2></b></td>" skip
               "</tr>" skip
               "</table>" skip
               "<table border=" vaspas "3" vaspas "borderColor=green summary=>"
               "<tr>" skip
               "<td width=756 align=center><b>CLASSES</b></td>"
               "</tr>"    skip
               "</table>"
               "<table border=3 borderColor=green>" skip
               "<tr>" skip
               "<td width=100 align=left><b>Classe</b></td>" skip
               "<td width=650 align=left><b>Descrição</b></td>" skip
               "</tr>" skip.
            
            for each ttclase by ttclase.data 
                             by ttclase.clanom.

                put skip
                    "<tr>"
                    skip
                    "<td width=100 align=left>" ttclase.clacod
                    "</td>"
                    skip
                    "<td width=650 align=left>" ttclase.clanom
                    "</td>"
                    "</tr>" skip.
                
            end.

            put "</table>" skip 
                "</body>"  skip 
                "</html>".
            
        output close.

        run /admcom/progr/envia_dg.p("7",varquivo).
