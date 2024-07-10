{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1019 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO nao cadastrado ou desativado".
    pause 0.
    return.
end.

/* Só deve rodar nos dias 10, 18 e 25 */
if day(today) <> 10
    and day(today) <> 18
    and day(today) <> 25
then return.
        
def temp-table tt-vendedor
    field etbcod    as integer
    field etbnom    as character
    field vencod    as integer
    field nome      as character
    field setor     as integer 
    field setor-nom as character
    field val-venda like plani.platot
    field val-meta  like plani.platot
    field vdif-meta as decimal
    index idx01 etbcod vencod.

def var varquivo          as char.
def var venvmail          as log.
def var vperc             as char.
def var v-variacao-meta   as decimal.
def var v-meta-vendedor   like plani.platot.
def var v-setor-vendedor  as integer.

def var vsp               as character.

def var vdti       as date.
def var vdtf       as date.

def var vdec-tot-ven like plani.platot.

assign vsp = "&nbsp;". 

assign vperc = string(tbcntgen.valor,">>9.99").

assign vperc = trim(vperc).

assign vdtf = today - 1
       vdti = date(month(vdtf),01,year(vdtf)) .


varquivo = "/admcom/work/informativo1019.html".
output to value(varquivo). 
put unformatted
"<html>" skip
"<body>" skip
"VENDEDORES QUE ESTAO " vperc "% ABAIXO DA META. <br>"
"------------------------------------------------<br>" skip(1)
. 

output close. 
 
venvmail = no.


for each estab no-lock,
    
    last duplic where duplic.duppc = month(vdtf)
                  and duplic.fatnum = estab.etbcod no-lock:
                  
    for each func where func.etbcod = estab.etbcod no-lock:
    
        assign vdec-tot-ven     = 0
               v-variacao-meta  = 0
               v-meta-vendedor  = 0
               v-setor-vendedor = 0.

        for each plani where plani.etbcod  = estab.etbcod
                         and plani.movtdc  = 5
                         and plani.pladat >= vdti   
                         and plani.pladat <= vdtf 
                         and plani.vencod  = func.funcod no-lock,
                         
            first movim where movim.etbcod = plani.etbcod
                          and movim.placod = plani.placod no-lock,
                          
            first produ where produ.procod = movim.procod
                            no-lock break by plani.etbcod:
            
            if first-of(plani.etbcod)
            then assign v-setor-vendedor = produ.catcod.
            
            assign vdec-tot-ven = vdec-tot-ven + plani.platot.             
            
        end.
        
        if v-setor-vendedor = 31
        then do:
        
            find first tabaux where
                       tabaux.tabela = "META-VENDA-31" and
                       tabaux.nome_campo = string(duplic.fatnum,"999")
                             no-lock no-error.
            if avail tabaux
            then assign v-meta-vendedor =
                            (duplic.dupjur / int(tabaux.valor_campo)).
            
            if vdec-tot-ven > v-meta-vendedor 
            then next.
            
            assign v-variacao-meta =
                            decimal(vdec-tot-ven * 100 / v-meta-vendedor).
            
            if v-variacao-meta < (100.00 - decimal(vperc))
            then do:

                create tt-vendedor.
                assign tt-vendedor.etbcod    = estab.etbcod
                       tt-vendedor.etbnom    = estab.etbnom
                       tt-vendedor.vencod    = func.funcod
                       tt-vendedor.nome      = func.funnom
                       tt-vendedor.setor     = v-setor-vendedor.
                       
                if v-setor-vendedor = 31
                then assign tt-vendedor.setor-nom = "Móveis".
                else assign tt-vendedor.setor-nom = "Confecções".
                       
                assign tt-vendedor.val-venda = vdec-tot-ven
                       tt-vendedor.val-meta  = v-meta-vendedor 
                       tt-vendedor.vdif-meta = v-variacao-meta.
            
            end.
        
        end.
        else if v-setor-vendedor = 41
        then do:
        
            find first tabaux where
                       tabaux.tabela = "META-VENDA-41" and
                       tabaux.nome_campo = string(duplic.fatnum,"999")
                             no-lock no-error.
            if avail tabaux
            then assign v-meta-vendedor =
                            (duplic.dupval / int(tabaux.valor_campo)).
            
            if vdec-tot-ven > v-meta-vendedor 
            then next.
            
            assign v-variacao-meta =
                            decimal(vdec-tot-ven * 100 / v-meta-vendedor).
            
            if v-variacao-meta < (100.00 - decimal(vperc))
            then do:

                create tt-vendedor.
                assign tt-vendedor.etbcod    = estab.etbcod
                       tt-vendedor.etbnom    = estab.etbnom
                       tt-vendedor.vencod    = func.funcod
                       tt-vendedor.nome      = func.funnom
                       tt-vendedor.setor     = v-setor-vendedor.
                       
                if v-setor-vendedor = 31
                then assign tt-vendedor.setor-nom = "Móveis".
                else assign tt-vendedor.setor-nom = "Confecções".
                       
                assign tt-vendedor.val-venda = vdec-tot-ven
                       tt-vendedor.val-meta  = v-meta-vendedor 
                       tt-vendedor.vdif-meta = v-variacao-meta.
            
            end.
        
        end.
        
    end.
    
end.

output to value(varquivo) append.
        
put unformatted
"<table>" skip.
                
for each tt-vendedor:

    assign venvmail = yes.

    assign tt-vendedor.vdif-meta = ((tt-vendedor.vdif-meta - 100)).

    put unformatted
    "<tr>" skip
    "<td>Filial:</td><td>" tt-vendedor.etbnom                           "</td>"
    "</tr>" skip
    "<tr>"
    "<td>Vendedor:&nbsp;</td>
                   <td>" tt-vendedor.vencod " - " tt-vendedor.nome  "</td>"
    "</tr>"
    "<tr>"
    "<td>Setor:</td><td>" tt-vendedor.setor " - " tt-vendedor.setor-nom "</td>"
    "</tr>"
    "<tr>"
    "<td>Venda:</td><td>" tt-vendedor.val-venda format ">>>,>>9.99"     "</td>"
    "</tr>"
    "<tr>"
    "<td>Meta:</td><td>" tt-vendedor.val-meta  format ">>>,>>9.99"      "</td>"
    "</tr>"
    "<tr>"
    "<td>Dif. Meta: </td><td>" tt-vendedor.vdif-meta format "->>9.99%"   "</td>"
    "</tr>"
    "<tr><td>&nbsp;</td></tr>"skip.
    
end.
                
                
output close.

if venvmail = yes
then do:
    run /admcom/progr/envia_info.p("1019", varquivo).
end.
    

