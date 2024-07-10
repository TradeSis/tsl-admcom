{admcab.i}

if connected ("d")
then disconnect d. 

run conecta_d.p .

hide message no-pause.

if connected ("d")
then do:
    run dreb101.p .
end.

if connected ("d")
then disconnect d. 

return.