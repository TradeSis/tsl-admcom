/*
TP 26447202 - 18.09.2018
*/
{admcab.i}
def input parameter par-clien as char.

def var vclicod like clien.clicod.

/* Atualiza variaveis */
if par-clien <> "Menu"
then do.
    vclicod = int(par-clien) no-error.

    find clien where clien.clicod = vclicod no-lock.
    if not avail clien
    then do.
        message "Clien nao encontrado:" par-clien.
        return.
    end.

    find neuclien where neuclien.clicod = vclicod no-lock no-error.
    if not avail neuclien
    then do:
        message "NeuClien nao encontrado:" par-clien.
        return.
    end.
end.
else do on error undo with frame f01 side-label width 80.
    update vclicod label "Cod. cliente" colon 15.
    find clien where clien.clicod = vclicod no-lock.
    if not avail clien
    then do:
        message "Clien nao encontrado!" view-as alert-box.
        next.
    end.

    find neuclien where neuclien.clicod = vclicod no-lock no-error.
    if not avail neuclien
    then do:
        message "Neuclien nao encontrado!" view-as alert-box.
        next.
    end.
end.
disp clien.clicod
     clien.clinom no-label
     clien.ciccgc colon 15
     neuclien.vlrlimite colon 15
     neuclien.VctoLimite.

if par-clien = "Menu"
then do.
    message "Confirma?" update sresp.
    if not sresp
    then return.
end.

def var var-DTULTCPA as date. /* #v1802 */
def var vvlrlimite as dec.
def var vvctolimite as date.
def var vsit_credito as char.
def var vtime as int.

run neuro/callimiteadmcom.p (recid(neuclien),
                             "COMP",
                             vtime,
                             setbcod,
                             0,
                             output vvlrLimite,
                             output vvctoLimite,
                             output vsit_credito).

