/* Recebe como Parametro um produto e emite etiquetas para a DREBES */


{admcab.i}

def var vvolume as char format "x(5)".
def var wint as i.

def var conta as i.

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

repeat:
    for each wfetq.
        delete wfetq.
    end.

    update vprocod with frame f1 side-label.

    find produ where produ.procod = vprocod no-lock.
    
    display produ.pronom no-label with frame f1.
    
    update par-qtd label "Quantidade" with frame f1.
     
    IF OPSYS = "UNIX"
    THEN DO:
        output to /tmp/moveis.bat.
    
            put "lpr -P zebra /admcom/zebra/lebes.grf " skip.

        output close.
    END. /*
    ELSE DO:
        output to c:\temp\moveis.bat.
    
            put "type l:\zebra\lebes.grf > prn" skip.

        output close.
    END.   */


IF OPSYS = "UNIX"
THEN
    input from /admcom/zebra/mov-vol.ale no-echo.
ELSE
    input from l:\zebra\mov-vol.ale no-echo.

vlinha = 0.
repeat:
    create wfetq.
    import comando.
    vlinha = vlinha + 1.   
    wfetq.linha = vlinha.
end.

input close.

    find estac where estac.etccod = produ.etccod no-lock.
    find estoq where estoq.etbcod = estab.etbcod and
                     estoq.procod = produ.procod no-lock.


    wcopias = (par-qtd * (if produ.procvcom > 0
                          then produ.procvcom
                          else 1)).
                          
    wvezes  = truncate(wcopias / 2,0).
    wvezes  = wvezes * 2.
    wetique = wvezes / 2.
    wsobra  = wcopias - wvezes.
    westac  = trim(
              string(estac.etcnom,"x(10)")   + " " +
              substring(string(year(today)),3,2) +
              string(month(today),"99")).

    do conta = 1 to wetique:
    
        if wint >= produ.procvcom
        then wint = 0.
        
        wint = wint + 1.
        
        vvolume =  string(wint,"99") + "/" + string(produ.procvcom,"99").
        
        if wetique > 0
        then
            run etiq .
    
        
    end.
    
    if wsobra > 0
    then
        run sobra .

    /*******    os-command silent /tmp/moveis.bat. ***/
    
end.    


procedure etiq.


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
        
        /* if wfetq.linha = 6
           then vpos = 18.    */
        
        assign
            substring(wfetq.comando,vpos) = /*if wfetq.linha = 6
                                            then string(vvolume,"x(5)")
                                            else*/
                                            if wfetq.linha = 4
                                            then /*string(wetique,"9999")*/
                                                 string(2,"9999")
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
                                            then string(westac,"x(15)")
                                            else if wfetq.linha = 17 or
                                                    wfetq.linha = 31
                                            then string(produ.procod,"999999")
                                            else substring(wfetq.comando,vpos).
        end.

        
        IF OPSYS = "UNIX"
        THEN DO:
            output to /tmp/moveis.bat.
                put trim(" lpr -P zebra /tmp/cris" + 
                          string(produ.procod) + string(conta,"99"))
                          format "x(40)" skip.
            output close.
        END. /*
        ELSE DO:
            output to c:\temp\moveis.bat append.
                put trim(" type c:\temp\cris" + 
                          string(produ.procod) + string(conta,"99")
                          + " > prn")
                          format "x(40)" skip.
            output close.
        END.   */
        
        
        IF OPSYS = "UNIX"
        THEN DO:
            output to value("/tmp/cris" + string(produ.procod) +
                            string(conta,"99")).
            for each wfetq break by linha.
                put unformatted wfetq.comando skip.
            end.
            output close.
        END.      /*
        ELSE DO:
            output to value("c:\temp\cris" + string(produ.procod) +
                            string(conta,"99")).
            for each wfetq break by linha.
                put unformatted wfetq.comando skip.
            end.
            output close.
        END.    */

    end.
    IF OPSYS = "UNIX"
    THEN
        os-command silent /tmp/moveis.bat.
    ELSE
        os-command silent c:\temp\moveis.bat.    

end procedure.

procedure sobra.
    

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
            substring(wfetq.comando,vpos) = if wfetq.linha = 6
                                            then string(vvolume,"x(5)")
                                            else
                                            if wfetq.linha = 4
                                            then /*string(wsobra,"9999")*/
                                                 string(2,"9999")
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
                                            then string(westac,"x(15)")
                                            else if wfetq.linha = 31
                                            then string(0,">>>>>>")
                                            else substring(wfetq.comando,vpos).
        end.

        IF OPSYS = "UNIX"
        THEN DO:
            output to /tmp/moveis.bat.
                put trim(" lpr -P zebra /tmp/crissob" + 
                          string(produ.procod) + string(conta,"99"))
                          format "x(40)" skip.
            output close.
        END.  /*
        ELSE DO:
            output to c:\temp\moveis.bat append.
                put trim(" type c:\temp\crissob" + 
                          string(produ.procod) + string(conta,"99")
                          + " > prn")
                          format "x(40)" skip.
            output close.
        END.    */


        IF OPSYS = "UNIX"
        THEN DO:
            output to value("/tmp/crissob" + string(produ.procod) + 
                             string(conta,"99")).
                for each wfetq break by linha.
                    put unformatted wfetq.comando skip.
                end.
        
            output close.        
        END.   /*
        ELSE DO:
            output to value("c:\tmp\crissob" + string(produ.procod) + 
                             string(conta,"99")).
                for each wfetq break by linha.
                    put unformatted wfetq.comando skip.
                end.
        
            output close.
        END.*/
        
        IF OPSYS = "UNIX"
        THEN
            os-command silent /tmp/moveis.bat.
        ELSE
            os-command silent c:\temp\moveis.bat.    
        
        
    end.


end procedure.
