/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
 initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem","Duplica"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btabmen       for tabmen.
def var vetbcod         like tabmen.etbcod.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
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
        find first tabmen where
            true no-error.
    else
        find tabmen where recid(tabmen) = recatu1.
    vinicio = yes.
    if not available tabmen
    then do:
        message "Cadastro de Mensagens".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 centered.
                create tabmen.
                update tabmen.RegCod column-label "Regiao"
                       tabmen.Etbcod column-label "Estab "
                       tabmen.datexp column-label "Data  ".
                update tabmen.mensa[01]
                       tabmen.mensa[02]
                       tabmen.mensa[03]
                       tabmen.mensa[04]
                       tabmen.mensa[05]
                       tabmen.mensa[06]
                       tabmen.mensa[07]
                       tabmen.mensa[08]
                       tabmen.mensa[09]
                       tabmen.mensa[10]  no-label with frame f-men centered
                            row 9 title "Mensagem" color message.
          vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        tabmen.regcod
        tabmen.etbcod
        tabmen.datexp
            with frame frame-a 14 down centered.

    recatu1 = recid(tabmen).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tabmen where
                true.
        if not available tabmen
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
            tabmen.regcod
            tabmen.etbcod
            tabmen.datexp
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tabmen where recid(tabmen) = recatu1.

        choose field tabmen.etbcod
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
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 6
                          then 6
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
                find next tabmen where true no-error.
                if not avail tabmen
                then leave.
                recatu1 = recid(tabmen).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tabmen where true no-error.
                if not avail tabmen
                then leave.
                recatu1 = recid(tabmen).
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
            find next tabmen where
                true no-error.
            if not avail tabmen
            then next.
            color display normal
                tabmen.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tabmen where
                true no-error.
            if not avail tabmen
            then next.
            color display normal
                tabmen.etbcod.
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
                create tabmen.
                update tabmen.Etbcod
                       tabmen.RegCod
                       tabmen.datexp.
                update tabmen.mensa[01]  no-label
                       tabmen.mensa[02]  no-label
                       tabmen.mensa[03]  no-label
                       tabmen.mensa[04]  no-label
                       tabmen.mensa[05]  no-label
                       tabmen.mensa[06]  no-label
                       tabmen.mensa[07]  no-label
                       tabmen.mensa[08]  no-label
                       tabmen.mensa[09]  no-label
                       tabmen.mensa[10]  no-label with frame f-men centered
                            row 9 title "Mensagem" color message.
                recatu1 = recid(tabmen).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update tabmen.Etbcod
                       tabmen.RegCod
                       tabmen.datexp.
                update tabmen.mensa[01]  no-label
                       tabmen.mensa[02]  no-label
                       tabmen.mensa[03]  no-label
                       tabmen.mensa[04]  no-label
                       tabmen.mensa[05]  no-label
                       tabmen.mensa[06]  no-label
                       tabmen.mensa[07]  no-label
                       tabmen.mensa[08]  no-label
                       tabmen.mensa[09]  no-label
                       tabmen.mensa[10]  no-label with frame f-men centered
                            row 9 title "Mensagem" .
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 side-label centered.
                disp   tabmen.Etbcod
                       tabmen.RegCod
                       tabmen.datexp.
                display tabmen.mensa[01]  no-label
                        tabmen.mensa[02]  no-label
                        tabmen.mensa[03]  no-label
                        tabmen.mensa[04]  no-label
                        tabmen.mensa[05]  no-label
                        tabmen.mensa[06]  no-label
                        tabmen.mensa[07]  no-label
                        tabmen.mensa[08]  no-label
                        tabmen.mensa[09]  no-label
                        tabmen.mensa[10]  no-label with frame f-men centered
                              row 9 title "Mensagem" .
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao da Mensagem" update sresp.
                if not sresp
                then leave.
                find next tabmen where true no-error.
                if not available tabmen
                then do:
                    find tabmen where recid(tabmen) = recatu1.
                    find prev tabmen where true no-error.
                end.
                recatu2 = if available tabmen
                          then recid(tabmen)
                          else ?.
                find tabmen where recid(tabmen) = recatu1.
                delete tabmen.
                recatu1 = recatu2.
                leave.
            end.

            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao" update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each tabmen:
                    display tabmen.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Duplica"
            then do with frame f-duplica side-label centered:
                message "Confirma Duplicacao" update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                create btabmen.
                update btabmen.Etbcod
                       btabmen.RegCod
                       btabmen.datexp.
                       
                assign btabmen.mensa[01]  = tabmen.mensa[01]
                       btabmen.mensa[02]  = tabmen.mensa[02] 
                       btabmen.mensa[03]  = tabmen.mensa[03] 
                       btabmen.mensa[04]  = tabmen.mensa[04] 
                       btabmen.mensa[05]  = tabmen.mensa[05] 
                       btabmen.mensa[06]  = tabmen.mensa[06]
                       btabmen.mensa[07]  = tabmen.mensa[07]
                       btabmen.mensa[08]  = tabmen.mensa[08]
                       btabmen.mensa[09]  = tabmen.mensa[09]
                       btabmen.mensa[10]  = tabmen.mensa[10].

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
        display
                tabmen.regcod
                tabmen.etbcod
                tabmen.datexp
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tabmen).
   end.
end.
