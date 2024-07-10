{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1022 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO nao cadastrado ou desativado".
    pause 0.
    return.
end.

def input parameter ipcat-aux as integer.

/*
def var ipcat-aux as integer initial 31.
*/
def temp-table tt-produ
    field etbcod    as integer
    field etbnom    as character
    field procod    as integer
    field pronom    as character
    field catcod    as integer
    field valvenda  as decimal
    index idx01 etbcod procod.

def var varquivo          as char.
def var venvmail          as log.

def var vtem-produ      as log.


def var vcont             as integer.

def var vsp               as character.

def var vdti       as date.
def var vdtf       as date.

def var vcatnom-aux  as char.

def var vmostra-cabec-loja as logical.

assign vsp = "&nbsp;". 

assign vdtf = today - 1
       vdti = vdtf - 30 .


if ipcat-aux = 31
then assign vcatnom-aux = "MOVEIS".
else assign vcatnom-aux = "CONFECCAO".



varquivo = "/admcom/work/informativo1022.html".
output to value(varquivo). 
put unformatted
"<html>" skip
"<body>" skip
"PRODUTOS CAMPEOES DE VENDA COM ESTOQUE ZERO - " vcatnom-aux "<br><br>"
 skip(1)
. 

output close. 
 
venvmail = no.

for each estab /*where estab.etbcod <= 10*/ no-lock,

    each plani where plani.etbcod = estab.etbcod
                 and plani.movtdc = 5
                 and plani.pladat >= vdti
                 and plani.pladat <= vdtf no-lock,
                 
    each movim where movim.etbcod = plani.etbcod
                 and movim.placod = plani.placod
                               no-lock,
                 
    first produ where produ.procod = movim.procod
                  and produ.catcod = ipcat-aux no-lock:

    find first tt-produ where tt-produ.etbcod = movim.etbcod
                          and tt-produ.procod = movim.procod  
                                        exclusive-lock no-error.
    
    /* Descarta produtos com Asterisco */
    if substring(produ.pronom,1,1) = "*"
    then next.

    /* Descarta cartão presente */                                    
    if produ.procod = 10000
    then next.
    
    if produ.pronom matches("*RECARGA*")
    then next.
                                        
    if not avail tt-produ
    then do:                                
    
        /*
        message "Produto Parte 1: " produ.pronom.
        pause 0.
        */
        
        create tt-produ.   
        assign tt-produ.etbcod = movim.etbcod
               tt-produ.etbnom = estab.etbnom 
               tt-produ.procod = movim.procod
               tt-produ.pronom = produ.pronom
               tt-produ.catcod = produ.catcod. 
        
    end.    
    
    assign tt-produ.valvenda = tt-produ.valvenda
                        + ((movim.movqtm * movim.movpc) - movim.movdes).     
                        
end.

/*
message "Comecando a segunda parte... ".
pause.                
*/

output to value(varquivo) append.
        
put unformatted
"<table>" skip.

for each estab no-lock:

    assign vmostra-cabec-loja = yes
           vtem-produ = no.

    bloco_produ:
    for each tt-produ where tt-produ.etbcod = estab.etbcod no-lock,
    
         first estoq where estoq.etbcod = tt-produ.etbcod
                       and estoq.procod = tt-produ.procod
                           no-lock break by tt-produ.etbcod
                                         by tt-produ.valvenda desc:
                                            
            if first-of(tt-produ.etbcod)
            then assign vcont = 1.
            
            if vcont >= tbcntgen.valor
            then leave bloco_produ.
                
            assign vcont = vcont + 1.
        
            if estoq.estatual > 0
            then next.
            
            /*
            if not vtem-produ
            then do:
            
                put unformatted
                    "<tr><td>Setor:</td>"
                    "<td>" tt-cat.catcod " - " tt-cat.catnom
                    "</td></tr>".
                
                assign vtem-produ = yes.
            
            end.
            */
            
            assign vtem-produ = yes.
            
            assign venvmail = yes.
            
            if vmostra-cabec-loja
            then do:

                 put unformatted
                     "<tr>" skip
                     "<td><u>FILIAL: " tt-produ.etbcod "</u></td>"
                     "</tr>" skip.
                     
                 assign vmostra-cabec-loja = no.
                 
            end.

            put unformatted
            "<tr>"
            "<td>"tt-produ.procod " - " tt-produ.pronom format "x(25)" " - "                            tt-produ.valvenda format "R$ zzz,zz9.99" "</td>"
            "</tr>" skip.
    
    end.    
        
    put unformatted
    skip(1).
    
    if vtem-produ
    then 
    put unformatted
    "<tr height='8'>" 
    "<td>"
    "</td></tr>"
    skip(1).
    
end.    

put unformatted
    "</table>"
    "</body>"
    "</html>"
    skip(1).
                
                
output close.

if venvmail = yes
then do:
    run /admcom/progr/envia_info.p("1022", varquivo).
end.

