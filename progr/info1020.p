{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1020 no-lock no-error.
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
        
def temp-table tt-filial
    field etbcod          as integer
    field etbnom          as character
    field val-venda-atual like plani.platot
    field val-venda-ant   like plani.platot
    field vdif-venda      as decimal
    index idx01 etbcod .

def var varquivo          as char.
def var venvmail          as log.
def var vperc             as char.
def var v-variacao-venda  as decimal.

def buffer bplani for plani.

def var vsp               as character.

def var vdti       as date.
def var vdtf       as date.

def var vdti-ant   as date.
def var vdtf-ant   as date.


def var vdec-venda-atual like plani.platot.
def var vdec-venda-ant   like plani.platot.

assign vsp = "&nbsp;". 

assign vperc = string(tbcntgen.valor,">>9.99").

assign vperc = trim(vperc).

assign vdtf = today - 1
       vdti = date(month(vdtf),01,year(vdtf)) .

/* Datas do ano anterior. */
assign vdti-ant = date(month(vdti),day(vdti),(year(vdti) - 1))
       vdtf-ant = date(month(vdtf),day(vdtf),(year(vdtf) - 1)).


varquivo = "/admcom/work/informativo1020.html".
output to value(varquivo). 
put unformatted
"<html>" skip
"<body>" skip
"FILIAIS QUE ESTAO " vperc "% ABAIXO DA VENDA DO ANO ANTERIOR. <br>"
"------------------------------------------------------------<br>" skip(1)
. 

output close. 
 
venvmail = no.


for each estab no-lock:
    
        assign vdec-venda-atual = 0
               vdec-venda-ant   = 0
               v-variacao-venda = 0.

        for each plani where plani.etbcod  = estab.etbcod
                         and plani.movtdc  = 5
                         and plani.pladat >= vdti   
                         and plani.pladat <= vdtf 
                         no-lock:
            
            if plani.biss > plani.platot
            then assign vdec-venda-atual = vdec-venda-atual + plani.biss.
            else assign vdec-venda-atual = vdec-venda-atual + plani.platot.
        
        end.
        
        for each bplani where bplani.etbcod  = estab.etbcod
                          and bplani.movtdc  = 5
                          and bplani.pladat >= vdti-ant   
                          and bplani.pladat <= vdtf-ant 
                              no-lock:
            
            if bplani.biss > bplani.platot
            then assign vdec-venda-ant = vdec-venda-ant + bplani.biss. 
            else assign vdec-venda-ant = vdec-venda-ant + bplani.platot.                     
        end.
        
        if vdec-venda-atual > vdec-venda-ant
        then next.
            
        assign v-variacao-venda =
                        decimal(vdec-venda-atual * 100 / vdec-venda-ant).
            
        if v-variacao-venda < (100.00 - decimal(vperc))
        then do:

            create tt-filial.
            assign tt-filial.etbcod          = estab.etbcod
                   tt-filial.etbnom          = estab.etbnom
                   tt-filial.val-venda-atual = vdec-venda-atual
                   tt-filial.val-venda-ant   = vdec-venda-ant
                   tt-filial.vdif-venda      = v-variacao-venda.
        
        end.

end.

output to value(varquivo) append.
        
put unformatted
"<table>" skip.
                
for each tt-filial:

    assign venvmail = yes.

    assign tt-filial.vdif-venda = ((tt-filial.vdif-venda - 100)).

    put unformatted
    "<tr>" skip
    "<td>Filial:</td><td>" tt-filial.etbnom           "</td>"
    "</tr>" skip
    "<tr>"
    "<td>Venda Atual:</td>"
               " <td>" tt-filial.val-venda-atual format ">>>,>>>,>>9.99"     "</td>"
    "</tr>"
    "<tr>"
    "<td>Venda Ano Anterior:&nbsp;</td>"
               "<td>" tt-filial.val-venda-ant  format ">>>,>>>,>>9.99"      "</td>"
    "</tr>"
    "<tr>"
    "<td>Dif. Venda: </td>"
               "<td>" tt-filial.vdif-venda  format "->>9.99%"   "</td>"
    "</tr>"
    "<tr><td>&nbsp;</td></tr>"skip.
    
end.
                
                
output close.

if venvmail = yes
then do:
    run /admcom/progr/envia_info.p("1020", varquivo).
end.
    

