/*                                                                  func.p
*
*    Esqueletao de Programacao
        manutencao de funcdor
*
*/
{admcab.i}

def var vopcao          as  char format "x(10)" extent 2
                                    initial ["Por Codigo","Por Nome"] .
def var vsetcod as int label "Setor Aut." format ">9". 
def var vok             as logical.

def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(15)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Procura"].

def buffer bfunc       for func.
def var vfuncod         like func.funcod.

    form
        esqcom1
            with frame f-com1 row 3 no-box no-labels column 1.
assign
    esqregua = yes
    esqpos1  = 1.

    form func except aplicod
         with overlay row 6 2 column centered color white/cyan
                frame f-altera.

bl-princ:
repeat:
    assign vok = no.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then find first func where true NO-LOCK no-error.
    else find func where recid(func) = recatu1 NO-LOCK.
    if not available func
    then do:
        message "Cadastro de funcionarios Vazio".
        undo.
    end.
    clear frame frame-a all no-pause.
    display
        func.etbcod
        func.funcod
        func.funnom
        func.funfunc column-label "Cargo"
        func.funsit column-label "Situacao"
        with frame frame-a 14 down centered color white/red.

    recatu1 = recid(func).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        find next func where true NO-LOCK NO-ERROR.
        if not available func
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        display
            func.etbcod
            func.funcod
            func.funnom
            func.funfunc
            func.funsit
            with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find func where recid(func) = recatu1 NO-LOCK.

        choose field func.funcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  PF4 F4 ESC return).
        if keyfunction(lastkey) = "cursor-right"
        then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next func where true NO-LOCK no-error.
            if not avail func
            then next.
            color display white/red func.funcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev func where true NO-LOCK no-error.
            if not avail func
            then next.
            color display white/red func.funcod.
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
            then do on error undo with frame f-altera.
                create func.
                update func except func.senha aplicod.
                update vsetcod.
                find setaut where setaut.setcod = vsetcod no-lock no-error.
                if not avail setaut
                then do:
                    message "Setor nao cadastrado".
                    undo, retry.
                end.
                /*display setaut.setnom no-label.*/
                func.aplicod = string(vsetcod).
                update func.senha blank.
                func.funnom = caps(func.funnom).
                recatu1 = recid(func).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do on error undo with frame f-altera:
                find current func exclusive.
                display func except func.senha aplicod.
                update func EXCEPT FUNCOD func.senha aplicod.
                vsetcod = int(func.aplicod).
                update vsetcod.
                find setaut where setaut.setcod = vsetcod no-lock no-error.
                if not avail setaut
                then do:
                    message "Setor nao cadastrado".
                    undo, retry.
                end.
                /*display setaut.setnom no-label.*/
                func.aplicod = string(vsetcod).
                run funsen.p (input  recid(func),
                              output vok,
                              output vfuncod).

                if vok then update func.senha blank.
                func.funnom = caps(func.funnom).
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-altera.
                disp func except func.senha aplicod.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" func.funnom update sresp.
                if not sresp
                then undo.
                run funsen.p (input  recid(func),
                              output vok,
                              output vfuncod).
                if vok
                then do on error undo:
                    find next func where true NO-LOCK no-error.
                    if not available func
                    then do:
                        find func where recid(func) = recatu1 NO-LOCK.
                        find prev func where true NO-LOCK no-error.
                    end.
                    recatu2 = if available func
                              then recid(func)
                              else ?.
                    find func where recid(func) = recatu1.
                    delete func.
                    recatu1 = recatu2.
                    leave.
                end.
            end.
            
            if esqcom1[esqpos1] = "Procura"
            then do:
                display vopcao
                         help "Escolha a Opcao"
                        with frame fescolha no-label
                        centered row 6 overlay color white/cyan.
                choose field vopcao with frame fescolha.
                if frame-index = 1
                then do with frame fprocura overlay row 9 1 column
                                color white/cyan:
                    prompt-for bfunc.funcod
                               bfunc.etbcod.
                    find first bfunc where bfunc.funcod = input bfunc.funcod
                                    and    bfunc.etbcod = input bfunc.etbcod
                                                    NO-LOCK no-error.
                    if not avail bfunc
                    then leave.
                    recatu1 = recid(bfunc).
                    leave.
                end.
                else do with frame fescolha1 side-label
                        column 30 row 9 overlay color white/cyan .
                   prompt-for bfunc.funnom.
                   find first bfunc where bfunc.funnom begins input bfunc.funnom
                                                      NO-LOCK no-error.
                   if not avail bfunc
                   then leave.
                   recatu1 = recid(bfunc).
                   leave.
                end.
            end.

            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de funcdores" update sresp.
                if not sresp
                then undo.
                recatu2 = recatu1.
                output to printer.
                for each func NO-LOCK:
                    display func.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.

          end.
          view frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        display func.etbcod
                func.funcod
                func.funnom
                func.funfunc
                func.funsit
                with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(func).
   end.
end.
