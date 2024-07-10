{admcab.i}

def var pprodutostatus  as log.
def var pperfilativo    as log.

{seg/defhubperfildin.i new}

 
    disp setbcod label "Filial"
         with frame f1 row 3 
            centered no-box
            color messages side-labels.

    update pvencod  label "Vendedor"
                with frame f1.

    find first func where func.etbcod = setbcod and
                              func.funcod = pvencod
                              no-lock no-error.
                                      
    disp func.funnom no-labels
                with frame f1.    
         
    run seg/telahubsegpro.p (output pprodutostatus).
    
    if pprodutostatus
    then do:    
        find first ttsegprodu where ttsegprodu.procod = pprocod no-lock.
        find first ttseguro   where ttseguro.id       = ttsegprodu.idseguro no-error.
                
        disp pprocod format ">>>>>>>>9" 
             ttsegprodu.pronom
             ttseguro.PerfilTitularId
             ttseguro.coberturavalor
            with frame frame-cab 1 down centered row 4 no-box
            no-labels.
        
        run api/segbuscaperfil.p (output pperfilativo).

        find first ttperfil where ttperfil.id = ttseguro.PerfilTitularId no-error.

        if pperfilativo = no
        then do:
            message "Perfil" ttseguro.PerfilTitularId "nao esta ativo"
                view-as alert-box.
            undo.
        end.    
                            
        run seg/telahubsegper.p.
    
        
    end.
