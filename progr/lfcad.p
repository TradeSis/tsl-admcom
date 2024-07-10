/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var vemp like estab.etbcod.
def var vnum like lfcad.codigo.
def var vetb like lfcad.empcod.
def var vempcod         like lfcad.empcod.
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


def buffer blfcad       for lfcad.
def buffer clfcad       for lfcad.
def buffer dlfcad       for lfcad.
def var vcodigo         like lfcad.codigo.


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
        find first lfcad where
            true no-error.
    else
        find lfcad where recid(lfcad) = recatu1.
    vinicio = yes.
    if not available lfcad
    then do:
        message "Cadastro de lfcadidades de Tit. Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create lfcad.
                update lfcad.
          vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        lfcad.codigo
        lfcad.nome
        lfcad.cgc
        lfcad.empcod
            with frame frame-a 14 down centered.

    recatu1 = recid(lfcad).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next lfcad where
                true.
        if not available lfcad
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
            lfcad.codigo
            lfcad.nome
            lfcad.cgc
            lfcad.empcod
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find lfcad where recid(lfcad) = recatu1.

        choose field lfcad.codigo
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
                find next lfcad where true no-error.
                if not avail lfcad
                then leave.
                recatu1 = recid(lfcad).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev lfcad where true no-error.
                if not avail lfcad
                then leave.
                recatu1 = recid(lfcad).
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
            find next lfcad where
                true no-error.
            if not avail lfcad
            then next.
            color display normal
                lfcad.codigo.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev lfcad where
                true no-error.
            if not avail lfcad
            then next.
            color display normal
                lfcad.codigo.
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
                create lfcad.
                update lfcad.
                for each estab no-lock.
                    
                    vemp = estab.etbcod.
                    if estab.etbcod = 1
                    then vemp = 50.
                    if estab.etbcod = 996
                    then vemp = 54. 
                    if estab.etbcod = 997 
                    then vemp = 51. 
                    if estab.etbcod = 998 
                    then vemp = 53. 
                    if estab.etbcod = 999 
                    then vemp = 52.



                    find first blfcad where blfcad.empcod = vemp and
                                            blfcad.cgc    = lfcad.cgc no-error.
                    if not avail blfcad
                    then do:
                        find last clfcad use-index lfcad
                            where clfcad.empcod = vemp no-error.
                        if not avail clfcad
                        then vnum = 1.
                        else vnum = clfcad.codigo + 1.
                        create dlfcad.
                        assign dlfcad.Codigo    = vnum 
                               dlfcad.Nome      = lfcad.Nome 
                               dlfcad.Ender     = lfcad.Ender 
                               dlfcad.Municipio = lfcad.Municipio 
                               dlfcad.Cep       = lfcad.Cep 
                               dlfcad.Uf        = lfcad.Uf 
                               dlfcad.Cgc       = lfcad.Cgc 
                               dlfcad.Insc      = lfcad.Insc 
                               dlfcad.Ativ-Econ = lfcad.Ativ-Econ 
                               dlfcad.Contrib   = lfcad.Contrib 
                               dlfcad.Cod-Cont  = lfcad.Cod-Cont 
                               dlfcad.Flag-Cont = lfcad.Flag-Cont 
                               dlfcad.empcod    = vemp.
                    end.
                end.                                   
                    
                recatu1 = recid(lfcad).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update lfcad with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp lfcad with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" lfcad.nome update sresp.
                if not sresp
                then leave.
                find next lfcad where true no-error.
                if not available lfcad
                then do:
                    find lfcad where recid(lfcad) = recatu1.
                    find prev lfcad where true no-error.
                end.
                recatu2 = if available lfcad
                          then recid(lfcad)
                          else ?.
                find lfcad where recid(lfcad) = recatu1.
                delete lfcad.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-Lista overlay row 6 1 column centered.
                recatu2 = recatu1.
                update vcodigo
                       vetb with frame f-pro centered side-label.
                find last lfcad where lfcad.codigo = vcodigo and
                                      lfcad.empcod = vetb
                                no-lock no-error.
                if avail lfcad
                then recatu1 = recid(lfcad).
                else recatu1 = recatu2.
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
                lfcad.codigo
                lfcad.nome
                lfcad.cgc
                lfcad.empcod
                        with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(lfcad).
   end.
end.
