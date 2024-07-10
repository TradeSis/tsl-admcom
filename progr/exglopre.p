{admcab.i}
def var vnumero like glopre.numero.
repeat:
    vnumero = 0.
    update vnumero label "Contrato" colon 15
            with frame f1 side-label width 80.
    find first glopre where glopre.numero = vnumero no-lock no-error.
    if not avail glopre
    then do:
        message "Consorcio nao cadastrado".
        undo, retry.
    end.
    find clien where clien.clicod = glopre.clicod no-lock no-error.
    display clien.clicod colon 15
            clien.clinom no-label 
            glopre.valpar colon 15
            glopre.dtemi with frame f1.
    message "confirma exclusao do consorcio" update sresp.
    if sresp = no
    then undo, retry.

    for each glopre where glopre.numero = vnumero:
        delete glopre.
    end.
end.