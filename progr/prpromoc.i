find ctpromoc where recid(ctpromoc) = a-seerec[frame-line].
                if keyfunction(lastkey) = "NEW-LINE" or
                   keyfunction(lastkey) = "INSERT-MODE" or
                   keyfunction(lastkey) = "I"
                then do:
                    /*if bctpromoc.situacao <> "M" then next keys-loop.*/
                    color display normal ctpromoc.procod with frame f-linha.
                    repeat on endkey undo, leave:
        find last dctpromoc where dctpromoc.sequencia = bctpromoc.sequencia 
                    no-lock no-error.
        scroll from-current down with frame f-linha.
        create ctpromoc.
        assign
            ctpromoc.promocod = bctpromoc.promocod  ctpromoc.situacao = "A"
            ctpromoc.sequencia = bctpromoc.sequencia
            ctpromoc.linha     = dctpromoc.linha + 1 ctpromoc.fincod = ? .
        do on error undo:
            update  ctpromoc.procod  with frame f-linha.
            find produ where produ.procod = ctpromoc.procod no-lock no-error.
            if not avail produ
            then do:
                message color red/with "Produto " ctpromoc.procod " nao cada~strado."  view-as alert-box. undo.
            end.
            disp produ.pronom with frame f-linha.
            update ctpromoc.precosugerido with frame f-linha.
            update ctpromoc.situacao with frame f-linha.
        end. 
    end. hide frame f-linha no-pause. next bl-princ1. end.
   if keyfunction(lastkey) = "DELETE-LINE" or keyfunction(lastkey) = "CUT" or
   keyfunction(lastkey) = "E"
   then do:

       if bctpromoc.situacao <> "M"
       then do:
           
           message "A Promocao ja foi liberada, por isso o produto deve ser inativado."
                       view-as alert-box.

           leave keys-loop.
           
       end.
       
       sresp = no.
       message "Confirma excluir da promocao a Filial" 
                ctpromoc.procod "?" update sresp.
           
       if sresp then do: 
           delete ctpromoc.
           hide frame f-linha no-pause.
           clear frame f-linha all.
           next bl-princ1.
       end.
           
       next keys-loop.
           
   end. 
 