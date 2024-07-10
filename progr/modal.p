/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

ON F7 help.

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


def var varquivo as char.
def buffer bmodal       for modal.
def var vmodcod         like modal.modcod.


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
        find first modal where
            true no-error.
    else
        find modal where recid(modal) = recatu1.
    pause 0.    
    vinicio = yes.
    if not available modal
    then do:
        message "Cadastro de Modalidades de Tit. Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create modal.
                update modnom
                       modcod.
          vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    find first lanaut where lanaut.etbcod = ? and
                            lanaut.forcod = ? and
                            lanaut.modcod = modal.modcod
                            no-lock no-error.
    display
        modal.modcod
        modal.modnom format "x(30)"
        lanaut.lancod when avail lanaut
        lanaut.lanhis when avail lanaut
            with frame frame-a 14 down centered.

    recatu1 = recid(modal).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next modal where
                true.
        if not available modal
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find first lanaut where lanaut.etbcod = ? and
                            lanaut.forcod = ? and
                            lanaut.modcod = modal.modcod
                            no-lock no-error.
        display
           modal.modcod
            modal.modnom
            lanaut.lancod when avail lanaut
            lanaut.lanhis when avail lanaut
            with frame frame-a 14 down centered.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find modal where recid(modal) = recatu1.

        run color-message.
        choose field modal.modcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return F7 PF7).
        if keyfunction(lastkey) = "HELP"
        then do:
            sretorno = "".
            run zmodal.p.
            find modal where modal.modcod = sretorno no-lock no-error.
            if avail modal and sretorno <> ""
            then do:
                recatu1 = recid(modal).
                next bl-princ.
            end.
        end.          
        run color-normal.
        
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
                find next modal where true no-error.
                if not avail modal
                then leave.
                recatu1 = recid(modal).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev modal where true no-error.
                if not avail modal
                then leave.
                recatu1 = recid(modal).
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
            find next modal where
                true no-error.
            if not avail modal
            then next.
            color display normal
                modal.modcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev modal where
                true no-error.
            if not avail modal
            then next.
            color display normal
                modal.modcod.
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
                
                prompt-for modal.modnom
                        modal.modcod.
                find first modal where 
                        modal.modcod = input frame f-inclui modal.modcod
                                no-lock no-error.
                if avail modal
                then do:
                    bell.
                    message color red/with
                        "Modalidade ja existe com codigo " 
                        input frame f-inclui modal.modcod
                        view-as alert-box
                        .
                    undo, retry.    
                end.            
                find first modal where 
                        modal.modnom = input frame f-inclui modal.modnom
                                no-lock no-error.
                if avail modal
                then do:
                    bell.
                    message color red/with
                        "Modalidade ja existe com nome " 
                        input frame f-inclui modal.modnom
                        view-as alert-box
                        .
                    undo, retry.    

                end.
                         
                create modal.
                assign
                    modal.modnom = input frame f-inclui modal.modnom
                    modal.modcod = input frame f-inclui modal.modcod 
                    .

                find first lanaut where lanaut.etbcod = ? and
                                        lanaut.forcod = ? and
                                        lanaut.modcod = modal.modcod
                                        no-error.
                if not avail lanaut
                then do:
                    create lanaut.   
                    lanaut.modcod = modal.modcod.   
                    lanaut.etbcod = ?.
                    lanaut.forcod = ?.                  
                end.
                /*
                update lanaut.lancod lanaut.lanhis with frame f-inclui.
                if lanaut.lancod = 0
                then do:
                    bell.
                    message color red/with
                        "Codigo para lancamento contabil obrigatorio"
                        view-as alert-box .
                    recatu1 = recatu2.    
                    undo.
                end.
                */
                recatu1 = recid(modal).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update modal with frame f-altera no-validate.
                find first lanaut where lanaut.etbcod = ? and
                                        lanaut.forcod = ? and
                                        lanaut.modcod = modal.modcod
                                        no-error.
                if not avail lanaut
                then do:
                    create lanaut.   
                    lanaut.modcod = modal.modcod. 
                    lanaut.etbcod = ?.
                    lanaut.forcod = ?.                    
                end.
                update lanaut.lancod lanaut.lanhis with frame f-altera.
                if lanaut.lancod = 0
                then /*do:
                    bell.
                    message color red/with
                        "Codigo para lancamento contabil obrigatorio"
                        view-as alert-box .
                    recatu1 = recatu2.    
                    undo.
                end*/.

            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp modal with frame f-consulta no-validate.
                find first lanaut where lanaut.etbcod = ? and
                                        lanaut.forcod = ? and
                                        lanaut.modcod = modal.modcod
                                        no-error.
                disp lanaut.lancod when avail lanaut 
                     lanaut.lanhis when avail lanaut
                     with frame f-consulta.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" modal.modnom update sresp.
                if not sresp
                then leave.
                find next modal where true no-error.
                if not available modal
                then do:
                    find modal where recid(modal) = recatu1.
                    find prev modal where true no-error.
                end.
                recatu2 = if available modal
                          then recid(modal)
                          else ?.
                find modal where recid(modal) = recatu1.
                find first lanaut where lanaut.etbcod = ? and
                                        lanaut.forcod = ? and
                                        lanaut.modcod = modal.modcod
                                        no-error.
                if avail lanaut
                then delete lanaut.
                delete modal.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                /*
                message "Confirma Impressao de Modalidades " update sresp.
                if not sresp
                then leave.
                */
                recatu2 = recatu1.
                varquivo = "..\relat\compu".
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = ""EXTMOV""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
        &Tit-Rel   = """ RELATORIO DE MODALIDADES """ 
        &Width     = "80"
        &Form      = "frame f-cabcab"}


                for each modal:
                    display modal.
                    find first lanaut where lanaut.etbcod = ? and
                                        lanaut.forcod = ? and
                                        lanaut.modcod = modal.modcod
                                        no-lock no-error.
                    disp lanaut.lancod when avail lanaut
                         lanaut.lanhis when avail lanaut.
                end.
                output close.
                {mrod.i}
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
        find first lanaut where lanaut.etbcod = ? and
                            lanaut.forcod = ? and
                            lanaut.modcod = modal.modcod
                            no-lock no-error.
       display
        modal.modcod
        modal.modnom
        lanaut.lancod when avail lanaut
        lanaut.lanhis when avail lanaut
            with frame frame-a 14 down centered.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(modal).
   end.
end.

procedure color-message.
color display message
        modal.modcod
        modal.modnom
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        modal.modcod
        modal.modnom
        with frame frame-a.
end procedure.

