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
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer brepre       for repre.
def var vrepcod         like repre.repcod.


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
        find first repre where
            true no-error.
    else
        find repre where recid(repre) = recatu1.
        vinicio = yes.
    if not available repre
    then do:
        message "Cadastro de reprecedores Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  row 4  centered .
                create repre.
                find last brepre exclusive-lock no-error.
                if available brepre
                then assign vrepcod = brepre.repcod + 1.
                else assign vrepcod = 1.
                assign repre.repcod = vrepcod.

                disp repre.repcod    label "Codigo......." skip.
                update repre.empresa   label "Empresa......" skip(1)
                       repre.repnom    label "Representante" skip 
                       repre.celular   label "Celular......" 
                       repre.fone      label "Telefone..." format ">>>>>>>>9"  at 40 skip
                       repre.email     label "e-mail......." skip
                       repre.repcon    label "Contato......" skip(1)
                       repre.repend    label "Endereco....." skip
                       repre.numero    label "Numero......."
                       repre.comp      label "Complemento"   at 40 skip
                       repre.cidade    label "Cidade......." skip
                       repre.cep       label "Cep.........." skip(1)
                       repre.repger    label "Gerente Venda" skip
                       repre.celger    label "Celular......"
                       repre.fonger    label "Telefone..."   at 40
                       WITH OVERLAY SIDE-LABELS color white/red.

        vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        repre.repcod
        repre.repnom
            with frame frame-a 13 down centered.

    recatu1 = recid(repre).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next repre where
                true.
        if not available repre
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then
        down
            with frame frame-a.
        display
            repre.repcod
            repre.repnom
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find repre where recid(repre) = recatu1.

        choose field repre.repcod repre.repnom
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
                find next repre where true no-error.
                if not avail repre
                then leave.
                recatu1 = recid(repre).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev repre where true no-error.
                if not avail repre
                then leave.
                recatu1 = recid(repre).
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
            find next repre where
                true no-error.
            if not avail repre
            then next.
            color display normal
                repre.repcod repre.repnom.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev repre where
                true no-error.
            if not avail repre
            then next.
            color display normal
                repre.repcod repre.repnom.
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
            then do with frame f-inclui
                        row 4  centered OVERLAY 2 COLUMNS SIDE-LABELS.
                create repre.
                find last brepre exclusive-lock no-error.
                if available brepre
                then assign vrepcod = brepre.repcod + 1.
                else assign vrepcod = 1.
                assign repre.repcod = vrepcod.

                disp repre.repcod    label "Codigo......." skip.
                update repre.empresa   label "Empresa......" skip(1)
                       repre.repnom    label "Representante" skip 
                       repre.celular   label "Celular......" 
                       repre.fone      label "Telefone..." format ">>>>>>>>9"  at 40 skip
                       repre.email     label "e-mail......." skip
                       repre.repcon    label "Contato......" skip(1)
                       repre.repend    label "Endereco....." skip
                       repre.numero    label "Numero......."
                       repre.comp      label "Complemento"   at 40 skip
                       repre.cidade    label "Cidade......." skip
                       repre.cep       label "Cep.........." skip(1)
                       repre.repger    label "Gerente Venda" skip
                       repre.celger    label "Celular......"
                       repre.fonger    label "Telefone..."   at 40
                       
                       
                       WITH OVERLAY SIDE-LABELS color white/red.

                recatu1 = recid(repre).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera
                        row 4  centered OVERLAY 2 COLUMNS SIDE-LABELS.
                        
                disp repre.repcod    label "Codigo......." skip.
                update repre.empresa   label "Empresa......" skip(1)
                       repre.repnom    label "Representante" skip 
                       repre.celular   label "Celular......" 
                       repre.fone      label "Telefone..." format ">>>>>>>>9"  at 40 skip
                       repre.email     label "e-mail......." skip
                       repre.repcon    label "Contato......" skip(1)
                       repre.repend    label "Endereco....." skip
                       repre.numero    label "Numero......."
                       repre.comp      label "Complemento"   at 40 skip
                       repre.cidade    label "Cidade......." skip
                       repre.cep       label "Cep.........." skip(1)
                       repre.repger    label "Gerente Venda" skip
                       repre.celger    label "Celular......"
                       repre.fonger    label "Telefone..."   at 40.
                
                
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta
                        row 4  centered OVERLAY 2 COLUMNS SIDE-LABELS.

                disp   repre.repcod    label "Codigo......." skip
                       repre.empresa   label "Empresa......" skip(1)
                       repre.repnom    label "Representante" skip 
                       repre.celular   label "Celular......" 
                       repre.fone      label "Telefone..."   at 40 skip
                       repre.email     label "e-mail......." skip
                       repre.repcon    label "Contato......" skip(1)
                       repre.repend    label "Endereco....." skip
                       repre.numero    label "Numero......."
                       repre.comp      label "Complemento"   at 40 skip
                       repre.cidade    label "Cidade......." skip
                       repre.cep       label "Cep.........." skip(1)
                       repre.repger    label "Gerente Venda" skip
                       repre.celger    label "Celular......"
                       repre.fonger    label "Telefone..."   at 40
                       with frame f-consulta no-validate.
                
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui
                        row 4  centered OVERLAY 2 COLUMNS SIDE-LABELS.
                message "Confirma Exclusao de" repre.repnom update sresp.
                if not sresp
                then leave.
                find next repre where true no-error.
                if not available repre
                then do:
                    find repre where recid(repre) = recatu1.
                    find prev repre where true no-error.
                end.
                recatu2 = if available repre
                          then recid(repre)
                          else ?.
                find repre where recid(repre) = recatu1.
                delete repre.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-Lista overlay row 6 1 column centered.
                update vrepcod with frame f-for centered row 15 overlay.
                find repre where repre.repcod = vrepcod no-lock.
                recatu1 = recid(repre).
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
                repre.repcod
                repre.repnom
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(repre).
   end.
end.
