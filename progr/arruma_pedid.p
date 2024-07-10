for each pedid where pedid.pedtdc = 1 and
                     pedid.clfcod = 5027:
    disp pedid.pednum
         pedid.pedtdc
         pedid.peddat with 1 down. 
    
    pause 0.
         
    for each liped of pedid: 
        
        do transaction: 
            liped.lipsit = "". 
            pedid.sitped = "". 
            if liped.lipent >= (liped.lipqtd -  
                               (liped.lipqtd * 0.10)) and 
               liped.lipent <= (liped.lipqtd + (liped.lipqtd * 0.10))
            then liped.lipsit = "F". 
            else liped.lipsit = "P". 
                    
            if liped.lipent = 0 
            then liped.lipsit = "A".
        end.
    
    end.
            
    for each liped of pedid: 
    
        do transaction: 
            if liped.lipsit = "A" 
            then pedid.sitped = "A".
            else if liped.lipsit = "P" and
                    pedid.sitped <> "A"
                 then pedid.sitped = "P".
                 else if liped.lipsit = "F" and
                         pedid.sitped = "" 
                      then pedid.sitped = "F". 
        end.
    end.    

end.
                           