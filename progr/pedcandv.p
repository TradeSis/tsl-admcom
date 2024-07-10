{admcab.i}

def var vetbcod like estab.etbcod.
def var vnumero like plani.numero.


repeat:

    vnumero = 0.

    do on error undo:

        assign
            vetbcod = setbcod.

        update vetbcod label "Emitente"
               with frame f-dados.

        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento nao Cadastrado".
            undo.
        end.
        disp estab.etbnom no-label with frame f-dados.
        
    end.           

    update skip
           vnumero label "Numero.."
           with frame f-dados width 80 side-labels.

    find plani where plani.movtdc = 3
                 and plani.etbcod = vetbcod
                 and plani.emite  = vetbcod
                 and plani.serie  = "V"
                 and plani.numero = vnumero no-error.

    if not avail plani
    then do:
        find plani where plani.movtdc = 3
                     and plani.etbcod = vetbcod
                     and plani.emite  = vetbcod
                     and plani.serie  = "VC"
                     and plani.numero = vnumero no-error.

        if avail plani
        then message "Transferencia ja foi cancelada".
        else message "Transferencia nao Cadastrada".

        undo.
    end.
    else do:
        
        disp plani.emite
             plani.desti
             plani.serie column-label "Serie"
             plani.pladat
             plani.platot
             with frame f-dados1 centered.
        
        message "Confirma o Cancelamento da NF ?" update sresp.
        if sresp
        then do:
           
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat no-lock:

                    run atuest.p (input recid(movim),
                                  input "E",
                                  input 0).

                end.
    
                plani.serie = "VC".
                message "Transferencia Cancelada".
            
        end.
        
    end.
    
end.    
