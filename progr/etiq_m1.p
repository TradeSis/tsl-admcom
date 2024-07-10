
{admcab.i}

def input parameter vrecid as recid.
def input parameter par-qtd as int.
def input parameter fila as char.
 
def var vtime as int.
def temp-table tt-pro
    field procod like produ.procod
    index i-pro is primary unique procod.
    
def var recimp as recid.

def var varquivo-etiq as char.
def var varquivo-etiq-sai-sob as char.
def var varquivo-etiq-sai as char.

def var westac like estac.etcnom format "x(20)".
def var vano as i format 99.
def var vmes as i format 99.
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

def var vprocod like produ.procod.

repeat:
    pause 0.   

    for each tt-pro.
        delete tt-pro.
    end.
    
    find produ where recid(produ) = vrecid no-lock no-error.
    vprocod = produ.procod.
    
    /* testa kit */
    
    find first kit where kit.procod = produ.procod no-lock no-error.
    if avail kit
    then do:
        for each kit where kit.procod = produ.procod no-lock:
            find tt-pro where tt-pro.procod = kit.itecod no-error.
            if not avail tt-pro
            then do:
                create tt-pro.
                assign tt-pro.procod = kit.itecod.
            end.
        end.
    end.

    /***
    find first wbsprokit where wbsprokit.procod = produ.procod no-lock no-error.
    if avail wbsprokit
    then do:
        for each wbsprokit where wbsprokit.procod = produ.procod no-lock:
            find tt-pro where tt-pro.procod = wbsprokit.codigoproduto no-error.
            if not avail tt-pro
            then do:
                create tt-pro.
                assign tt-pro.procod = wbsprokit.codigoproduto.
            end.
        end.
    end.
    ****/
    else do:
        find tt-pro where tt-pro.procod = produ.procod no-error.
        if not avail tt-pro
        then do:
            create tt-pro.
            assign tt-pro.procod = produ.procod.
        end.
    end.
    /*****
    if opsys = "UNIX"
    then do:
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do:
            run acha_imp.p (input recid(impress), 
                            output recimp).
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp). 
        end.
    end.    
    else fila = "".
    *****/
    if opsys = "UNIX"
    then do:
        os-command silent /admcom/progr/cupszebra.sh  value(fila).
        os-command silent "lpr " value(fila) " /admcom/zebra/lebes.grf".
    end. 
    else do:  
       output to "c:\temp\lebes-grf.bat".
        
             put "c:\windows\command\mode com1:9600,e,7,2,r" skip
                      "copy l:\zebra\lebes.grf com1" skip.

       output close.
                      
       os-command silent etique.bat. 
    end.
    
    if opsys = "UNIX"
    then varquivo-etiq = "/admcom/zebra/moveis.ale.jc".
    else varquivo-etiq = "l:\zebra\moveis.ale.jc".
    
    input from value(varquivo-etiq) no-echo.
    
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


    wcopias = par-qtd.
    wvezes  = truncate(wcopias / 2,0).
    wvezes  = wvezes * 2.
    wetique = wvezes / 2.
    wsobra  = wcopias - wvezes.
    westac  = trim(
              string(estac.etcnom,"x(10)")   + " " +
              substring(string(year(today)),3,2) +
              string(month(today),"99")).

    FOR EACH TT-PRO:
        find produ where produ.procod = tt-pro.procod no-lock no-error.

            
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
                                        then string(produ.procod,">>>>>>>>>9")
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
                                            then string(produ.procod,">>>>>>>>>9")
                                            else substring(wfetq.comando,vpos).
        end.

        vtime = 0.
        vtime = time.
        
        if opsys = "UNIX"
        then varquivo-etiq-sai = "/admcom/zebra-fila/cris"
                               + string(produ.procod,"9999999999")
                               + string(vtime).
        else varquivo-etiq-sai = "l:\zebra-fila\cris"
                               + string(produ.procod,"9999999999")
                               + string(vtime).
        
        output to value(varquivo-etiq-sai).
        
            for each wfetq break by linha.
                put unformatted wfetq.comando skip.
            end.

        output close.
        
        if opsys = "UNIX"
        then do:
            os-command silent /admcom/progr/cupszebra.sh  value(fila).

            os-command silent "lpr " value(fila) value(varquivo-etiq-sai).
        end.
        else do:
            os-command silent "copy " value(varquivo-etiq-sai) " > com1".
        end.

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
                                            then string(produ.procod,">>>>>>>>>9")
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
                                            then string(produ.procod,">>>>>>>>>9")
                                            else if wfetq.linha = 7  or
                                                    wfetq.linha = 21
                                            then string(westac,"x(15)")
                                            else if wfetq.linha = 31
                                            then string(0,">>>>>>")
                                            else substring(wfetq.comando,vpos).
        end.

        vtime = 0.
        vtime = time.
        
        if opsys = "UNIX"
        then varquivo-etiq-sai-sob = "/admcom/zebra-fila/crissob"
                                   + string(produ.procod,"9999999999")
                                   + string(vtime).
        else varquivo-etiq-sai-sob = "l:\zebra-fila\crissob"
                                   + string(produ.procod,"9999999999")
                                   + string(vtime).
        
        output to value(varquivo-etiq-sai-sob).

            for each wfetq break by linha.
                put unformatted wfetq.comando skip.
            end.
        
        output close.
        
        if opsys = "UNIX"
        then do:
            os-command silent /admcom/progr/cupszebra.sh  value(fila).
            os-command silent "lpr " value(fila) value(varquivo-etiq-sai-sob).
        end.
        else do:
            os-command silent "copy " value(varquivo-etiq-sai-sob) " > com1".
        end.
    end.
    
    END.
    leave.
end.    
