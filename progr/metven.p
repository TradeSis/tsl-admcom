/*
*
*    Esqueletao de Programacao
*
*/

{admcab.i}

def var vclacod like clase.clacod.

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


def buffer bmetven       for metven.
def var vetbcod         like metven.etbcod.
def var vforcod like forne.forcod.
def var vmes  like metven.metmes.
def var vano  like metven.metano.



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

    assign vforcod = 5027
           vano    = year(today)
           vmes    = month(today).
           
    update vforcod label "Fornecedor" with frame f-forne side-label
                    width 80 row 4 no-box color message.
    if vforcod <> 0
    then do:
        find forne where forne.forcod = vforcod no-lock no-error.
        if not avail forne
        then do:
            message "Fornecedor nao cadastrado.".
            undo, retry.
        end.
        else display forne.fornom no-label with frame f-forne.
    end.
    else disp "Geral" @ forne.fornom with frame f-forne.
    
    update vano label "Ano"
           vmes label "Mes" with frame f-forne.

    do on error undo:

        update vclacod label "Classe...."
               with frame f-forne.
        if vclacod <> 0
        then do:
            find clase where clase.clacod = vclacod no-lock no-error.
            if not avail clase
            then do:
                message "Classe nao cadastrada.".
                undo.
            end.
            else disp clase.clanom no-label with frame f-forne.
        end.
    end.    
    
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first metven where metven.forcod = vforcod      and
                                 metven.clacod = vclacod      and
                                 metven.metano = vano         and
                                 metven.metmes = vmes no-error.
    else find metven where recid(metven) = recatu1.
   
    vinicio = yes.
    
    if not available metven
    then do:
        message "Cadastro de metas Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create metven.
                update metven.etbcod
                       metven.metval.

                assign metven.forcod = vforcod
                       metven.clacod = vclacod
                       metven.metano = vano  
                       metven.metmes = vmes.

                
          vinicio = no.
        end.
    end.

    clear frame frame-a all no-pause.
    pause 0.

    display
        metven.etbcod
        metven.metval format ">>>,>>9.99"
            with frame frame-a 13 down centered row 6 width 30.

    recatu1 = recid(metven).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next metven where metven.forcod = vforcod      and
                               metven.clacod = vclacod      and
                               metven.metano = vano         and
                               metven.metmes = vmes  no-error.
        if not available metven
        then leave.

        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        if vinicio
        then down
            with frame frame-a.
        
        display
            metven.etbcod
            metven.metval
                with frame frame-a.
    end.
    
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find metven where recid(metven) = recatu1.

        choose field metven.etbcod
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
                find next metven where metven.forcod = vforcod and
                                       metven.clacod = vclacod      and
                                       metven.metano = vano         and
                                       metven.metmes = vmes no-error.
                if not avail metven
                then leave.
                recatu1 = recid(metven).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev metven where metven.forcod = vforcod and
                                       metven.clacod = vclacod      and
                                       metven.metano = vano         and
                                       metven.metmes = vmes no-error.
                if not avail metven
                then leave.
                recatu1 = recid(metven).
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
            find next metven where metven.forcod = vforcod and
                                   metven.clacod = vclacod      and
                                   metven.metano = vano         and
                                   metven.metmes = vmes no-error.
            if not avail metven
            then next.
            color display normal
                metven.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev metven where metven.forcod = vforcod and
                                   metven.clacod = vclacod      and
                                   metven.metano = vano         and
                                   metven.metmes = vmes no-error.
            if not avail metven
            then next.
            color display normal
                metven.etbcod.
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
                create metven.
                update metven.etbcod
                       metven.metval format ">>>,>>9.99".

                assign metven.forcod = vforcod
                       metven.clacod = vclacod
                       metven.metano = vano  
                       metven.metmes = vmes.

                recatu1 = recid(metven).
                leave.
            end.

            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                display metven.etbcod.
                update  metven.metval format ">>>,>>9.99"
                        with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp metven with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" metven.forcod update sresp.
                if not sresp
                then leave.
                find next metven where metven.forcod = vforcod and
                                       metven.clacod = vclacod      and
                                       metven.metano = vano         and
                                       metven.metmes = vmes no-error.
                if not available metven
                then do:
                    find metven where recid(metven) = recatu1.
                    find prev metven where metven.forcod = vforcod and
                                           metven.clacod = vclacod      and
                                           metven.metano = vano         and
                                           metven.metmes = vmes no-error.
                end.
                
                recatu2 = if available metven
                          then recid(metven)
                          else ?.
                find metven where recid(metven) = recatu1.
                delete metven.
                recatu1 = recatu2.
                leave.
            end.
            
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de metvenidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each metven:
                    display metven.
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
        
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.

        display
                metven.etbcod
                metven.metval
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(metven).
   end.
end.
