{admcab.i}
def var v-qtd like movim.movqtm.
def input parameter  total_nota like plani.platot.
def output parameter total_item  like plani.platot.
def shared temp-table w-movim 
    field marca     as char format "x(01)"
    field procod    like produ.procod 
    field pronom    like produ.pronom
    field movqtm    like movim.movqtm 
    field subtotal  like movim.movpc 
    field movpc     like movim.movpc
    field qtd_item  like movim.movqtm
        index ind-1 subtotal desc.
        
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 2
            initial ["Marca","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bw-movim       for w-movim.
def var vprocod         like w-movim.procod.


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

    pause 0.
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then find first w-movim where true no-error.
    else find w-movim where recid(w-movim) = recatu1.
    vinicio = yes.
    if not available w-movim
    then do:
        message "Nenhum registro encontrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.

    display
        w-movim.marca  no-label
        w-movim.procod
        w-movim.pronom format "x(45)"
        w-movim.movqtm   column-label "Estoque"      format ">>>>9"
        w-movim.qtd_item column-label "Qtd.Sugerida" format ">>>>9" 
        w-movim.movpc    column-label "Custo" format ">>,>>9.99"
        w-movim.subtotal column-label "Subtotal" format ">>>,>>9.99"
            with frame frame-a 14 down centered.

    display total_nota label "Total Nota"
            total_item label "Total Mercadorias"
                with frame f-totais side-label no-box centered.

    recatu1 = recid(w-movim).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next w-movim where true. 
        if not available w-movim
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.

        display w-movim.marca
                w-movim.procod 
                w-movim.pronom 
                w-movim.movqtm  
                w-movim.qtd_item
                w-movim.movpc 
                w-movim.subtotal 
                            with frame frame-a.
        display total_nota
                total_item
                    with frame f-totais.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find w-movim where recid(w-movim) = recatu1.

        run color-message.
        choose field w-movim.procod
            go-on(cursor-down cursor-up A a
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
                esqpos2 = if esqpos2 = 2
                          then 2
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
                find next w-movim where true no-error.
                if not avail w-movim
                then leave.
                recatu1 = recid(w-movim).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev w-movim where true no-error.
                if not avail w-movim
                then leave.
                recatu1 = recid(w-movim).
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
            find next w-movim where
                true no-error.
            if not avail w-movim
            then next.
            color display normal
                w-movim.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev w-movim where
                true no-error.
            if not avail w-movim
            then next.
            color display normal
                w-movim.procod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        
        if keyfunction (lastkey) = "A" or
           keyfunction (lastkey) = "a"
        then do on error undo, retry: 
            
            v-qtd = w-movim.qtd_item.
            update w-movim.qtd_item validate( w-movim.qtd_item > 0,
                                   "Quantidade invalida" ).
            
            if w-movim.marca = ""
            then do:
                total_item = total_item + (w-movim.movpc * w-movim.qtd_item). 
                if total_nota < total_item 
                then do: 
                    message "Total de Mercadorias maior que Total da Nota". 
                    pause.
                    total_item = total_item - (w-movim.movpc * w-movim.qtd_item).
                    w-movim.qtd_item = v-qtd.
                    retry.
                end.
                else w-movim.marca = "*".
            end.
            else do:
                total_item = total_item - (w-movim.movpc * v-qtd). 
                total_item = total_item + (w-movim.movpc * w-movim.qtd_item). 
                if total_nota < total_item 
                then do: 
                    message "Total de Mercadorias maior que Total da Nota". 
                    pause.
                    
                    total_item = total_item + (w-movim.movpc * v-qtd). 
                    total_item = total_item - (w-movim.movpc * w-movim.qtd_item). 
                    w-movim.qtd_item = v-qtd.
                    retry.
                end.
            end.

            
            w-movim.subtotal = w-movim.qtd_item * w-movim.movpc.
            
            display w-movim.marca
                    w-movim.procod  
                    w-movim.pronom  
                    w-movim.movqtm   
                    w-movim.qtd_item 
                    w-movim.movpc  
                    w-movim.subtotal 
                            with frame frame-a.
            
            display total_nota
                    total_item
                    with frame f-totais.
            recatu1 = recid(w-movim).        
            leave.        
        end.
        
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.

        if esqregua 
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Marca"
            then do:
                if w-movim.marca = ""
                then do: 
                    total_item = total_item + (w-movim.movpc * w-movim.qtd_item). 
                    w-movim.marca = "*".
                    if total_nota < total_item
                    then do:
                        message "Total de Mercadorias maior que Total da Nota".
                        w-movim.marca = "".
                        total_item = total_item - (w-movim.movpc * w-movim.qtd_item).
                        pause.
                    end.   
                end.        
                else do:
                    w-movim.marca = "".
                    total_item = total_item - (w-movim.movpc * w-movim.qtd_item).
                end.    
            end.
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-procura overlay centered side-label.
                vprocod = 0.
                update vprocod label "Produto".
                find first w-movim where w-movim.procod = vprocod no-error.
                if not avail w-movim
                then do:
                    message "Produto nao Cadastrado".
                    pause.
                    undo, retry.
                end.
                recatu1 = recid(w-movim).
                leave.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp w-movim with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" w-movim.pronom update sresp.
                if not sresp
                then leave.
                find next w-movim where true no-error.
                if not available w-movim
                then do:
                    find w-movim where recid(w-movim) = recatu1.
                    find prev w-movim where true no-error.
                end.
                recatu2 = if available w-movim
                          then recid(w-movim)
                          else ?.
                find w-movim where recid(w-movim) = recatu1.
                delete w-movim.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de w-movimidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each w-movim:
                    display w-movim.
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

        display w-movim.marca
                w-movim.procod 
                w-movim.pronom 
                w-movim.movqtm  
                w-movim.qtd_item
                w-movim.movpc 
                w-movim.subtotal 
                    with frame frame-a.
                    
        display total_nota
                total_item
                    with frame f-totais.
        
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(w-movim).
   end.
end.

procedure color-message.
color display message
        w-movim.procod
        w-movim.pronom
        w-movim.movqtm 
        w-movim.qtd_item
        w-movim.movpc
        w-movim.subtotal
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        w-movim.procod
        w-movim.pronom format "x(25)"
        w-movim.movqtm 
        w-movim.qtd_item
        w-movim.movpc
        w-movim.subtotal
        with frame frame-a.
end procedure.

