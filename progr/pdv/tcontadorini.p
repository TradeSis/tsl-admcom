{admcab.i}
def var petbcod like estab.etbcod.
def var pdata   as date format "99/99/9999".
def var pdtfim  as date format "99/99/9999".

    petbcod = ?.
    pdata = ?.
    disp petbcod colon 25 pdata colon 25 with frame fcontador. 
    update petbcod label "filial"
        with frame fcontador
        row 9 centered side-labels overlay.

    update pdata label "periodo de" with frame fcontador.
        if pdata = ? and petbcod = ?
        then do:
            message "selecione uma filial ou data de contador".
            undo.
        end.
        if pdata = ?
        then pdtfim = ?.
        else update pdtfim label "ate" with frame fcontador.
                                            
    run pdv/qtdprevenda.p   ( input petbcod, input pdata, input pdtfim).


