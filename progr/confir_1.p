/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def input parameter vetb like estab.etbcod.

def shared temp-table tt-plani
    field movtdc like plani.movtdc
    field pladat like plani.pladat  
    field datexp like plani.datexp format "99/99/9999" 
    field emite  like plani.emite 
    field desti  like plani.desti
    field numero like plani.numero format ">>>>>>9"
    field notant like plani.numero format ">>>>>>9"
    field serie  like plani.serie  
    field placod like plani.placod
    field confi  as char format "x(15)".

def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(16)" extent 2
            initial ["Consulta/Produto","     Listagem"].
def var esqcom2         as char format "x(12)" extent 5.

def var vmodcod as char.
def var varquivo as char.
def var vpdf as char no-undo.

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
    pause 0.
    if recatu1 = ?
    then find first tt-plani where true no-error.
    else find tt-plani where recid(tt-plani) = recatu1.
    vinicio = yes.
    if not available tt-plani
    then do:
        message "Nenhum registro encontrado".
        leave.
    end.
    clear frame frame-a all no-pause.
    display
        tt-plani.pladat
/*        tt-plani.datexp */
        tt-plani.emite  
        tt-plani.desti
        tt-plani.numero 
        tt-plani.notant column-label "Num.Antigo"
        tt-plani.serie  
        tt-plani.confi
            with frame frame-a 14 down centered.

    recatu1 = recid(tt-plani).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        find next tt-plani where true.
        if not available tt-plani
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
            tt-plani.pladat
/*          tt-plani.datexp */
            tt-plani.emite 
            tt-plani.desti
            tt-plani.numero
            tt-plani.notant
            tt-plani.serie 
            tt-plani.confi 
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-plani where recid(tt-plani) = recatu1.

        choose field tt-plani.pladat
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  PF4 F4 ESC return).

        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 2 then 2 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                color display messages esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-plani where true no-error.
                if not avail tt-plani
                then leave.
                recatu1 = recid(tt-plani).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-plani where true no-error.
                if not avail tt-plani
                then leave.
                recatu1 = recid(tt-plani).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                color display messages esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-plani where true no-error.
            if not avail tt-plani
            then next.
            color display normal tt-plani.pladat.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-plani where true no-error.
            if not avail tt-plani
            then next.
            color display normal tt-plani.pladat.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Consulta/Produto"
            then do with frame f-consulta overlay row 6 down centered.
                for each movim where movim.etbcod = tt-plani.emite  and
                                     movim.placod = tt-plani.placod and
                                     movim.movdat = tt-plani.pladat and
                                     movim.movtdc = tt-plani.movtdc no-lock,
                    first produ where produ.procod = movim.procod no-lock.

                   vmodcod = "Nao Encontrado".
                   find last liped where liped.pedtdc = 3
                                 and liped.procod = movim.procod
                                 and liped.predt <= tt-plani.pladat
                                 and liped.etbcod = vetb
                                 and liped.lipsit = "L"
                                 no-lock no-error.
                   if avail liped
                   then do:          
                        find first pedid where pedid.etbcod = liped.etbcod
                                      and pedid.pedtdc = liped.pedtdc
                                      and pedid.pednum = liped.pednum
                                      /*and pedid.sitped = "F"*/
                                     no-lock no-error.
                        if avail pedid
                        then do:
                         if pedid.modcod = "PEDE" 
                         then vmodcod = "ESPECIAL".
                         else if pedid.modcod = "PEDA"
                              THEN vmodcod = "AUTOMATICO".
                              else if pedid.modcod = "PEDM" 
                              then vmodcod = "MANUAL".
                              else if pedid.modcod = "PEDP" 
                              then vmodcod = "PENDENTE".
                              else if pedid.modcod = "PEDR" 
                              then vmodcod = "REPOSICAO".
                              else if pedid.modcod = "PEDO" 
                              then vmodcod = "O.FILIAL".
                              else if pedid.modcod = "PEDF" 
                              then vmodcod = "E.FUTURA".
                              else if pedid.modcod = "PEDC" 
                              then vmodcod = "COMERCIAL".
                        end.   
                   end.

                    display movim.procod
                            produ.pronom format "x(30)"
                            movim.movpc column-label "Pr.Custo" 
                                                    format ">>>,>>9.99"
                            movim.movqtm column-label "Qtd" format ">>>>9"
                            (movim.movpc * movim.movqtm)(total) 
                                    column-label "Total"
                            vmodcod column-label "Tip.Pedido" format "x(12)"
                            with frame f-x 13 down width 87.
                end.
            end.
            if esqcom1[esqpos1] = "     Listagem"
            then do:
                message "Confirma Impressao?" update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                
                varquivo = "../relat/confir_1" + string(mtime).

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = """confir_1"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = " ""LISTAGEM DE CONFIRMACAO DE FILIAIS - FILIAL "" +
                      string(vetb) + "" DIA: "" + string(today) "
        &Width     = "120"
        &Form      = "frame f-cab"}
                
                for each tt-plani:
                    find first plani where plani.etbcod = tt-plani.emite  and
                                           plani.placod = tt-plani.placod and
                                           plani.serie  = tt-plani.serie  and
                                           plani.movtdc = tt-plani.movtdc
                                            no-lock no-error.
                    if not avail plani
                    then next.
                    
                    if plani.etbcod >= 900 or
                       plani.desti  >= 900
                    then next.
                    
                    if {conv_igual.i plani.etbcod}
                    then next.
                     
                    if {conv_igual.i plani.dest}
                    then next. 
 
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movdat = plani.pladat and
                                         movim.movtdc = plani.movtdc no-lock.
                        find produ where produ.procod = movim.procod 
                                no-lock no-error.
                        display plani.etbcod column-label "Emitente"
                                plani.desti  column-label "Destino"
                                plani.numero
                                plani.pladat
                                movim.procod
                                produ.pronom format "x(30)"
                                movim.movpc
                                movim.movqtm column-label "Qtd" format ">>>>99"
                                "______________________________" 
                                        column-label "Motivo"
                                            with frame f-lista width 200
                                                down.
                    end.                            
                end.
                output close.
                if sremoto
                then run pdfout.p (input varquivo,
                      input "/admcom/kbase/pdfout/",
                      input "confir_1" + string(mtime) + ".pdf",
                      input "Portrait",
                      input 8.2,
                      input 1,
                      output vpdf).
                else run visurel.p (varquivo,"").

                recatu1 = recatu2.
                leave.
            end.

          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        display
                tt-plani.pladat
/*              tt-plani.datexp */
                tt-plani.emite 
                tt-plani.desti
                tt-plani.numero
                tt-plani.notant
                tt-plani.serie 
                tt-plani.confi 
                    with frame frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-plani).
   end.
end.

