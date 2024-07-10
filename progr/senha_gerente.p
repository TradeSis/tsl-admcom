/*
*
*    MANUTENCAO EM ESTABELECIMENTOS                         estab.p    02/05/95
*
*/

{admcab.i }

def var vsenha like func.senha.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 2
            initial["Gera Senha","Etiqueta"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bestab       for estab.
def var vetbcod         like estab.etbcod.

form estab.etbcod colon 18
     estab.RegCod
     estab.etbnom  colon 18
     estab.ufecod   colon 18
     estab.etbinsc   colon 18
     estab.etbcgc     colon 18
     estab.endereco    colon 18
     estab.etbtofne    colon 18
     estab.etbtoffe     colon 18
     estab.munic
     estab.etbserie label "Fone" format "x(15)"
     estab.movndcfim  colon 18
     estab.etbfluxo
     estab.estcota label "N.I.R.C" format "99999999999" colon 18
     estab.etbcon  colon 18 format ">,>>>,>>9.99"
     estab.etbmov  format ">,>>>,>>9.99"   colon 18
     estab.vencota  format "99" label "N.Dias"
             with frame f-altera1 side-label
                    overlay row 6 centered color white/cyan.

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

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first estab where true no-lock no-error.
    else
        find estab where recid(estab) = recatu1 no-lock.
        vinicio = no.
    if not available estab
    then do:
        message "Cadastro de Estabelecimento Vazio".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    display estab.etbcod  column-label "Filial"
            estab.vencota column-label "Senha" format ">>>>99"
            with frame frame-a 14 down centered color white/red.

    recatu1 = recid(estab).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next estab where true no-lock.
        if not available estab
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio = no
        then
        down
            with frame frame-a.
        display
            estab.etbcod
            estab.vencota
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find estab where recid(estab) = recatu1 no-lock.

        choose field estab.etbcod
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
                find next estab where true no-lock no-error.
                if not avail estab
                then leave.
                recatu2 = recid(estab).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev estab where true no-lock no-error.
                if not avail estab
                then leave.
                recatu1 = recid(estab).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next estab where true no-lock no-error.
            if not avail estab
            then next.
            color display white/red
                estab.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev estab where true no-lock no-error.
            if not avail estab
            then next.
            color display white/red
                estab.etbcod.
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

            if esqcom1[esqpos1] = "Gera Senha"
            then do transaction with frame f-altera1 no-validate.
                for each estab where estab.etbcod < 900 and
                        {conv_difer.i estab.etbcod}.
    
                    estab.vencota = int(string(string( int(12345 * 
                                        dec(estab.etbcod / 100))  ) +
                                        string(estab.etbcod))).
            
    
    
                end.
                find estab where estab.etbcod = 1 no-lock.
                recatu1 = recid(estab).

                leave.
                
            end.
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao" or
               esqcom1[esqpos1] = "Listagem"
            then do with frame f-altera1 no-validate:
                disp estab .
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera1 no-validate:
                
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera:
                
            end.
            if esqcom1[esqpos1] = "Etiqueta"
            then do:

                run etiq_gerente.p(input estab.vencota).
                
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
        display
            estab.etbcod
            estab.vencota
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(estab).
   end.
end.
