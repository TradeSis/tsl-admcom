def input parameter vetbcod like estab.etbcod.

def var vconta as int init 0.
for each adm.tbcartao no-lock:
                      
    vconta = vconta + 1.                                
                                    
    display "Atualizando Cartao Lebes...."
                 vconta no-label
                 adm.tbcartao.nrocartao no-label
                        with frame f1 1 down centered.
    pause 0.         

    find admloja.tbcartao where
         admloja.tbcartao.codoper = adm.tbcartao.codoper and
         admloja.tbcartao.nrocartao = adm.tbcartao.nrocartao
         no-error.
         
    if not avail admloja.tbcartao
    then do transaction:
        
        create admloja.tbcartao.
        buffer-copy adm.tbcartao to admloja.tbcartao.
    end.  
end.    
