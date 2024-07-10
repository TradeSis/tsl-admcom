/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : procar.p
***** Diretorio                    : cadas
***** Autor                        : Claudir Santolin
***** Descri‡ao Abreviada da Funcao: Cadastro de Caracteristicas
***** Data de Criacao              : 17/08/2000

                                ALTERACOES
***** 1) Autor     :
***** 1) Descricao : 
***** 1) Data      :

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*******************************************************************************/

{admcab.i}

{setbrw.i}

def input parameter p-procod like produ.procod .
/*def var p-procod like produ.procod init 9999.*/

def buffer bprodu for produ.

def temp-table tt-caract
    field subcod like subcaract.subcod
    field cardes like caract.cardes
    field subdes like subcaract.subdes
    index i1 cardes.

form    tt-caract.cardes column-label "Caracteristica"
        tt-caract.subdes column-label "Sub-Caracteristica"
        with frame f-linha down row 12   overlay
          title " Caracteristicas do produto "
          color white/black centered.

l1: repeat on endkey undo, leave with frame f-linha:
    HIDE FRAME F-LINHA NO-PAUSE.
    
    for each tt-caract:
        delete tt-caract.
    end.    

    for each procaract where 
             procaract.procod = p-procod no-lock:
        find  subcaract where
              subcaract.subcod = procaract.subcod no-lock.
        find  caract where
              caract.carcod = subcaract.carcod no-lock.
              
        create tt-caract.
        assign
            tt-caract.subcod = subcaract.subcod
            tt-caract.cardes = caract.cardes
            tt-caract.subdes = subcaract.subdes.
    end.        
                 

    assign 
        a-seeid = -1.

    {sklcls.i
        &help =  "F4=Retorna F9=Inclui F10=Exclui"
        &file         = tt-caract
        &cfield       = tt-caract.cardes
        &ofield       = " 
                         tt-caract.subdes
                        " 
        &where        = "true"
        &color        = withe
        &color1       = black
        &locktype     = " use-index i1 " 
        &otherkeys1   = "  
            if keyfunction(lastkey) = ""DELETE-LINE"" or
               keyfunction(lastkey) = ""CUT""
            then do transaction:
               find tt-caract where recid(tt-caract) = a-seerec[frame-line].
               bell.
               sresp = no.
               message color withe/black
                    ""Confirma Exclusao de "" + tt-caract.cardes +
                    "" / "" + subcaract.subdes + "" ?"" 
                    update sresp.
               if not sresp
               then next keys-loop.
               find procaract where 
                    procaract.procod = p-procod and
                    procaract.subcod = tt-caract.subcod
                    no-error.
               if avail procaract   
               then do:
                   delete procaract.
             
                   find produ where produ.procod = p-procod no-error.
                   if avail produ
                   then produ.procar = """".
                   find produ where produ.procod = p-procod no-lock no-error.

                   next l1.
               end.     
            end.        "
        &naoexiste1   = " 
                          run procarac.p(input p-procod).
                          find first procaract where
                                     procaract.procod = p-procod
                                     no-lock no-error.
                          if not avail procaract
                          then leave l1.           
                          next l1. "
        &abrelinha1   = " hide frame f-linha no-pause.
                          run procarac.p(input p-procod). 
                          next l1.  " 
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave l1.

end.
hide frame f-linha no-pause.
