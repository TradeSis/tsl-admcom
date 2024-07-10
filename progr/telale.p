def var lin   as i.
def var cln   as i.
def var som   as log.
def var dim   as log.

som = yes.
dim = yes.

repeat while keyfunction(lastkey) <> "END-ERROR" /*loop <= 50*/:
    
    if som 
    then lin = lin + 1.
    else lin = lin - 1.
    if lin = 22 
    then som = no.
    if lin = 1
    then som = yes.
    
    if dim 
    then cln = cln + 1.
    else cln = cln - 1.
    if cln = 80 
    then dim = no.
    if cln = 1
    then dim = yes.

    /*
    cln = cln + 1.
    
    if cln = 80
    then assign
            cln = 1.
    */        

    disp "¾" with frame f 
         row lin column cln 
         no-label no-box . pause 1 no-message.
    hide frame f.     
end.