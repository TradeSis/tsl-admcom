    def input parameter vdata as date.
    def input parameter vtabela as char.
    def output parameter vstatus as char.
    def shared var vclicod like gerloja.clien.clicod.
    def new shared var vqtd as int init 0.
    if vtabela = "EXC-CLIEN"
    then do:
        run exclilj3.p.
    end.
    else if vtabela = "DEPOSITO"
    THEN DO:
        run deposito.
    END.
    else if vtabela = "PRE-CADASTRO"
    then do:
        run pre-cadastro.
    end.
    else if vtabela = "INDICA-CLIENTE"
    then do:
        run indica-cliente.
    end.    
    vstatus = string(vqtd) + " REGISTROS ATUALIZADOS ".

procedure indica-cliente:
    for each gerloja.indicacl where gerloja.indicacl.dtinclu > vdata no-lock:
        find first ger.indicacl where
                   ger.indicacl.clicod = gerloja.indicacl.clicod
                   no-error.
        if not avail ger.indicacl
        then do:
            create ger.indicacl.
            buffer-copy gerloja.indicacl to ger.indicacl.   
            vqtd = vqtd + 1.
        end.
    end.                    
end procedure.


procedure pre-cadastro:
    for each gerloja.tclien where gerloja.tclien.tclinom = "1-A VISTA" no-lock:
        find gerloja.clien where 
             gerloja.clien.clicod = gerloja.tclien.tclicod no-lock no-error.
        if avail gerloja.clien
        then do:
            find ger.clien where ger.clien.clicod = gerloja.clien.clicod
                 no-lock no-error.
            if not avail ger.clien
            then do on error undo:
                 create ger.clien.
                 buffer-copy gerloja.clien to ger.clien.
                 release ger.clien no-error.
                 vqtd = vqtd + 1.
            end.
        end.
    end.                    
end procedure.


procedure deposito:

    def buffer bdeposito for gerloja.deposito.

    for each gerloja.deposito where gerloja.deposito.datmov >= vdata no-lock:
        if gerloja.deposito.depalt <> ""
        then next.
        find ger.deposito where 
             ger.deposito.etbcod = gerloja.deposito.etbcod and
             ger.deposito.datmov = gerloja.deposito.datmov
                              no-lock no-error.
        if not avail ger.deposito
        then do:
            create ger.deposito.
            buffer-copy gerloja.deposito to ger.deposito.
            vqtd = vqtd + 1.
            /*** TP 22262869 ***/
            find bdeposito where recid(bdeposito) = recid(gerloja.deposito).
            bdeposito.depalt = "REPLICADO".
        end.
    end.
end procedure.

