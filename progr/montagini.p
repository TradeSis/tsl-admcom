{admcab.i}

def var petbcod like estab.etbcod.
def var pdtini  as date format "99/99/9999" label "Desde".

repeat.
    if setbcod = 999
    then do:
        update petbcod label "Filial"
            with frame f1.
    end.
    else     petbcod = setbcod.
    disp petbcod with frame f1.    

    pdtini = date(month(today),01,year(today)).
    pdtini = pdtini - 1.
    pdtini = date(month(pdtini),01,year(pdtini)).


    update pdtini with frame f1
        row 3 centered side-labels width 80 no-box.

    run montagmov.p (input petbcod, input pdtini).



end.
