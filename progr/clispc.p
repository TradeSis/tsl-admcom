{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(15)" extent 5
        initial ["Inclusao","Alteracao","Consulta","Exclusao","Procura"].
def var esqcom2         as char format "x(15)" extent 5
        initial [" Contrato ",""].

def buffer bclispc      for clispc.
def var atraso          as log.

form with frame f-altera overlay row 6 2 column centered color white/cyan.

form esqcom1 with frame f-com1 row 3 no-box no-labels column 1.
form esqcom2 with frame f-com2 row screen-lines no-box no-labels  column 1.
assign
    esqregua  = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first clispc NO-LOCK no-error.
    else find clispc where recid(clispc) = recatu1 NO-LOCK.
    if not available clispc
    then do:
        message "Cadastro de Clientes no SPC esta Vazio".
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.
    recatu1 = recid(clispc).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        find next clispc NO-LOCK no-error.
        if not available clispc
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find clispc where recid(clispc) = recatu1 NO-LOCK.

        choose field clispc.contnum
            go-on(cursor-down cursor-up
                  page-down   page-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return).
        hide message no-pause.
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                color display message esqcom2[esqpos2] with frame f-com2.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                color display message esqcom1[esqpos1] with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                color display messages esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                color display messages esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next clispc NO-LOCK no-error.
                if not avail clispc
                then leave.
                recatu2 = recid(clispc).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            else recatu1 = recid(clispc).
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev clispc NO-LOCK no-error.
                if not avail clispc
                then leave.
                recatu1 = recid(clispc).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next clispc NO-LOCK no-error.
            if not avail clispc
            then next.
            color display white/red clispc.contnum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev clispc NO-LOCK no-error.
            if not avail clispc
            then next.
            color display white/red clispc.contnum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        if esqcom1[esqpos1] <> "Procura"
        then hide frame frame-a no-pause.
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-altera ON ERROR UNDO.
                create clispc.
                update clispc.clicod
                       clispc.contnum.
                find clien of clispc NO-LOCK.
                disp clien.clinom.
                find contrato of clispc no-lock.
                if contrato.clicod <> clispc.clicod
                then do:
                    message "Contrato nao pertence a este cliente !!".
                    pause.
                    undo.
                end.

                atraso = no.
                for each titulo where titulo.clifor = clispc.clicod NO-LOCK:
                    if titulo.titsit = "LIB" and
                       titulo.titnum = string(clispc.contnum)
                    then display titulo.titnum
                                 titulo.titdtven
                                 titulo.titsit
                                 titulo.titpar with centered color white/red.

                    if titulo.titsit   = "LIB" and
                       titulo.titdtven < today and
                       titulo.titnum = string(clispc.contnum)
                    then atraso = yes.

                    if titulo.titsit = "LIB" and
                       titulo.tpcontrato = "L" /*titpar > 50*/  and
                       titulo.titnum = string(clispc.contnum)
                    then atraso = yes.
                end.

                if not atraso
                then do:
                    message "Este Contrato nao esta atrasado !!".
                    pause.
                    undo.
                end.

                find bclispc where bclispc.clicod  = clispc.clicod  and
                                   bclispc.contnum = clispc.contnum and
                                   bclispc.dtcanc  = ? no-lock no-error.
                if avail bclispc
                then do:
                message "Cliente ja esta registrado no SPC neste contrato !!".
                    pause.
                    undo.
                end.

                update clispc.spcpro
                       clispc.dtneg
                       clispc.dtcanc.

                recatu1 = recid(clispc).
                leave.
            end.
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao" or
               esqcom1[esqpos1] = "Alteracao" or
               esqcom1[esqpos1] = "Listagem"
            then do with frame f-altera:
                disp clispc.clicod
                     clispc.contnum
                     clispc.spcpro
                     clispc.dtneg
                     clispc.dtcanc.
                find clien of clispc NO-LOCK.
                disp clien.clinom.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera ON ERROR UNDO:
                find current clispc exclusive.
                update clispc.clicod
                       clispc.contnum.
                find contrato of clispc no-lock.
                if contrato.clicod <> clispc.clicod
                then do:
                    message "Contrato nao pertence a este cliente !!".
                    pause.
                    undo.
                end.
                find clien of clispc NO-LOCK.
                disp clien.clinom.
                update clispc.spcpro
                       clispc.dtneg
                       clispc.dtcanc when clispc.dtcanc = ?.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera ON ERROR UNDO:
                message "Confirma Exclusao de" clispc.clicod update sresp.
                if not sresp
                then undo.
                find next clispc NO-LOCK no-error.
                if not available clispc
                then do:
                    find clispc where recid(clispc) = recatu1 NO-LOCK.
                    find prev clispc NO-LOCK no-error.
                end.
                recatu2 = if available clispc
                          then recid(clispc)
                          else ?.
                find clispc where recid(clispc) = recatu1 EXCLUSIVE.
                delete clispc.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do:
                prompt-for clien.clicod with side-label
                           color white/cyan overlay centered row 10 frame fp.
                find first bclispc where bclispc.clicod = input clien.clicod
                                                    no-lock no-error.
                if avail bclispc
                then recatu1 = recid(bclispc).
                leave.
            end.

            if esqcom1[esqpos1] = "Listagem"
            then do:
                message "Confirma Impressao de Clientes no SPC" update sresp.
                if not sresp
                then undo.
                recatu2 = recatu1.
                output to printer.
                for each clispc where clispc.dtcanc = ? NO-LOCK:
                    display clispc.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.

            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                    with frame f-com2.
                if esqcom2[esqpos2] = " Contrato "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    find contrato of clispc no-lock no-error.
                    if avail contrato
                    then run fqtitfat.p (recid(contrato),
                                      input 11 /* row f-com1 */).
                    view frame f-com1.
                    view frame f-com2.
                end.
            end.
            view frame frame-a.
        end.
        if keyfunction (lastkey) = "end-error"
        then view frame frame-a.
        run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(clispc).
    end.
end.

procedure frame-a.
    find clien of clispc NO-LOCK no-error.
    display
        clispc.contnum format ">>>>>>>>9"
        clispc.clicod
        clien.clinom   format "x(30)" when avail clien
        clispc.dtneg
        clispc.dtcanc  column-label "Cancelamen"
        with frame frame-a 14 down centered color white/red.
end procedure.
