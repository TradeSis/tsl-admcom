/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def input parameter total_loja as int.
def input parameter dtini like plani.pladat.
def input parameter dtfin like plani.pladat.
def shared temp-table tt-habil
        field funcod like func.funcod
        field funnom like func.funnom
        field vope    as char format "x(12)"
        field celular like habil.celular
        field ciccgc  like habil.ciccgc
        field habsit  like habil.habsit
        field habdat  like habil.habdat
            index ind-1 habdat
                        vope.


def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 2
            initial ["Alteracao","Consulta"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-habil       for tt-habil.
def var vfuncod         like tt-habil.funcod.


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

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    display dtini label "Periodo"
            dtfin no-label with frame f-periodo side-label row 4 color message
                            centered no-box.

    if recatu1 = ?
    then
        find first tt-habil where
            true no-error.
    else
        find tt-habil where recid(tt-habil) = recatu1.
    if not available tt-habil
    then do:
        message "Nunhum registro para este periodo".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.

    pause 0.
    disp tt-habil.funcod   column-label "Codigo"
         tt-habil.funnom   column-label "Vendedor" format "x(15)"
         tt-habil.vope     column-label "Operacao" format "x(12)"
         tt-habil.celular  column-label "Telefone"
         tt-habil.habsit   column-label "Situacao" format "x(12)"
            with frame frame-a 13 down centered row 5
             title "TOTAL DE HABILITACOES:  " + string(total_loja,">>>>9").


    recatu1 = recid(tt-habil).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-habil where
                true.
        if not available tt-habil
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        
        display tt-habil.funcod   
                tt-habil.funnom   
                tt-habil.vope     
                tt-habil.celular  
                tt-habil.habsit
                    with frame frame-a.
        
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-habil where recid(tt-habil) = recatu1.

        choose field tt-habil.funcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
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
                esqpos1 = if esqpos1 = 2
                          then 2
                          else esqpos1 + 1.
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
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
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
            find next tt-habil where
                true no-error.
            if not avail tt-habil
            then next.
            color display normal
                tt-habil.funcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-habil where
                true no-error.
            if not avail tt-habil
            then next.
            color display normal
                tt-habil.funcod.
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
                create tt-habil.
                update tt-habil.funcod
                       tt-habil.funnom.
                recatu1 = recid(tt-habil).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do:

                update tt-habil.habsit with frame frame-a.
                find habil where habil.celular = tt-habil.celular and
                                 habil.ciccgc  = tt-habil.ciccgc no-error.

                habil.habsit = tt-habil.habsit.
                leave.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp tt-habil with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-habil.funnom update sresp.
                if not sresp
                then undo.
                find next tt-habil where true no-error.
                if not available tt-habil
                then do:
                    find tt-habil where recid(tt-habil) = recatu1.
                    find prev tt-habil where true no-error.
                end.
                recatu2 = if available tt-habil
                          then recid(tt-habil)
                          else ?.
                find tt-habil where recid(tt-habil) = recatu1.
                delete tt-habil.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tt-habilidades " update sresp.
                if not sresp
                then undo.
                recatu2 = recatu1.
                output to printer.
                for each tt-habil:
                    display tt-habil.
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
                                            
             
        
        display tt-habil.funcod   
                tt-habil.funnom   
                tt-habil.vope     
                tt-habil.celular
                tt-habil.habsit  
                    with frame frame-a.
        
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-habil).
   end.
end.
