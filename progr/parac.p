input from b:\diretorio.
repeat with centered:
    set diretorio as char format "x(30)".
    dos silent copy  value("b:\" + diretorio + "\*.* ..\" + diretorio).
end.
input close.
