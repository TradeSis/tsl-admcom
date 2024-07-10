def var wdata as date initial today label "Data Referencia".

def temp-table wf-clien
    field clicod like clien.clicod.
def temp-table wf-contrato
    field contnum like contrato.contnum.
def stream sclien.
def stream stitulo.
def stream scontrato.

update wdata colon 30 with frame fdata width 80.

output stream sclien to c:\admcom\clien.d.
output stream sclien close.
output stream scontrato to c:\admcom\contrato.d.
output stream scontrato close.

output stream stitulo to c:\admcom\titulo.d.
for each titulo use-index titdtpag
        where titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = "CRE" and
                      titulo.titdtpag = ? and
                      titulo.etbcod = 1 or
                      titulo.etbcod = 6 or
                      titulo.etbcod = 17 or
                      titulo.etbcod = 15 or
                      titulo.etbcod = 7 no-lock:
    export stream stitulo titulo.

    pause 0 before-hide.
    display titulo.etbcod titulo.clifor titulo.titnum titulo.titpar
                with 1 down centered.

    find first wf-clien where
            wf-clien.clicod = titulo.clifor no-error.
    if not available wf-clien
    then do:
        output stream sclien to c:\admcom\clien.d append.
        find clien where clien.clicod = titulo.clifor no-lock no-error.
        if available clien
        then do:
            export stream sclien clien.
            create wf-clien.
            wf-clien.clicod = clien.clicod.
        end.
        output stream sclien close.
    end.
    find first wf-contrato where
            wf-contrato.contnum = int(titulo.titnum) no-error.
    if not available wf-contrato
    then do:
        output stream scontrato to c:\admcom\contrato.d append.
        find contrato where contrato.contnum = int(titulo.titnum)
                no-lock no-error.
        if available contrato
        then do:
            export stream scontrato contrato.
            create wf-contrato.
            wf-contrato.contnum = contrato.contnum.
        end.
        output stream scontrato close.
    end.
end.
output stream  stitulo close.
