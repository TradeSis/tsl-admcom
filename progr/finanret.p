{admcab.i}

def var vcontnum like contrato.contnum.

repeat:
    update vcontnum format ">>>>>>>>>9"
        at 4 with frame f1 1 down side-label width 80.
    
    find contrato where contrato.contnum = vcontnum no-lock no-error.
    if not avail contrato
    then do:
        message color red/with "Contrato não encontrado." view-as alert-box.
        next.
    end.
    find clien where clien.clicod = contrato.clicod no-lock.
    disp clien.clicod at 1
         clien.clinom no-label
         with frame f1.
         
    sresp = no.
    message "Confirma retornar contrato?" update sresp.
    if not sresp then next. 
    
    find first envfinan where envfinan.empcod = 19
                        and envfinan.titnat = no
                        and envfinan.modcod = contrato.modcod
                        and envfinan.etbcod = contrato.etbcod
                        and envfinan.clifor = contrato.clicod
                        and envfinan.titnum = string(contrato.contnum)
                        no-lock no-error.
    if not avail envfinan
    then do:
        find first titulo where titulo.empcod = 19
                        and titulo.titnat = no
                        and titulo.modcod = contrato.modcod
                        and titulo.etbcod = contrato.etbcod
                        and titulo.clifor = contrato.clicod
                        and titulo.titnum = string(contrato.contnum)
                        and titulo.cobcod = 10
                        no-lock no-error.
        if not avail titulo
        then do:
            message color red/with "Contrato não esta na financeira."
            view-as alert-box.
            next.
        end.
        else do:
            for each titulo where titulo.empcod = 19
                        and titulo.titnat = no
                        and titulo.modcod = contrato.modcod
                        and titulo.etbcod = contrato.etbcod
                        and titulo.clifor = contrato.clicod
                        and titulo.titnum = string(contrato.contnum)
                        and titulo.cobcod = 10.
                run p-grava-cobcod.
            end.            
        end.
    end.
    else do:
        for each envfinan where envfinan.empcod = 19
                        and envfinan.titnat = no
                        and envfinan.modcod = contrato.modcod
                        and envfinan.etbcod = contrato.etbcod
                        and envfinan.clifor = contrato.clicod
                        and envfinan.titnum = string(contrato.contnum).
            find first titulo where titulo.empcod = envfinan.empcod
                                and titulo.titnat = envfinan.titnat
                                and titulo.modcod = envfinan.modcod
                                and titulo.etbcod = envfinan.etbcod
                                and titulo.clifor = envfinan.clifor
                                and titulo.titnum = envfinan.titnum
                                and titulo.titpar = envfinan.titpar
                                no-error.
            if avail titulo
            then run p-grava-cobcod.
            assign 
                envfinan.datexp = today
                envfinan.envsit = "RET".
        end.
    end.          
end.        

procedure p-grava-cobcod:

        assign titulo.cobcod = 2.
        
        find contrato where contrato.contnum = int(titulo.titnum)
                            no-error.
        
        create titulolog.
        assign
            titulolog.empcod = titulo.empcod
            titulolog.titnat = titulo.titnat
            titulolog.modcod = titulo.modcod
            titulolog.etbcod = titulo.etbcod
            titulolog.clifor = titulo.clifor
            titulolog.titnum = titulo.titnum
            titulolog.titpar = titulo.titpar
            titulolog.data    = today
            titulolog.hora    = time
            titulolog.funcod  = sfuncod
            titulolog.campo   = "CobCod"
            titulolog.valor   = string(titulo.cobcod)
            titulolog.obs     = "RETORNA CONTRATO PARA DREBES".

end procedure.

