
if keyfunction(lastkey) = "return" 
then repeat TRANSACTION with frame f-linha: 

    update 
        prefcli.cardes.
        
    prefcli.cardes = caps(prefcli.cardes).

    next keys-loop.
end.
else 
if keyfunction(lastkey) = "GO"
then do TRANSACTION:
    run cadpref2.p.
    next keys-loop.
end.    
else
if keyfunction(lastkey) = "delete-line" or
   keyfunction(lastkey) = "cut"
then do TRANSACTION:
             
    for each  subpref where
              subpref.carcod = prefcli.carcod no-lock.

        find first clipref where 
                   clipref.subcod = subpref.subcod no-lock no-error.
        if avail clipref
        then do:
            bell.
            message Color red/withe
                    "Preferencia Associada ao Cliente" 
                    view-as alert-box title " Exclusao Negada ".
            next keys-loop.        
        end.                    
    end. 

    find first subpref where
              subpref.carcod = prefcli.carcod no-lock no-error.
    if avail subpref
    then do:
        bell.
        message color red/withe
            "Excluir Primeiro as Sub-Preferencias"
            view-as alert-box title " Exclusao Negada ".
        next keys-loop.
    end.            
    bell.
    sresp = no. 
    message color red/withe " Confirma exclusao? " update sresp.
    if sresp
    then 
        delete prefcli.
    else do:
        bell.
        message color red/withe "Exclusao nao confirmada" 
                view-as alert-box.
    end. 
    color display {&color}/{&color1} {&ofield}.
    pause 0.               
           
    next l1.
end. 

