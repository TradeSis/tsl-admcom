{admcab.i}

if connected ("d")
then disconnect d.

run conecta_d.p.
hide message no-pause.

if connected ("d")
then do.
    run pagedeve00.p.
    disconnect d.
end.
else message "Sem conexao com bancos ... D" view-as alert-box.

