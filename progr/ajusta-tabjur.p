def buffer btabjur for tabjur.

def temp-table tt-tabjur like tabjur.


for each tabjur where etbcod = 1  no-lock.

    find first btabjur where btabjur.etbcod = 0
                         and btabjur.nrdias = tabjur.nrdias
                                exclusive-lock no-error.
    if not avail btabjur
    then do:
    
        create tt-tabjur.
        
        buffer-copy tabjur to tt-tabjur.
        
        assign tt-tabjur.etbcod = 0.
        
        create btabjur.
        
        buffer-copy tt-tabjur to btabjur.
    
        empty temp-table tt-tabjur.

    end.
    else do:
    
        create tt-tabjur.
        
        buffer-copy tabjur to tt-tabjur.
        
        assign tt-tabjur.etbcod = 0.
        
        buffer-copy tt-tabjur to btabjur.

        empty temp-table tt-tabjur.
        
    end.
    
end.