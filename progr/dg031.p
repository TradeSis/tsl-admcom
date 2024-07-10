def input parameter ipint-pednum as integer.

def buffer pedid     for pedid.
def buffer pedecom   for pedecom.
def buffer boletopag for boletopag.
def buffer clien     for clien.


{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 31 no-lock no-error.
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

varquivo = "/admcom/work/arquivodg031.htm".
output to value(varquivo). 
put unformatted
"PEDIDO DO E-COMMERCE LIBERADO "
"<br>COM PAGAMENTO ABAIXO DO ESPERADO<br>"
"------------------------------------------------------------------<br>" skip(1)
. 
 
venvmail = no.

find first pedecom where pedecom.etbcod = 200
                     and pedecom.pedtdc = 3
                     and pedecom.pednum = ipint-pednum
                            no-lock no-error.

find first pedid where pedid.etbcod = pedecom.etbcod
                   and pedid.pedtdc = pedecom.pedtdc
                   and pedid.pednum = pedecom.pednum
                              no-lock no-error.
   
   
find first boletopag where boletopag.bolcod = pedid.pednum
                              no-lock no-error.
                                              
find first clien where clien.clicod = pedid.clfcod
                              no-lock no-error.
                        
find first func where func.etbcod = 999
                  and func.funcod = pedid.vencod
                        no-lock no-error.                                      
                                            
if not avail boletopag
then return.    
    
    
    put unformatted
         vsp vsp vsp vsp vsp vsp vsp vsp vsp vsp vsp vsp vsp vsp vsp
        "Pedido: " pedid.pednum                 "<br>"
         
         vsp vsp   
        "Valor esperado: " (pedecom.valor + pedecom.valfrete)
                                format ">>>,>>9.99"  "<br>"
         /*
         produ.pronom format "x(28)"       "<br>"
         */
        vsp vsp vsp vsp vsp vsp vsp vsp 
        "Valor Pago: " boletopag.bolvalpag                      "<br>"

         vsp 
        "Data do Pedido: " pedid.peddat  format "99/99/9999"      "<br>"
        
         vsp
        "Data Liberacao: " today format "99/99/9999"   "<br>".
        
        if avail func
        then do:
        
            put unformatted
            "Funcionario: " func.funnom. 
        
        end.
        
        put unformatted
        "<br>"
        vsp vsp vsp
        " ---------- PRODUTOS ---------- <br>" skip.
        
        
     for each liped of pedid no-lock,
     
         first produ of liped no-lock:
         
         put unformatted
             vsp vsp vsp vsp vsp vsp vsp
             "<br>" produ.pronom skip
             "<br>Qtd.: " liped.lipqtd skip(1).
         
     end.
     put unformatted
    "<br>------------------------------------------------------------------<br>"
            skip(1).
    
    venvmail = yes.
    
output close.
                       
if venvmail = yes
then do:
    run /admcom/progr/envia_dg.p("31",varquivo).
end.

