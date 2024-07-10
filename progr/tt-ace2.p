/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var vtit like menu.mentit.
def var recimp as recid.
def var fila as char.
def var vrel as char.
def var varquivo as char.


def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 1
            initial [""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def new shared temp-table tt-aplifun
    field funcod like  func.funcod  
    field funnom like  func.funnom  
    field aplicod like aplicativo.aplicod
        index ind-1 funnom. 
    

def shared temp-table tt-apli
    field aplicod like aplicativo.aplicod
    field aplinom like aplicativo.aplinom
    index ind-1 aplicod.

def new shared temp-table tt-menu1 like menu.



def buffer btt-apli       for tt-apli.
def var vaplinom         like tt-apli.aplinom.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    
   /* disp esqcom1 with frame f-com1. */
   /* disp esqcom2 with frame f-com2. */
    if recatu1 = ?
    then
        find first tt-apli where
            true no-error.
    else
        find tt-apli where recid(tt-apli) = recatu1.
    vinicio = yes.
    if not available tt-apli
    then do:
        message "Nenhum registro encontrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    find aplicativo where aplicativo.aplicod = tt-apli.aplicod no-lock.
    display
        tt-apli.aplinom help "[ C ] Visualizar Usuarios" 
                no-label format "x(25)" 
            with frame frame-a 12 down
                title "MENU".

    recatu1 = recid(tt-apli).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-apli where
                true.
        if not available tt-apli
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
           tt-apli.aplinom
            with frame frame-a.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-apli where recid(tt-apli) = recatu1.

        run color-message.
        choose field tt-apli.aplinom
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return C c).
        run color-normal.

        if keyfunction(lastkey) = "C" or
           keyfunction(lastkey) = "c"
        then do:
           
            for each tt-aplifun:
                delete tt-aplifun.
            end.    
            for each func where func.etbcod = 999 no-lock:
                find aplifun where aplifun.funcod = func.funcod and
                                   aplifun.aplicod = tt-apli.aplicod
                                   no-lock no-error.
                if not avail aplifun
                then do:
                    find aplifun where aplifun.funcod = func.funcod and
                                       aplifun.aplicod = "(D)" + tt-apli.aplicod
                            no-lock no-error.
                    if not avail aplifun
                    then do:
                        create tt-aplifun. 
                        assign tt-aplifun.funcod = func.funcod 
                               tt-aplifun.funnom = func.funnom 
                               tt-aplifun.aplicod = tt-apli.aplicod.
                    end.
                end.    
            end.

            hide frame frame-a no-pause.
            
            if opsys = "unix" 
            then varquivo = "/admcom/relat/tt-arq" + string(time).
            else varquivo = "l:\relat\tt-arq" + string(time).

            {mdad.i
                &Saida     = "value(varquivo)"
                &Page-Size = "0"
                &Cond-Var  = "100"
                &Page-Line = "0"
                &Nom-Rel   = ""tt-ace2""
                &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
                &Tit-Rel   = """USUARIOS AUTORIZADOS PELO SISTEMA"""
                &Width     = "100"
                &Form      = "frame f-cabcab"}
            
       
        
            display tt-apli.aplinom label "Menu"
                        with frame f-tit side-label centered.

            for each tt-aplifun:
                display tt-aplifun.funcod column-label "Codigo"
                        tt-aplifun.funnom column-label "Funcionario"
                            with frame f-func down.
            end.

            output close.
            if opsys = "UNIX" 
            then do:

                run visurel.p (input varquivo, input "").
            end.    
            else do: 
                {mrod.i} 
            end.    

            view frame frame-a.
            undo, retry.
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
                esqpos2 = if esqpos2 = 1
                          then 1
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
                find next tt-apli where true no-error.
                if not avail tt-apli
                then leave.
                recatu1 = recid(tt-apli).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-apli where true no-error.
                if not avail tt-apli
                then leave.
                recatu1 = recid(tt-apli).
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
            find next tt-apli where
                true no-error.
            if not avail tt-apli
            then next.
            color display normal
                tt-apli.aplinom.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-apli where
                true no-error.
            if not avail tt-apli
            then next.
            color display normal
                tt-apli.aplinom.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.
            for each tt-menu1:
                delete tt-menu1.
            end.
            for each menu where menu.aplicod = tt-apli.aplicod and
                                menu.menniv  = 1 no-lock:
                find first tt-menu1 where 
                           tt-menu1.aplicod = menu.aplicod and
                           tt-menu1.menniv  = menu.menniv  and
                           tt-menu1.ordsup  = menu.ordsup  and
                           tt-menu1.menord  = menu.menord no-error.
                if not avail tt-menu1
                then do:
                    create tt-menu1.
                    buffer-copy menu to tt-menu1.
                end.
            end.    
            hide frame frame-a no-pause.
            for each tt-aplifun:
                delete tt-aplifun.
            end.    
            for each func where func.etbcod = 999 no-lock:
                find aplifun where aplifun.funcod = func.funcod and
                                   aplifun.aplicod = tt-apli.aplicod
                                   no-lock no-error.
                if not avail aplifun
                then do:
                    find aplifun where aplifun.funcod = func.funcod and
                                       aplifun.aplicod = "(D)" + tt-apli.aplicod
                            no-lock no-error.
                    if not avail aplifun
                    then do:
                        create tt-aplifun. 
                        assign tt-aplifun.funcod = func.funcod 
                               tt-aplifun.funnom = func.funnom 
                               tt-aplifun.aplicod = tt-apli.aplicod.
                    end.
                end.    
            end.

 
            run tt-menu1.p.                                       
         
          if esqregua
          then do:
            /* display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1. */

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                create tt-apli.
                update 
                       tt-apli.aplinom.
                recatu1 = recid(tt-apli).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update tt-apli with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp tt-apli with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-apli.aplinom update sresp.
                if not sresp
                then leave.
                find next tt-apli where true no-error.
                if not available tt-apli
                then do:
                    find tt-apli where recid(tt-apli) = recatu1.
                    find prev tt-apli where true no-error.
                end.
                recatu2 = if available tt-apli
                          then recid(tt-apli)
                          else ?.
                find tt-apli where recid(tt-apli) = recatu1.
                delete tt-apli.
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
       display
        tt-apli.aplinom
            with frame frame-a.

        /*
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2. */
        recatu1 = recid(tt-apli).
   end.
end.

procedure color-message.
color display message
        tt-apli.aplinom
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-apli.aplinom
        with frame frame-a.
end procedure.

