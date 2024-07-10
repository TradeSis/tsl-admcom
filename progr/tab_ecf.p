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
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Envia filial","","","",""].


def buffer btabecf       for tabecf.
def var vetbcod         like tabecf.etbcod.


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
    esqregua = yes.
    clear frame f-com1 all.
    clear frame f-com2 all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tabecf where
            true no-error.
    else
        find tabecf where recid(tabecf) = recatu1.
    vinicio = yes.
    if not available tabecf
    then do:
        message "Cadastro de tabecfidades de Tit. Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create tabecf.
                update serie
                       etbcod.
          vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        tabecf.etbcod format ">99" column-label "Filial"
        tabecf.de1    format ">9"  column-label "Caixa"
        tabecf.equipa
        tabecf.serie  format "x(25)"
        tabecf.datini column-label "Data Inicial"
        tabecf.datfin column-label "Data Final"
        tabecf.ch1    format "x(03)" column-label "Win"
            with frame frame-a 12 down centered.

    recatu1 = recid(tabecf).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tabecf where
                true.
        if not available tabecf
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        display tabecf.etbcod 
                tabecf.de1    
                tabecf.equipa 
                tabecf.serie  
                tabecf.datini 
                tabecf.datfin 
                tabecf.ch1   
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tabecf where recid(tabecf) = recatu1.

        run color-message.
        choose field tabecf.etbcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC p return).
        run color-normal.
        
        if keyfunction(lastkey) = "p"
        then do:
            pause 0.
            update vetbcod label "Filial"
                with frame f-proc 1 down
                centered row 8 side-labe overlay.
            find first tabecf where tabecf.etbcod = vetbcod no-lock no-error.
            if avail tabecf
            then recatu1 = recid(tabecf).
            leave.    
        end.
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
                esqpos1 = if esqpos1 = 5
                          then 5
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
                find next tabecf where true no-error.
                if not avail tabecf
                then leave.
                recatu1 = recid(tabecf).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tabecf where true no-error.
                if not avail tabecf
                then leave.
                recatu1 = recid(tabecf).
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
            find next tabecf where
                true no-error.
            if not avail tabecf
            then next.
            color display normal
                tabecf.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tabecf where
                true no-error.
            if not avail tabecf
            then next.
            color display normal
                tabecf.etbcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        
        /*hide frame frame-a no-pause.
          */
          if esqregua
          then do:
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                create tabecf.
                update tabecf.etbcod format ">99" label "Filial"
                       tabecf.de1    format ">9"  label "Caixa"
                       tabecf.equipa
                       tabecf.serie  format "x(25)"
                       tabecf.datini label "Data Inicial"
                       tabecf.datfin label "Data Final"
                       tabecf.ch1    format "x(03)" label "Win".
                tabecf.dt1 = today.    
                recatu1 = recid(tabecf).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update tabecf.etbcod format ">99" label "Filial"
                       tabecf.de1    format ">9"  label "Caixa"
                       tabecf.equipa
                       tabecf.serie  format "x(25)"
                       tabecf.datini label "Data Inicial"
                       tabecf.datfin label "Data Final"
                       tabecf.ch1    format "x(03)" label "Win"
                            with frame f-altera no-validate.
                tabecf.dt1 = today.
                find current tabecf no-lock.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                display tabecf.etbcod  
                        tabecf.de1     
                        tabecf.equipa  
                        tabecf.serie   
                        tabecf.datini  
                        tabecf.datfin  
                        tabecf.ch1   
                             with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tabecf.serie update sresp.
                if not sresp
                then leave.
                find next tabecf where true no-error.
                if not available tabecf
                then do:
                    find tabecf where recid(tabecf) = recatu1.
                    find prev tabecf where true no-error.
                end.
                recatu2 = if available tabecf
                          then recid(tabecf)
                          else ?.
                find tabecf where recid(tabecf) = recatu1.
                delete tabecf.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tabecfidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each tabecf:
                    display tabecf.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
           if esqcom2[esqpos2] = "ENVIA FILIaL"
           then do:
                message "Informe a filial " update vetbcod.
                for each tabecf where tabecf.etbcod = vetbcod:
                    tabecf.dt1 = today.
                    MESSAGE "EXPORTANDO.... " tabecf.serie .
                    pause 1 no-message.
                end.    
                recatu1 = ?.
           end.
           next bl-princ.
          end.
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error" 
        then view frame frame-a.
        display tabecf.etbcod 
                tabecf.de1    
                tabecf.equipa 
                tabecf.serie  
                tabecf.datini 
                tabecf.datfin 
                tabecf.ch1   
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tabecf).
   end.
end.

procedure color-message.
color display message 
    tabecf.etbcod  
    tabecf.de1     
    tabecf.equipa  
    tabecf.serie   
    tabecf.datini  
    tabecf.datfin  
    tabecf.ch1   
        with frame frame-a.
end procedure.
procedure color-normal. 
color display normal 
    tabecf.etbcod  
    tabecf.de1     
    tabecf.equipa  
    tabecf.serie   
    tabecf.datini  
    tabecf.datfin  
    tabecf.ch1   
        with frame frame-a.
end procedure.

