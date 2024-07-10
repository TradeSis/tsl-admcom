def var vetb as int.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vdata like plani.pladat.

pause.
for each lanfor:

    if datven <> ?
    then next.
               
           
           
    for each fin.modal no-lock:
        find first fin.titulo 
                            where fin.titulo.empcod = 19 and
                                  fin.titulo.titnat   = yes and
                                  fin.titulo.modcod = modal.modcod and
                                  fin.titulo.titdtpag = lanfor.datope and
                                  fin.titulo.titvlcob = lanfor.valtit and
                                  fin.titulo.titnum   = lanfor.numdoc
                                                no-lock no-error.
        if not avail fin.titulo  
        then do:      
            find first fin.titulo 
                        where fin.titulo.empcod = 19 and
                              fin.titulo.titnat = yes and
                              fin.titulo.modcod = modal.modcod and   
                              fin.titulo.titdtpag = lanfor.datope   and
                              fin.titulo.titvlcob = lanfor.valtit 
                                                no-lock no-error.
            if avail fin.titulo  
            then do: 
                 assign lanfor.datemi = fin.titulo.titdtemi 
                        lanfor.datven = fin.titulo.titdtven
                        lanfor.numdoc = fin.titulo.titnum
                        lanfor.clifor = string(fin.titulo.clifor)
                        lanfor.tipope = "P"  
                        lanfor.tipdoc = "DUP".
            end.    
        end.            
        else do:
    
           assign lanfor.datemi = fin.titulo.titdtemi  
                  lanfor.datven = fin.titulo.titdtven 
                  lanfor.numdoc = fin.titulo.titnum 
                  lanfor.clifor = string(fin.titulo.clifor) 
                  lanfor.tipope = "P"   
                  lanfor.tipdoc = "DUP".

            
        end.     
    end.
end.