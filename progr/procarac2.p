/*******************************************************************************
  Descricao: Caracteristicas do produto

                         procarac.p

  Data     Autor       Caracteristica  
  17/08/00 GRBROWSE    GERADOR DE PROGRAMAS
******************************************************************************/
{admcab.i}
{setbrw.i}

def input parameter p-procod like produ.procod.

def new shared buffer caract for caract.

form    a-seelst format "x" no-label
        caract.carcod column-label "Codigo"
        caract.cardes column-label "Descricao"
        with frame f-linha down row 12   overlay
          title "-- Inc. Caracteristicas do produto -- "
          color white/brown.

l1: repeat on endkey undo, leave with frame f-linha:

    assign 
        a-seeid = -1
        a-seelst = ",".
        
    for each procaract where procaract.procod = p-procod no-lock.
        find first subcaract where subcaract.subcod = procaract.subcod no-lock.
        find first caract where caract.carcod = subcaract.carcod no-lock.
        a-seelst = a-seelst + string(caract.carcod,"999") + ",".
    end.         
                   
    {sklcls3.i
        &help =  "ENTER=Sub-Caract F4=Retorna "
        &file         = caract
        &cfield       = caract.cardes
        &ofield       = "caract.cardes
                         caract.carcod" 
        &where        = "true"
        &color        = withe
        &color1       = brown
        &UsePick      = "*"
        &pickfld      = caract.carcod
        &pickfrm      = "999"        
        &locktype     = " no-lock use-index cardes " 
        &aftselect1   = " 
                /***
                for each subcaract where 
                         subcaract.carcod = caract.carcod no-lock:
                         
                    find procar where 
                         procar.procod = p-procod and
                         procar.subcar = subcaract.subcar
                         no-lock no-error.
                    if avail procar
                    then do:
                        message color red/withe
                            ""Produto ja possui caracteristica de "" +
                            caract.cardes view-as alert-box. 
                        next keys-loop.    
                    end.
                end.           
                **/
                run prosub2.p(input p-procod).
                next l1. " 
        &naoexiste1   = " leave keys-loop. " 
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave l1.
end.
hide frame f-linha no-pause.
