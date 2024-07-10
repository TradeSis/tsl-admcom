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
        initial ["Inclusao","Alteracao","Exclusao","Consulta","Cod.Contabil"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Por Setor","","","",""].


def buffer bforaut       for foraut.
def var vsetcod         like foraut.setcod.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels centered.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

def var p-setor like foraut.setcod.


def var vforautnom like foraut.fornom. 
bl-princ:
repeat:


    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then
        find first foraut where
           (if p-setor > 0
            then foraut.setcod = p-setor else  true) no-error.
    else
        find foraut where recid(foraut) = recatu1.
    vinicio = yes.
    if not available foraut
    then do:
        message "Cadastro de fornecedores Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
            create foraut.
            update foraut.setcod 
                   foraut.forcod 
                   foraut.modcod 
                   foraut.autlp.
            find forne where forne.forcod = foraut.forcod no-lock.
            foraut.fornom = forne.fornom.
            vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    find setaut where setaut.setcod = foraut.setcod no-lock no-error.
    find forne where forne.forcod = foraut.forcod no-lock no-error.
    display
        foraut.setcod
        setaut.setnom format "x(15)"
        foraut.forcod column-label "Codigo"
        forne.fornom  column-label "Nome" format "x(30)"
        foraut.modcod column-label "Mod"
        foraut.autlp
            with frame frame-a 13 down centered.

    recatu1 = recid(foraut).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next foraut where 
            (if p-setor > 0 
             then foraut.setcod = p-setor else true).
        if not available foraut
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        find setaut where setaut.setcod = foraut.setcod no-lock no-error.
        find forne where forne.forcod = foraut.forcod no-lock no-error.


        display foraut.setcod 
                setaut.setnom
                foraut.forcod 
                forne.fornom
                foraut.modcod 
                foraut.autlp
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find foraut where recid(foraut) = recatu1.

        run color-message.
        message "Tecle P para procura ou F4 para sair.".
        choose field foraut.setcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return p P)
                  .

        run color-normal.
        if keyfunction(lastkey) = "p"
        then do:
            pause 0.
            run zforaut.p.

            find first foraut where 
                        (if p-setor > 0
                         then foraut.setcod = p-setor else true) and
                         foraut.forcod = int(sretorno)
                         no-lock no-error.
            if avail foraut
            then recatu1 = recid(foraut).
            else do:
                bell.
                if p-setor > 0
                then 
                message color red/with
                "Nao encontrado no setor " p-setor
                view-as alert-box.
                else  
                message color red/with
                "Nao encontrado no setor " 
                view-as alert-box.
                recatu1 = ?.
            end.          
            sretorno = "".  
            next bl-princ. 
        end.
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
                find next foraut where 
                    (if p-setor > 0
                     then foraut.forcod = p-setor else true) no-error.
                if not avail foraut
                then leave.
                recatu1 = recid(foraut).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev foraut where 
                    (if p-setor > 0
                     then foraut.setcod = p-setor else true) no-error.
                if not avail foraut
                then leave.
                recatu1 = recid(foraut).
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
            find next foraut where
               (if p-setor > 0
                then foraut.setcod = p-setor else true) no-error.
            if not avail foraut
            then next.
            color display normal
                foraut.setcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev foraut where
                (if p-setor > 0
                 then foraut.setcod = p-setor else true) no-error.
            if not avail foraut
            then next.
            color display normal
                foraut.setcod.
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
            then do with frame f-inclui overlay row 6 centered side-label.
                create foraut.
                do on error undo, retry:
                    update foraut.setcod at 5.
                    find setaut where setaut.setcod = foraut.setcod 
                                no-lock no-error.
                    if not avail setaut
                    then do:
                        message "Setor nao cadastrado". 
                        undo, retry.
                    end.
                    display setaut.setnom no-label.            
                end.
                
                do on error undo, retry:
                
                    update foraut.forcod at 5.
                
                    find forne where forne.forcod = foraut.forcod 
                            no-lock no-error.
                    if not avail forne
                    then do:
                        message "Fornecedor nao cadastrado".
                        undo, retry.
                    end.
                    display forne.fornom no-label.
                    foraut.fornom = forne.fornom.
                end.
                do on error undo, retry:
                    update foraut.modcod at 5.
                    find modal where modal.modcod = foraut.modcod 
                                                        no-lock no-error.
                    if not avail modal
                    then do:
                        message "Modalidade nao cadastrada".
                        undo, retry.
                    end.
                    display modal.modnom no-label.
                end.
                update foraut.autlp  at 5.
                recatu1 = recid(foraut).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 centered side-label.
                do on error undo, retry:
                    update foraut.setcod at 5.
                    find setaut where setaut.setcod = foraut.setcod 
                                no-lock no-error.
                    if not avail setaut
                    then do:
                        message "Setor nao cadastrado". 
                        undo, retry.
                    end.
                    display setaut.setnom no-label.            
                end.
                
                do on error undo, retry:
                
                    update foraut.forcod at 5.
                
                    find forne where forne.forcod = foraut.forcod 
                            no-lock no-error.
                    if not avail forne
                    then do:
                        message "Fornecedor nao cadastrado".
                        undo, retry.
                    end.
                    display forne.fornom no-label.
                    foraut.fornom = forne.fornom.
                
                end.
                
                do on error undo, retry:
                    update foraut.modcod at 5.
                    find modal where modal.modcod = foraut.modcod 
                                                        no-lock no-error.
                    if not avail modal
                    then do:
                        message "Modalidade nao cadastrada".
                        undo, retry.
                    end.
                    display modal.modnom no-label.
                end.
                update foraut.autlp at 5.

            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp foraut 
                
                with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" foraut.forcod update sresp.
                if not sresp
                then leave.
                find next foraut where 
                    (if p-setor > 0
                     then foraut.setcod = p-setor else true) no-error.
                if not available foraut
                then do:
                    find foraut where recid(foraut) = recatu1.
                    find prev foraut where 
                        (if p-setor > 0 
                         then foraut.setcod = p-setor else true) no-error.
                end.
                recatu2 = if available foraut
                          then recid(foraut)
                          else ?.
                find foraut where recid(foraut) = recatu1.
                delete foraut.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Cod.Contabil"
            then do:
                if foraut.autlp
                then do:
                
                    message "Fornecedor cadastrado para LP".
                    pause.
                    undo, retry.
                    
                end.
                run lanaut.p (input foraut.forcod).
                
                leave.
            end.

          end.
          else do:
            view frame frame-a.
            pause 0.
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            if esqcom2[esqpos2] = "Por Setor"
            then do:
                update p-setor     label "Setor"
                with frame f-setor 
                    1 down centered row 10 side-label
                    color message overlay.
                recatu1 = ?.
                next bl-princ.    
            end. 
          end.
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.

        find setaut where setaut.setcod = foraut.setcod no-lock no-error.
        find forne where forne.forcod = foraut.forcod no-lock no-error.

          
        display foraut.setcod 
                setaut.setnom
                foraut.forcod 
                forne.fornom
                foraut.modcod 
                foraut.autlp
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(foraut).
   end.
end.

procedure color-message.
color display message
        foraut.setcod
        setaut.setnom
        foraut.forcod
        forne.fornom
        foraut.modcod
        foraut.autlp
            with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        foraut.setcod
        setaut.setnom
        foraut.forcod
        forne.fornom
        foraut.modcod
        foraut.autlp
            with frame frame-a.
end procedure.

