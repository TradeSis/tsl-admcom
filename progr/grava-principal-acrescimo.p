
def input parameter p-clicod like clien.clicod.
def input parameter  p-contnum like contrato.contnum.
def var vtitpar as dec.
def var valtitulo as dec decimals 4 format ">>>,>>>9.99". 
def var val-entrada like contrato.vlentra.
def var vtotaltit as dec.
def var valprazo as dec.

{/admcom/progr/retorna-pacnv.i new}

def buffer btitulo for titulo.
def buffer bcontrato for contrato.

if p-clicod <> ?
then
for each contrato where contrato.clicod = p-clicod no-lock:

    run /admcom/progr/retorna-pacnv-valores-contrato.p 
                    (input ?, 
                     input recid(contrato), 
                     input ?).

    if pacnv-principal < 0
    then assign
            pacnv-principal = 0
            pacnv-acrescimo = 0.
            
    if pacnv-acrescimo < 0
    then assign
            pacnv-principal = pacnv-principal + pacnv-acrescimo
            pacnv-acrescimo = 0.
    
    vtitpar = 0.
    vtotaltit = 0.
        
    valprazo = contrato.vltotal - pacnv-entrada.
    if pacnv-principal > valprazo
    then assign
             pacnv-principal = valprazo
             pacnv-acrescimo = 0.
    
    do on error undo:
        find bcontrato where bcontrato.contnum = contrato.contnum 
            no-error.
        if avail bcontrato
        then do:
            assign
                    bcontrato.vlf_principal = pacnv-principal
                    bcontrato.vlf_acrescimo = pacnv-acrescimo
                    vtitpar = 0.
            valtitulo = 0.        
                          
            for each titulo where
                     titulo.titnat = no and
                     titulo.clifor = bcontrato.clicod and
                     titulo.titnum = string(bcontrato.contnum) and
                     titulo.titpar > 0
                     no-lock:
                if titulo.titparger > 0 and titulo.titparger < 100 
                then next.
 
                valtitulo = valtitulo + titulo.titvlcob.
                vtitpar = vtitpar + 1.

            end.
            
            for each btitulo where
                     btitulo.titnat = no and
                     btitulo.clifor = bcontrato.clicod and
                     btitulo.titnum = string(bcontrato.contnum) and
                     btitulo.titpar > 0
            
                     .
                if btitulo.titparger > 0 and btitulo.titparger < 100 
                then next.
                assign
                    btitulo.vlf_principal = 
                                bcontrato.vlf_principal / vtitpar
                    btitulo.vlf_acrescimo = 
                                bcontrato.vlf_acrescimo / vtitpar
                    .
                if bcontrato.vlseguro > 0 and
                   btitulo.titdes = 0
                then btitulo.titdes = bcontrato.vlseguro / vtitpar.    
            end. 
            bcontrato.nro_parcelas  = vtitpar.
        end.
    end.
end.
else if p-contnum <> ?
then
for each contrato where contrato.contnum = p-contnum no-lock:

    run /admcom/progr/retorna-pacnv-valores-contrato.p 
                    (input ?, 
                     input recid(contrato), 
                     input ?).

    if pacnv-principal < 0
    then assign
            pacnv-principal = 0
            pacnv-acrescimo = 0.
            
    if pacnv-acrescimo < 0
    then assign
            pacnv-principal = pacnv-principal + pacnv-acrescimo
            pacnv-acrescimo = 0.
    
    vtitpar = 0.
    vtotaltit = 0.
        
    valprazo = contrato.vltotal - pacnv-entrada.
    if pacnv-principal > valprazo
    then assign
             pacnv-principal = valprazo
             pacnv-acrescimo = 0.
    
    do on error undo:
        find bcontrato where bcontrato.contnum = contrato.contnum 
            no-error.
        if avail bcontrato
        then do:
            assign
                    bcontrato.vlf_principal = pacnv-principal
                    bcontrato.vlf_acrescimo = pacnv-acrescimo
                    vtitpar = 0.
            valtitulo = 0.        
                          
            for each titulo where
                     titulo.titnat = no and
                     titulo.clifor = bcontrato.clicod and
                     titulo.titnum = string(bcontrato.contnum) and
                     titulo.titpar > 0
                     no-lock:
                if titulo.titparger > 0 and titulo.titparger < 100 
                then next.
 
                valtitulo = valtitulo + titulo.titvlcob.
                vtitpar = vtitpar + 1.

            end.
            
            for each btitulo where
                     btitulo.titnat = no and
                     btitulo.clifor = bcontrato.clicod and
                     btitulo.titnum = string(bcontrato.contnum) and
                     btitulo.titpar > 0
            
                     .
                if btitulo.titparger > 0 and btitulo.titparger < 100 
                then next.
                assign
                    btitulo.vlf_principal = 
                                bcontrato.vlf_principal / vtitpar
                    btitulo.vlf_acrescimo = 
                                bcontrato.vlf_acrescimo / vtitpar
                    .
            end. 
            bcontrato.nro_parcelas  = vtitpar.
        end.
    end.
end.             
        
