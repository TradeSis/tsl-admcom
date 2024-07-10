{admcab.i}
{setbrw.i}.

def input parameter p-clicod like clien.clicod.

def buffer bclien for clien.

def shared buffer prefcli for prefcli.

form    a-seelst format "x" no-label
        subpref.subcar  column-label "Codigo"
        subpref.subdes  column-label "Descricao"
        with frame f-linha down overlay column 40 row 12 
          title  " Sub-Preferencias de " + prefcli.cardes + " "
          color white/green.

form with frame f-le row 04 overlay column 01 01 down.

l1: repeat on endkey undo, leave with frame f-linha:

    assign 
        a-seeid = -1
        a-seelst= ",".
        

    for each subpref where
             subpref.carcod = prefcli.carcod no-lock.
    
        find clipref where
             clipref.clicod = p-clicod and
             clipref.subcod = subpref.subcod no-lock no-error.
        
        if avail clipref
        then a-seelst = a-seelst + "," + 
                        string(subpref.subcod,"9999").
                        
    end.
                            
    {sklcls.i
        &help = "ENTER=Altera F4=Retorna F9=Inclui F10=Exclui"
        &file         = subpref
        &cfield       = subpref.subdes
        &ofield       = " 
                         subpref.subcar
                         subpref.subdes
                        " 
        &where        = "subpref.carcod = prefcli.carcod"
        &color        = withe
        &color1       = brown
        &locktype     = " no-lock use-index subdes " 
        &aftselect1   = " 
                if keyfunction(lastkey) = ""return"" 
                then do:
                    find clipref where 
                         clipref.clicod = p-clicod and
                         clipref.subcod = subpref.subcod no-lock no-error.
                    if avail clipref
                    then do:
                        bell.
                        message color red/withe
                            ""Cliente ja possui essa Preferencia!""
                            view-as alert-box.
                        next keys-loop.
                    end. 
                    do transaction:
                        create clipref.
                        assign
                            clipref.clicod = p-clicod
                            clipref.subcod = subpref.subcod.
                    end.
                    leave l1.
                end. " 
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave l1.

end.
hide frame f-linha no-pause. 
