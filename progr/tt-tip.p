/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def input  parameter vfuncod like clitel.funcod.
def input  parameter vdata   as date format "99/99/9999". 
def output parameter rettip  like tipcont.codcont.
def var vtot as int.

def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.

def var esqcom1         as char format "x(12)" extent 1
            initial ["Seleciona"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def var vcodcont         like clitel.codcont.

def temp-table tt-tip
    field codcont like clitel.codcont
    field desccont like tipcont.desccont
    field totlig  as int format ">>>9"
    index ind-1 codcont.

    rettip = 0.
    for each tt-tip.
        delete tt-tip.
    end.

    for each clitel where
             clitel.teldat = vdata and
             clitel.funcod = vfuncod no-lock:
        
        find first tt-tip where tt-tip.codcont = clitel.codcont no-error.
        if not avail tt-tip
        then do:
            find tipcont where tipcont.codcont = clitel.codcont 
                        no-lock no-error.
            if avail tipcont
            then do:
                create tt-tip.
                assign tt-tip.codcont  = clitel.codcont
                       tt-tip.desccont = tipcont.desccont.
            end.
            else next.
        end.
        tt-tip.totlig = tt-tip.totlig + 1.
    end.   
    vtot = 0.
    for each tt-tip:
        vtot = vtot + tt-tip.totlig.
    end.
     
     
    find first tt-tip where tt-tip.codcont = 0 no-error.
    if not avail tt-tip
    then do:
        create tt-tip.
        assign tt-tip.codcont  = 0
               tt-tip.desccont = "TODAS AS LIGACOES"
               tt-tip.totlig   = vtot.
    end.

   
                   
    
    form
        esqcom1
            with frame f-com1
                 row 6 no-box no-labels side-labels centered.
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
    if recatu1 = ?
    then
        find first tt-tip where
            true no-error.
    else
        find tt-tip where recid(tt-tip) = recatu1.
    if not available tt-tip
    then do:
        message "Nenhum registro encontrado".
        undo, leave.
    end.
    clear frame frame-a all no-pause.
    display
        tt-tip.codcont column-label "Codigo" 
        tt-tip.desccont column-label "Tip.Ligacao" 
        tt-tip.totlig column-label "Tot.Lig." 
            with frame frame-a 10 down centered.

    recatu1 = recid(tt-tip).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-tip where
                true.
        if not available tt-tip
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display
            tt-tip.codcont
            tt-tip.desccont
            tt-tip.totlig
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-tip where recid(tt-tip) = recatu1.

        choose field tt-tip.codcont
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  PF4 F4 ESC return).
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
                esqpos1 = if esqpos1 = 1
                          then 1
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
            find next tt-tip where
                true no-error.
            if not avail tt-tip
            then next.
            color display normal
                tt-tip.codcont.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-tip where
                true no-error.
            if not avail tt-tip
            then next.
            color display normal
                tt-tip.codcont.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            rettip = tt-tip.codcont.
            hide frame f-com1 no-pause.
            return.
        end.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Seleciona"
            then do with frame f-inclui overlay row 6 1 column centered.
            
                rettip = tt-tip.codcont.
                hide frame f-com1 no-pause.
                return.
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
          then do:
             rettip = tt-tip.codcont.
             hide frame f-com1 no-pause.
             return.
           
          end.
        display
                tt-tip.codcont
                tt-tip.desccont
                tt-tip.totlig
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-tip).
   end.
end.
