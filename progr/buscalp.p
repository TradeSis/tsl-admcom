def input parameter vetbcod like estab.etbcod.
def input parameter vdti    like plani.pladat.
def input parameter vdtf    like plani.pladat.
def var   vtotal like plani.platot.

def temp-table tt-titulo
    field data like plani.pladat
    field vtot like plani.platot.

for each tt-titulo.
    delete tt-titulo.
end.        

for each finloja.titulo use-index titsit
         where finloja.titulo.etbcobra = vetbcod and
                       finloja.titulo.titdtpag >= vdti and
                       finloja.titulo.titdtpag <= vdtf 
                            no-lock.
                       
                       
    
    if finloja.titulo.titpar = 0 or
       finloja.titulo.clifor = 1
    then next.

    vtotal = vtotal + titulo.titvlcob.
    
    disp finloja.titulo.clifor
         finloja.titulo.titdtpag 
         vtotal label "Total Prestacoes" with 1 down. pause 0.
         
    find first tt-titulo where tt-titulo.data = finloja.titulo.titdtpag
                                        no-error.
    if not avail tt-titulo
    then do:
        create tt-titulo.
        assign tt-titulo.data = finloja.titulo.titdtpag.
    end.
    tt-titulo.vtot = tt-titulo.vtot + finloja.titulo.titvlcob.
        
                                        
                 
end.                 

for each tt-titulo.
    disp tt-titulo.
end.    

                       
