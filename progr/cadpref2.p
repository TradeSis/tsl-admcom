{admcab.i}
{setbrw.i}.

def buffer bsubpref for subpref.

def shared buffer prefcli for prefcli.

form    subpref.subcar  column-label "Codigo"
        subpref.subdes  column-label "Descricao"
        with frame f-linha down overlay column 40 row 04 
          title  " Sub-Preferencias de " + prefcli.cardes + " "
          color white/brown.

form with frame f-le row 04 overlay column 01 01 down.

repeat on endkey undo, leave with frame f-linha:

    assign 
        a-seeid = -1.

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
        &procura1     = " 
        repeat with frame f-le:
            prompt-for 
                subpref.subcod
                with no-validate.
            find first subpref where 
                       subpref.subcod >= input frame f-le subpref.subcod
                       no-lock no-error.
            if not available subpref
            then do: 
                bell.
                message color red/withe
                    "" Nenhum registro encontrado ""
                    view-as alert-box title "" Menssagem "". 
                next keys-loop.
            end.
            leave.
        end.
        hide frame f-le no-pause.
        clear frame f-le all." 
        &locktype     = " use-index subdes " 
        &aftselect    = " cadpref2.al " 
        &abrelinha    = " cadpref2.in " 
        &naoexiste    = " cadpref2.in " 
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave .

end.
hide frame f-linha no-pause. 
