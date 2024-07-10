{admcab.i}
def var vetbcod like estab.etbcod.
def var vnumero like plani.numero.
def var vserie  like plani.serie.
def var vmovtdc like plani.movtdc format "99".
repeat:
    vserie = "".
    vnumero = 0.
    vetbcod = 0.
    update vetbcod label "Filial" 
           vmovtdc label "Tipo de Movimento"
           vserie
           vnumero with frame f1 side-label width 80.
    if vmovtdc <> 7 and
       vmovtdc <> 8
    then do:
        message "Movimento invalido".
        undo, retry.
    end.
        
    find tabaux where 
                 tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                 tabaux.nome_campo = "BLOCOK" no-error.
    if avail tabaux and tabaux.valor_campo = "SIM"
    then return.
    
    find plani where plani.etbcod = vetbcod and
                     plani.emite  = vetbcod and
                     plani.movtdc = vmovtdc and
                     plani.serie  = vserie  and
                     plani.numero = vnumero no-error.
    if not avail plani
    then do:
        message "Nota nao cadastrada".
        undo, retry.
    end.
    message "confirma exclusao de ajuste" update sresp.
    if not sresp
    then next.
    
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat:
        do transaction:
            run atuest.p(input recid(movim),
                         input "E",
                         input 0).
            delete movim.
        end.
    end.
    do transaction:
        delete plani.
    end.
end.
