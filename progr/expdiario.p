def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".

def var varquivo as char format "x(40)".



repeat:


    update vdti label "Periodo"
           vdtf no-label
           varquivo label "Caminho" with frame f1 side-label width 80.



    output to value(varquivo).
    
    for each lanca where lanca.landat >= vdti and
                         lanca.landat <= vdtf no-lock:
                         
                         
        find titulo where titulo.empcod = lanca.empcod and
                          titulo.titnat = lanca.titnat and
                          titulo.modcod = lanca.modcod and
                          titulo.etbcod = lanca.etbcod and
                          titulo.clifor = lanca.clifor and
                          titulo.titnum = lanca.titnum and
                          titulo.titpar = lanca.titpar no-lock.
                          
                          
        if lanca.lannat = "V" or
           lanca.lannat = "P"
        then put "11020100010" format "x(28)".
        else put "53020100011" format "x(28)".
        
        put string(titulo.clifor) format "x(14)"
            lanca.landat  format "99/99/99"
            " " format "x(50)"
            (lanca.lanval * 100) format ">>>>>>>>>>>>>>>>>".
            
        if lanca.lannat = "V"
        then put "C".
            
        if lanca.lannat = "P"
        then put "P".
        
    
        if lanca.lannat = "J"
        then put "B".

        put "CRE".
        
        put trim(lanca.titnum + "/" + string(lanca.titpar)) format "x(12)". 
        
        put (lanca.lanval * 100) format ">>>>>>>>>>>>>>>>>".
        
        put titulo.titdtemi format "99/99/99". 
        put titulo.titdtven format "99/99/99".


        
        
        

        
                              
    end.
end.
                                        
                                        
