{admcab.i}
def input parameter vetb like estab.etbcod.
def input parameter vdti like plani.pladat.
def input parameter vdtf like plani.pladat.
def var varquivo as char.

def shared temp-table tt-plani
    field etbcod like plani.etbcod
    field pladat like plani.pladat  
    field procod like produ.procod
    field pronom like produ.pronom
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field platot like plani.platot
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
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-plani    for tt-plani.
def var vpladat         like tt-plani.pladat.


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
        find first tt-plani where
            true no-error.
    else
        find tt-plani where recid(tt-plani) = recatu1.
    vinicio = yes.
    if not available tt-plani
    then do:
        message "Nenhum registro encontrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    display tt-plani.pladat
            tt-plani.desti
            tt-plani.numero
            tt-plani.procod
            tt-plani.pronom format "x(20)"
            tt-plani.platot
                with frame frame-a 14 down centered.

    recatu1 = recid(tt-plani).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-plani where
                true.
        if not available tt-plani
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
            tt-plani.pladat
            tt-plani.desti
            tt-plani.numero
            tt-plani.procod
            tt-plani.pronom
            tt-plani.platot with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-plani where recid(tt-plani) = recatu1.

        choose field tt-plani.pladat
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
            find next tt-plani where
                true no-error.
            if not avail tt-plani
            then next.
            color display normal
                tt-plani.pladat.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-plani where
                true no-error.
            if not avail tt-plani
            then next.
            color display normal
                tt-plani.pladat.
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
                create tt-plani.
                update tt-plani.datexp
                       tt-plani.pladat.
                recatu1 = recid(tt-plani).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update tt-plani with frame f-altera no-validate.
            end.

            if esqcom1[esqpos1] = "Consulta/Produto"
            then do with frame f-consulta overlay row 6 down centered.
                for each movim where movim.etbcod = tt-plani.emite  and
                                     movim.placod = tt-plani.placod and
                                     movim.movdat = tt-plani.pladat and
                                     movim.movtdc = 09 no-lock.
                                     
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
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-plani.datexp update sresp.
                if not sresp
                then leave.
                find next tt-plani where true no-error.
                if not available tt-plani
                then do:
                    find tt-plani where recid(tt-plani) = recatu1.
                    find prev tt-plani where true no-error.
                end.
                recatu2 = if available tt-plani
                          then recid(tt-plani)
                          else ?.
                find tt-plani where recid(tt-plani) = recatu1.
                delete tt-plani.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "     Listagem"
            then do:
                recatu2 = recatu1.
                for each estab where if vetb = 0
                                     then true
                                     else estab.etbcod = vetb no-lock:
                    if opsys = "unix"
                    then varquivo = "/admcom/relat/alm" + STRING(day(today)) + 
                                     string(estab.etbcod,"999").

                    else varquivo = "l:\relat\alm" + STRING(day(today)) + 
                                    string(estab.etbcod,"999").


                    {mdad.i &Saida     = "value(varquivo)" 
                            &Page-Size = "64"
                            &Cond-Var  = "130" 
                            &Page-Line = "66" 
                            &Nom-Rel   = ""confir_2""
                            &Nom-Sis   = """SISTEMA DE ALMOXARIFADO"""
                            &Tit-Rel   = """FILIAL "" + 
                                         string(estab.etbcod,"">>9"") + 
                                         "" DE "" +
                                      string(vdti,""99/99/9999"") + "" A "" +
                                      string(vdtf,""99/99/9999"") "
                            &Width     = "130"          
                            &Form      = "frame f-cabcab"}


 
               
                for each tt-plani where tt-plani.desti = estab.etbcod
                                        break by tt-plani.procod:
                                        
                    

                    display tt-plani.pladat  
                            tt-plani.desti  
                            tt-plani.numero  
                            tt-plani.procod  
                            tt-plani.pronom  
                            tt-plani.movqtm(total by tt-plani.procod)
                            tt-plani.movpc
                            tt-plani.platot(total by tt-plani.procod)
                                column-label "Total" format ">,>>>,>>9.99"
                                            with frame f-lista width 200
                                                down.
                end.
                output close.
                if opsys = "unix"
                then do:
                    run visurel.p (input varquivo,
                                   input "").
                                    
                end.
                else do:
                    {mrod.i}
                end.
                end.
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
          
        display tt-plani.pladat 
                tt-plani.desti 
                tt-plani.numero 
                tt-plani.procod 
                tt-plani.pronom 
                tt-plani.platot
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-plani).
   end.
end.
