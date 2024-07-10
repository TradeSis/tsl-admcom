input from diretorio.
repeat with centered:
    set diretorio as char format "x(30)".
    dos silent mkdir value("A:\" + diretorio).
    dos silent xcode -d value("a: " + diretorio + "\*.p " +
				      diretorio + "\*.i " +
				      diretorio + "\*.v" ).
end.
input close.
