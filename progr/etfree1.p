/*
 *
 * Recebe como Parametro um produto e emite etiquetas para a DREBES
 *
 */


{admcab.i}
def var westac like estac.etcnom.
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
/*
dos silent type h:\zebra\lebes.grf > com2.

dos silent mode com2:9600,e,7,2 .
dos silent copy ..\zebra\lebes.grf com2 .


dos silent quoter value(search("..\cadas\luiz4.zpl")) > .\admcom.ale.
*/
input from ..\work\admcom.ale no-echo.
vlinha = 0.
repeat:
    create wfetq.
    import
        comando.
/*
    if comando = "" then do:
        delete wfetq.
        next.
    end.
*/
    vlinha = vlinha + 1.
    wfetq.linha = vlinha.
end.
input close.

    find produ where recid(produ) = par-rec no-lock.
    find estac where estac.etccod = produ.etccod no-lock.
    find estoq where estoq.etbcod = 999 and
                     estoq.procod = produ.procod no-lock.


    wcopias = par-qtd.
    wvezes  = truncate(wcopias / 2,0).
    wvezes  = wvezes * 2.
    wetique = wvezes / 2.
    wsobra  = wcopias - wvezes.
    westac  = estac.etcnom.


    if wetique > 0
    then do:
      for each wfetq break by linha:
        if wfetq.linha = 11 or
           wfetq.linha = 12 or
           wfetq.linha = 25 or
           wfetq.linha = 26
        then vpos = 18.
        else if wfetq.linha = 13 or
                wfetq.linha = 27
             then vpos = 33.
             else if wfetq.linha = 15 or
                     wfetq.linha = 29
                  then vpos = 18.
                  else if wfetq.linha = 17 or
                          wfetq.linha = 31
                       then vpos = 25.
                       else if wfetq.linha = 4
                             then vpos = 4.
                       else vpos = 1.
        if wfetq.linha = 7
        then vpos = 18.
        if wfetq.linha = 21
        then vpos = 18.
        assign
            substring(wfetq.comando,vpos) = if wfetq.linha = 4
                                            then string(wetique,"9999")
                                            else if wfetq.linha = 11 or
                                               wfetq.linha = 12 or
                                               wfetq.linha = 25 or
                                               wfetq.linha = 26
                                            then string(produ.procod,"999999")
                                            else if wfetq.linha = 13 or
                                                    wfetq.linha = 27
                                            then string(produ.pronom,"x(44)")
                                            else if wfetq.linha = 15 or
                                                    wfetq.linha = 29
                                            then string(estoq.estvenda,">>9.99")
                                            else if wfetq.linha = 7  or
                                                    wfetq.linha = 21
                                            then string(estac.etcnom,"x(12)")
                                            else if wfetq.linha = 17 or
                                                    wfetq.linha = 31
                                            then string(produ.procod,"999999")
                                            else substring(wfetq.comando,vpos).
        end.

        output to value("cris" + string(produ.procod)).
        for each wfetq break by linha.
            put unformatted wfetq.comando skip.
        end.
        output close.
        if opsys = "UNIX"
        then unix silent lp -dbarra2
        value(".\cris" + string(produ.procod)).
        else dos silent type
             value("cris" + string(produ.procod)) > com2.
    end.
    if wsobra > 0
    then do:
      for each wfetq break by linha:
        if wfetq.linha = 11 or
           wfetq.linha = 12 or
           wfetq.linha = 25 or
           wfetq.linha = 26
        then vpos = 18.
        else if wfetq.linha = 13 or
                wfetq.linha = 27
             then vpos = 33.
             else if wfetq.linha = 15 or
                     wfetq.linha = 29
                  then vpos = 18.
                  else if wfetq.linha = 17 or
                          wfetq.linha = 31
                       then vpos = 25.
                        else if wfetq.linha = 4
                             then vpos = 4.
                       else vpos = 1.

        if wfetq.linha = 7
        then vpos = 18.
        if wfetq.linha = 21
        then vpos = 18.

        assign
            substring(wfetq.comando,vpos) = if wfetq.linha = 4
                                            then string(wsobra,"9999")
                                            else if wfetq.linha = 11 or
                                               wfetq.linha = 12
                                            then string(produ.procod,"999999")
                                            else if wfetq.linha = 25 or
                                               wfetq.linha = 26
                                            then string(0,">>>>>>")
                                            else if wfetq.linha = 13
                                            then string(produ.pronom,"x(44)")
                                            else if wfetq.linha = 27
                                            then string("","x(44)")
                                            else if wfetq.linha = 15
                                            then string(estoq.estvenda,">>9.99")
                                            else if wfetq.linha = 29
                                            then string(0,">>>,>>")
                                            else if wfetq.linha = 17
                                            then string(produ.procod,"999999")
                                            else if wfetq.linha = 7  or
                                                    wfetq.linha = 21
                                            then string(estac.etcnom,"x(12)")
                                            else if wfetq.linha = 31
                                            then string(0,">>>>>>")
                                            else substring(wfetq.comando,vpos).
        end.
        /*
        if vconta > wsobra
        then delete wfetq.
        if vconta = 2 then vconta = 0.
        */
        output to value("crissob" + string(produ.procod)).
        for each wfetq break by linha.
            put unformatted wfetq.comando skip.
        end.
        output close.
        if opsys = "UNIX"
        then unix silent lp -dbarra2
        value(".\crissob" + string(produ.procod)).
        else dos silent type
             value("crissob" + string(produ.procod)) > com2.
    end.

/* unix silent rm cris*. */
