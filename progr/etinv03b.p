/*
 *
 * Recebe como Parametro um produto e emite etiquetas para a DREBES
 *
*/

{admcab.i}

def var westac like estac.etcnom format "x(22)".
def input parameter par-rec as recid.
def input parameter par-qtd as dec initial 2.
def input parameter par-taman as char format "x(3)".
def var vproant as char format "x(8)".
def var vlinha as int.
def var wcopias as int.
def var wvezes  as int.
def var wetique as int.
def var wsobra  as int.
def var wcarac  as char.
def var vconta as int.
def var vpos   as int.
def var vnome1 as char .
def var vnome2 as char.
def var vdata as char format "x(4)".
def var vdtped  as char form   "x(4)".
def var iprocod like produ.procod.

def var varquivo as char.
def buffer bf-produ for produ.

def temp-table  wfetq
    field linha as int
    field comando as char format "x(70)".

if opsys = "UNIX"
then do:
    output to /admcom/zebra/03/eti-03.bat append.
        
     put "copy c:~\drebes~\lebes.grf prn" skip. 

    output close.
end.
else do:
    output to l:~\zebra~\03~\eti-03.bat append.
        
     put "copy c:~\drebes~\lebes.grf prn" skip. 

    output close.
end.
/*
output to l:\zebra\03\eti-03.bat append.
        
     put "copy c:\drebes\lebes.grf prn" skip. 

output close.
*/
/****
output to "c:\temp\etique.bat".
        
     put "c:\windows\command\mode com1:9600,e,7,2,r" skip
         "copy L:\zebra\LEBES_S.grf com1" skip.
         
output close.
***/
/*
dos silent
 c:\dlc\bin\quoter value(search("l:\progr\etiqueta-d.zpl")) > l:\progr\etiqueta-d.d.
*/  
  
if opsys = "UNIX"
then varquivo = "../progr/etiqueta-d1.d".
else varquivo = "..~\progr~\etiqueta-d1.d".
input from value(varquivo) no-echo.
vlinha = 0.
repeat:
    create wfetq.
    import comando.
    vlinha = vlinha + 1.
    wfetq.linha = vlinha.
