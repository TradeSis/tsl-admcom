def temp-table tt-forpaifi
    field forpai like fabri.fabcod
    field forcod like fabri.fabcod .
    
procedure Pi-Ger-Paifilho.

def input parameter p-forcod like forne.forcod.
def buffer bforne for forne.

for each tt-forpaifi:
    delete tt-forpaifi.
end.        

for each forne where forne.forcod = p-forcod no-lock:
 
    find first tt-forpaifi where tt-forpaifi.forcod = forne.forcod 
                        no-error.
    if not avail tt-forpaifi
    then do:
        create tt-forpaifi.
        assign /*tt-forpaifi.forpai   = forne.forpai*/
               tt-forpaifi.forcod   = forne.forcod.  
    end. 
    
    for each bforne where 
             bforne.forpai = forne.forcod
             no-lock:
        find first tt-forpaifi where tt-forpaifi.forcod = bforne.forcod 
                            no-error.
        if not avail tt-forpaifi
        then do:
            create tt-forpaifi.
            assign /*tt-forpaifi.forpai   = bforne.forpai*/
                   tt-forpaifi.forcod   = bforne.forcod.  
        end. 
    end.         
end.

end procedure.
