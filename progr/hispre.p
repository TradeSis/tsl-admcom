{admcab.i}

/* programa antigo : conaltpr.p */

def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 1
            initial ["Consulta"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bhispre       for hispre.
def var vprocod         like hispre.procod.


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

    vprocod = 0.
    update vprocod label "Produto" with frame f1 side-label width 80.
    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do:
        message "Produto nao cadastrado".
        pause.
        undo, retry.
    end.
    display produ.pronom no-label with frame f1.
    
    hide frame f1 no-pause.
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        find first hispre where hispre.procod = vprocod no-error.
    else
        find hispre where recid(hispre) = recatu1.
    vinicio = yes.
    if not available hispre
    then do:
        message "Nenhum registro encontrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    
    find produ where produ.procod = hispre.procod no-lock.
    find func where func.funcod = hispre.funcod and
                    func.etbcod = 999 no-lock no-error.
    display
        setbcod       column-label "Fl" format ">>9"
        hispre.funcod column-label "Func" format ">>>9"
        func.funnom   when avail func
            column-label "Nome"    format "x(10)" 
        hispre.dtalt  column-label "Data"     
        hispre.estvenda-ant column-label "Pr.Anterior"
                            format ">>,>>9.99"
        hispre.estvenda-nov column-label "Pr.Novo"
                            format ">>,>>9.99"
            with frame frame-a 14 down centered
             title "Produto: " + string(hispre.procod,"999999") + 
                   " - " +  produ.pronom.


    recatu1 = recid(hispre).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next hispre where hispre.procod = vprocod.
        if not available hispre
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        
        find produ where produ.procod = hispre.procod no-lock. 
        find func where func.funcod = hispre.funcod and
                        func.etbcod = 999 no-lock no-error.

        display setbcod      
                hispre.funcod
                func.funnom   when avail func 
                hispre.dtalt 
                hispre.estvenda-ant
                hispre.estvenda-nov
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find hispre where recid(hispre) = recatu1.

        run color-message.
        choose field hispre.funcod
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
                find next hispre where hispre.procod = vprocod no-error.
                if not avail hispre
                then leave.
                recatu1 = recid(hispre).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev hispre where hispre.procod = vprocod no-error.
                if not avail hispre
                then leave.
                recatu1 = recid(hispre).
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
            find next hispre where hispre.procod = vprocod no-error.
            if not avail hispre
            then next.
            color display normal
                hispre.funcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev hispre where hispre.procod = vprocod no-error.
            if not avail hispre
            then next.
            color display normal
                hispre.funcod.
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
                create hispre.
                update hispre.funcod
                       hispre.procod.
                recatu1 = recid(hispre).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update hispre with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                find produ where produ.procod = hispre.procod no-lock. 
                find func where func.funcod = hispre.funcod and
                                func.etbcod = 999 no-lock no-error.

                display setbcod       
                        hispre.procod  
                        produ.pronom    
                        hispre.funcod 
                        func.funnom   when avail func  
                        hispre.dtalt
                        string(hispre.hora-inc,"HH:MM:SS") label "Hora"  
                        hispre.estvenda-ant 
                        hispre.estvenda-nov.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" hispre.funcod update sresp.
                if not sresp
                then leave.
                find next hispre where hispre.procod = vprocod no-error.
                if not available hispre
                then do:
                    find hispre where recid(hispre) = recatu1.
                    find prev hispre where hispre.procod = vprocod no-error.
                end.
                recatu2 = if available hispre
                          then recid(hispre)
                          else ?.
                find hispre where recid(hispre) = recatu1.
                delete hispre.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de hispreidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each hispre:
                    display hispre.
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
        
        find produ where produ.procod = hispre.procod no-lock. 
        find func where func.funcod = hispre.funcod and
                        func.etbcod = 999 no-lock no-error.

        display setbcod       
                hispre.funcod
                func.funnom   when avail func 
                hispre.dtalt 
                hispre.estvenda-ant
                hispre.estvenda-nov
                    with frame frame-a.
        
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(hispre).
   end.
end.

procedure color-message.
color display message
              setbcod       
              hispre.funcod 
              func.funnom   
              hispre.dtalt  
              hispre.estvenda-ant 
              hispre.estvenda-nov
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
              setbcod       
              hispre.funcod
              func.funnom   
              hispre.dtalt  
              hispre.estvenda-ant 
              hispre.estvenda-nov
                with frame frame-a.
end procedure.

