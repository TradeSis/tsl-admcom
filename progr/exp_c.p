{admcab.i}
def var vetbcod like ger.estab.etbcod.
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.
def stream sclien.


def temp-table tt-cli
    field clicod like ger.clien.clicod
    index i1 clicod.

def temp-table tt-estab
    field etbcod like estab.etbcod
    index i1 etbcod.
    
form with frame f-1.
def var varquivo as char.

repeat:
    
    for each tt-cli: 
        delete tt-cli. 
    end.
    
    vdti = today.
    vdtf = today.

    repeat:       
        update vetbcod label "Filial" at 7 with frame f-1.
        find estab where estab.etbcod = vetbcod no-lock .
        find first tt-estab where
                   tt-estab.etbcod = vetbcod no-error.
        if not avail tt-estab
        then do:
            create tt-estab.
            tt-estab.etbcod = vetbcod.
        end.           
        disp tt-estab.etbcod estab.etbnom
            with frame f-est down centered no-label.
    end.                            
    for each tt-estab where tt-estab.etbcod = 0 .
        delete tt-estab.
    end. 
    /**
    if vetbcod <> 0 
    then do: 
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab 
        then do: 
            message "Estabelecimento nao Cadastrado".
            undo. 
        end. 
        else disp estab.etbnom no-label 
                        with frame f-1.
    end. 
    else disp "Todas" @ estab.etbnom no-label with frame f-1.
    **/
    
    update vdti  label "Data Inicial" at 7
           vdtf  label "Data Final"  
                with frame f-1 side-label width 80
                         title "ATUALIZACAO DE CLIENTES".

    for each estab /*where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod*/ no-lock:
                        
        find first tt-estab where 
                   tt-estab.etbcod = estab.etbcod no-error.
        if not avail tt-estab then next.
        
        for each tt-cli:
            delete tt-cli.
        end.               
        for each contrato where contrato.etbcod = estab.etbcod and
                                contrato.dtinicial >= vdti and
                                contrato.dtinicial <= vdtf no-lock.
                                
            display "Buscando Clientes...."
                     contrato.etbcod
                     contrato.clicod no-label
                        with frame f1 1 down centered.
            pause 0.         

            find first tt-cli where tt-cli.clicod = contrato.clicod no-error.
            if not avail tt-cli
            then do:
                create tt-cli.
                assign tt-cli.clicod = contrato.clicod.
            end.
    
        end.    
        varquivo = "".
        if opsys = "UNIX"
        then varquivo = "/admcom/dados/clien" + 
                            string(estab.etbcod,"999") + ".d".
        else varquivo = "l:\dados\clien" + 
                            string(estab.etbcod,"999") + ".d".
 
        output stream sclien to value(varquivo).

        for each tt-cli:  
        
            find clien where clien.clicod = tt-cli.clicod no-lock no-error. 
            if not avail ger.clien 
            then next.
        
            display "Exportando Clientes...."
                tt-cli.clicod no-label with frame f2 1 down centered.
                
            pause 0.    
        
            export stream sclien clien.
    
        end.
        output stream sclien close.
    end.    
end.    




    



         

                       
