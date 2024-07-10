def input parameter par-funcao as char.                            
def input parameter par-rowid as rowid. 
def buffer A01_infnfe for A01_infnfe.

find A01_infnfe where rowid(A01_infnfe) = par-rowid no-lock.

if par-funcao = "Cria"
then run cria-movimento.
else if par-funcao = "Cancela"
then run canc-movimento. 
 
procedure cria-movimento:
   
    def var vctonota as dec no-undo.
    
    def buffer bplani for plani.
    
    find placon where placon.etbcod = A01_infnfe.etbcod and
                      placon.emite  = A01_infnfe.etbcod and
                      placon.serie  = A01_infnfe.serie and
                      placon.numero = A01_infnfe.numero
                      no-lock no-error.
    if avail placon
    then do:
        /*** 01/02/2013 ***/
        find plani where plani.etbcod = placon.etbcod
                     and plani.placod = placon.placod
                     and plani.serie  = placon.serie
               no-lock no-error.
        if avail plani
        then return.

        do transaction.
            create plani.
            buffer-copy placon to plani.
            plani.notsit = no.
        end.

        for each movcon where movcon.etbcod = placon.etbcod and
                              movcon.placod = placon.placod and
                              movcon.movtdc = placon.movtdc
                              no-lock:
            create movim.
            buffer-copy movcon to movim.
        end.

        /* #1 */
        for each mimpcon where mimpcon.etbcod = placon.etbcod
                           and mimpcon.placod = placon.placod
                         no-lock:
            create movimimp.
            buffer-copy mimpcon to movimimp.
        end.

        if placon.crecod <> 2 /*and placon.etbcod >= 200*/
        then 
            for each movim where movim.etbcod = placon.etbcod
                             and movim.placod = placon.placod
                             and movim.movtdc = placon.movtdc
                           no-lock.
                 if movim.opfcod = 3102
                 then do:
                     vctonota = movim.movpc + 
                                (movim.movipi / movim.movqtm) +
                                (movim.movii / movim.movqtm) +
                                (movim.movpis / movim.movqtm) +
                                (movim.movcofins / movim.movqtm) +
                                (movim.movacfin / movim.movqtm) +
                                (movim.movicms / movim.movqtm)
                                .
                    for each estoq where
                             estoq.procod = movim.procod exclusive:
                        estoq.estcusto = vctonota.
                    end.         
                 end.
                 
                 run /admcom/progr/atuest.p (input recid(movim),
                                             input "I",
                                             input 0).
            end.

        /* envia interface para ALCIS */
        if plani.etbcod = 995 and 
           plani.notped <> "" 
        then do. 
            run /admcom/progr/alcis/nfgl.p (input recid(plani)).
        end.
        if plani.etbcod = 900 and 
           plani.notped <> "" 
        then do. 
            run /admcom/progr/alcis/nfgl-900.p (input recid(plani)).
        end.
    end.
    else do:
        find first placon where placon.etbcod = A01_infnfe.etbcod and
                      placon.placod  = A01_infnfe.placod and
                      placon.serie  = A01_infnfe.serie and
                      placon.numero = A01_infnfe.numero
                      no-lock no-error.
        if avail placon
        then do:
            /*** 01/02/2013 ***/
            find plani where plani.etbcod = placon.etbcod
                     and plani.placod = placon.placod
                     and plani.serie  = placon.serie
               no-lock no-error.
            if avail plani
            then return.

            do transaction.
                create plani.
                buffer-copy placon to plani.
                plani.notsit = no.
            end.

            for each movcon where movcon.etbcod = placon.etbcod and
                              movcon.placod = placon.placod and
                              movcon.movtdc = placon.movtdc
                              no-lock:
                create movim.
                buffer-copy movcon to movim.
            end. 

            /* #1 */
            for each mimpcon where mimpcon.etbcod = placon.etbcod
                               and mimpcon.placod = placon.placod
                             no-lock:
                create movimimp.
                buffer-copy mimpcon to movimimp.
            end.

            if placon.crecod <> 2 /*and placon.etbcod >= 200*/
            then 
                for each movim where movim.etbcod = placon.etbcod
                             and movim.placod = placon.placod
                             and movim.movtdc = placon.movtdc
                           no-lock.
                    run /admcom/progr/atuest.p (input recid(movim),
                                             input "I",
                                             input 0).
                end.

            /* envia interface para ALCIS */
            if plani.etbcod = 995 and 
               plani.notped <> "" 
            then do. 
                run /admcom/progr/alcis/nfgl.p (input recid(plani)).
            end.
            if plani.etbcod = 900 and 
               plani.notped <> "" 
            then do. 
                run /admcom/progr/alcis/nfgl-900.p (input recid(plani)).
            end.
        end.
    end.

