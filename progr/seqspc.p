{admcab.i}

def var vsel as char extent 2 format "x(20)".

vsel[1] = "DREBES LOJAS".
vsel[2] = "DREBES FINANCEIRA".
/*
DISP vsel with frame fsel no-label centered.

choose field vsel with frame fsel.

if frame-index = 1
then*/ do on error undo:
    find estab 995.
    update vista label "Sequencial SPC" with frame f1 side-label
                    width 80.
end.
/*else do on error undo:
    find estab 996.
    update vista label "Sequencial SPC" with frame f1 side-label
                    width 80.
end.*/


