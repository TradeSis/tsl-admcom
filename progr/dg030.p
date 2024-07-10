{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 30 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.
def var varquivo as char.
def var venvmail as log.
def var percentual-altp as dec.
def var perc-min-divergencia-aux as char.
def var vsp      as character.
 
assign vsp = "&nbsp;". 

assign perc-min-divergencia-aux = string(tbcntgen.valor,">>9").

assign perc-min-divergencia-aux = trim(perc-min-divergencia-aux).

varquivo = "/admcom/work/arquivodg030M.htm".
output to value(varquivo). 
put unformatted
"VENDAS COM DESCONTO MAIOR QUE " perc-min-divergencia-aux
"%<br>AUTORIZADAS PELO SUPERVISOR<BR>"
"------------------------------------------------<br>" skip(1)
. 
 
venvmail = no.

for each divpre where divpre.etbcod < 900
               /* and divpre.datexp >= today - 7   */
                  and divpre.divdat = today - 1
               /* and divpre.preven > 1            */ 
                  and divpre.divjus = "DESC. SUPERVISOR" no-lock,
                  
    first produ where produ.procod = divpre.procod no-lock,
        
    first plani where plani.etbcod = divpre.etbcod
                  and plani.placod = divpre.placod
                  and plani.serie  = "v" exclusive-lock,
                                  
    first func where func.etbcod = plani.etbcod
                 and func.funcod = plani.vencod no-lock:    
    
    if plani.nottran > 30
    then next.

    assign plani.nottran = 30.
    
    assign percentual-altp = 0.
    assign percentual-altp =
            (((divpre.preven - divpre.premat) / divpre.premat ) * 100) * -1.

    /*
    message "percentual-altp " percentual-altp " tbcntgen.valor " tbcntgen.valor .
pause.
    */
      
    if percentual-altp < tbcntgen.valor
    then next.
  
    put unformatted
         vsp vsp vsp vsp vsp vsp vsp vsp vsp vsp vsp
        "Loja: " divpre.etbcod                         "<br>"
         
         vsp vsp vsp vsp vsp vsp   
        "Produto: " produ.procod "<br>"
         
         produ.pronom format "x(28)"       "<br>"
        
        vsp vsp vsp vsp vsp vsp vsp vsp vsp vsp 
        "Nota: " plani.numero                      "<br>"

         vsp vsp vsp vsp vsp vsp vsp vsp vsp vsp
        "Data: " plani.pladat                         "<br>"
        
         vsp
        "Preco Venda: " trim(string(divpre.premat,">>>,>>9.99"))    "<br>"
        
        "Val.Vendido: " trim(string(divpre.preven,">>>,>>9.99"))    "<br>"
         
         vsp vsp vsp vsp
        "Desconto: " trim(string(percentual-altp,">>,>>9.99"))    "%<br>"

         vsp vsp vsp vsp
        "Vendedor: " func.funape format "x(15)" skip (1)  "<br>"
        "------------------------------------------------<br>" skip(1)
    
        skip. 
    venvmail = yes.
    
end.            
                
output close.
                       
if venvmail = yes
then do:
    run /admcom/progr/envia_dg.p("30",varquivo).
end.

