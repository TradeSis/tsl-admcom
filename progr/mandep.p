{admcab.i}
def var vetbcod like estab.etbcod.
def var vdata   like plani.pladat.
def var vsenha  like func.senha.

/*****

repeat:
    vetbcod = 0.
    vdata = today.
    
    vsenha = "".
    update vsenha label "Senha"
        blank with frame f-senha side-label centered.
        
    if vsenha <> "32940" and
       vsenha <> "1079"
    then do:
        message "Senha Invalida".
        undo, retry.
    end.
        

    update vetbcod label "Filial" with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f1.
    update vdata label "Data Mov." with frame f1.
    
    if vetbcod = 999
    then do:
        find deposito where deposito.etbcod = estab.etbcod and
                            deposito.datmov = vdata
                             no-lock no-error.
        if not avail deposito
        then do:
            create deposito.
            assign
                deposito.etbcod = estab.etbcod 
                deposito.datmov = vdata
                .
                
            update deposito.                
        end.
    end.
    
    for each deposito where deposito.etbcod = estab.etbcod and
                            deposito.datmov = vdata.
                    
        disp deposito with frame f-dep 1 column centered.
        if vsenha = "1079"
        then update deposito with frame f-dep.
        else do:
            update deposito.datcon 
             validate(deposito.datcon = today,"Data Invalida")
             with frame f-dep.
            update  depsit
            with frame f-dep.
        end.
        find lotdep where lotdep.etbcod = deposito.etbcod and
                          lotdep.datcon = deposito.datmov no-error.
        if not avail lotdep
        then do:
            create lotdep.
            assign lotdep.etbcod = deposito.etbcod
                   lotdep.datcon = deposito.datmov.
        end.
        update lotdep.lote with frame f-dep.

    end.

end.

***/
