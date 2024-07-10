display string(time,"hh:mm:ss").

for each plani where no-lock:

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat:
    if movim.desti <> plani.desti then
        do transaction:
            movim.desti = plani.desti.
            movim.emite = plani.emite.
            display plani.etbcod
                    plani.pladat with 1 down. pause 0.
        end.
    end.
end.
display string(time,"hh:mm:ss").