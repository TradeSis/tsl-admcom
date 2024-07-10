        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next titulo where titulo.empcod   = wempre.empcod and
                                       titulo.titnat   = vtitnat       and
                                       titulo.modcod   = vmodcod       and
                                       titulo.etbcod   = vetbcod   and
                                       titulo.clifor   = vclifor 
                                       no-lock no-error.
                if not avail titulo
                then leave.
                recatu1 = recid(titulo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev titulo where titulo.empcod   = wempre.empcod and
                                       titulo.titnat   = vtitnat       and
                                       titulo.modcod   = vmodcod       and
                                       titulo.etbcod   = vetbcod   and
                                       titulo.clifor   = vclifor
                                        no-lock no-error.
                if not avail titulo
                then leave.
                recatu1 = recid(titulo).
            end.
            leave.
        end.
