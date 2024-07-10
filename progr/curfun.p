{admcab.i}
def var vfuncod         like func.funcod.
def var vdti            like plani.pladat.
def var vdtf            like plani.pladat.
def var vcurso          as char.
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
            initial ["","","","",""].


def buffer bcurfun       for curfun.
def var vetbcod         like curfun.etbcod.


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
        find first curfun where
            true no-error.
    else
        find curfun where recid(curfun) = recatu1.
    vinicio = yes.
    if not available curfun
    then do:
        message "Cadastro de Cursos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 centered side-label.
            update vetbcod label "Filial" at 1.
            setbcod = vetbcod.
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Filial nao cadastrada".
                pause.
                undo , retry.
            end.
            display estab.etbnom no-label.
            update vfuncod label "Funcionario" at 1.
            find func where func.etbcod = estab.etbcod and
                            func.funcod = vfuncod no-lock no-error.
                             
            if not avail func
            then do:
                message "funcionario nao cadastrado".
                pause. 
                undo, retry.
            end.
            display func.funnom no-label.
            update vdti label "Periodo" at 1
                   vdtf no-label.
            update vcurso label "Curso" at 1 format "x(70)".
            find curfun where curfun.etbcod = estab.etbcod and
                              curfun.funcod = func.funcod  and
                              curfun.dtini = vdti          and
                              curfun.dtfin = vdtf  no-error.
            if not avail curfun
            then do transaction:
                create curfun. 
                assign curfun.etbcod = estab.etbcod
                       curfun.funcod = func.funcod 
                       curfun.dtini  = vdti
                       curfun.dtfin  = vdtf
                       curfun.curdes = vcurso
                       curfun.datexp = today.
                        
            end.
            vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    find func where func.etbcod = curfun.etbcod and
                    func.funcod = curfun.funcod no-lock.
    display
        curfun.etbcod column-label "FL" format ">99"
        curfun.funcod column-label "Fun" format ">99"
        func.funnom format "x(15)"
        func.funfunc column-label "Cargo" format "x(15)"
        curfun.dtini column-label "Inicio"
        curfun.dtfin column-label "Fim"
        curfun.curdes column-label "Curso" format "x(15)"
            with frame frame-a 14 down centered.

    recatu1 = recid(curfun).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next curfun where
                true.
        if not available curfun
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find func where func.etbcod = curfun.etbcod and
                        func.funcod = curfun.funcod no-lock.
                        
        display curfun.etbcod 
                curfun.funcod 
                func.funnom 
                func.funfunc
                curfun.dtini
                curfun.dtfin 
                curfun.curdes
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find curfun where recid(curfun) = recatu1.

        run color-message.
        choose field curfun.etbcod
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
                find next curfun where true no-error.
                if not avail curfun
                then leave.
                recatu1 = recid(curfun).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev curfun where true no-error.
                if not avail curfun
                then leave.
                recatu1 = recid(curfun).
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
            find next curfun where
                true no-error.
            if not avail curfun
            then next.
            color display normal
                curfun.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev curfun where
                true no-error.
            if not avail curfun
            then next.
            color display normal
                curfun.etbcod.
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
            then do with frame f-inclui overlay row 6 
                                centered side-label.

                update vetbcod label "Filial" at 1.
                setbcod = vetbcod.
                find estab where estab.etbcod = vetbcod no-lock no-error.
                if not avail estab
                then do:
                    message "Filial nao cadastrada".
                    pause.
                    undo , retry.
                end.
                display estab.etbnom no-label.
                update vfuncod label "Funcionario" at 1.
                find func where func.etbcod = estab.etbcod and
                                func.funcod = vfuncod no-lock no-error.
                                 
                if not avail func
                then do:
                    message "funcionario nao cadastrado".
                    pause. 
                    undo, retry.
                end.
                display func.funnom no-label.
                update vdti label "Periodo" at 1
                       vdtf no-label.
                update vcurso label "Curso" at 1 format "x(70)".
                find curfun where curfun.etbcod = estab.etbcod and
                                  curfun.funcod = func.funcod  and
                                  curfun.dtini = vdti          and
                                  curfun.dtfin = vdtf  no-error.
                if not avail curfun
                then do transaction:
                    create curfun. 
                    assign curfun.etbcod = estab.etbcod
                           curfun.funcod = func.funcod 
                           curfun.dtini  = vdti
                           curfun.dtfin  = vdtf
                           curfun.curdes = vcurso
                           curfun.datexp = today.
                        
                end.

                
                recatu1 = recid(curfun).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                do transaction:
                    update curfun with frame f-altera no-validate.
                end.    
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp curfun with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" curfun.funcod update sresp.
                if not sresp
                then leave.
                find next curfun where true no-error.
                if not available curfun
                then do:
                    find curfun where recid(curfun) = recatu1.
                    find prev curfun where true no-error.
                end.
                recatu2 = if available curfun
                          then recid(curfun)
                          else ?.
                find curfun where recid(curfun) = recatu1.
                do transaction:
                    delete curfun.
                end.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de curfunidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each curfun:
                    display curfun.
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

        find func where func.etbcod = curfun.etbcod and
                        func.funcod = curfun.funcod no-lock.
                        
        display curfun.etbcod 
                curfun.funcod 
                func.funnom 
                func.funfunc
                curfun.dtini
                curfun.dtfin 
                curfun.curdes 
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(curfun).
   end.
end.

procedure color-message.
color display message
        curfun.etbcod  
        curfun.funcod  
        func.funnom  
        func.funfunc 
        curfun.dtini 
        curfun.dtfin 
        curfun.curdes
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        curfun.etbcod  
        curfun.funcod  
        func.funnom  
        func.funfunc 
        curfun.dtini 
        curfun.dtfin 
        curfun.curdes
        with frame frame-a.
end procedure.

