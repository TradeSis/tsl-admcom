def var vetbcod like ger.estab.etbcod.
def var vcli as int.
def var vdep as int.
def var vdti     as date format "99/99/9999" initial today.
def var vdtf     as date format "99/99/9999" initial today.
def var v-cria-cli as int.
def var v-alt-cli as int.
def buffer bdeposito for gerloja.deposito.
    
repeat:
    update vetbcod label "Filial"
           vdti label "Periodo" 
           vdtf no-label with frame f1 side-label width 80.

    vdep = 0.
    for each gerloja.deposito where gerloja.deposito.etbcod = vetbcod and
                                    gerloja.deposito.datmov >= vdti   and
                                    gerloja.deposito.datmov <= vdtf   no-lock:
        if gerloja.deposito.depalt <> ""
        then next.
                            
        find ger.deposito where ger.deposito.etbcod = gerloja.deposito.etbcod
                            and ger.deposito.datmov = gerloja.deposito.datmov
                          no-error.
        if not avail ger.deposito
        then do transaction:
            create ger.deposito.
            buffer-copy gerloja.deposito to ger.deposito.
            vdep = vdep + 1.

            /*** TP 22262869 ***/
            find bdeposito where recid(bdeposito) = recid(gerloja.deposito).
            bdeposito.depalt = "REPLICADO".
        end.
    end.                                            
                                            
    vcli = 0.
    v-cria-cli = 0.
    v-alt-cli = 0.
    
    for each gerloja.clien where 
                    gerloja.clien.dtcad >= vdti and
                    gerloja.clien.dtcad <= vdtf no-lock:
        if length(string(gerloja.clien.clicod)) > 10
        then do:
            if substring(string(gerloja.clien.clicod),2,3) = string(vetbcod)
            then.
            else next.
        end.
        else do:
            if (substring(string(gerloja.clien.clicod),7,2)) = string(vetbcod)
            then.
            else next.
        end.
        vcli = vcli + 1.            
                                 
        find ger.clien where ger.clien.clicod = gerloja.clien.clicod no-error.
        if not avail ger.clien
        then do transaction:
            create ger.clien.
            {tt-clien.i ger.clien gerloja.clien}.
            
            ger.clien.datexp = today.
            v-cria-cli = v-cria-cli + 1.
        end.
        else do:
        
            if ger.clien.endereco[1]     = ""    or
               ger.clien.endereco[1]     = ?     or
               ger.clien.ciccgc          = ""    or
               ger.clien.ciccgc          = ?     or
               ger.clien.fone            = ""    or
               ger.clien.fone            = ?     or
               ger.clien.mae             = ""    or
               ger.clien.mae             = ?     or
               ger.clien.cidade[1]       = ""    or
               ger.clien.cidade[1]       = ?
             then if   
                            
             gerloja.clien.endereco[1] <> ?    or
             gerloja.clien.endereco[1] <> ""   or
             gerloja.clien.ciccgc      <> ""   or
             gerloja.clien.ciccgc      <> ?    or
             gerloja.clien.fone        <> ""   or
             gerloja.clien.fone        <> ?    or
             gerloja.clien.mae         <> ""   or
             gerloja.clien.mae         <> ?    or
             gerloja.clien.cidade[1]   <> ""   or
             gerloja.clien.cidade[1]   <> ?

            then do transaction:    
            
                {tt-clien.i ger.clien gerloja.clien}.
                
                ger.clien.datexp = today.
                v-alt-cli = v-alt-cli + 1.
            end.                   
        end.                       
                           
        display ger.clien.clicod
                    with frame f2 centered 1 down.
        pause 0.
    end.
    
    hide frame f2 no-pause.
    
    display vetbcod  label "Filial   "
            vdep       label "Depositos"
            vcli       label "Clientes lidos"
            v-cria-cli label "     incluidos"
            v-alt-cli  label "   atualizados"
                with frame f3 1 column side-label width 80.
end.
