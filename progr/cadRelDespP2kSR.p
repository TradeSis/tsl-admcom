{admcab.i}
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 4
            initial ["Inclusao","Alteracao","Exclusao","Consulta"].
def var esqcom2         as char format "x(12)" extent 4
            initial ["","","",""].


def buffer bmrelDespesaP2k       for relDespesaP2k.
def var vcodCampanha         like relDespesaP2k.codCampanha.


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
        find first relDespesaP2k where
            true  no-lock no-error.
    else
        find relDespesaP2k where recid(relDespesaP2k) = recatu1 no-lock.         
		    if not available relDespesaP2k
    then do:
        message "Cadastro de Despesa P2k. Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered on error undo.
                create relDespesaP2k.
                update relDespesaP2k.codFornec
                       relDespesaP2k.codCampanha
					   relDespesaP2k.modalidade.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        relDespesaP2k.codFornec
	    relDespesaP2k.codCampanha
	    relDespesaP2k.modalidade
            with frame frame-a 14 down centered.

    recatu1 = recid(relDespesaP2k).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next relDespesaP2k where
                true no-lock.
        if not available relDespesaP2k
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display
			relDespesaP2k.codFornec
			relDespesaP2k.codCampanha
			relDespesaP2k.modalidade
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find relDespesaP2k where recid(relDespesaP2k) = recatu1 no-lock.

        choose field relDespesaP2k.codCampanha
            go-on(cursor-down cursor-up               
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
                esqpos1 = if esqpos1 = 4
                          then 4
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 4
                          then 4
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
            find next relDespesaP2k where
                true no-lock no-error.
            if not avail relDespesaP2k
            then next.
            color display normal
                relDespesaP2k.codCampanha.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.     
			        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev relDespesaP2k where
                true no-lock no-error.
            if not avail relDespesaP2k
            then next.
            color display normal
                relDespesaP2k.codCampanha.
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
                create relDespesaP2k.
                update relDespesaP2k.codCampanha
					   relDespesaP2k.codFornec
                       relDespesaP2k.modalidade.
                recatu1 = recid(relDespesaP2k).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
				recatu1 = recid(relDespesaP2k).
				find relDespesaP2k where recid(relDespesaP2k) = recatu1 no-error.
					update relDespesaP2k with frame f-altera no-validate.
				
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp relDespesaP2k with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" relDespesaP2k.codCampanha update sresp.            
				                if not sresp
                then undo.
                find next relDespesaP2k where true no-error.
                if not available relDespesaP2k
                then do:
                    find relDespesaP2k where recid(relDespesaP2k) = recatu1.
                    find prev relDespesaP2k where true no-error.
                end.
                recatu2 = if available relDespesaP2k
                          then recid(relDespesaP2k)
                          else ?.
                find relDespesaP2k where recid(relDespesaP2k) = recatu1.
                delete relDespesaP2k.
                recatu1 = recatu2.
                leave.
            end.
           

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            /*pause.*/
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        display
                relDespesaP2k.codCampanha     
				relDespesaP2k.codFornec				
				relDespesaP2k.modalidade
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(relDespesaP2k).
   end.
end.