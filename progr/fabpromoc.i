find ctpromoc where recid(ctpromoc) = a-seerec[frame-line].
                if keyfunction(lastkey) = "NEW-LINE" or
                   keyfunction(lastkey) = "INSERT-MODE" or
                   keyfunction(lastkey) = "I"
                then do:
                    if bctpromoc.situacao <> "M"
                    then next keys-loop.
                    color display normal
                       ctpromoc.procod with frame f-linha3.
                    repeat on endkey undo, next bl-princ4:
        find last dctpromoc where dctpromoc.sequencia = bctpromoc.sequencia 
                    no-lock no-error.
        scroll from-current down with frame f-linha3.
        create ctpromoc.
        assign ctpromoc.promocod = bctpromoc.promocod
            ctpromoc.sequencia = bctpromoc.sequencia ctpromoc.situacao = "A"
            ctpromoc.linha     = dctpromoc.linha + 1 ctpromoc.fincod = ?.
        do on error undo, next bl-princ4:
            update  ctpromoc.fabcod  with frame f-linha3.
            find fabri where fabri.fabcod = ctpromoc.fabcod
                no-lock no-error.
            if not avail fabri
            then do:
                message color red/with
                    "Fabricante " ctpromoc.fabcod " nao cadastrado." 
                    view-as alert-box. undo.
            end.
            disp fabri.fabnom with frame f-linha3.
        end.
    end.
                    hide frame f-linha3 no-pause. next bl-princ4.
                end.
                if keyfunction(lastkey) = "DELETE-LINE" or
                   keyfunction(lastkey) = "CUT" or
                   keyfunction(lastkey) = "E"
                then do:
                    if bctpromoc.situacao <> "M"
                    then next keys-loop.
                    sresp = no.
                    message "Confirma excluir da promocao o Fabricante" 
                    ctpromoc.fabcod "?" update sresp.
                    if sresp  then do:
                        delete ctpromoc. hide frame f-linha3 no-pause.
                        clear frame f-linha3 all.  next bl-princ4.
                    end. next keys-loop.
                end.
