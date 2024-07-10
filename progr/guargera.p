def var dt as date.

def temp-table ttven
    field ven as int
    field etb as int
    field dat as date
    field val as dec.

def temp-table ttloj
    field etb as int
    field dat as date
    field val as dec.

def temp-table ttemp
    field dat as date
    field val as dec.

do dt = 01/01/2000 to today:

    for each ttemp:
        delete ttemp.
    end.    
    
    for each estab no-lock:
    
        disp estab.etbcod dt with 1 down. pause 0.
        
        for each ttven:
            delete ttven.
        end.
            
        for each ttloj:
            delete ttloj.
        end.    
        
        for each plani where plani.movtdc = 5
                         and plani.etbcod = estab.etbcod
                         and plani.pladat = dt no-lock:

            find first ttloj where ttloj.etb = plani.etbcod no-error.
 
            if not avail ttloj
            then do:
            
                create ttloj.
                assign ttloj.etb = plani.etbcod
                       ttloj.dat = plani.pladat.
                            
            end.                           
            
            ttloj.val = ttloj.val + plani.platot.
            
            find first ttemp no-error.
            
            if not avail ttemp
            then do:
            
                create ttemp.
                assign ttemp.dat = plani.pladat.
                            
            end.                           
            
            ttemp.val = ttemp.val + plani.platot.
            
            if plani.vencod = 0
            then next.
            
            find first ttven where ttven.ven = plani.vencod and
                                   ttven.etb = plani.etbcod no-error.
            if not avail ttven
            then do:
            
                create ttven.
                assign ttven.ven = plani.vencod
                       ttven.etb = plani.etbcod
                       ttven.dat = plani.pladat.
                            
            end.                           
            
            ttven.val = ttven.val + plani.platot.

        end.

        for each ttven:

            find first recorde where recorde.vencod = ttven.ven and
                                     recorde.etbcod = ttven.etb no-error.
            if not avail recorde
            then do:
            
                create recorde.
                assign recorde.vencod = ttven.ven
                       recorde.etbcod = ttven.etb
                       recorde.dtreco = ttven.dat
                       recorde.vlreco = ttven.val.
                     
            end.
            else do:
                
                if ttven.val > recorde.vlreco
                then do:
                    
                    assign recorde.dtrecoant = recorde.dtreco
                           recorde.vlrecoant = recorde.vlreco.
                           
                    assign recorde.dtreco    = ttven.dat
                           recorde.vlreco    = ttven.val.    
                           
                end.           
                       
            end.           
                       
        end.               
        
        for each ttloj:

            find first recorde where recorde.vencod = 0 and
                                     recorde.etbcod = ttloj.etb no-error.
            if not avail recorde
            then do:
            
                create recorde.
                assign recorde.vencod = 0
                       recorde.etbcod = ttloj.etb
                       recorde.dtreco = ttloj.dat
                       recorde.vlreco = ttloj.val.
                     
            end.
            else do:
                
                if ttloj.val > recorde.vlreco
                then do:
                    
                    assign recorde.dtrecoant = recorde.dtreco
                           recorde.vlrecoant = recorde.vlreco.
                           
                    assign recorde.dtreco    = ttloj.dat
                           recorde.vlreco    = ttloj.val.    
                           
                end.           
                       
            end.           
                       
        end.               
        
    end.        
        
    for each ttemp:

        find first recorde where recorde.vencod = 0 and
                                 recorde.etbcod = 0 no-error.
        if not avail recorde
        then do:
            
            create recorde.
            assign recorde.vencod = 0
                   recorde.etbcod = 0
                   recorde.dtreco = ttemp.dat
                   recorde.vlreco = ttemp.val.
                     
        end.
        else do:
                
            if ttemp.val > recorde.vlreco
            then do:
                    
                assign recorde.dtrecoant = recorde.dtreco
                       recorde.vlrecoant = recorde.vlreco.
                           
                assign recorde.dtreco    = ttemp.dat
                       recorde.vlreco    = ttemp.val.    
                           
            end.           
                       
        end.           
                       
    end.

end.

for each recorde:

    disp recorde.
    
end.    
