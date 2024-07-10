{admcab.i}
def var vsel as char format "x(40)" extent 6.


vsel[1] = "CONTROLE DE COMPETENCIAS".
vsel[2] = "PROCESSAMENTO PREMIOS BATE META".
vsel[3] = "GERA ARQUIVO PARA RH".
vsel[4] = "RELATORIO ENVIDOS RH".

repeat:
    disp vsel with frame f-sel no-label 1 column.
    choose field vsel with frame f-sel.

    hide frame f-sel.               

    if frame-index = 1
    then run man_complpmo.p.
    else if frame-index = 2
        then run exe_complpmo.p.
        else if frame-index = 3
            then run arq_complpmo.p.
            else if frame-index = 4
                then run rel_complpmo.p.

end.