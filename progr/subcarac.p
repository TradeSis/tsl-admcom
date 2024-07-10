
/*******************************************************************************
  Descricao: Sub-Caracteristicas do produto
                       subcarac.p

  Data     Autor       Caracteristica  
  17/08/00 GRBROWSE    GERADOR DE PROGRAMAS
******************************************************************************/
{admcab.i}
{setbrw.i}.

def buffer bsubcaract for subcaract.

def shared buffer caract for caract.

form    subcaract.subcar  column-label "Codigo"
        subcaract.subdes  column-label "Descricao"
        with frame f-linha down overlay column 40 row 04 
          title  " Sub-caracteristicas de " + caract.cardes + " "
          color white/brown.

form with frame f-le row 04 overlay column 01 01 down.

repeat on endkey undo, leave with frame f-linha:

    assign 
        a-seeid = -1.

    {sklcls.i
        &help = "ENTER=Altera F4=Retorna F9=Inclui F10=Exclui"
        &file         = subcaract
        &cfield       = subcaract.subdes
        &ofield       = " 
                         subcaract.subcar
                         subcaract.subdes
                        " 
        &where        = "subcaract.carcod = caract.carcod"
        &color        = withe
        &color1       = brown
        &procura1     = " 
        repeat with frame f-le:
            prompt-for 
                subcaract.subcod
                with no-validate.
            find first subcaract where 
                       subcaract.subcod     >= input frame f-le subcaract.subcod
                       no-lock no-error.
            if not available subcaract
            then do: 
                bell.
                message color red/withe
                    "" Nenhum registro encontrado ""
                    view-as alert-box title "" Menssagem "". 
                next keys-loop.
            end.
            leave.
        end. 
        hide  frame f-le no-pause.
        clear frame f-le all." 
        &locktype     = " use-index subdes " 
        &aftselect    = " subcarac.al " 
        &abrelinha    = " subcarac.in " 
        &naoexiste    = " subcarac.in " 
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave .

end.
hide frame f-linha no-pause. 
