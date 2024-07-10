{admcab.i}
def input parameter par-clifor   as recid.
       /*********
def var vinf    like cpfis.infoad extent 0 format "x(64)".
def shared frame finf.


form vinf   label "Inf.Adicionais" at 1
     with frame finf row 5 overlay  width 81 no-box color input
                        side-label no-hide.
find clifor where recid(clifor) = par-clifor no-lock.

if clifor.tippes
then do:
    find cpfis of clifor no-lock no-error.
    if avail cpfis
    then
        if cpfis.infoad[1] <> ""
        then
            vinf = cpfis.infoad[1].
end.
else do:
    find cpjur of clifor no-lock no-error.
    if avail cpjur
    then
        if cpjur.infoad[1] <> ""
        then
            vinf = cpjur.infoad[1].
end.
if vinf <> ""
then
    display vinf
            with frame finf.
else            ***/
    hide frame finf no-pause.
