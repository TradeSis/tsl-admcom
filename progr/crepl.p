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
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bcrecod      for crepl.
def var vcrecod         like crepl.crecod.
    form
     credias[1]  label "dias"  colon 10 creperc[1]  label "parcelas" colon 30
        credias[2]  no-label      colon 12 creperc[2]  no-label      colon 32
        credias[3]  no-label      colon 12 creperc[3]  no-label      colon 32
        credias[4]  no-label      colon 12 creperc[4]  no-label      colon 32
        credias[5]  no-label      colon 12 creperc[5]  no-label      colon 32
        credias[6]  no-label      colon 12 creperc[6]  no-label      colon 32
        credias[7]  no-label      colon 12 creperc[7]  no-label      colon 32
        credias[8]  no-label      colon 12 creperc[8]  no-label      colon 32
        credias[9]  no-label      colon 12 creperc[9]  no-label      colon 32
        credias[10] no-label      colon 12 creperc[10] no-label      colon 32
        with frame inclu2 overlay side-label .
    form
        esqcom1
            with frame f-com1
                 row 4 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

def var vtipo as char label "Tipo".
def var vtipo-antes as char.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first crepl where
            true no-error.
    else
        find crepl where recid(crepl) = recatu1.
        vinicio = yes.
    if not available crepl
    then do:
        message "Cadastro de Planos de Pgt. p/ Crediario Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 centered.
                create crepl.
                update crecod
                       crenom
                       cresit
           with frame inclui2  overlay row 6 2 column centered.
                update credias
                       creperc.
                       vinicio = no.
        end.
    end.
    run find-biz.
    clear frame frame-a all no-pause.
    display
        crepl.crecod format "9999"
        crepl.crenom
        crepl.cresit
        vtipo no-label
            with frame frame-a 12 down centered.

    recatu1 = recid(crepl).
    if esqregua
    then do:
        display esqcom1[esqpos1] with frame f-com1.
        color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
        find next crepl where
                true.
        if not available crepl
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then
        down
            with frame frame-a.
        run find-biz.
        display
            crepl.crecod format "9999"
            crepl.crenom
            crepl.cresit
            vtipo
                with frame frame-a .
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find crepl where recid(crepl) = recatu1.

        choose field crepl.crecod
            go-on(cursor-down cursor-up
                  page-down page-up
                  cursor-left cursor-right
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
                find next crepl where true no-error.
                if not avail crepl
                then leave.
                recatu1 = recid(crepl).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev crepl where true no-error.
                if not avail crepl
                then leave.
                recatu1 = recid(crepl).
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
            find next crepl where
                true no-error.
            if not avail crepl
            then next.
            color display normal
                crepl.crecod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev crepl where
                true no-error.
            if not avail crepl
            then next.
            color display normal
                crepl.crecod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.
          form with frame f-altera.
          form with frame f-altera1 centered.
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-altera overlay row 6 2 col centered:
                create crepl.
                update crepl.crecod format "9999"
                       crepl.crenom
                       crepl.cresit.
                update crepl.credias[1] label "DIAS"        colon 8
                       crepl.creperc[1] label "PERCENTUAL" colon 28
                       crepl.credias[2] colon 10
                       crepl.creperc[2] colon 30
                       crepl.credias[3] colon 10
                       crepl.creperc[3] colon 30
                       crepl.credias[4] colon 10
                       crepl.creperc[4] colon 30
                       crepl.credias[5] colon 10
                       crepl.creperc[5] colon 30
                       crepl.credias[6] colon 10
                       crepl.creperc[6] colon 30
                       crepl.credias[7] colon 10
                       crepl.creperc[7] colon 30
                       crepl.credias[8] colon 10
                       crepl.creperc[8] colon 30
                       crepl.credias[9] colon 10
                       crepl.creperc[9] colon 30
                     with frame f-altera1 side-labels no-labels
                        title string(crepl.crecod) + "/" + crepl.crenom.
                recatu1 = recid(crepl).
                leave.
              end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera:
                run find-biz.
                vtipo-antes = vtipo.
                disp vtipo.
                update crepl.crecod format "9999"
                       crepl.crenom
                       crepl.cresit
                       .
                repeat:       
                   update vtipo label "Tipo" 
                       help "Informe se plano BIZ".
                   if vtipo <> "BIZ" and
                      vtipo <> ""
                   then do:
                        bell.
                        message color red/with
                            "Tipo invalido."
                            view-as alert-box.
                        next.    
                   end.
                   leave.
                end.
                if keyfunction(lastkey) = "END-ERROR"
                then undo.
                
                find first tabaux where 
                           tabaux.tabela = "PLANOBIZ" and
                           tabaux.valor_campo = string(crepl.crecod) 
                           no-error.
                if not avail tabaux and
                    vtipo = "BIZ"
                then do:
                    create tabaux.
                    assign
                        tabaux.tabela = "PLANOBIZ"
                        tabaux.valor_campo = string(crepl.crecod)
                        tabaux.datexp = today
                        .
                end.
                else if avail tabaux and
                    vtipo = ""
                then do:
                    delete tabaux.
                end.
                update crepl.credias[1] crepl.creperc[1]
                       crepl.credias[2] crepl.creperc[2]
                       crepl.credias[3] crepl.creperc[3]
                       crepl.credias[4] crepl.creperc[4]
                       crepl.credias[5] crepl.creperc[5]
                       crepl.credias[6] crepl.creperc[6]
                       crepl.credias[7] crepl.creperc[7]
                       crepl.credias[8] crepl.creperc[8]
                       crepl.credias[9] crepl.creperc[9]
                        with frame f-altera1.
            end.
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera:
                displa crepl.credias[1] crepl.creperc[1]
                       crepl.credias[2] crepl.creperc[2]
                       crepl.credias[3] crepl.creperc[3]
                       crepl.credias[4] crepl.creperc[4]
                       crepl.credias[5] crepl.creperc[5]
                       crepl.credias[6] crepl.creperc[6]
                       crepl.credias[7] crepl.creperc[7]
                       crepl.credias[8] crepl.creperc[8]
                       crepl.credias[9] crepl.creperc[9]
                        with frame f-altera1.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" crepl.crenom update sresp.
                if not sresp
                then leave.
                find next crepl where true no-error.
                if not available crepl
                then do:
                    find crepl where recid(crepl) = recatu1.
                    find prev crepl where true no-error.
                end.
                recatu2 = if available crepl
                          then recid(crepl)
                          else ?.
                find crepl where recid(crepl) = recatu1.
                delete crepl.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de Plan. de Pgt." update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each crepl:
                    display crepl.
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
          view frame frame-a.
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        run find-biz.
        display
                crepl.crecod format "9999"
                crepl.crenom
                crepl.cresit
                vtipo
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(crepl).
   end.
end.

procedure find-biz:

    find first tabaux where tabaux.tabela = "PLANOBIZ" and
               tabaux.valor_campo = string(crepl.crecod) no-lock no-error.
    if avail tabaux
    then vtipo = "BIZ".
    else vtipo = "".            
    
end procedure 
