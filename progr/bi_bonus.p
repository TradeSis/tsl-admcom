def var valorliberado as dec.
def var valorutilizado as dec.
def var valorexcluido as dec.



output to "/admcom/lebesintel/bi_bonus.csv".

 for each titulo where titulo.modcod = "BON"                                                       and titulo.titnat   = yes                                                       and titulo.titdtven >= today - 400 no-lock.


       find last plani where plani.movtdc    = 5
                                and plani.desti    = titulo.clifor
                                and plani.pladat   = titulo.titdtpag
                                  no-lock no-error.

        if avail plani then do:
            filialdobonus = plani.etbcod.
        end.
        else do:
            filialdobonus =  titulo.etbcod.
        end.



    valorutilizado = 0.
    valorliberado = 0.
    valorexcluido = 0.

    if titsit = "LIB" and titdtven >= today then do:
        valorliberado = fin.titulo.titvlcob.
    end.
 valorutilizado = 0.
    valorliberado = 0.
    valorexcluido = 0.

    if titsit = "LIB" and titdtven >= today then do:
        valorliberado = fin.titulo.titvlcob.
    end.

    if titsit = "PAG" then do:
        valorutilizado = fin.titulo.titvlpag.
    end.

    if titsit = "EXC" then do:
        valorexcluido = fin.titulo.titvlcob.
    end.


    put clifor ";" titvlcob format ">>>>>>>>>>9.99" ";"                                            titvlpag format ">>>>>>>>>>9.99" ";"

                                                                            YEAR(titdtemi) format "9999" "-" MONTH(titdtemi) format "99" "-"
DAY(titdtemi) format "99" ";"


   YEAR(titdtven) format "9999" "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";".                                                                                    if titdtpag <> ? then do:                                    put YEAR(titdtpag) format "9999" "-" MONTH(titdtpag) format "99" "-"
DAY(titdtpag) format "99" ";".
                    end.
                    else do:                                                                 put ";".
                    end.
                put    filialdobonus ";" titsit ";" valorliberado format ">>>>>.99" ";" valorutilizado format ">>>>>.99" ";" valorexcluido format ">>>>>.99" ";" titobs format "x(100)" ";" skip.
                       end.
                         output close.

