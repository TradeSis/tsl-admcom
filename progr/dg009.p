{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 9 no-lock no-error.
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

def var vtotal as dec.
def var d as date .
def var vi as date.
def var vf as date.

vi = today  - 7. /*1*/

def var vdata as date format "99/99/9999".

def temp-table tt-ent
    field procod like produ.procod.

do vdata = (today - 7) to today:
    for each plani where plani.movtdc = 4 
                     and plani.etbcod = 900
                     and plani.datexp = vdata no-lock:
    
        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock:
                         
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.
            
            if produ.catcod <> 31 then next.
            
            if produ.prodtcad >= today - 7
            then do:
                find tt-ent where tt-ent.procod = produ.procod no-error.
                if not avail tt-ent
                then do:
                    create tt-ent.
                    assign tt-ent.procod = produ.procod.
                end.
            end.
        end.

    end.
end.


if weekday(today) =  2 or weekday(today) > 0  /* todos os dias p/teste */
then do:

output to /admcom/work/dg009.log.
    put "Processo Iniciado de Busca de Novos PRODUTOS - Segunda-feira" skip.
output close.


/*********
find first produ where produ.prodtcad >= today - 7 /*1*/ no-lock no-error.
if avail produ
then do:
*********/

find first tt-ent no-lock no-error.
if avail tt-ent
then do:

     varquivo = "/admcom/work/arquivodg009.htm".
     output to value(varquivo).
    
           put "<html>" skip
               "<body>" skip
               skip
               
               "<table border=" vaspas "0" vaspas "summary=>" skip
               "<tr>" skip
               "<td width=820 align=center><b><h2>PRODUTOS NOVOS"
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
               "<td width=80 align=left><b>Dt.Cadastro</b></td>" skip
               "</tr>" skip.

    for each tt-ent no-lock.
    /********
    for each produ where produ.prodtcad >= today - 7 /*1*/ no-lock:
    *********/
        
        /***if produ.catcod <> 31 then next.***/
        
        find produ where produ.procod = tt-ent.procod no-lock no-error.
        
        find first fabri where fabri.fabcod = produ.fabcod no-lock.

        put skip 
            "<tr>" 
            skip 
            "<td width=70 align=left>"  produ.procod   "</td>"  skip
            "<td width=400 align=left>"  produ.pronom   "</td>" skip
            "<td width=250 align=left>"  fabri.fabnom   "</td>" skip
            "<td width=80 align=right>" produ.prodtcad "</td>"  skip
            "</tr>" skip.

    end.

    put "</table>" skip
        "</body>" skip
        "</html>".
    
    output close.
    run /admcom/progr/envia_dg.p("9",varquivo).

end.
end.
