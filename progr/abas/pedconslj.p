{admcab.i}

if setbcod < 500
then return.

def var par-etbcod  like estab.etbcod init 0.
def var xetbcod     like estab.etbcod.

        update
            par-etbcod
             
             with frame f1 side-label 1 down width 80
                 overlay  row 3 no-box color message.
        find estab where estab.etbcod = par-etbcod no-lock no-error.
        if not avail estab
        then undo.

        disp estab.etbnom no-label
            with frame f1.

        xetbcod = setbcod.
        setbcod = par-etbcod. 

    hide frame f1 no-pause.
        
        
        run abas/transfloj.p.
        
        setbcod = xetbcod.
        
        
