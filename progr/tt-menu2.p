/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def input parameter vtit like menu.mentit.
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


def shared temp-table tt-menu2 like menu.



def shared temp-table tt-aplifun
    field funcod like  func.funcod  
    field funnom like  func.funnom  
    field aplicod like aplicativo.aplicod
        index ind-1 funnom. 
 


def buffer btt-menu2       for tt-menu2.
def var vmentit         like tt-menu2.mentit.


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
        find first tt-menu2 where
            true no-error.
    else
        find tt-menu2 where recid(tt-menu2) = recatu1.
    vinicio = yes.
    if not available tt-menu2
    then do:
        message "Nenhum registro encontrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    find first menu where menu.aplicod = tt-menu2.aplicod and
                          menu.menniv  = 1                and
                          menu.ordsup  = tt-menu2.menord no-lock no-error.
    display
        tt-menu2.mentit  help "[ C ] Visualizar Usuarios" 
            no-label format "x(32)"
            with frame frame-a 12 down column 38 
                title string(vtit,"x(34)"). 

    recatu1 = recid(tt-menu2).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-menu2 where
                true.
        if not available tt-menu2
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
           tt-menu2.mentit
            with frame frame-a.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-menu2 where recid(tt-menu2) = recatu1.

        run color-message.
        choose field tt-menu2.mentit
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return C c).
        run color-normal.
        if keyfunction(lastkey) = "C" or
           keyfunction(lastkey) = "c"
        then do:
            for each tt-aplifun no-lock:
                find admaplic where 
                              admaplic.cliente = string(tt-aplifun.funcod) and
                              admaplic.aplicod = tt-menu2.aplicod and                                          admaplic.menniv  = tt-menu2.menniv and
                              admaplic.ordsup  = tt-menu2.ordsup and
                              admaplic.menord  = tt-menu2.menord
                                no-lock no-error.
                if avail admaplic
                then delete tt-aplifun.
            end. 
                        hide frame frame-a no-pause.
            
            if opsys = "unix" 
            then varquivo = "/admcom/relat/tt-arq" + string(time).
            else varquivo = "l:\relat\tt-arq" + string(time).

            {mdad.i
                &Saida     = "value(varquivo)"
                &Page-Size = "0"
                &Cond-Var  = "130"
                &Page-Line = "0"
                &Nom-Rel   = ""tt-ace2""
                &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
                &Tit-Rel   = """USUARIOS AUTORIZADOS PELO SISTEMA"""
                &Width     = "130"
                &Form      = "frame f-cabcab"}
            
       
        
            find aplicativo 
                 where aplicativo.aplicod = tt-menu2.aplicod no-lock.
            vtit = aplicativo.aplinom + " - " + 
                   tt-menu2.mentit.
                 
            display vtit label "Menu" format "x(90)"
                        with frame f-tit side-label width 110.

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
                find next tt-menu2 where true no-error.
                if not avail tt-menu2
                then leave.
                recatu1 = recid(tt-menu2).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-menu2 where true no-error.
                if not avail tt-menu2
                then leave.
                recatu1 = recid(tt-menu2).
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
            find next tt-menu2 where
                true no-error.
            if not avail tt-menu2
            then next.
            color display normal
                tt-menu2.mentit.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-menu2 where
                true no-error.
            if not avail tt-menu2
            then next.
            color display normal
                tt-menu2.mentit.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            leave bl-princ.
            clear frame frame-a all no-pause.
        end.    
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.
         
          if esqregua
          then do:
            /* display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1. */

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                create tt-menu2.
                update 
                       tt-menu2.mentit.
                recatu1 = recid(tt-menu2).
                leave.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-menu2.mentit update sresp.
                if not sresp
                then leave.
                find next tt-menu2 where true no-error.
                if not available tt-menu2
                then do:
                    find tt-menu2 where recid(tt-menu2) = recatu1.
                    find prev tt-menu2 where true no-error.
                end.
                recatu2 = if available tt-menu2
                          then recid(tt-menu2)
                          else ?.
                find tt-menu2 where recid(tt-menu2) = recatu1.
                delete tt-menu2.
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
        tt-menu2.mentit
            with frame frame-a.

        /*
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2. */
        recatu1 = recid(tt-menu2).
   end.
end.
hide frame frame-a no-pause.

procedure color-message.
color display message
        tt-menu2.mentit
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-menu2.mentit
        with frame frame-a.
end procedure.

