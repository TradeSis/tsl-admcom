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

def input parameter p-clicod like clien.clicod .
/*def var p-clicod like clien.clicod init 677667. */

def buffer bclien for clien.

def temp-table tt-caract
    field subcod like subpref.subcod
    field cardes like prefcli.cardes
    field subdes like subpref.subdes
    index i1 cardes.

form    tt-caract.cardes column-label "Caracteristica"
        tt-caract.subdes column-label "Sub-Caracteristica"
        with frame f-linha down row 12   overlay
          title " Preferencias do cliente "
          color white/black centered .

l1: repeat on endkey undo, leave with frame f-linha:
    HIDE FRAME F-LINHA NO-PAUSE.
    
    for each tt-caract:
        delete tt-caract.
    end.    

    for each clipref where
             clipref.clicod = p-clicod no-lock:
             
        find  subpref where
              subpref.subcod = clipref.subcod no-lock.

        find  prefcli where
              prefcli.carcod = subpref.carcod no-lock.
              
        create tt-caract.
        assign
            tt-caract.subcod = subpref.subcod
            tt-caract.cardes = prefcli.cardes
            tt-caract.subdes = subpref.subdes.
            
    end.        
                 

    assign 
        a-seeid = -1.
    pause 0.
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
                    "" / "" + subpref.subdes + "" ?"" 
                    update sresp.
               if not sresp
               then next keys-loop.

               find clipref where 
                    clipref.clicod = p-clicod and
                    clipref.subcod = tt-caract.subcod
                    no-error.
                    
               if avail clipref
               then do:
                   delete clipref.
                   next l1.
               end.     
            end.        "
        &naoexiste1   = " 
                          run clipref1.p(input p-clicod).
                          find first clipref where
                                     clipref.clicod = p-clicod
                                     no-lock no-error.
                          if not avail clipref
                          then leave l1.
                          next l1."
        &abrelinha1   = " hide frame f-linha no-pause.
                          run clipref1.p(input p-clicod).
                          next l1.  " 
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave l1.

end.
hide frame f-linha no-pause.
