{admcab.i}

def var recatu1     as recid.
def var reccont     as int.
def var vclacod     like clase.clacod.
def var vtotperc    like distr.proper.

recatu1 = ?.
repeat:

    update vclacod with frame f-cla row 4 side-label centered color white/red.
    find clase where clase.clacod = vclacod no-lock no-error.
    if not avail clase
    then do:
        bell.
        message "Classe nao Cadastrada".
        undo, retry.
    end.
    disp clase.clanom no-label with frame f-cla.

    for each estab where estab.etbcod < 900 no-lock.
       if {conv_igual.i estab.etbcod} then next.

        find distr where distr.etbcod = estab.etbcod and
                         distr.clacod = clase.clacod no-error.
        if not avail distr
        then do:
            create distr.
            assign distr.etbcod = estab.etbcod
                   distr.clacod = clase.clacod
                   distr.proper = 0.
        end.
    end.

    bl-princ:
    repeat:
        if recatu1 = ?
        then do:
            find first distr where distr.clacod = vclacod and
                                   distr.etbcod < 900 and
                                   {conv_difer.i distr.etbcod}
                                   no-error.
        end.
        else
            find first distr where recid(distr) = recatu1.

        clear frame frame-a all no-pause.
        display
            distr.etbcod column-label "Filial"
            distr.proper with frame frame-a 10 down row 7 column 21
                                    color white/cyan.

        recatu1 = recid(distr).

        repeat:
            find next distr where distr.clacod = vclacod and
                                  distr.etbcod < 900 and
                                  {conv_difer.i distr.etbcod}.
            if not available distr
            then leave.
            if frame-line(frame-a) = frame-down(frame-a)
            then leave.
            down
                with frame frame-a.
            display
                distr.etbcod
                distr.proper with frame frame-a.
        end.
        up frame-line(frame-a) - 1 with frame frame-a.

        vtotperc = 0.
        for each distr where distr.clacod = vclacod and
                             distr.etbcod < 900.
                             
            if {conv_igual.i distr.etbcod} then next.
                 
            vtotperc = vtotperc + distr.proper.
        end.

        repeat with frame frame-a:
            view frame frame-a.
            disp vtotperc label "Total" with frame f-tot side-label
                                         column 44 row 7 color yellow/black.
            find distr where recid(distr) = recatu1.
            choose field distr.etbcod
            help "Informe os Percentuais para cada Filial"
                go-on(cursor-down cursor-up
                    cursor-left cursor-right
                    page-up page-down
                    tab PF4 F4 ESC F3 PF3
                    return P p) color message.

            if keyfunction(lastkey) = "TAB"
            then do:
            end.

            if keyfunction(lastkey) = "cursor-right"
            then do:
            end.

            if keyfunction(lastkey) = "cursor-left"
            then do:
            end.

            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    find next distr where distr.clacod = vclacod and
                                          distr.etbcod < 900 and
                                          {conv_difer.i distr.etbcod}
                                          no-error.
                    if not avail distr
                    then leave.
                    recatu1 = recid(distr).
                end.
                leave.
            end.

            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    find prev distr where distr.clacod = vclacod and
                                          distr.etbcod < 900 and
                                         {conv_difer.i distr.etbcod}
                                          no-error.
                    if not avail distr
                    then leave.
                    recatu1 = recid(distr).
                end.
                leave.
            end.

            if keyfunction(lastkey) = "cursor-down"
            then do:
                find next distr where distr.clacod = vclacod and
                                      distr.etbcod < 900 and
                                      {conv_difer.i distr.etbcod}
                                       no-error.
                if not avail distr
                then next.
                recatu1 = recid(distr).
                color display white/cyan
                    distr.etbcod.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                find prev distr where distr.clacod = vclacod and
                                      distr.etbcod < 900 and
                                      {conv_difer.i distr.etbcod}
                                      no-error.
                if not avail distr
                then next.
                recatu1 = recid(distr).
                color display white/cyan
                    distr.etbcod.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.

            if keyfunction(lastkey) = "end-error"
            then do:
                hide frame frame-a no-pause.
                if vtotperc = 0
                then do:
                    for each distr where distr.clacod = clase.clacod.
                        delete distr.
                    end.
                end.
                if vtotperc <> 100 and vtotperc <> 0
                then do:
                    bell.
                    message "Percentual Total deve ser 100".
                    undo.
                end.
                else do:
                    recatu1 = ?.
                    leave bl-princ.
                end.
            end.

            display
                distr.etbcod
                distr.proper with frame frame-a.

            if keyfunction(lastkey) = "return"
            then do on error undo, retry on endkey undo, leave.
                update distr.proper.
                vtotperc = 0.
                for each distr where distr.clacod = clase.clacod and
                                     distr.etbcod < 900.
                    if {conv_igual.i distr.etbcod} then next.
                 
                                     
                    vtotperc = vtotperc + distr.proper.
                end.
            end.
        end.
    end.
end.
