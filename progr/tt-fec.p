/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}


def shared temp-table tt-nota
    field etbcod like estab.etbcod
    field numero like plani.numero
    field data   like plani.pladat
    field fornom like forne.fornom format "x(20)"
    field emite  like plani.emite
    field rec    as recid
    field base   as dec
    field platot as dec
    field dif    as dec
        index ind1 etbcod
                   data.



def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 2
            initial ["Alteracao","Consulta"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-nota       for tt-nota.
def var vdata         like tt-nota.data.


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
        find first tt-nota where
            true no-error.
    else
        find tt-nota where recid(tt-nota) = recatu1.
    vinicio = yes.
    if not available tt-nota
    then do:
        message "Cadastro de tt-notaidades de Tit. Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create tt-nota.
                update emite
                       data.
          vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.

           
    display tt-nota.data 
            tt-nota.emite  column-label "Emite" format ">>>>>9"
            tt-nota.numero
            tt-nota.fornom column-label "Fornecedor" format "x(15)"
            tt-nota.base column-label "Base.Cal." 
            tt-nota.platot column-label "Total Nota" 
            tt-nota.dif column-label "Diferenca"
                with frame frame-a 14 down centered.

    recatu1 = recid(tt-nota).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-nota where
                true.
        if not available tt-nota
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        
        display tt-nota.data 
                tt-nota.emite 
                tt-nota.numero 
                tt-nota.fornom
                tt-nota.base 
                tt-nota.platot
                tt-nota.dif 
                    with frame frame-a.
                    
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-nota where recid(tt-nota) = recatu1.

        run color-message.
        choose field tt-nota.data
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        run color-normal.
        
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
                find next tt-nota where true no-error.
                if not avail tt-nota
                then leave.
                recatu1 = recid(tt-nota).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-nota where true no-error.
                if not avail tt-nota
                then leave.
                recatu1 = recid(tt-nota).
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
            find next tt-nota where
                true no-error.
            if not avail tt-nota
            then next.
            color display normal
                tt-nota.data.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-nota where
                true no-error.
            if not avail tt-nota
            then next.
            color display normal
                tt-nota.data.
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
                create tt-nota.
                update tt-nota.emite
                       tt-nota.data.
                recatu1 = recid(tt-nota).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                find plani where recid(plani) = tt-nota.rec. 
                update plani.bicms
                       plani.icms
                       plani.ipi
                       plani.frete
                       plani.outras
                       plani.platot
                    with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.

                find plani where recid(plani) = tt-nota.rec no-lock. 

                disp plani.bicms
                     plani.icms
                     plani.ipi
                     plani.frete
                     plani.outras
                     plani.platot
                         with frame f-consulta no-validate.

            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-nota.emite update sresp.
                if not sresp
                then leave.
                find next tt-nota where true no-error.
                if not available tt-nota
                then do:
                    find tt-nota where recid(tt-nota) = recatu1.
                    find prev tt-nota where true no-error.
                end.
                recatu2 = if available tt-nota
                          then recid(tt-nota)
                          else ?.
                find tt-nota where recid(tt-nota) = recatu1.
                delete tt-nota.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tt-notaidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each tt-nota:
                    display tt-nota.
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
        
        
        display tt-nota.data
                tt-nota.emite
                tt-nota.numero
                tt-nota.fornom 
                tt-nota.base
                tt-nota.platot
                tt-nota.dif
                    with frame frame-a.
                    
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-nota).
   end.
end.

procedure color-message.
color display message
        tt-nota.data
        tt-nota.emite
        tt-nota.numero 
        tt-nota.fornom
        tt-nota.base
        tt-nota.platot
        tt-nota.dif
                with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-nota.data
        tt-nota.emite
        tt-nota.numero
        tt-nota.fornom
        tt-nota.base
        tt-nota.platot
        tt-nota.dif
        with frame frame-a.
end procedure.

