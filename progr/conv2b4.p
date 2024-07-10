def temp-table wf-clien
    field clicod like clien.clicod.
def temp-table wf-contrato
    field contnum like contrato.contnum.
def stream sclien.
def stream stitulo.
def stream scontrato.

output stream sclien to clien.d.
output stream sclien close.
output stream scontrato to contrato.d.
output stream scontrato close.

output stream stitulo to titulo.d.
for each titulo use-index titnum
        where titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = "CRE" and
                      titulo.etbcod = 1 or
                      titulo.etbcod = 6 or
                      titulo.etbcod = 17:
    export stream stitulo titulo.

    pause 0 before-hide.
    display titulo.etbcod titulo.clifor titulo.titnum titulo.titpar
                with 1 down centered.

    find first wf-clien where
            wf-clien.clicod = titulo.clifor no-error.
    if not available wf-clien
    then do:
        output stream sclien to clien.d append.
        find clien where clien.clicod = titulo.clifor no-error.
        if available clien then export stream sclien clien.
        output stream sclien close.
        create wf-clien.
        wf-clien.clicod = clien.clicod.
    end.
    find first wf-contrato where
            wf-contrato.contnum = int(titulo.titnum) no-error.
    if not available wf-contrato
    then do:
        output stream scontrato to contrato.d append.
        find contrato where contrato.contnum = int(titulo.titnum) no-error.
        if available contrato then export stream scontrato contrato.
        output stream scontrato close.
        create wf-contrato.
        wf-contrato.contnum = contrato.contnum.
    end.
end.
output stream  stitulo close.
