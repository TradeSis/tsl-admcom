/*******************************************************************************
  Descricao: Sub-Caracteristicas do produto
                       subcarac.p

  Data     Autor       Caracteristica  
  17/08/00 GRBROWSE    GERADOR DE PROGRAMAS
******************************************************************************/
{admcab.i}
{setbrw.i}

def input parameter p-procod like produ.procod.

def buffer bprodu for produ.

def shared buffer caract for caract.

form a-seelst format "x" no-label
     subcaract.subcod  column-label "Codigo"
     subcaract.subdes  column-label "Descricao"
     with frame f-linha down overlay column 40 row 12 
          title  " Sub-caracteristicas de " + caract.cardes + " "
          color white/green.

form with frame f-le row 04 overlay column 01 01 down.

l1: repeat on endkey undo, leave with frame f-linha:

    assign 
        a-seeid = -1
        a-seelst= ",".
        
    for each subcaract where subcaract.carcod = caract.carcod no-lock.
        find procaract where procaract.procod = p-procod and
                             procaract.subcod = subcaract.subcod
                        no-lock no-error.
        if avail procar
        then a-seelst = a-seelst + "," + 
                        string(subcaract.subcod,"9999").
    end.
                            
    {sklcls3.i
        &help = "ENTER=Altera F4=Retorna F9=Inclui F10=Exclui"
        &file         = subcaract
        &cfield       = subcaract.subdes
        &ofield       = "subcaract.subcod
                         subcaract.subdes" 
        &where        = "subcaract.carcod = caract.carcod"
        &UsePick      = "*"
        &pickfld      = subcaract.subcod
        &pickfrm      = "9999"
        &color        = withe
        &color1       = brown
        &locktype     = " no-lock use-index subdes " 
        &aftselect1   = " 
                if keyfunction(lastkey) = ""return"" 
                then do:
                    find procaract where 
                         procaract.procod = p-procod and
                         procaract.subcod = subcaract.subcod
                         no-lock no-error.
                    if avail procaract
                    then do:
                        message ""Produto ja possui essa caracteristica!""
                            view-as alert-box. 
                        next keys-loop.    
                    end. 
                    do transaction:
                        create procaract.
                        assign
                            procaract.procod = p-procod
                            procaract.subcod = subcaract.subcod.
                    
                        find produ where produ.procod = p-procod no-error.
                        if avail produ
                        then do:
                            /*produ.procar = string(subcaract.subcod).*/
                            if subcaract.subdes = ""INATIVO""
                            then produ.procar = subcaract.subdes.
                        end.
                    end.
                    leave l1.
                end. " 
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave l1.
end.
hide frame f-linha no-pause. 
