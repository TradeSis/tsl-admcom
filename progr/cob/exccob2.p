{admcab.i}
def input param par-rec as recid.

def var vclicod like clien.clicod.

    find cobranca where recid(cobranca) = par-rec no-lock no-error.
    if not avail cobranca
    then do:
        vclicod = 0.
        hide frame f2 no-pause.
        update vclicod label "Cliente" colon 15 
                with frame f1 side-label width 80.
        find clien where clien.clicod = vclicod no-lock.
        display clien.clinom no-label with frame f1.
    find first cobranca where cobranca.clicod = clien.clicod no-lock no-error.
        if not avail cobranca
        then do:
            message "Nao existe cobranca para este cliente"
                view-as alert-box.
            return.
        end.
        display cobranca with frame f2.
    end.
    if cobranca.etbcod <> setbcod and
       setbcod <> 999
    then do:
        find cobfil of cobranca no-lock.
        message "Cliente em Cobranca com " cobfil.cobnom "Filial"
            cobfil.etbcod "desde" cobranca.cobgera
            view-as alert-box.
        return.
    end.   
    
    message "Deseja excluir cobranca? " update sresp.
    if sresp
    then do transaction:
        find current cobranca exclusive. 
        find cobdata of cobranca exclusive no-error.
        if avail cobdata
        then do:
            cobdata.cobqtd = cobdata.cobqtd + 1.
            if cobdata.cobqtd = 0
            then delete cobdata.
        end.    
        delete cobranca.
    end.

