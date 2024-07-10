{admcab.i}
def var vdata like plani.pladat.
def var varq as char.
def var varq2 as char.

repeat:

    update vdata label "Data Arquivo"
        with frame f1 side-label width 80.
        
        
    varq = "/admcom/import/leitora/" + 
             string(year(vdata),"9999") +
             string(month(vdata),"99")  + 
             string(day(vdata),"99") + ".txt".
             
             
    if search(varq) <> ?
    then do:
    
        message "Deseja excluir o arquivo de " vdata update sresp.
        if sresp
        then do:
            dos silent del value(varq).
         
            varq2 = "/admcom/import/leitora/" + 
                    string(year(vdata),"9999") + 
                    string(month(vdata),"99")  +  
                    string(day(vdata),"99") + ".dig".
                    
            if search(varq2) <> ?
            then dos silent del value(varq2).
            
        end.
    end.
    else message "Arquivo nao encontrado".
end.
        
            
            
          
         
             
             
    
     
