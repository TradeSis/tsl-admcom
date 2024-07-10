/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def buffer              bplani for plani.
def var vser            like plani.serie.
def var vdata           like plani.pladat.
def var vperc           as dec format ">9.99 %".
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Manutencao","Soma","Total","Perc","Conf.Mov"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def var vnumero         like plani.numero.

def var vetbcod like estab.etbcod.
def var vdti as date label "Dt.Inicial" format "99/99/9999".
def var vdtf as date label "Dt.Final"   format "99/99/9999".

def var vacfprod like plani.acfprod.
def var vvltotal like plani.platot.
def var vvlcont  like plani.platot.
def var wacr     like plani.platot.
def var valortot like plani.platot.
def var wper     as decimal.
def var vtotori  as decimal.
def var vtotatu  as decimal.

def buffer bcontnf for contnf.

update vetbcod label "Estab."
    with frame fff side-labels centered color white/red.
find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom no-label format "x(30)" with frame fff.

update vdti label "Periodo"
       vdtf no-label with frame fff.

    form
        esqcom1
            with frame f-com1
                 row 6 no-box no-labels side-labels column 1.
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
        find first plani where
                               plani.movtdc  = 5            and
                               plani.etbcod  = estab.etbcod and
                               plani.pladat >= vdti         and
                               plani.pladat <= vdtf         no-error.
    else
        find plani where recid(plani) = recatu1.
    vinicio = yes.
    if not available plani
    then do:
        message "Cadastro de Notas Vazio".
        undo.
    end.
    clear frame frame-a all no-pause.
    do transaction:
        {juro.i}
    end.
    display
        plani.pladat
        plani.numero
        plani.serie
        vacfprod
        plani.platot
        plani.outras
            with frame frame-a 11 down centered color white/cyan.

    recatu1 = recid(plani).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next plani where
                               plani.movtdc  = 5            and
                               plani.etbcod  = estab.etbcod and
                               plani.pladat >= vdti         and
                               plani.pladat <= vdtf         no-error.

        if not available plani
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        do transaction:
        {juro.i}
        end.

        display
        plani.pladat
        plani.numero
        plani.serie
        vacfprod
        plani.platot
        plani.outras
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find plani where recid(plani) = recatu1.

        choose field plani.numero
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
                find next plani where
                               plani.movtdc  = 5            and
                               plani.etbcod  = estab.etbcod and
                               plani.pladat >= vdti         and
                               plani.pladat <= vdtf         no-error.

                if not avail plani
                then leave.
                recatu1 = recid(plani).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev plani where
                               plani.movtdc  = 5            and
                               plani.etbcod  = estab.etbcod and
                               plani.pladat >= vdti         and
                               plani.pladat <= vdtf         no-error.

                if not avail plani
                then leave.
                recatu1 = recid(plani).
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
            find next plani where
                               plani.movtdc  = 5            and
                               plani.etbcod  = estab.etbcod and
                               plani.pladat >= vdti         and
                               plani.pladat <= vdtf         no-error.

            if not avail plani
            then next.
            color display white/cyan
                plani.numero.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev plani where
                               plani.movtdc  = 5            and
                               plani.etbcod  = estab.etbcod and
                               plani.pladat >= vdti         and
                               plani.pladat <= vdtf         no-error.

            if not avail plani
            then next.
            color display white/cyan
                plani.numero.
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

            if esqcom1[esqpos1] = "Manutencao"
            then do transaction:

                update plani.outras with no-validate frame frame-a.

            end.
            if esqcom1[esqpos1] = "Soma"
            then do:
                do transaction:
                    {juro.i}

                    assign plani.outras = plani.platot + vacfprod.

                    update plani.outras with no-validate frame frame-a.
                end.
            end.
            if esqcom1[esqpos1] = "Total"
            then do:

                vtotori = 0.
                vtotatu = 0.
                for each bplani where bplani.movtdc = 5             and
                                      bplani.etbcod = estab.etbcod  and
                                      bplani.pladat >= vdti         and
                                      bplani.pladat <= vdtf no-lock:

                    vtotori = vtotori + bplani.platot.

                    vtotatu = vtotatu + (if bplani.outras = 0
                                         then bplani.platot
                                         else bplani.outras).

                end.

                disp vtotori label "Total Orig."
                     vtotatu label "Total Atual"
                     with frame ggg centered row 15 side-labels overlay
                     color white/red.

            end.

            if esqcom1[esqpos1] = "Perc"
            then do:
                update vser
                       vperc label "Perc"
                            with frame f-perc centered side-label
                                color black/cyan row 15 overlay.

                for each bplani where bplani.movtdc = 5             and
                                      bplani.etbcod = estab.etbcod  and
                                      bplani.pladat >= vdti         and
                                      bplani.pladat <= vdtf:
                    if bplani.serie <> vser
                    then next.
                    do transaction:
                        bplani.outras = bplani.platot - (bplani.platot *
                                        (vperc / 100)).
                    end.
                end.
                hide frame f-perc no-pause.
                leave.
            end.
            if esqcom1[esqpos1] = "Conf.Mov"
            then do:
                clear frame f-data all.
                do vdata = vdti to vdtf:
                    find first bplani where bplani.movtdc  = 5            and
                                            bplani.etbcod  = estab.etbcod and
                                            bplani.pladat  = vdata
                                                no-lock no-error.
                    if not avail bplani
                    then disp vdata
                              "DOMINGO" when weekday(vdata) = 1
                                with frame f-data down centered.
                    down with frame f-data.
                end.
            end.



            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                /*
                update plani with frame f-altera no-validate.
                */
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp
                plani.pladat
                plani.numero
                plani.serie
                plani.platot
                plani.outras
                with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                /*
                message "Confirma Exclusao de" plani.modnom update sresp.
                if not sresp
                then leave.
                find next plani where
                               plani.movtdc  = 5            and
                               plani.etbcod  = estab.etbcod and
                               plani.pladat >= vdti         and
                               plani.pladat <= vdtf         no-error.

                if not available plani
                then do:
                    find plani where recid(plani) = recatu1.
                    find prev plani where
                               plani.movtdc  = 5            and
                               plani.etbcod  = estab.etbcod and
                               plani.pladat >= vdti         and
                               plani.pladat <= vdtf         no-error.

                end.
                recatu2 = if available plani
                          then recid(plani)
                          else ?.
                find plani where recid(plani) = recatu1.
                delete plani.
                recatu1 = recatu2.
                leave.
                */
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                /*
                message "Confirma Impressao de planiidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each plani:
                    display plani.
                end.
                output close.
                recatu1 = recatu2.
                leave.
                */
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
        do transaction:
        {juro.i}
        end.

        display
        plani.pladat
        plani.numero
        plani.serie
        vacfprod
        plani.platot
        plani.outras
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(plani).
   end.
end.
