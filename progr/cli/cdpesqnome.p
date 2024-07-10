/* Higienizacao de Cadastros   - telas
   Tela de Pesquisa Por Nome de Higienizacao de Cadastro
*/

{cabec.i}

def var vnome like clien.clinom.


form 
        vnome   colon 30 
        with frame fcab
        row 3 side-labels.
form 
         clien.clicod
         clien.ciccgc format "x(14)"
         clien.clinom format "x(25)"
         clien.dtnasc format "99/99/9999"
         clien.dtcad  format "99/99/9999" column-label "Cadast"
         clien.etbcad format ">>9" column-label "Lj"
        with frame frame-a
            width 80 no-box
            10 down row 7.

repeat on endkey undo, leave.

    vnome = "".
    clear frame frame-a all no-pause.
    update vnome
        with frame fcab.
    if vnome = ""
    then do:
        next.
    end.
    for each clien where clien.clinom contains vnome                   
        no-lock 
            break 
                by clien.clinom 
                by clien.ciccgc
        on endkey undo, leave.
        if clien.clicod = ?
        then next.
        run frame-a.
        if keyfunction(lastkey) = "END-ERROR"
         then leave.
    end.    
    pause.

end.

hide frame fcab no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    find first neuclien where neuclien.clicod = clien.clicod no-lock no-error.
    disp 
         clien.clicod
         clien.ciccgc
         clien.clinom
         clien.dtnasc 
         clien.dtcad
         clien.etbcad
         avail neuclien format "*/ " column-label "N"
        with frame frame-a.
    down with frame frame-a.         
         
end procedure.         
