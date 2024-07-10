def var ii as int.
disable triggers for load of gerloja.clien.
def input parameter vetbi   like ger.estab.etbcod.
def input parameter vetbf   like ger.estab.etbcod.
def input parameter vdti    like plani.pladat.
def input parameter vdtf    like plani.pladat.

def var vclicod  like ger.clien.clicod.
def var vcontnum as int.

def temp-table tt-cli
    field clicod like ger.clien.clicod
    index i1 clicod.


for each tt-cli: 
    delete tt-cli. 
end.
     
def  shared temp-table tt-estab
    field etbcod like ger.estab.etbcod
    index i1 etbcod.

ii = 0.
for each ger.estab /*where ger.estab.etbcod >= vetbi and
                         ger.estab.etbcod <= vetbf*/ no-lock:
    
    find first tt-estab where tt-estab.etbcod = ger.estab.etbcod no-error.
    if not avail tt-estab
    then next.
                      
    for each contrato where contrato.etbcod = ger.estab.etbcod and
                            contrato.dtinicial >= vdti and
                            contrato.dtinicial <= vdtf no-lock.
                  
        find first tt-cli where tt-cli.clicod = contrato.clicod no-error.
        if not avail tt-cli
        then do:
            ii = ii + 1.
            create tt-cli.
            assign tt-cli.clicod = contrato.clicod.
        end.
        display "Buscando Clientes...."
                 contrato.etbcod
                 contrato.clicod no-label
                 ii label "Total" with frame f1 1 down centered.
        pause 0. 
    end.    
end. 

ii = 0.
for each tt-cli where tt-cli.clicod > 0:
    
    find ger.clien where ger.clien.clicod = tt-cli.clicod no-lock no-error. 
    if not avail ger.clien 
    then next.
    
    ii = ii + 1.
    display "Atualizando Clientes...."
                 tt-cli.clicod no-label
                 ii label "Total"  with frame f2 1 down centered.
    
    pause 0. 
    find gerloja.clien where gerloja.clien.clicod = ger.clien.clicod no-error.
    if not avail gerloja.clien 
    then do transaction: 
        create gerloja.clien. 
        buffer-copy ger.clien to gerloja.clien.
        /*
        {clien.i gerloja.clien ger.clien}. 
        */
        gerloja.clien.exportado = yes.
    end.
    else do transaction:
        buffer-copy ger.clien to gerloja.clien.
        /*
        {clien_f.i gerloja.clien ger.clien}. 
        */
        gerloja.clien.exportado = yes.
    
    end.
end.
                    

                                    
                                    
 



    



         

                       
