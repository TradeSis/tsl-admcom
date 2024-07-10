{admcab.i}

{setbrw.i}

def input parameter p-clicod like clien.clicod.

def new shared buffer prefcli for prefcli.

form    a-seelst format "x" no-label
        prefcli.carcod column-label "Codigo"
        prefcli.cardes column-label "Descricao"
        with frame f-linha down row 12   overlay
          title " Preferencias do cliente "
          color white/brown.

l1: repeat on endkey undo, leave with frame f-linha:

    assign 
        a-seeid = -1
        a-seelst = ",".
        
    for each clipref where
             clipref.clicod = p-clicod no-lock.

        find subpref where
             subpref.subcod = clipref.subcod no-lock.
        
        find prefcli where
             prefcli.carcod = subpref.carcod no-lock.

        a-seelst = a-seelst + string(prefcli.carcod,"999") + ",".
        
    end.         
                   
    {sklcls.i
        &help =  "ENTER=Sub-Preferencia F4=Retorna "
        &file         = prefcli
        &cfield       = prefcli.cardes
        &ofield       = " 
                         prefcli.cardes
                         prefcli.carcod
                        " 
        &where        = "true"
        &color        = withe
        &color1       = brown
        &usepick      = "*"
        &pickfld      = prefcli.carcod
        &pickfrm      = "999"
        &locktype     = " no-lock use-index cardes " 
        &aftselect1    = " 
                for each subpref where 
                         subpref.carcod = prefcli.carcod no-lock:
                         
                    find clipref where 
                         clipref.clicod = p-clicod and
                         clipref.subcod = subpref.subcod
                         no-lock no-error.
                         
                    if avail clipref
                    then do:
                        bell.
                        message color red/withe
                            ""Cliente ja possui preferencia de "" +
                            prefcli.cardes view-as alert-box. 
                        next keys-loop.    
                    end.
                end.           
                run clipref2.p(input p-clicod).
                next l1. " 
        &naoexiste1   = " leave keys-loop. " 
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave l1.

end.
hide frame f-linha no-pause.
