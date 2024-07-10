{admcab.i}
def shared temp-table ttconf
    field etbcod like estab.etbcod label "Fl"
    field totplani as dec          label "Tot.Vendas" format ">,>>>,>>9.99"
    field totmovim as dec          label "Tot.Linhas" format ">,>>>,>>9.99"
    field totvista as dec          label "Tot.Vista"  
    field totcomissao as dec       label "Tot.Comissao" format ">,>>>,>>9.99"
    field totprazo as dec          label "Tot.Prazo"    format ">,>>>,>>9.99"
    field totcontr as dec          label "Tot.Contrato" format ">,>>>,>>9.99"
    field tottitul as dec          label "Tot.Titulos"  format ">,>>>,>>9.99" 
    field totpagos as dec          label "Tot.Pagos"    format ">,>>>,>>9.99" 
    field totdepos as dec          label "Tot.Deposito"
            index ind-1 etbcod.

def input parameter vdti like plani.pladat.
def input parameter vdtf like plani.pladat.

def input parameter vetbi like estab.etbcod.
def input parameter vetbf like estab.etbcod.
for each estab where estab.etbcod >= vetbi and
                     estab.etbcod <= vetbf no-lock.
    for each d.titulo where d.titulo.etbcobra = estab.etbcod and
                            d.titulo.titdtpag >= vdti and
                            d.titulo.titdtpag <= vdtf no-lock:
                
        disp d.titulo.titnum with 1 down. pause 0.
            
        find first ttconf where ttconf.etbcod = estab.etbcod  no-lock no-error.
        if not avail ttconf 
        then do: 
            create ttconf.
            assign ttconf.etbcod = estab.etbcod.
        end.
        ttconf.totpagos = ttconf.totpagos + d.titulo.titvlpag.
    end.
end.    
 