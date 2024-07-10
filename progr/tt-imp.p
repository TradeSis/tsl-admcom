/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def temp-table tt-imp
    field codimp as int format "99"
    field nome   as char
    field versao as dec format "9.99"
        index ind-1 codimp.
    
def var v-codimp like tt-imp.codimp.
def var v-nome   like tt-imp.nome. 
def var v-versao like tt-imp.versao.
    

input from ..\admini\impressora.ini.
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


def buffer btt-imp       for tt-imp.
def var vcodimp          like tt-imp.codimp.


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
        find first tt-imp where
            true no-error.
    else
        find tt-imp where recid(tt-imp) = recatu1.
    vinicio = yes.
    if not available tt-imp
    then do:
        /*
        message "Cadastro de impressoras Vazio".
        pause.
        undo, retry.
        */
        create tt-imp.
        update tt-imp.
    end.

    clear frame frame-a all no-pause.

    display
        tt-imp.codimp column-label "Codigo"
        tt-imp.nome   column-label "Impressora"
        tt-imp.versao
            with frame frame-a 14 down centered.

    recatu1 = recid(tt-imp).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-imp where
                true.
        if not available tt-imp
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display tt-imp.codimp 
                tt-imp.nome 
                tt-imp.versao
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-imp where recid(tt-imp) = recatu1.

        choose field tt-imp.codimp
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
                find next tt-imp where true no-error.
                if not avail tt-imp
                then leave.
                recatu1 = recid(tt-imp).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-imp where true no-error.
                if not avail tt-imp
                then leave.
                recatu1 = recid(tt-imp).
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
            find next tt-imp where
                true no-error.
            if not avail tt-imp
            then next.
            color display normal
                tt-imp.codimp.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-imp where
                true no-error.
            if not avail tt-imp
            then next.
            color display normal
                tt-imp.codimp.
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
            then do with frame f-inclui overlay row 6 1 column centered.
                           
                v-codimp  = 0.
                v-nome   = "".
                v-versao = 0.
                find last btt-imp no-error.
                v-codimp = btt-imp.codimp + 1.
                  
                display v-codimp label "Codigo".
                
                update v-nome   label "Impressora"
                       v-versao label "Versao".
                       
                find first tt-imp where tt-imp.nome   = v-nome and
                                        tt-imp.versao = v-versao no-error.
                if avail tt-imp
                then do:
                
                    message "Impressora ja cadastrada".
                    pause.
                    undo, retry.
                    
                end.    
                        
                    
                create tt-imp.
                assign tt-imp.codimp = v-codimp
                       tt-imp.nome   = v-nome
                       tt-imp.versao = v-versao.
                       
                
                recatu1 = recid(tt-imp).

                leave.
                
            end.

            if esqcom1[esqpos1] = "Procura"
            then do:
                vcodimp = 0.
                update vcodimp label "Produto"
                        with frame f-procura side-label centered.
                find first tt-imp where tt-imp.codimp = vcodimp no-error.
                if avail tt-imp
                then recatu1 = recid(tt-imp).
                else do:
                    message "Produto nao cadastrado".
                    pause.
                end.
                leave.

            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp tt-imp with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao" update sresp.
                if not sresp
                then leave.
                find next tt-imp where true no-error.
                if not available tt-imp
                then do:
                    find tt-imp where recid(tt-imp) = recatu1.
                    find prev tt-imp where true no-error.
                end.
                recatu2 = if available tt-imp
                          then recid(tt-imp)
                          else ?.
                find tt-imp where recid(tt-imp) = recatu1.
                delete tt-imp.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tt-impidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each tt-imp:
                    display tt-imp.
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


        display tt-imp.codimp 
                tt-imp.nome 
                tt-imp.versao
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-imp).
   end.
end.

output to ..\admini\impressora.ini.
for each tt-imp.
    export tt-imp.
end.
output close.
    
