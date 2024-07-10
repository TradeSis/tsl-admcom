
{admcab.i}


def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
 initial ["Inclusao","Alteracao","Exclusao","Consulta","Procura",""].
def var esqcom2         as char format "x(20)" extent 3
            initial ["Inclui Filho","Inclui Irmao",""].


def buffer clasitesup     for clasite.
def buffer bclasite       for clasite.
def var vclacod         like clasite.clacod.
def var vclasup         like clasite.clasup.


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

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first clasite use-index iclasup where
            true no-error.
    else
        find clasite where recid(clasite) = recatu1.
        vinicio = yes.
    if not available clasite
    then do:
        message "Cadastro de Classes Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do transaction with frame f-inclui1  overlay row 6 1 column centered
            color black/cyan.
                create clasite.
                update clasite.clacod
                       clasite.clanom
                       clasite.clasup.
                do on error undo.
                update clasite.claerp  label "Classe Admcom".
                find first produ where produ.clacod = clasite.claerp
                                       no-lock no-error.
                if not avail produ
                then do:
                    message "Nenhum produto cadastrado com essa classe no ADMCOM." . pause 2 no-message.
                    undo.
                end.             end.

                update clasite.claordem
                       clasite.claimp
                       clasite.clatipo.
                next.
                vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    find clasitesup where clasitesup.clacod = clasite.clasup no-error.
    display
        clasitesup.clacod when avail clasitesup
        clasitesup.clanom when avail clasitesup
        clasite.clacod
        clasite.clanom
        clasite.clatipo
            with frame frame-a 12 down centered color white/red
                title " Classes - Site ".

    recatu1 = recid(clasite).
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
        find next clasite use-index iclasup where
                true.
        if not available clasite
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then
        down
            with frame frame-a.
        find clasitesup where clasitesup.clacod = clasite.clasup no-error.
        display
            clasitesup.clacod when avail clasitesup
            clasitesup.clanom when avail clasitesup
            clasite.clacod
            clasite.clanom
            clasite.clatipo
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find clasite where recid(clasite) = recatu1.

        choose field clasite.clanom
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
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 3
                          then 3
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
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next clasite use-index iclasup where
                true no-error.
            if not avail clasite
            then next.
            color display white/red
                clasite.clanom.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev clasite use-index iclasup where
                true no-error.
            if not avail clasite
            then next.
            color display white/red
                clasite.clanom.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next clasite where true no-error.
                if not avail clasite
                then leave.
                recatu1 = recid(clasite).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev produ where true no-error.
                if not avail clasite
                then leave.
                recatu1 = recid(clasite).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
            hide frame frame-a no-pause.
          form clasite.clacod
               clasite.clanom
               clasite.claordem
               clasite.clasup
               clasite.claerp  label "Classe Admcom"
               clasite.claimp
               clasite.clatipo
               with frame f-altera color black/cyan.
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do on error undo
                    with frame f-altera overlay row 6 centered 1 column.
                
                 
                create clasite.
                
                find last bclasite use-index iclacod no-lock no-error.
                if not avail bclasite
                then clasite.clacod = 1.
                else clasite.clacod = bclasite.clacod + 1.
                

                update clasite.clacod
                       clasite.clanom
                       clasite.claordem
                       clasite.clasup.

                do on error undo.
                update clasite.claerp  label "Classe Admcom".
                find first produ where produ.clacod = clasite.claerp
                                       no-lock no-error.
                if not avail produ
                then do:
                    message "Nenhum produto cadastrado com essa classe no ADMCOM." . pause 2 no-message.
                    undo.
                end.             end.
                       
                update       clasite.claimp clasite.clatipo.
                recatu1 = recid(clasite).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera.
                display clasite.clacod.
                do transaction:
                    update clasite.clacod
                           clasite.clanom
                           clasite.claordem
                           clasite.clasup .
                           
                do on error undo.
                update clasite.claerp  label "Classe Admcom" with frame f-altera.
                find first produ where produ.clacod = clasite.claerp
                                       no-lock no-error.
                if not avail produ
                then do:
                    message "Nenhum produto cadastrado com essa classe no ADMCOM." . pause 2 no-message.
                    undo.
                end.             end.

                           update clasite.claimp clasite.clatipo
                           with frame f-altera .
                update clasite.claper label "Estoque Minimo"
                with frame f-altera.
                end.

            end.
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera:
                displa clasite.clacod
                       clasite.clanom
                       clasite.claordem
                       clasite.clasup
                       clasite.claerp  label "Classe Admcom"
                       clasite.claimp
                       clasite.clatipo
                       clasite.claper label "Estoque minimo".
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera:
                message "Confirma Exclusao de" clasite.clanom update sresp.
                if not sresp
                then leave.
                find next clasite use-index iclasup where true no-error.
                if not available clasite
                then do:
                    find clasite where recid(clasite) = recatu1.
                    find prev clasite use-index iclasup where true no-error.
                end.
                recatu2 = if available clasite
                          then recid(clasite)
                          else ?.
                find clasite where recid(clasite) = recatu1.
                do transaction:
                    delete clasite.
                end.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-procura row 6 centered.
                update vclacod label "Classe".
                find clasite where clasite.clacod = vclacod no-lock no-error.
                if avail clasite
                then recatu1 = recid(clasite).
                else do:
                    message "Classe nao encontrada". 
                    pause.
                end.
                
                leave.
            end. 
            /***
            if esqcom1[esqpos1] = "Venda Adic."
            then do with frame f-venda row 6 centered.
            
                find first bclasite where 
                           bclasite.clasup = clasite.clacod no-lock no-error.
                if avail bclasite
                then do:
                    message "Classe Invalida".
                    pause.
                    undo, retry.
                end.
                hide frame f-com1 no-pause.
                run adicla.p (input clasite.clacod).                
                
                leave.
                
            end.
            ***/

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            if esqcom2[esqpos2] = "Inclui Filho"
            then do transaction with frame f-altera.
                vclasup = clasite.clacod.
                create clasite.
                clasite.clasup = vclasup.

                find last bclasite use-index iclacod no-lock no-error.
                if not avail bclasite
                then clasite.clacod = 1.
                else clasite.clacod = bclasite.clacod + 1.
                
                
                update clasite.CLACOD
                       clasite.clanom
                       clasite.claordem
                       clasite.claimp
                       clasite.clasup
                       clasite.claerp  label "Classe Admcom"
                       clasite.clatipo.
                recatu1 = recid(clasite).
                leave.
            end.
            if esqcom2[esqpos2] = "Inclui Irmao"
            then do transaction with frame f-altera.
                vclasup = clasite.clasup.
                create clasite.
                clasite.clasup = vclasup.

                find last bclasite use-index iclacod no-lock no-error.
                if not avail bclasite
                then clasite.clacod = 1.
                else clasite.clacod = bclasite.clacod + 1.
                

                
                update clasite.CLACOD
                       clasite.clanom
                       clasite.claordem
                       clasite.claimp
                       clasite.clasup
                       clasite.claerp  label "Classe Admcom"
                       clasite.clatipo.
                recatu1 = recid(clasite).
                leave.
            end.
          end.
          view frame frame-a.
        end.
         if keyfunction(lastkey) = "end-error"
         then view frame frame-a.
        find clasitesup where clasitesup.clacod = clasite.clasup no-error.
        display
            clasitesup.clacod when avail clasitesup
            clasitesup.clanom when avail clasitesup
                clasite.clacod
                clasite.clanom
                clasite.clatipo
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(clasite).
   end.
end.
