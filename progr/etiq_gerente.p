/*
 *
 * Recebe como Parametro um produto e emite etiquetas para a DREBES
 *
 */


{admcab.i}
def input parameter vsenha like estab.vencota.
def var westac like estac.etcnom format "x(20)".
def var vano as i format 99.
def var vmes as i format 99.
def var par-qtd as int initial 1.
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

     
output to c:\temp\gerente.bat.
        
     put /* "c:\windows\command\mode com2:9600,e,7,2,r" skip */
         "copy ..\zebra\lebes.grf prn" skip. 
         
output close.

input from ..\zebra\gerente.ale no-echo.
vlinha = 0.
repeat:
    create wfetq.
    import comando.
    vlinha = vlinha + 1.
    wfetq.linha = vlinha.
end.
input close.


    wcopias = par-qtd.
    wvezes  = truncate(wcopias / 2,0).
    wvezes  = wvezes * 2.
    wetique = wvezes / 2.
    wsobra  = wcopias - wvezes.
    

    if wetique > 0
    then do:
      for each wfetq break by linha:
        if wfetq.linha = 11 or
           wfetq.linha = 12 or
           wfetq.linha = 25 or
           wfetq.linha = 18
        then vpos = 26.
        else if wfetq.linha = 13 or
                wfetq.linha = 27
             then vpos = 33.
             else if wfetq.linha = 15 or
                     wfetq.linha = 29
                  then vpos = 18.
                  else if wfetq.linha = 17 or
                          wfetq.linha = 19 or
                          wfetq.linha = 31
                       then vpos = 26.
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
                                            else if wfetq.linha = 10 or
                                               wfetq.linha = 12 or
                                               wfetq.linha = 18 or
                                               wfetq.linha = 16
                                            then string(vsenha,"999999")
                                            else if wfetq.linha = 17 or
                                                    wfetq.linha = 19 or
                                                    wfetq.linha = 31
                                            then string(vsenha,"999999")
                                            else substring(wfetq.comando,vpos).
        end.

        output to value("c:\temp\cris" + string(vsenha)).
        for each wfetq break by linha.
            put unformatted wfetq.comando skip.
        end.
        output close.
        

        output to c:\temp\gerente.bat append.
            put trim(" type c:\temp\cris" + 
                      string(vsenha) + " > prn") format "x(40)" skip.
        output close.
        

    end.
    if wsobra > 0
    then do:
      for each wfetq break by linha:
        if wfetq.linha = 11 or
           wfetq.linha = 12 or
           wfetq.linha = 25 or
           wfetq.linha = 18
        then vpos = 26.
        else if wfetq.linha = 13 or
                wfetq.linha = 27
             then vpos = 33.
             else if wfetq.linha = 15 or
                     wfetq.linha = 29
                  then vpos = 18.
                  else if wfetq.linha = 17 or
                          wfetq.linha = 19 or
                          wfetq.linha = 31
                       then vpos = 26.
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
                                            else if wfetq.linha = 10 or
                                               wfetq.linha = 16
                                            then string(vsenha,"999999")
                                            else if wfetq.linha = 25 or
                                               wfetq.linha = 26
                                            then string(0,">>>>>>")
                                            else if wfetq.linha = 17 or
                                                    wfetq.linha = 19 or
                                                    wfetq.linha = 31
                                            then string(vsenha,"999999")
                                            else substring(wfetq.comando,vpos).
        end.
        output to value("c:\temp\crissob" + string(vsenha)).
        for each wfetq break by linha.
            put unformatted wfetq.comando skip.
        end.
        output close.
        
        output to c:\temp\gerente.bat append.
            put trim(" type c:\temp\crissob" + 
                      string(vsenha) + " > prn") format "x(40)" skip.
        output close.
        
    end.
                                  
    dos silent c:\temp\gerente.bat. 
