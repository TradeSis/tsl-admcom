display string(time,"hh:mm:ss").

for each plani no-lock:

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat:

        do transaction:
            movim.desti = plani.desti.
            movim.emite = plani.emite.
        end.
    end.
    display plani.etbcod
            plani.pladat with 1 down. pause 0.
end.
display string(time,"hh:mm:ss").