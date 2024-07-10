{admcab.i }
def var vetbcod like estab.etbcod.
def var varq as char.
def stream splani.
def stream smovim.
def stream sestoq.
output stream splani to ..\auditori\plani.d append.
output stream smovim to ..\auditori\movim.d append.
output stream sestoq  to terminal.
def buffer bmovim for movim.
def buffer bplani for plani.
def workfile westoq like estoq.
repeat:
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.

    message "Confirma Exportacao de dados" update sresp.
    if not sresp
    then return.
    
        for each plani where plani.etbcod = vetbcod and
                             plani.emite  = vetbcod and
                             plani.pladat > 12/31/2000 no-lock:
            if plani.movtdc <> 5 and
               plani.movtdc <> 6 and  
               plani.movtdc <> 12
            then next.
            export stream splani plani.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod no-lock.
                export stream smovim movim.
                find first estoq where estoq.etbcod = movim.etbcod
                                   and estoq.procod = movim.procod no-lock
                                   no-error.
                if avail estoq 
                then do:
                    create westoq.
                    ASSIGN                    
                    westoq.etbcod    = estoq.etbcod
                    westoq.procod    = estoq.procod
                    westoq.pronomc   = estoq.pronomc
                    westoq.fabfant   = estoq.fabfant
                    westoq.estatual  = estoq.estatual
                    westoq.estmin    = estoq.estmin
                    westoq.estrep    = estoq.estrep
                    westoq.estideal  = estoq.estideal
                    westoq.estloc    = estoq.estloc
                    westoq.estmgoper = estoq.estmgoper
                    westoq.estmgluc  = estoq.estmgluc
                    westoq.estcusto  = estoq.estcusto
                    westoq.estvenda  = estoq.estvenda
                    westoq.estdtcus  = estoq.estdtcus
                    westoq.estdtven  = estoq.estdtven
                    westoq.estreaj   = estoq.estreaj
                    westoq.estimp    = estoq.estimp
                    westoq.estinvqtd = estoq.estinvqtd
                    westoq.estinvdat = estoq.estinvdat
                    westoq.ctrcod    = estoq.ctrcod.
                
                    ASSIGN
                    westoq.estinvctm = estoq.estinvctm
                    westoq.tabcod    = estoq.tabcod
                    westoq.estbaldat = estoq.estbaldat
                    westoq.estbalqtd = estoq.estbalqtd
                    westoq.estprodat = estoq.estprodat
                    westoq.estproper = estoq.estproper
                    westoq.estpedcom = estoq.estpedcom
                    westoq.estpedven = estoq.estpedven
                    westoq.datexp    = estoq.datexp.
 
                end.
                else next.
                if plani.movtdc = 5
                then westoq.estatual = westoq.estatual + movim.movqtm.
                if plani.movtdc = 6
                then westoq.estatual = westoq.estatual + movim.movqtm.
                if plani.movtdc = 12
                then westoq.estatual = westoq.estatual - movim.movqtm.
            end.
            display estab.etbcod
                    plani.movtdc format "99"
                    plani.etbcod
                    plani.emite
                    plani.desti format "999999999"
                    plani.pladat with 1 down.
            pause 0.
        end.
    /*end.*/
    output stream splani close.
    output stream smovim close.
    for each estoq where estoq.etbcod = vetbcod no-lock.
        find first westoq where westoq.etbcod = estoq.etbcod
                            and westoq.procod = estoq.procod
                            no-lock no-error.
        if avail westoq
        then next. 
        disp "Gerando exportacao... " estoq.procod no-label
             with frame ffff centered . pause 0.
        create westoq.
                    ASSIGN                    
                    westoq.etbcod    = estoq.etbcod
                    westoq.procod    = estoq.procod
                    westoq.pronomc   = estoq.pronomc
                    westoq.fabfant   = estoq.fabfant
                    westoq.estatual  = estoq.estatual
                    westoq.estmin    = estoq.estmin
                    westoq.estrep    = estoq.estrep
                    westoq.estideal  = estoq.estideal
                    westoq.estloc    = estoq.estloc
                    westoq.estmgoper = estoq.estmgoper
                    westoq.estmgluc  = estoq.estmgluc
                    westoq.estcusto  = estoq.estcusto
                    westoq.estvenda  = estoq.estvenda
                    westoq.estdtcus  = estoq.estdtcus
                    westoq.estdtven  = estoq.estdtven
                    westoq.estreaj   = estoq.estreaj
                    westoq.estimp    = estoq.estimp
                    westoq.estinvqtd = estoq.estinvqtd
                    westoq.estinvdat = estoq.estinvdat
                    westoq.ctrcod    = estoq.ctrcod.
                
                    ASSIGN
                    westoq.estinvctm = estoq.estinvctm
                    westoq.tabcod    = estoq.tabcod
                    westoq.estbaldat = estoq.estbaldat
                    westoq.estbalqtd = estoq.estbalqtd
                    westoq.estprodat = estoq.estprodat
                    westoq.estproper = estoq.estproper
                    westoq.estpedcom = estoq.estpedcom
                    westoq.estpedven = estoq.estpedven
                    westoq.datexp    = estoq.datexp.
                   
    end.
    varq = "..\export\estle" + string(vetbcod) + ".d".
    output to value(varq).
    for each westoq no-lock.
        export westoq.
        display stream sestoq
            "SALDOS" westoq.procod westoq.estatual format "->>>,>>9" 
            with 1 down.
            pause 0.
    end.
    output close.
end.
