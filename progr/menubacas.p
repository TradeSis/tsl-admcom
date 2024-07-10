{admcab.i new}


def var esqcom1 as char extent 10 format "x(35)"
    init ["Criar contrato",
          ""].
def var esqpos1 as int.

repeat.
    disp esqcom1 with frame f-com1 no-label 1 col centered.
    choose field esqcom1 with frame f-com1.
    esqpos1 = frame-index.
    hide frame f-com1 no-pause.
    disp esqcom1[esqpos1]
    with frame f-titulo centered color message no-box no-label.

    if esqcom1[esqpos1] = "Criar contrato"
    then run ./bcacriacontr.p.
end.
