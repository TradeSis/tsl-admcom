{admcab.i}
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vetbcod   like  plani.etbcod.
def var vserie    like  plani.serie.

form
    estab.etbcod label "Emitente" colon 15
    estab.etbnom  no-label
    vnumero   colon 15
    vserie
    with frame f1 side-label color white/cyan width 80 row 4.

repeat:
    clear frame f1 no-pause.
    prompt-for estab.etbcod label "Emitente" with frame f1.
    find estab where estab.etbcod = input estab.etbcod no-lock no-error.
    if not avail estab
    then do:
        message "estabelecimento nao cadastrado".
        undo, retry.
    end.
    vserie = "U".
    display estab.etbnom with frame f1.
    update vnumero
           vserie with frame f1.
    find plani where plani.numero = vnumero and
                     plani.emite  = estab.etbcod and
                     plani.movtdc = 26   and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao cadastrada".
        undo, retry.
    end.

    run not_consnota.p (recid(plani)).
/***
    message "Confirma Emissao da Nota " update sresp.
    if sresp
    then run impoutsai.p (input recid (plani)).  
***/
end.