end.
input close.

    find produ where recid(produ) = par-rec no-lock.
    find estac where estac.etccod = produ.etccod no-lock.
    find estoq where estoq.etbcod = 999 and
                     estoq.procod = produ.procod no-lock.
    wcarac = "".
    find first procaract where 
               procaract.procod = produ.procod no-lock no-error.
    if avail procaract
    then do:
        find first subcaract where
                   subcaract.subcar = procaract.subcod no-lock.
        wcarac = subcarac.subdes.           
    end.           
    assign iprocod = produ.procod.

    run pi-dataped.
    /*
    vdtped = string(month(today),"99") + string(day(today),"99").
    */
    wcopias = par-qtd.
    wvezes  = truncate(wcopias / 2,0).
    wvezes  = wvezes * 2.
    wetique = wvezes / 2.
    wsobra  = wcopias - wvezes.
    westac  = trim(
              string(estac.etcnom,"x(13)")) /*  + " " +
              /*substring(string(year(today)),3,2) +
              string(month(today),"99") + */
              vdtped +
              " TAM: " +
              string(par-taman,"x(3)"))*/.

    if wetique > 0
    then do:
      for each wfetq break by linha:
        
        if wfetq.linha = 6 or
           wfetq.linha = 7 or
           wfetq.linha = 8 or
           wfetq.linha = 17 or
           wfetq.linha = 28
        then vpos = 23.
        else if
           wfetq.linha = 18 or
           wfetq.linha = 19 or
           wfetq.linha = 20 or
           wfetq.linha = 14 or
           wfetq.linha = 26 or
           wfetq.linha = 29
        then vpos = 24.
        else if wfetq.linha = 5 
             then vpos = 22.
             else if wfetq.linha = 11 or
                     wfetq.linha = 23
                  then vpos = 24.
                  else if wfetq.linha = 15
                       then vpos = 34.
                       else if wfetq.linha = 27
                       then vpos = 35.
                       else if wfetq.linha = 3
                             then vpos = 4.
                       else vpos = 1.
        assign
            substring(wfetq.comando,vpos) = if wfetq.linha = 3
                                            then string(wetique,"9999")
                                            else if wfetq.linha = 15 or
                                               wfetq.linha = 27
                                            then string(produ.procod,"999999")
                                            else if wfetq.linha = 8 or
                                                    wfetq.linha = 20
                                            then string(produ.pronomc,"x(25)")
                                            else if wfetq.linha = 28 or
                                                    wfetq.linha = 29
                                            then 
           substr(string(produ.pronom,"x(60)"),26,25)
                                            else if wfetq.linha = 11 or
                                                    wfetq.linha = 23
                                            then string(estoq.estvenda,">>9.99")
                                            else if wfetq.linha = 7  or
                                                    wfetq.linha = 19
                                            then string(westac,"x(13)")
                                            else if wfetq.linha = 6 or
                                                    wfetq.linha = 18
                                            then string(wcarac,"x(17)")
                                            else if wfetq.linha = 5 or
                                                    wfetq.linha = 17
                                            then string(vdtped,"x(4)")
                                            else if wfetq.linha = 14 or
                                                    wfetq.linha = 26
                                            then string(caps(par-taman),"x(2)")
                                            else substring(wfetq.comando,vpos).
        end.
        if opsys = "UNIX"
        then varquivo = "/admcom/zebra/03/c" + string(produ.procod)
                               + "." + trim(string(par-taman,"x(3)")).
        else varquivo = "l:~\zebra~\03~\c" + string(produ.procod) 
                       + "." + trim(string(par-taman,"x(3)")).
        output to value(varquivo).  
            for each wfetq break by linha.
                put unformatted wfetq.comando skip.
            end.
        output close.
        if opsys = "UNIX"
        then varquivo = "/admcom/zebra/03/eti-03.bat".
        else varquivo = "l:~\zebra~\03~\eti-03.bat".
        output to value(varquivo) append.
            put trim(" type c:~\drebes~\c" + 
                      string(produ.procod)
                      + "." + string(par-taman,"x(3)")                      
                      + " > prn") format "x(40)" skip.
        output close.
    end.
    if wsobra > 0
    then do:
      for each wfetq break by linha:
        if wfetq.linha = 6 or
           wfetq.linha = 7 or
           wfetq.linha = 8 or
           wfetq.linha = 17  or
           wfetq.linha = 28
        then vpos = 23.
        else if wfetq.linha = 18 or
           wfetq.linha = 19 or
           wfetq.linha = 20 or
           wfetq.linha = 14 or
           wfetq.linha = 26 or
           wfetq.linha = 29
        then vpos = 24.
        else if wfetq.linha = 5 
             then vpos = 22.
             else if wfetq.linha = 11 or
                     wfetq.linha = 23
                  then vpos = 24.
                  else if wfetq.linha = 15 
                       then vpos = 34.
                       else if wfetq.linha = 27
                       then vpos = 35.
                       else if wfetq.linha = 3
                             then vpos = 4.
                       else vpos = 1.
        assign
            substring(wfetq.comando,vpos) = if wfetq.linha = 3
                                            then string(wsobra,"9999")
                                            else if wfetq.linha = 15 or
                                               wfetq.linha = 27
                                            then string(produ.procod,"999999")
                                            else if wfetq.linha = 8 or
                                                    wfetq.linha = 20
                                            then string(produ.pronomc,"x(25)")
                                            else if wfetq.linha = 28 or
                                                    wfetq.linha = 29
                                            then 
           substr(string(produ.pronom,"x(60)"),26,25)
                                            else if wfetq.linha = 11 or
                                                    wfetq.linha = 23
                                            then string(estoq.estvenda,">>9.99")
                                            else if wfetq.linha = 7  or
                                                    wfetq.linha = 19
                                            then string(westac,"x(13)")
                                            else if wfetq.linha = 6 or
                                                    wfetq.linha = 18
                                            then string(wcarac,"x(17)")
                                            else if wfetq.linha = 5 or
                                                    wfetq.linha = 17
                                            then string(vdtped,"x(4)") 
                                            else if wfetq.linha = 14 or
                                                    wfetq.linha = 26
                                            then string(caps(par-taman),"x(2)")
                                            else substring(wfetq.comando,vpos).
        end.
        if opsys = "UNIX"
        then varquivo = "/admcom/zebra/03/cr" + string(produ.procod) + 
                            "." + trim(string(par-taman,"x(3)")).
        else varquivo = "l:~\zebra~\03~\cr" + string(produ.procod) +
                            "." + trim(string(par-taman,"x(3)")).
        output to value(varquivo). 
        for each wfetq break by linha.
            put unformatted wfetq.comando skip.
        end.
        output close.
        if opsys = "UNIX"
        then varquivo = "/admcom/zebra/03/eti-03.bat".
        else varquivo = "l:~\zebra~\03~\eti-03.bat" .
        output to value(varquivo) append.
            put trim(" type c:~\drebes~\cr" + 
                      string(produ.procod) 
                      + "." + string(par-taman,"x(3)") 
                      + " > prn") format "x(40)" skip.
        output close.
    end.

/* ------------------------------------------------------------------------- */
procedure pi-dataped:
        
def var vdtfliped  as date form "99/99/9999".
def var vdtfpedid  as date form "99/99/9999".
def var vprocod    like produ.procod.
        
find first bf-produ where
           bf-produ.procod = iprocod no-lock no-error.
if avail bf-produ
then do:
        for each liped   of   bf-produ NO-LOCK:
    
            if liped.predtf <> ? 
            then assign vdtfliped = liped.predtf.
            else assign vdtfliped = liped.predt.
             
            for each pedid where
                     pedid.etbcod = liped.etbcod and
                     pedid.pedtdc = liped.pedtdc and
                     pedid.pednum = liped.pednum no-lock:
                
                if pedid.peddtf <> ?
                then assign vdtfpedid = pedid.peddtf.
                 
            end.          
    
        end.
        if vdtfpedid <> ?
        then do:
                assign vdtped = substring(string(year(vdtfpedid)),3,2)
                                + string(month(vdtfpedid),"99").                         end.
        if vdtped = ""
        then do:        
                if vdtfliped <> ?
                then do:
                        assign vdtped = substring(string(year(vdtfliped)),3,2)
                                      + string(month(vdtfliped),"99").
                end.
        end. 
        if vdtfpedid = ? and
           vdtfliped = ?
        then do:
                assign vdtped = substring(string(year(today)),3,2) 
                                + string(month(today),"99").                           end.            
end.

end procedure. 

/* ------------------------------------------------------------------------- */

