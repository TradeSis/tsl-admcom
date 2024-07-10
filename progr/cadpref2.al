if keyfunction(lastkey) = "return" 
then repeat TRANSACTION with frame f-linha: 

    update 
        subpref.subcar
        subpref.subdes .

    subpref.subdes = caps(subpref.subdes).    

next keys-loop.
end.
else
if keyfunction(lastkey) = "delete-line" or
   keyfunction(lastkey) = "cut"
then do TRANSACTION with frame f-linha:
    find first clipref where 
                   clipref.subcod = subpref.subcod no-lock no-error.
    if avail clipref
    then do:
        bell.
        message Color red/withe
                    "Sub-Preferencia Associada ao Cliente" 
                    view-as alert-box title " Exclusao Negada ".
        next keys-loop.        
    end.                    
    color display withe/black  {&ofield}.
    sresp = no. bell.
    message color red/withe
        "Sub-Preferencia " subpref.subdes
        view-as alert-box buttons yes-no 
        title " Confirma exclusao? " update sresp.
    if sresp 
    then 
        delete subpref.
    else 
            bell.
            message color red/withe "Exclusao nao confirmada"
                    view-as alert-box title "".

    color display {&color}/{&color1} {&ofield}.
    pause 0.               
    assign a-seeid = -1. 
    clear frame f-linha all.
    next keys-loop.
end. 

