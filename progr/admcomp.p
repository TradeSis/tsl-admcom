pause 0 before-hide.
def var prog as c format "x(40)".
def var i as i.
def stream tela .

output stream tela to terminal.
output to compila.log .

input from l:\progr\compila no-echo.
repeat:
    set prog .
    display stream tela prog.
    compile value(prog) save.
end.
