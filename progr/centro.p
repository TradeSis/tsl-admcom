/**    MANUTENCAO EM EM CENTROS DE CUSTOS centro.p    **/

{admcab.i}

def var vsenha like func.senha.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bcentro       for centro.
def var vetbcod         like centro.etbcod.

form centro.etbcod colon 18
     centro.RegCod
     centro.etbnom  colon 18
     centro.ufecod   colon 18
     centro.etbinsc   colon 18
     centro.etbcgc     colon 18
     centro.endereco    colon 18
     centro.etbtofne    colon 18
     centro.etbtoffe     colon 18
     centro.munic
     centro.etbserie label "Fone" format "x(15)"
     centro.movndcfim  colon 18
     centro.etbfluxo
     centro.estcota label "N.I.R.C" format "99999999999" colon 18
     centro.etbcon  colon 18 format ">,>>>,>>9.99"
     centro.etbmov  format ">,>>>,>>9.99"   colon 18
     centro.vencota  format "99" label "N.Dias"
             with frame f-altera1 side-label
                    overlay row 6 centered color white/cyan.

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

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first centro where
            true no-error.
    else
        find centro where recid(centro) = recatu1.
        vinicio = no.
    if not available centro
    then do:
        form centro
            with frame f-altera
            overlay row 6 1 column centered color white/cyan.
        message "Cadastro de centroelecimento Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-altera:
                create centro.
                update centro.
                centro.etbnom = caps(centro.etbnom).
                vinicio = yes.
        end.
    end.
    clear frame frame-a all no-pause.
    display centro.etbcod column-label "Codigo"
            centro.etbnom label "Centro de Custo"
            with frame frame-a 14 down centered color white/red.

    recatu1 = recid(centro).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next centro where
                true.
        if not available centro
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio = no
        then
        down with frame frame-a.
    
        display centro.etbcod 
                centro.etbnom with frame frame-a.
                
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find centro where recid(centro) = recatu1.

        choose field centro.etbcod
            go-on(cursor-down cursor-up
                  page-down   page-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return).
        hide message no-pause.
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
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next centro where
                    true no-error.
                if not avail centro
                then leave.
                recatu2 = recid(centro).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev centro where
                    true no-error.
                if not avail centro
                then leave.
                recatu1 = recid(centro).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next centro where
                true no-error.
            if not avail centro
            then next.
            color display white/red
                centro.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev centro where
                true no-error.
            if not avail centro
            then next.
            color display white/red
                centro.etbcod.
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
            then do with frame f-inc side-label centered no-validate.
                
                create centro.
                update centro.etbcod label "Codigo"
                       centro.etbnom label "Centro de Custo".
                centro.etbnom = caps(centro.etbnom).
                recatu1 = recid(centro).
                leave.

            end.
            
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao" or
               esqcom1[esqpos1] = "Listagem"
            then do with frame f-con centered side-label no-validate:
                disp centro.etbcod
                     centro.etbnom.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-alt centered side-label no-validate:
                
                update centro.etbcod
                       centro.etbnom with no-validate.
                       
                centro.etbnom = caps(centro.etbnom).
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera:
                
                message "Confirma Exclusao de" centro.etbnom update sresp.
                if not sresp
                then leave.
                find next centro where true no-error.
                if not available centro
                then do:
                    find centro where recid(centro) = recatu1.
                    find prev centro where true no-error.
                end.
                recatu2 = if available centro
                          then recid(centro)
                          else ?.
                find centro where recid(centro) = recatu1.
                delete centro.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
                message "Confirma Impressao do centroelecimento" update sresp.
                if not sresp
                then LEAVE.
                recatu2 = recatu1.
                output to printer.
                for each centro:
                    display centro.
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
        if keyfunction (lastkey) = "end-error"
         then view frame frame-a.

        display centro.etbcod 
                centro.etbnom with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(centro).
   end.
end.
