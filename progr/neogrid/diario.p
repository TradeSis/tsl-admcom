
/* 10.04.19 helio.neto , elimina o programa diario.p */


if weekday(today) = 1 /* domingo */
then do: 
    run /admcom/progr/neogrid/expneogridh2.p (input "SEMANAL" ,
                                            input today - 7,
                                            input today - 1).
end.
else do:
    run /admcom/progr/neogrid/expneogridh2.p (input "DIARIO" ,
                                input today - 1,
                                input today - 1).
end.

