    find ctpromoc where recid(ctpromoc) = a-seerec[frame-line].
                if keyfunction(lastkey) = "NEW-LINE" or
                   keyfunction(lastkey) = "INSERT-MODE" or
                   keyfunction(lastkey) = "I"
                then do:
                    /*if bctpromoc.situacao <> "M" and sfuncod <> 101
                    then next keys-loop.*/
                    color display normal ctpromoc.clacod with frame f-linha1.
                    repeat on endkey undo, next bl-princ2:
        find last dctpromoc where dctpromoc.sequencia = bctpromoc.sequencia 
                    no-lock no-error.
        scroll from-current down with frame f-linha1.
        create ctpromoc.
        assign ctpromoc.promocod = bctpromoc.promocod
            ctpromoc.sequencia = bctpromoc.sequencia ctpromoc.situacao = "A"
            ctpromoc.linha     = dctpromoc.linha + 1 ctpromoc.fincod = ?.
        do on error undo, next bl-princ2:
            update  ctpromoc.clacod  with frame f-linha1.
            find clase where clase.clacod = ctpromoc.clacod no-lock no-error.
            if not avail clase
            then do: message color red/with
                    "Classe  " ctpromoc.clacod " nao cadastrada." 
                    view-as alert-box. undo.
            end.
            disp clase.clanom with frame f-linha1.
            update ctpromoc.situacao with frame f-linha1.
        end.
    end.
                    hide frame f-linha1 no-pause. next bl-princ2.
                end.

                if keyfunction(lastkey) = "DELETE-LINE" or
                   keyfunction(lastkey) = "CUT" or
                   keyfunction(lastkey) = "E"
                then do:
                    if bctpromoc.situacao <> "M"
                    then next keys-loop.
                    sresp = no.
                    message "Confirma excluir da promocao a Classe" 
                    ctpromoc.clacod "?" update sresp.
                    if sresp  then do:
                        delete ctpromoc.
                        hide frame f-linha1 no-pause.
                        clear frame f-linha1 all. next bl-princ2.
                    end.
                    next keys-loop.
                end.
