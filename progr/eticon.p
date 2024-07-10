{admcab.i}

def var vcont-cli  as char format "x(15)" extent 2
      initial ["  Contratos  ","  Clientes  "].
repeat with side-labels centered row 4 1 down color white/cyan:
    disp vcont-cli no-label.
    choose field vcont-cli.
    if frame-index = 1
    then
	run numcont.p.
    else
	run numcli.p.

end.
