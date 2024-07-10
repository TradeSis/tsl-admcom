def var vdt as date.
    def var vv as int.

def var ii as int.
def var xx as int.
def var zz as char.
pause.



def temp-table tt-tit like fin.titulo.                              

           
                                       
                              
   


              

for each lanfor:

            
    ii = ii + 1.
    if ii mod 100 = 0
    then display ii with 1 down. pause 0.
      
    if lanfor.datven <> ?
    then next.
    
  
    for each tt-tit:
        delete tt-tit.
    end.    
                
    
    for each fin.modal no-lock:
        for each fin.titulo where titulo.empcod = 19 and
                              titulo.titnat = yes and
                              titulo.modcod = fin.modal.modcod and
                              titulo.titdtpag >= 01/01/2001 and
                              titulo.titdtpag <= 12/31/2001 and
                              titulo.titvlpag = lanfor.valtit no-lock:
                              
        create tt-tit.
        buffer-copy fin.titulo to tt-tit.
                              
        end.
    end.
    
    vv = 0.
    for each tt-tit:
        vv = vv + 1.
    end.
    
    if vv = 1
    then do:
        find first tt-tit.
        assign lanfor.datemi = tt-tit.titdtemi  
                lanfor.datven = tt-tit.titdtven 
                lanfor.numdoc = tt-tit.titnum 
                lanfor.clifor = string(tt-tit.clifor) 
                lanfor.tipope = "P"   
                lanfor.tipdoc = "DUP".
    end.
    else do:
   
        for each tt-tit:

            xx = length(tt-tit.titnum).
            if xx >= 2
            then zz = substring(tt-tit.titnum,(xx - 1),2).
            
            if xx = 1
            then zz = substring(tt-tit.titnum,1,1).


        
        
            if lanfor.numdoc = zz
            then assign  lanfor.datemi = tt-tit.titdtemi  
                        lanfor.datven = tt-tit.titdtven 
                        lanfor.numdoc = tt-tit.titnum 
                        lanfor.clifor = string(tt-tit.clifor) 
                        lanfor.tipope = "P"   
                        lanfor.tipdoc = "DUP".
             
        end.
    
    end.
        

        
end.
