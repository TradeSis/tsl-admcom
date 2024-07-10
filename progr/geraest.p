{admcab.i}

def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.
def var vetbcod like estab.etbcod.
def stream splani.
def stream smovim.
def stream sestoq.

def buffer bmovim for movim.
def buffer bplani for plani.
repeat:
    /*
    dos silent del l:\auditori\*.d.
    dos silent del l:\auditori\*.zip.
    */
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    /*
    update vdti label "Data Inicial"
           vdtf label "Data Final" with frame f2 side-label width 80
                            title "Periodo de Movimento".
    */
    
   message "Confirma Exportacao de dados" update sresp.
   if not sresp
   then return.
   output stream sestoq to terminal.
   /*
   output stream splani to ..\auditori\plani.d.
   output stream smovim to ..\auditori\movim.d.
  
   for each estab no-lock:
        for each plani where plani.etbcod = estab.etbcod and
                             plani.emite  = vetbcod      and
                             plani.pladat >= vdti        and
                             plani.pladat <= vdtf no-lock:
            if plani.movtdc = 5 or
               plani.movtdc = 4
            then next.
            export stream splani plani.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod no-lock.
                export stream smovim movim.
            end.
            display estab.etbcod
                    plani.movtdc format "99"
                    plani.etbcod
                    plani.emite
                    plani.desti format "999999999"
                    plani.pladat with 1 down.
            pause 0.
        end.
        for each bplani where bplani.etbcod = estab.etbcod and
                              bplani.desti  = vetbcod      and
                              bplani.pladat >= vdti        and
                              bplani.pladat <= vdtf no-lock:
            if bplani.movtdc = 5 or
               bplani.movtdc = 4
            then next.
            export stream splani bplani.
            for each bmovim where bmovim.etbcod = bplani.etbcod and
                                  bmovim.placod = bplani.placod no-lock.
                export stream smovim bmovim.
            end.
            display estab.etbcod
                    bplani.movtdc format "99"
                    bplani.etbcod
                    bplani.emite
                    bplani.desti format "999999999"
                    bplani.pladat with 1 down.
            pause 0.
        end.
    end.
    output stream splani close.
    output stream smovim close.
    */

    output to ..\auditori\estoq.d.
    for each estoq where estoq.etbcod = vetbcod no-lock.
        export estoq.
        display stream sestoq
            "SALDOS" estoq.procod estoq.estatual format "->>>,>>9" with 1 down.
            pause 0.
    end.
    output close.
    output to ..\auditori\produ.d.
    for each produ:
        export produ.
        display stream sestoq produ.procod with 1 down. pause 0.
    end.
    output close.
    output stream sestoq close.
    /*
    dos silent pkzip l:\auditori\estoque.zip l:\auditori\*.*.
    message "Deseja copiar para o disquete ?" update sresp.
    if sresp 
    then dos silent copy l:\auditori\*.zip a:. 
    */
end.
