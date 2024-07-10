{admcab.i}
def var varquivo as char format "x(65)".
if opsys = "UNIX"
then.
else do:
    varquivo = sel-arq01().
    {mrod.i}
end.

disp varquivo with frame ff
        side-label width 80 row 7.

if varquivo = ""
then do:
    update varquivo label  "Arquivo"
            with frame ff 1 down.
end.

if search(varquivo) = ?
then do:
    message color red/with
        "Arquivo nao encontrado" skip
        varquivo
        view-as alert-box.
    return.
end.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.
return.