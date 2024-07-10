/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i }

def temp-table tt-cxecf
    field etbcod like estab.etbcod format ">>9"
    field cxacod like caixa.cxacod
    field codimp as int format "99"
        index ind-1 etbcod
                    cxacod.
    
def var v-etbcod like tt-cxecf.etbcod.
def var v-cxacod like tt-cxecf.cxacod. 
def var v-codimp like tt-cxecf.codimp.
    

input from l:\work\cxecf.ini.
repeat:
    create tt-cxecf.
    import tt-cxecf.
end.
input close.


for each tt-cxecf.

    if tt-cxecf.etbcod = 0
    then delete tt-cxecf.
    
end.    


def temp-table tt-imp
    field codimp as int format "99"
    field nome   as char
    field versao as dec format "9.99"
        index ind-1 codimp.
    

input from l:\work\impressora.ini.
repeat:
    create tt-imp.
    import tt-imp.
end.
input close.


for each tt-imp.

    if tt-imp.codimp = 0
    then delete tt-imp.
    
end.    
 


 


def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 3
            initial ["Inclusao","Exclusao","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-cxecf       for tt-cxecf.
def var vetbcod          like tt-cxecf.etbcod.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tt-cxecf where
            true no-error.
    else
        find tt-cxecf where recid(tt-cxecf) = recatu1.
    vinicio = yes.
    if not available tt-cxecf
    then do:
        message "Cadastro de impressoras Vazio".
        pause.
        undo, retry.
    end.
    clear frame frame-a all no-pause.

    find first tt-imp where tt-imp.codimp = tt-cxecf.codimp no-error. 
    
    
    display
        tt-cxecf.etbcod column-label "Filial"
        tt-cxecf.cxacod column-label "Caixa"
        tt-imp.nome     column-label "Impressora"
        tt-imp.versao   column-label "Versao"
            with frame frame-a 14 down centered.

    recatu1 = recid(tt-cxecf).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-cxecf where
                true.
        if not available tt-cxecf
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
 
        find first tt-imp where tt-imp.codimp = tt-cxecf.codimp no-error.
    
    
        display tt-cxecf.etbcod 
                tt-cxecf.cxacod 
                tt-imp.nome     
                tt-imp.versao 
                    with frame frame-a.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-cxecf where recid(tt-cxecf) = recatu1.

        choose field tt-cxecf.etbcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 3
                          then 3
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-cxecf where true no-error.
                if not avail tt-cxecf
                then leave.
                recatu1 = recid(tt-cxecf).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-cxecf where true no-error.
                if not avail tt-cxecf
                then leave.
                recatu1 = recid(tt-cxecf).
            end.
            leave.
        end.


        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-cxecf where
                true no-error.
            if not avail tt-cxecf
            then next.
            color display normal
                tt-cxecf.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-cxecf where
                true no-error.
            if not avail tt-cxecf
            then next.
            color display normal
                tt-cxecf.etbcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui 
                overlay row 6 centered side-label.
                           
                v-etbcod  = 0.
                v-cxacod  = 0.
                v-codimp  = 0.
                  
                                
                update v-etbcod label "Filial"
                       v-cxacod label "Caixa".
                       
                for each tt-imp:
                    disp tt-imp 
                        with frame f-imp 5 down centered.
                end.
                
                do on error undo:
                    update v-codimp label "codimp".
                
                    find first tt-imp where tt-imp.codimp = v-codimp no-error.
                    if not avail tt-imp
                    then do:
                        message "Impressora fiscal nao cadastrada".
                        pause.
                        undo, retry.
                    end.
                
                end.
                    
                       
                find first tt-cxecf where tt-cxecf.cxacod = v-cxacod and
                                          tt-cxecf.codimp = v-codimp and                                           tt-cxecf.etbcod = v-etbcod no-error.
                if avail tt-cxecf
                then do:
                
                    message "Impressora ja cadastrada".
                    pause.
                    undo, retry.
                    
                end.    
                        
                    
                create tt-cxecf.
                assign tt-cxecf.etbcod = v-etbcod
                       tt-cxecf.cxacod = v-cxacod
                       tt-cxecf.codimp = v-codimp.
                       
                
                recatu1 = recid(tt-cxecf).

                leave.
                
            end.

            if esqcom1[esqpos1] = "Procura"
            then do:
                vetbcod = 0.
                update vetbcod label "Filial"
                        with frame f-procura side-label centered.
                find first tt-cxecf where tt-cxecf.etbcod = vetbcod no-error.
                if avail tt-cxecf
                then recatu1 = recid(tt-cxecf).
                else do:
                    message "Produto nao cadastrado".
                    pause.
                end.
                leave.

            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp tt-cxecf with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao" update sresp.
                if not sresp
                then leave.
                find next tt-cxecf where true no-error.
                if not available tt-cxecf
                then do:
                    find tt-cxecf where recid(tt-cxecf) = recatu1.
                    find prev tt-cxecf where true no-error.
                end.
                recatu2 = if available tt-cxecf
                          then recid(tt-cxecf)
                          else ?.
                find tt-cxecf where recid(tt-cxecf) = recatu1.
                delete tt-cxecf.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tt-cxecfidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each tt-cxecf:
                    display tt-cxecf.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.

        find first tt-imp where tt-imp.codimp = tt-cxecf.codimp no-error.
    
    
        display tt-cxecf.etbcod 
                tt-cxecf.cxacod 
                tt-imp.nome     
                tt-imp.versao 
                    with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-cxecf).
   end.
end.

output to ..\work\cxecf.ini.
for each tt-cxecf.
    export tt-cxecf.
end.
output close.
    
