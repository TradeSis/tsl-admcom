{admcab.i}

def var vaplinom like aplicativo.aplinom.
 

def new shared temp-table tt-apli
    field aplicod like aplicativo.aplicod
    field aplinom like aplicativo.aplinom
    index ind-1 aplicod.

repeat:
    
                                 
    for each tt-apli:
        delete tt-apli.
    end.
    
    for each aplicativo no-lock:
        find first tt-apli 
             where tt-apli.aplicod = aplicativo.aplicod no-error.
        if not avail tt-apli
        then do:
            create tt-apli.
            assign tt-apli.aplicod = aplicativo.aplicod
                   tt-apli.aplinom = aplicativo.aplinom.
        end.
    end.
                           
    hide frame f-data no-pause.
    run tt-ace2.p. 
    return.
   
end.




