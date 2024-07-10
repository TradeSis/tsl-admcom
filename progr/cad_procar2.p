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

def input parameter p-procod like produ.procod.

def buffer bprodu for produ.
def temp-table tt-caract
    field cardes like caract.cardes
    field subdes like subcaract.subdes
    field subcod like subcaract.subcod column-label "Cod"
    index i1 cardes.

form    
    tt-caract.cardes column-label "Caracteristica"
    tt-caract.subcod
    tt-caract.subdes column-label "Sub-Caracteristica"
    with frame f-linha down row 12   overlay
          title " *** Caracteristicas atuais do produto *** "
          color white/black centered.

l1: repeat on endkey undo, leave with frame f-linha:
    HIDE FRAME F-LINHA NO-PAUSE.
    
    for each tt-caract:
        delete tt-caract.
    end.    

    for each procaract where procaract.procod = p-procod no-lock:
        find first subcaract where subcaract.subcod = procaract.subcod no-lock.
        find first caract where caract.carcod = subcaract.carcod no-lock.
        create tt-caract.
        assign
            tt-caract.cardes = caract.cardes
            tt-caract.subdes = subcaract.subdes
            tt-caract.subcod = subcaract.subcod.
    end.        

    assign 
        a-seeid = -1.

    {sklcls3.i
        &help =  "F4=Retorna I=Inclui E=Exclui"
        &file         = tt-caract
        &cfield       = tt-caract.cardes
        &ofield       = "tt-caract.subdes tt-caract.subcod" 
        &where        = "true"
        &color        = withe
        &color1       = black
        /***
        &UsePick      = *
        &pickfld      = tt-caract.cardes
        &pickfrm      = "999"
        **/
        &locktype     = " no-lock use-index i1 " 
        &go-on        = "I i E e"
        &otherkeys1   = "  
            if keyfunction(lastkey) = ""I"" or
               keyfunction(lastkey) = ""i""
            then do:
                hide frame f-linha no-pause.
                run procarac2.p(input p-procod).
                next l1.  
            end.
            if keyfunction(lastkey) = ""E"" or
               keyfunction(lastkey) = ""e""
            then do transaction:
               find tt-caract where recid(tt-caract) = a-seerec[frame-line].
               find procaract where procaract.procod = p-procod
                                and procaract.subcod = tt-caract.subcod
                              no-lock no-error.
               if not avail procaract
               then next keys-loop.
               sresp = no.
               message color message
                    ""Confirma Exclusao de "" + tt-caract.cardes +
                    "" / "" + tt-caract.subdes + "" ?"" 
                    update sresp.
               if not sresp
               then next keys-loop.

               find current procaract.
               delete procaract.
               find produ where produ.procod = p-procod no-lock.
               find produpai where produpai.itecod = produ.itecod
                             no-lock no-error.
               if avail produpai
               then
                  for each bprodu of produpai no-lock.
                    find procaract where procaract.procod = bprodu.procod and
                                         procaract.subcod = tt-caract.subcod
                                   no-error.
                    if avail procaract
                    then delete procaract.
                  end.
               next l1.
            end."
        &naoexiste1   = " run procarac2.p(input p-procod).
                          find first procaract where
                                     procaract.procod = p-procod
                                     no-lock no-error.
                          if not avail procaract
                          then leave l1.           
                          next l1."
        &abrelinha1   = " hide frame f-linha no-pause.
                          run procarac2.p(input p-procod). 
                          next l1." 
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave l1.

end.
hide frame f-linha no-pause.
