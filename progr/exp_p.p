{admcab.i}
def var vetbcod like estab.etbcod.
def var vdti    like com.plani.pladat.
def var vdtf    like com.plani.pladat.
def stream smovim.
def stream splani.
def var expmov as log format "Sim/Nao".
def var expcob as log format "Sim/Nao".

repeat:

        
    vdti = today.
    vdtf = today.

    update  vetbcod label "Filial"
            vdti    label "Data Inicial"
            vdtf    label "Data Final" 
            expmov  label "Exportar Notas"
            expcob  label "Exportar Comissao Cobrador"
                with frame f0 side-label width 80 1 column
                    title "EXPORTACAO DE NOTAS FISCAIS".
    

    
    if expmov
    then do:
    output stream smovim to l:\dados\movim.d.
    output stream splani to l:\dados\plani.d.

    for each tipmov where tipmov.movtdc <> 4
                      and tipmov.movtdc <> 30 no-lock.
        for each plani where plani.etbcod = vetbcod           and
                             plani.movtdc = tipmov.movtdc     and
                             plani.pladat >= vdti             and
                             plani.pladat <= vdtf no-lock.
                             
            display "Atualizando Vendas...."
                     plani.etbcod no-label
                     plani.pladat no-label
                     plani.numero no-label format "9999999"
                            with frame f1 1 down centered.
            pause 0.         
                               
    
        
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat no-lock:
                             
                export stream smovim movim.
        
            end.    

            export stream splani plani.
        end.
    
    end.    


    /*****************  transferencia de entrada ************************/
    for each plani where plani.desti  = vetbcod           and
                         plani.movtdc = 6                 and
                         plani.pladat >= vdti             and
                         plani.pladat <= vdtf no-lock.
                             
                         
        display "Atualizando Transf...."
                 plani.etbcod no-label
                 plani.pladat no-label
                 plani.numero no-label format "9999999"
                    with frame f2 1 down centered.
        pause 0.         
                                   
        
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
    
        
            export stream smovim movim.
        
        end.
        
    
        export stream splani plani.
        
    end.    
    output stream smovim close.
    output stream splani close.
    end.
    
    if expcob
    then do:
    
        output to l:\dados\cobranca.d.
        for each cobranca where cobranca.etbcod = vetbcod no-lock:
        
        
            export cobranca.
            
            
        end.
        output close.    
            
            
    end.            
end.
    



         

                       
