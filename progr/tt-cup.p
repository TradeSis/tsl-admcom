{admcab.i}

def var varquivo as char.
def shared temp-table tt-cup
    field etbcod like estab.etbcod
    field datmov like plani.pladat
    field cxacod like plani.cxacod
    field flag   as log format "Fechado/Aberto".



def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 2
            initial ["Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-cup       for tt-cup.
def var vdatmov         like tt-cup.datmov.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
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
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tt-cup where
            true no-error.
    else
        find tt-cup where recid(tt-cup) = recatu1.
    vinicio = yes.
    if not available tt-cup
    then do:
        message "Nenhum registro encontrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    display
        tt-cup.datmov column-label "Data"
        tt-cup.etbcod column-label "Filial"
        tt-cup.cxacod column-label "Caixa"
        tt-cup.flag column-label "Status"
            with frame frame-a 14 down centered.

    recatu1 = recid(tt-cup).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-cup where
                true.
        if not available tt-cup
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
            tt-cup.datmov
            tt-cup.etbcod
            tt-cup.cxacod
            tt-cup.flag
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-cup where recid(tt-cup) = recatu1.

        run color-message.
        choose field tt-cup.datmov
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
                find next tt-cup where true no-error.
                if not avail tt-cup
                then leave.
                recatu1 = recid(tt-cup).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-cup where true no-error.
                if not avail tt-cup
                then leave.
                recatu1 = recid(tt-cup).
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
            find next tt-cup where
                true no-error.
            if not avail tt-cup
            then next.
            color display normal
                tt-cup.datmov.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-cup where
                true no-error.
            if not avail tt-cup
            then next.
            color display normal
                tt-cup.datmov.
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
                create tt-cup.
                update tt-cup.etbcod
                       tt-cup.datmov.
                recatu1 = recid(tt-cup).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update tt-cup with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp tt-cup with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-cup.etbcod update sresp.
                if not sresp
                then leave.
                find next tt-cup where true no-error.
                if not available tt-cup
                then do:
                    find tt-cup where recid(tt-cup) = recatu1.
                    find prev tt-cup where true no-error.
                end.
                recatu2 = if available tt-cup
                          then recid(tt-cup)
                          else ?.
                find tt-cup where recid(tt-cup) = recatu1.
                delete tt-cup.
                recatu1 = recatu2.
                leave.
            end. 
            
            if esqcom1[esqpos1] = "Listagem"
            then do:
                recatu2 = recatu1. 
                
                varquivo = "l:\relat\cup." + string(time).  
                {mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "0" 
                        &Cond-Var  = "147" 
                        &Page-Line = "0" 
                        &Nom-Rel   = ""tt-cup"" 
                        &Nom-Sis   = """SISTEMA CONTABILIDADE""" 
                        &Tit-Rel   = """LISTAGEM DE CAIXAS SEM REGISTRO DE CUPOM"""
                        &Width     = "147"  
                        &Form      = "frame f-cabcab"}
    
                
                for each tt-cup by tt-cup.datmov
                                by tt-cup.etbcod:
                                   
                     
                    display tt-cup.datmov column-label "Data"
                            tt-cup.etbcod column-label "Filial"
                            tt-cup.cxacod column-label "Caixa"
                            tt-cup.flag column-label "Status"
                                with frame f-lista down width 120.
                    
                end.

                output close.
                {mrod.i}
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
                tt-cup.datmov
                tt-cup.etbcod
                tt-cup.cxacod
                tt-cup.flag
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-cup).
   end.
end.

procedure color-message.
color display message
        tt-cup.datmov
        tt-cup.etbcod
        tt-cup.cxacod
        tt-cup.flag
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-cup.datmov
        tt-cup.etbcod
        tt-cup.cxacod
        tt-cup.flag
        with frame frame-a.
end procedure.