end procedure.

procedure canc-movimento:
    def buffer bplani for plani.
    
    find placon where placon.etbcod = A01_infnfe.etbcod and
                      placon.emite  = A01_infnfe.etbcod and
                      placon.serie  = A01_infnfe.serie and
                      placon.numero = A01_infnfe.numero
                      no-lock no-error.
    if avail placon
    then do.
        find plani where plani.etbcod = placon.etbcod and
                         plani.emite  = placon.emite and
                         plani.serie = placon.serie and
                         plani.numero = placon.numero
                   no-error.
/***
    else
        find plani where plani.etbcod = A01_infnfe.etbcod and
                         plani.emite  = A01_infnfe.etbcod and
                         plani.serie = A01_infnfe.serie and
                         plani.numero = A01_infnfe.numero
                   no-error.
***/

        if avail plani
        then do on error undo:
            if placon.crecod <> 2 and placon.etbcod >= 200
            then
                for each movim where movim.etbcod = plani.etbcod and
                                  movim.placod = plani.placod and
                                  movim.movtdc = plani.movtdc
                                  no-lock:
                  run /admcom/progr/atuest.p (input recid(movim),
                                                 input "E",
                                                 input 0).
                end.
            if A01_infnfe.situacao = "CANCELADA"
            THEN DO:
                find planiaux where planiaux.etbcod = plani.etbcod and
                         planiaux.emite  = plani.emite and
                         planiaux.serie = plani.serie and
                         planiaux.numero = plani.numero and
                         planiaux.nome_campo = "SITUACAO" AND
                         planiaux.valor_campo = "CANCELADA"
                         NO-LOCK no-error.
                if not avail planiaux
                THEN DO:
                    message "create".
                    create planiaux.
                    assign
                        planiaux.etbcod = plani.etbcod 
                        planiaux.placod = plani.placod
                        planiaux.emite  = plani.emite 
                        planiaux.serie = plani.serie 
                        planiaux.numero = plani.numero 
                        planiaux.nome_campo = "SITUACAO" 
                        planiaux.valor_campo = "CANCELADA".
                END.
            END.
            assign
                plani.notsit = yes
                plani.modcod = "CAN".
        end.
        else do on error undo:
            if A01_infnfe.situacao = "INUTILIZADA"
            THEN DO:
                find planiaux where planiaux.etbcod = placon.etbcod and
                         planiaux.emite  = placon.emite and
                         planiaux.serie = placon.serie and
                         planiaux.numero = placon.numero and
                         planiaux.nome_campo = "SITUACAO" AND
                         planiaux.valor_campo = "INUTILIZADA"
                         NO-LOCK no-error.
                if not avail planiaux
                THEN DO:
                    create planiaux.
                    assign
                        planiaux.etbcod = placon.etbcod 
                        planiaux.placod = placon.placod
                        planiaux.emite  = placon.emite 
                        planiaux.serie = plani.serie 
                        planiaux.numero = plani.numero 
                        planiaux.nome_campo = "SITUACAO" 
                        planiaux.valor_campo = "INUTILIZADA".
                END.
            END.
        end.                              
    end.
end procedure.

