pause 0 before-hide.
disable triggers for load of clien.
for each clien .
    if estciv = 6 and falecido = no
    then do:
        falecido = yes.
        run cli/statuscadins.p (input clien.clicod, "STATUSCAD_FALECIDO", ?).
    end.
    if genero = "" or genero = ?
    then do:
        genero = string(clien.sexo,"Masculino/Feminino").
        if clien.sexo = ?
        then genero = "Prefiro nao informar".
    end.
    disp falecido sexo genero estciv idstatuscad.
                        
end.