propath = "/admcom/progr,/usr/dlc".
    
    
{/admcom/progr/admcab-batch.i new}


def var vdata-ini      as date format "99/99/9999".
def var vdata-fin      as date format "99/99/9999".
def var vdata          as date format "99/99/9999".
def var vtotal-venda   like  plani.platot.
def var varquivo       as char.

repeat: 
 pause 15 no-message.
vdata-ini = date(month(today),1,year(today)).
vdata-fin = today.

varquivo = "".
varquivo  = "/admcom/import/vendageral.txt".

vtotal-venda = 0.

do vdata = vdata-ini to vdata-fin:

    for each estab no-lock:
            
        for each plani where plani.movtdc = 5 
                         and plani.etbcod = estab.etbcod
                         and plani.pladat = vdata
                         use-index pladat no-lock:
                         
            if plani.biss > 0 
            then vtotal-venda = vtotal-venda + plani.biss.
            else vtotal-venda = vtotal-venda 
                               + (plani.platot - plani.vlserv).

        end.
    
    end.
    
end.

output to value(varquivo).
    disp vtotal-venda no-label
         format "->>>,>>>,>>9.99" with no-box.
output close.

end.
