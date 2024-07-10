 find ctpromoc where recid(ctpromoc) = a-seerec[frame-line].
                if keyfunction(lastkey) = "NEW-LINE" or
                   keyfunction(lastkey) = "INSERT-MODE" or
                   keyfunction(lastkey) = "I"
                then do:
                    /*
                    if bctpromoc.situacao <> "M"
                    then next keys-loop.
                    */
                    color display normal ctpromoc.setcod with frame f-linha2.
                    repeat on endkey undo, next bl-princ3:
        find last dctpromoc where dctpromoc.sequencia = bctpromoc.sequencia 
                    no-lock no-error.
        scroll from-current down with frame f-linha2.
        create ctpromoc.
        assign ctpromoc.promocod = bctpromoc.promocod
            ctpromoc.sequencia = bctpromoc.sequencia ctpromoc.situacao = "A"
            ctpromoc.linha     = dctpromoc.linha + 1 ctpromoc.fincod = ?.
        do on error undo, next bl-princ3:
            update  ctpromoc.setcod  with frame f-linha2.
            find categoria where categoria.catcod = ctpromoc.setcod
                no-lock no-error.
            if not avail categoria
            then do: message color red/with
                    "Setor " ctpromoc.setcod " nao cadastrado." 
                    view-as alert-box. undo.
            end.
            disp categoria.catnom with frame f-linha2.
        end.
    end.
                    hide frame f-linha2 no-pause. next bl-princ3.
                end.
                if keyfunction(lastkey) = "DELETE-LINE" or
                   keyfunction(lastkey) = "CUT" or
                   keyfunction(lastkey) = "E"
                then do:
                    if bctpromoc.situacao <> "M"
                    then next keys-loop.
                    sresp = no. 
                    message "Confirma excluir da promocao o Setor"
                                         ctpromoc.setcod "?" update sresp.
                    if sresp  then do:
                        delete ctpromoc. clear frame f-linha2 all.
                        hide frame f-linha2 no-pause. next bl-princ3.
                    end. next keys-loop.
                end.
