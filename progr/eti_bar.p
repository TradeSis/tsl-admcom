/*
 *
 * Recebe como Parametro um produto e emite etiquetas para a DREBES
 *
 */


{admcab.i}
def var vano as i format 99.
def var vmes as i format 99.
def input parameter par-rec as recid.
def input parameter  par-qtd as dec initial 2.
def var vproant as char format "x(8)".
def var vlinha as int.
def var wcopias as int.
def var wvezes  as int.
def var wetique as int.
def var wsobra  as int.
def var vconta as int.
def var vpos   as int.
def var vnome1 as char .
def var vnome2 as char.
def var vdata as char format "x(4)".
def temp-table wfetq
    field linha as int
    field comando as char format "x(70)".
    dos silent type .\vitor4.grf > com2.

    dos silent quoter value(search(".\luiz.zpl")) > .\luiz.ale.

input from .\luiz.ale no-echo.
    vlinha = 0.
    repeat:
        create wfetq.
        import
            comando.
        if comando = "" then do:
            delete wfetq.
            next.
        end.
        vlinha = vlinha + 1.
        wfetq.linha = vlinha.
    end.
    input close.

    find produ where recid(produ) = par-rec no-lock.
    vnome1 = substring(produ.pronom,1,18).
    vproant = string(int(produ.proant),"999999").
    find estoq where estoq.etbcod = 1 and
                     estoq.procod = produ.procod no-lock no-error.
    vano = if avail estoq
           then year(estoq.dtcrmer) - 1900
           else 00.
    vmes = if avail estoq
           then month(estoq.dtcrmer)
           else 00.

    vdata = if avail estoq
            then string(vano,"99") + string(vmes,"99")
            else "".


    wcopias = par-qtd.
    wvezes  = truncate(wcopias / 2,0).
    wvezes  = wvezes * 2.
    wetique = wvezes / 2.
    wsobra  = wcopias - wvezes.

    if wetique > 0
    then do:
      for each wfetq break by linha:
        if wfetq.linha = 5 or
           wfetq.linha = 16
        then vpos = 18.
        else if wfetq.linha = 2
             then vpos = 4.
             else if wfetq.linha = 7 or
                     wfetq.linha = 18
                  then vpos = 24.
                  else if wfetq.linha = 8 or
                          wfetq.linha = 19
                       then vpos = 24.

                  else if wfetq.linha = 9 or
                          wfetq.linha = 20
                       then vpos = 18.

                       else if wfetq.linha = 10 or
                               wfetq.linha = 21
                            then vpos = 18.

                       else if wfetq.linha = 12 or
                               wfetq.linha = 23
                            then vpos = 18.
                            else if wfetq.linha = 13 or
                                    wfetq.linha = 24
                                 then vpos = 32.
                                 else vpos = 25.

        assign
            substring(wfetq.comando,vpos) = if wfetq.linha = 5 or
                                             wfetq.linha = 16
                                          then string(vnome1,"x(18)")
                                    else if wfetq.linha = 7 or
                                            wfetq.linha = 18
                                         then string(produ.refer,"x(8)")
                                    else if wfetq.linha = 9 or
                                            wfetq.linha = 20
                                         then string(vdata,"9999")
                                    else if wfetq.linha = 10 or
                                            wfetq.linha = 21
                                         then string(vproant,"99.99.99")

                                    else substring(wfetq.comando,vpos).
        assign
            substring(wfetq.comando,vpos) = if wfetq.linha = 12 or
                                            wfetq.linha = 23
                                         then string(produ.tamcod,"xx")
                                    else if wfetq.linha = 8 or
                                            wfetq.linha = 19
                                         then string(produ.procod,">>>>>>>")
                                    else if wfetq.linha = 13 or
                                            wfetq.linha = 24
                                         then string(produ.procod,">>>>>>>")
                                    else if wfetq.linha = 02
                                         then string(wetique,"9999")
                                    else substring(wfetq.comando,vpos).
        end.

        output to value(".\cris" + string(produ.procod)).
        for each wfetq break by linha.
            put unformatted wfetq.comando skip.
        end.
        output close.
        if opsys = "UNIX"
        then unix silent lp -dbarra2
        value(".\cris" + string(produ.procod)).
        else dos silent type
                        value(".\cris" + string(produ.procod)) > com2.

    end.
    if wsobra > 0
    then do:
      for each wfetq break by linha:
        if wfetq.linha = 4
        then  do:
            delete wfetq.
            next.
        end.

        if wfetq.linha = 5 or
           wfetq.linha = 16
        then vpos = 18.
        else if wfetq.linha = 2
             then vpos = 4.
             else if wfetq.linha = 7 or
                     wfetq.linha = 18
                  then vpos = 24.
                  else if wfetq.linha = 8 or
                          wfetq.linha = 19
                       then vpos = 24.

                  else if wfetq.linha = 9 or
                          wfetq.linha = 20
                       then vpos = 18.

                       else if wfetq.linha = 10 or
                               wfetq.linha = 21
                            then vpos = 18.

                       else if wfetq.linha = 12 or
                               wfetq.linha = 23
                            then vpos = 18.
                            else if wfetq.linha = 13 or
                                    wfetq.linha = 24
                                 then vpos = 32.
                                 else vpos = 25.

        if wfetq.linha = 5
        then do:
            vconta = 0.
        end.
        if wfetq.linha >= 5
        then vconta = vconta + 1.
        if vconta <= wsobra
        then do:
        assign
            substring(wfetq.comando,vpos) = if wfetq.linha = 5 or
                                             wfetq.linha = 16
                                          then string(vnome1,"x(18)")
                                    else if wfetq.linha = 7 or
                                            wfetq.linha = 18
                                         then string(produ.refer,"x(8)")
                                    else if wfetq.linha = 9 or
                                            wfetq.linha = 20
                                         then string(vdata,"9999")

                                    else if wfetq.linha = 10 or
                                            wfetq.linha = 21
                                         then string(vproant,"99.99.99")

                                    else substring(wfetq.comando,vpos).
        assign
            substring(wfetq.comando,vpos) = if wfetq.linha = 12 or
                                            wfetq.linha = 23
                                         then string(produ.tamcod,"xx")
                                    else if wfetq.linha = 8 or
                                            wfetq.linha = 19
                                         then string(produ.procod,">>>>>>>")
                                    else if wfetq.linha = 13 or
                                            wfetq.linha = 24
                                         then string(produ.procod,">>>>>>>")
                                    else if wfetq.linha = 02
                                         then string(wetique,"9999")
                                    else substring(wfetq.comando,vpos).
        end.
        if vconta > wsobra
        then delete wfetq.
        if vconta = 2 then vconta = 0.
        end.
        output to value("crissob" + string(produ.procod)).
        for each wfetq break by linha.
            put unformatted wfetq.comando skip.
        end.
        output close.
        if opsys = "UNIX"
        then unix silent lp -dbarra2
                    value(".\crissob" + string(produ.procod)).
        else dos  silent type
                        value(".\crissob" + string(produ.procod)) > com2.
    end.

/* unix silent rm cris*. */
