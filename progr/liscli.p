def temp-table tt-con like contluc.

for each tt-con:
    delete tt-con.
end.

disp "Gerando Arquivo de Clientes...." with frame f-cab1 centered row 10.

input from ..\bases\contluc.d.
repeat:
    create tt-con.
    import tt-con.
    disp tt-con.clicod no-label with frame f-cab1 side-label.
end.
input close.

output to ..\bases\clien.d.
for each tt-con break by tt-con.clicod.
    if first-of(tt-con.clicod)
    then do:
        find clien where clien.clicod = tt-con.clicod no-lock no-error.
        export clien.
    end.
end.
output close.
