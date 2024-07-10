{admcab.i}
def var vdt like plani.pladat.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["","","","",""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def shared temp-table tt-titulo
    field titnum   like titulo.titnum format "x(7)"
    field titpar   like titulo.titpar format "99"
    field modcod   like titulo.modcod
    field titdtemi like titulo.titdtemi format "99/99/9999"
    field titdtven like titulo.titdtven format "99/99/9999"
    field titvlcob like titulo.titvlcob column-label "Vl.Cobrado"
                       format ">>>,>>9.99"
    field titsit   like titulo.titsit
    field clifor   like titulo.clifor column-label "FL" format "99"
    index ind-1 titdtemi desc.


def buffer btt-titulo       for tt-titulo.
def var vmodcod         like tt-titulo.modcod.

    esqregua  = yes.
bl-princ:
repeat:
    if recatu1 = ?
    then
        find first tt-titulo where
            true no-error.
    else
        find tt-titulo where recid(tt-titulo) = recatu1.
    vinicio = yes.
    if not available tt-titulo
    then do:
        message "Cadastro Vazio".
        return.
    end.
    clear frame frame-a all no-pause.
    
    find forne where forne.forcod = tt-titulo.clifor no-lock no-error.
    display titnum    format "x(7)"
            titpar    format "99" 
            forne.fornom format "x(15)" when avail forne
            modcod    
            titdtemi  format "99/99/9999" 
            titdtven  format "99/99/9999" 
            titvlcob  column-label "Vl.Cobrado" format ">>>,>>9.99" 
            titsit    
                with frame frame-a 13 down centered.

    recatu1 = recid(tt-titulo).
    repeat:
        find next tt-titulo where
                true.
        if not available tt-titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.

        find forne where forne.forcod = tt-titulo.clifor no-lock no-error.
    
        display titnum    format "x(7)"
                titpar    format "99" 
                forne.fornom when avail forne
                modcod    
                titdtemi  format "99/99/9999" 
                titdtven  format "99/99/9999" 
                titvlcob  column-label "Vl.Cobrado" format ">>>,>>9.99" 
                titsit    
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-titulo where recid(tt-titulo) = recatu1.

        on f7 recall.
        choose field tt-titulo.titnum 
            go-on(cursor-down cursor-up cursor-left cursor-right F7 PF7
                  page-up page-down tab PF4 F4 ESC return v V ).
       if  keyfunction(lastkey) = "RECALL"
       then do with frame fproc centered row 5 overlay color message side-label:
            prompt-for tt-titulo.titnum colon 10.
            find first tt-titulo where tt-titulo.titnum <= 
                                                input tt-titulo.titnum 
                                        no-error.
            recatu1 = if avail tt-titulo
                      then recid(tt-titulo) 
                      else ?. 
            leave.
       end. 
       on f7 help.
       
       if  keyfunction(lastkey) = "V" or
           keyfunction(lastkey) = "v"
       then do with frame fdt centered row 5 overlay color message side-label:
            vdt = today.
            update vdt label "Vencimento".
            find first tt-titulo where tt-titulo.titdtven <= vdt no-error.
            recatu1 = if avail tt-titulo
                      then recid(tt-titulo) 
                      else ?. 
            leave.
        end. 
        


        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-titulo where true no-error.
                if not avail tt-titulo
                then leave.
                recatu1 = recid(tt-titulo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-titulo where true no-error.
                if not avail tt-titulo
                then leave.
                recatu1 = recid(tt-titulo).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-titulo where
                true no-error.
            if not avail tt-titulo
            then next.
            color display normal
                tt-titulo.titnum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-titulo where
                true no-error.
            if not avail tt-titulo
            then next.
            color display normal
                tt-titulo.titnum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
            hide frame frame-a no-pause.
            view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
                
        find forne where forne.forcod = tt-titulo.clifor no-lock no-error.
        display titnum    format "x(7)"
                titpar    format "99" 
                forne.fornom when avail forne
                modcod    
                titdtemi  format "99/99/9999" 
                titdtven  format "99/99/9999" 
                titvlcob  column-label "Vl.Cobrado" format ">>>,>>9.99" 
                titsit    
                    with frame frame-a.
        recatu1 = recid(tt-titulo).
   end.
end.
