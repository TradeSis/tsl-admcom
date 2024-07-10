def input parameter vetbcod like estab.etbcod.
def input parameter vdti    like com.plani.pladat.
def input parameter vdtf    like com.plani.pladat.
def stream scon.
def stream stit.
def stream scnf.


output stream scnf to l:\dados\contnf.d.
output stream scon to l:\dados\contrato.d.
for each contrato where contrato.etbcod = vetbcod  and
                        contrato.dtinicial >= vdti and
                        contrato.dtinicial <= vdtf no-lock.
                                
    display "Atualizando Contratos...."
                 contrato.contnum
                 contrato.dtinicial format "99/99/9999" no-label
                        with frame f1 1 down centered.
    pause 0.         

    export stream scon contrato.
    
    for each contnf where contnf.etbcod  = contrato.etbcod and
                          contnf.contnum = contrato.contnum no-lock:
        
        export stream scnf contnf.        
    end.    
    
end.    
output stream scon close.
output stream scnf close.


output stream stit to l:\dados\titulo.d. 
for each titulo where titulo.empcod = 19      and
                          titulo.titnat = no      and
                          titulo.modcod = "CRE"   and
                          titulo.etbcod = vetbcod and
                          titulo.titsit = "LIB" no-lock:
                          
                                
    display "Atualizando Titulos Abertos...."
                 titulo.clifor
                 titulo.titdtven format "99/99/9999" no-label
                        with frame f2 1 down centered.
    pause 0.         

    export stream stit titulo.
    
end.

for each titulo where titulo.etbcobra = vetbcod and
                      titulo.titdtpag >= vdti   and 
                      titulo.titdtpag <= vdtf no-lock:
                          
    if titulo.clifor = 1
    then next.
                                

    
    display "Atualizando Titulos Pagos...."
                 titulo.clifor
                 titulo.titdtven format "99/99/9999" no-label
                        with frame f3 1 down centered.
    pause 0.         
    export stream stit titulo.

end.
output stream stit close.

    



         

                       
