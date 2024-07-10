/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def input parameter vdti like plani.pladat.
def input parameter vdtf like plani.pladat.
def shared temp-table tt-movim
    field movrec as recid.
def var vtitulo as char.
 

def var varquivo        as char.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(16)" extent 2
            initial ["Consulta/Produto","     Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-movim    for tt-movim.


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
        find first tt-movim where
            true no-error.
    else
        find tt-movim where recid(tt-movim) = recatu1.
    vinicio = yes.
    if not available tt-movim
    then do:
        message "nenhum registro encontrato".
        return.
    end.
    clear frame frame-a all no-pause.
    
    find movim where recid(movim) = tt-movim.movrec no-lock.
    find produ where produ.procod = movim.procod no-lock no-error.
    
    find first plani where plani.placod = movim.placod and
                           plani.etbcod = movim.etbcod and
                           plani.movtdc = movim.movtdc and
                           plani.pladat = movim.movdat no-lock no-error.

    vtitulo = "DATA :" + string(vdti) + " ATE " + string(vdtf).
                       
    
    display
        movim.procod column-label "Cliente"
        produ.pronom when avail produ format "x(28)" 
        plani.platot format ">>,>>9.99"
        plani.numero format ">>>>>>9"
        plani.serie column-label "Sr"
        plani.etbcod column-label "Fil"
            with frame frame-a 12 down centered title vtitulo.

    recatu1 = recid(tt-movim).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-movim where
                true.
        if not available tt-movim
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.

    
        find movim where recid(movim) = tt-movim.movrec no-lock.
        find produ where produ.procod = movim.procod no-lock no-error.
    
        find first plani where plani.placod = movim.placod and
                               plani.etbcod = movim.etbcod and
                               plani.movtdc = movim.movtdc and
                               plani.pladat = movim.movdat no-lock no-error.
    
        display movim.procod  
                produ.pronom when avail produ  
                plani.platot  
                plani.numero  
                plani.serie 
                plani.etbcod 
                    with frame frame-a.

 
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-movim where recid(tt-movim) = recatu1.
        

        choose field movim.procod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
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
                find next tt-movim where true no-error.
                if not avail tt-movim
                then leave.
                recatu1 = recid(tt-movim).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-movim where true no-error.
                if not avail tt-movim
                then leave.
                recatu1 = recid(tt-movim).
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
            find next tt-movim where
                true no-error.
            if not avail tt-movim
            then next.
            color display normal
                movim.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-movim where
                true no-error.
            if not avail tt-movim
            then next.
            color display normal
                movim.procod.
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

            if esqcom1[esqpos1] = "     Observacao"
            then do with frame f-observacao overlay 
                        side-label no-box row 21.
                find plani where recid(plani) = tt-movim.movrec no-error.
                update plani.notobs[2] no-label format "x(78)".
                hide frame f-observacao no-pause.
            end.


            if esqcom1[esqpos1] = "Consulta/Produto"
            then do with frame f-consulta overlay row 6 down centered.
                for each movim where movim.etbcod = plani.emite  and
                                     movim.placod = plani.placod and
                                     movim.movdat = plani.pladat and
                                     movim.movtdc = plani.movtdc no-lock.
                                     
                    find produ where produ.procod = movim.procod 
                                            no-lock no-error.
                    display movim.procod
                            produ.pronom format "x(30)"
                            movim.movpc column-label "Pr.Custo"
                            movim.movqtm column-label "Qtd"
                            (movim.movpc * movim.movqtm)(total)
                                    column-label "Total".
                                             
                end.
            end.
            if esqcom1[esqpos1] = "     Listagem"
            then do:
                message "Confirma Impressao" update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.

                varquivo = "..\relat\brinde" + string(time). 
                {mdad.i
                    &Saida     = "value(varquivo)"
                    &Page-Size = "63"
                    &Cond-Var  = "120"
                    &Page-Line = "66"
                    &Nom-Rel   = ""venda1_p""
                    &Nom-Sis   = """SISTEMA COMERCIAL"""
                    &Tit-Rel   = """VENDAS DA "" +
                                ""FILIAL "" + string(plani.etbcod) +
                                ""  - Data: "" + string(plani.pladat)"
                    &Width     = "120"
                    &Form      = "frame f-cabcab"}

 

                for each tt-movim:
                    
                    find movim where recid(movim) = tt-movim.movrec no-lock.
                    find produ where produ.procod = movim.procod 
                                no-lock no-error.
    
                    find first plani where plani.placod = movim.placod and
                                           plani.etbcod = movim.etbcod and
                                           plani.movtdc = movim.movtdc and
                                           plani.pladat = movim.movdat 
                                                   no-lock no-error.
    
                    display movim.procod  
                            produ.pronom when avail produ  
                            plani.platot  
                            plani.numero format ">>>>>>9" 
                            plani.serie 
                                with frame frame-b down width 130.

 

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
        
        find movim where recid(movim) = tt-movim.movrec no-lock.
        find produ where produ.procod = movim.procod no-lock no-error.
    
        find first plani where plani.placod = movim.placod and
                               plani.etbcod = movim.etbcod and
                               plani.movtdc = movim.movtdc and
                               plani.pladat = movim.movdat no-lock no-error.
    
        display movim.procod  
                produ.pronom when avail produ  
                plani.platot  
                plani.numero  
                plani.serie 
                plani.etbcod
                    with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-movim).
   end.
end.
