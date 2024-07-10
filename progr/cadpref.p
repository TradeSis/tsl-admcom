
{admcab.i}
{setbrw.i}

def new shared buffer prefcli for prefcli.
def buffer bprefcli for prefcli.

form    prefcli.carcod column-label "Codigo"
        prefcli.cardes column-label "Descricao"

        with frame f-linha down row 04   overlay
          title " Preferencias do cliente "     
          color white/red.

form with frame f-le row 04 overlay column 01 01 down.

l1: repeat on endkey undo, leave with frame f-linha:
    hide frame f-linha no-pause.
    assign 
        a-seeid = -1.

    {stdfman.i}   /* Manutencao */
    

    {sklcls.i
        &help = 
        "ENTER=Altera F1=Sub-Preferencia F4=Retorna F9=Inclui F10=Exclui"
        &file         = prefcli
        &cfield       = prefcli.cardes
        &ofield       = " 
                         prefcli.cardes
                         prefcli.carcod
                         
                        " 
        &where        = "true"
        &color        = withe
        &color1       = red
        &procura1     = " 
        repeat with frame f-le:
            prompt-for 
                prefcli.cardes
                with no-validate.
            find first prefcli where 
                       prefcli.cardes >= input frame f-le prefcli.cardes
                       no-lock no-error.
            if not available prefcli
            then do:        
                bell.
                message "" Nenhum registro encontrado. "". 
                undo.
            end.
            leave.
        end. 
        hide  frame f-le no-pause.
        clear frame f-le all." 
        &locktype     = " use-index cardes " 
        &aftselect    = " cadpref.al " 
        &abrelinha    = " cadpref.in " 
        &naoexiste    = " cadpref.in " 
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave l1.

end.
