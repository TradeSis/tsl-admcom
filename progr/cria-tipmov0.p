{admcab.i}
def var vetbcod like estab.etbcod.
def var vip     as char.
for each estab where estab.etbcod = 38:
    
    vetbcod = estab.etbcod.
        
        
    display estab.etbnom no-label with frame f1 down.
    pause 0.  
    vip = "filial" + string(estab.etbcod,"999").
                       
    message "Criando tipo de movimento na loja.....". 
    connect com -H value(vip) -S sdrebcom -N tcp -ld comloja no-error.
   
    run cria-tipmov.p.
                
    disconnect comloja.
    
end.        