/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial [""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].



def var vdata       like titulo.titdtemi.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vjuro       like titulo.titjuro.
def var vdesc       like titulo.titdesc.

def shared temp-table wfresumo
    field etbcod    like estab.etbcod       column-label "Loja"
    field compra    like titulo.titvlcob    column-label "Tot.Compra"
                                                  format ">>>,>>9.99"
    field entrada   like titulo.titvlcob    column-label "Tot.Entrada"
                                                  format ">>>,>>9.99"
    field vlpago    like titulo.titvlpag    column-label "Valor Pago"
                                                  format ">>>,>>9.99"
    field titjuro   like titulo.titjuro     column-label "Juros"
                                                  format ">>>,>>9.99"
    field titdesc   like titulo.titdesc     column-label "Decontos"
                                                  format ">>>,>>9.99".

def temp-table wftela
    field etbcod    like estab.etbcod       column-label "Loja"
    field compra    like titulo.titvlcob    column-label "Tot.Compra"
                                                  format ">>>,>>9.99"
    field entrada   like titulo.titvlcob    column-label "Tot.Entrada"
                                                  format ">>>,>>9.99"
    field vlpago    like titulo.titvlpag    column-label "Valor Pago"
                                                  format ">>>,>>9.99"
    field titjuro   like titulo.titjuro     column-label "Juros"
                                                  format ">>>,>>9.99"
    field titdesc   like titulo.titdesc     column-label "Decontos"
                                                  format ">>>,>>9.99".

for each wfresumo by wfresumo.etbcod.
    create wftela.
    assign wftela.etbcod    = wfresumo.etbcod
           wftela.compra    = wfresumo.compra
           wftela.entrada   = wfresumo.entrada
           wftela.vlpago    = wfresumo.vlpago
           wftela.titjuro   = wfresumo.titjuro
           wftela.titdesc   = wfresumo.titdesc.
end.

def buffer bwftela        for wftela.

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
                      /*
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    */
    if recatu1 = ?
    then
        find first wftela where
            true no-error.
    else
        find wftela where recid(wftela) = recatu1.
        vinicio = yes.
    if not available wftela
    then do:
        leave.
    end.
    clear frame frame-a all no-pause.
    display
        wftela
            with frame frame-a 14 down centered.

    recatu1 = recid(wftela).
    /*
    color display message
        esqcom1[esqpos1]
            with frame f-com1.*/
    repeat:
        find next wftela where
                true.
        if not available wftela
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then
        down
            with frame frame-a.
        display
            wftela
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find wftela where recid(wftela) = recatu1.

        choose field wftela.etbcod
            go-on(cursor-down cursor-up
                  page-down page-up
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
                find next wftela where true no-error.
                if not avail wftela
                then leave.
                recatu1 = recid(wftela).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev wftela where true no-error.
                if not avail wftela
                then leave.
                recatu1 = recid(wftela).
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
            find next wftela where
                true no-error.
            if not avail wftela
            then next.
            color display normal
                wftela.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev wftela where
                true no-error.
            if not avail wftela
            then next.
            color display normal
                wftela.etbcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo,leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a.
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        display
                wftela
                    with frame frame-a.
                     /*
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        */
        recatu1 = recid(wftela).
   end.
end.
