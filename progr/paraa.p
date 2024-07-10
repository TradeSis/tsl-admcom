input from diretorio.
repeat with centered:
    set diretorio as char format "x(30)".
    dos silent mkdir value("A:\" + diretorio).
    dos silent copy  value(diretorio + "\*.* a:\" + diretorio).
end.
input close.
