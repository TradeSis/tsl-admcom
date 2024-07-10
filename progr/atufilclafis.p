{admcab.i}

def var ip   as char format "x(15)".

repeat:
    update ip  label "IP - Filial"
    with frame f1 side-label width 80 1 column
    title "Atualizar CLAFIS".

    compile atufilclafis1.p save.

    run atufilclafis1.r (input ip).

    leave.
end.

