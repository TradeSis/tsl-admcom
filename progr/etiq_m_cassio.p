/*
 *
 * Recebe como Parametro um produto e emite etiquetas para a DREBES
 *
 */


{admcab.i}
def var westac like estac.etcnom format "x(20)".
def var vano as i format 99.
def var vmes as i format 99.
def var vprocod like produ.procod. 
def var par-qtd as int.
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
if search("c:\temp\etique.bat") <> ?
then do:
    dos silent del c:\temp\etique.bat.
    dos silent c:\temp\cris*.* .
end.
*/

repeat:
    
    update vprocod with frame f1 side-label.

    find produ where produ.procod = vprocod no-lock.
    
    display produ.pronom no-label with frame f1.
    
    update par-qtd label "Quantidade" with frame f1.
     
    output to /admcom/zebra/tmp/moveis.bat.
     /* if opsys = "unix"  
     then */
        put "lpr -P zebra /admcom/zebra/lebes.grf " skip.
        /* else   
          "copy ../zebra/lebes.grf > prn" skip. */ 
       output close.

input from /admcom/zebra/moveis.ale no-echo.
vlinha = 0.
repeat:
    create wfetq.
    import
        comando.
    vlinha = vlinha + 1.
    wfetq.linha = vlinha.
end.
input close.

    find estac where estac.etccod = produ.etccod no-lock.
    find estoq where estoq.etbcod = estab.etbcod and
                     estoq.procod = produ.procod no-lock.


    wcopias = par-qtd.
    wvezes  = truncate(wcopias / 2,0).
    wvezes  = wvezes * 2.
    wetique = wvezes / 2.
    wsobra  = wcopias - wvezes.
    westac  = trim(
              string(estac.etcnom,"x(10)")   + " " +
              substring(string(year(today)),3,2) +
              string(month(today),"99")).


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
                       then vpos = 36.
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
                                            then string(estoq.estvenda,">>>>9.99")
                                            else if wfetq.linha = 7  or
                                                    wfetq.linha = 21
                                            then string(westac,"x(15)")
                                            else if wfetq.linha = 17 or
                                                    wfetq.linha = 31
                                            then string(produ.procod,"999999")
                                            else substring(wfetq.comando,vpos).
        end.

        output to value("../zebra/tmp/cris" + string(produ.procod)).
        for each wfetq break by linha.
            put unformatted wfetq.comando skip.
        end.
        output close.
        

        output to /admcom/zebra/tmp/moveis.bat append.
            put trim(" lpr -P zebra /admcom/zebra/tmp/cris" + 
                      string(produ.procod)) format "x(40)" skip.
        output close.
        

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
                       then vpos = 36.
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
                                            then string(estoq.estvenda,">>>>9.99")
                                            else if wfetq.linha = 29
                                            then string(0,">>>,>>")
                                            else if wfetq.linha = 17
                                            then string(produ.procod,"999999")
                                            else if wfetq.linha = 7  or
                                                    wfetq.linha = 21
                                            then string(westac,"x(15)")
                                            else if wfetq.linha = 31
                                            then string(0,">>>>>>")
                                            else substring(wfetq.comando,vpos).
        end.
        output to value("/admcom/zebra/tmp/crissob" + string(produ.procod)).
        for each wfetq break by linha.
            put unformatted wfetq.comando skip.
        end.
        output close.
        
        output to /admcom/zebra/tmp/moveis.bat append.
            put trim(" lpr -P zebra /admcom/zebra/tmp/crissob" + 
                      string(produ.procod)) format "x(40)" skip.
        output close.
        
    end.
    
    os-command  chmod 777 /admcom/zebra/tmp/*. 
    os-command  /admcom/zebra/tmp/moveis.bat. 
end.    
/* unix silent rm cris*. */
