/*
 *
 * Recebe como Parametro um produto e emite etiquetas para a DREBES
 *
 */

{admcab.i}

def var varquivo-sobra as char.
def var varquivo as char.
/*def var vtime as int.*/
def var recimp as recid.

/* DREBES */
if opsys = "UNIX"
then do:
/*         os-command silent rm /admcom/relat/etique.bat.*/
end.
else do:        
         os-command silent del c:\temp\etique.bat.
end.

def var westac like estac.etcnom format "x(20)".
def var vano as i format 99.
def var vmes as i format 99.

def var wtaman as char format "x(8)".

def input parameter par-rec as recid. 
def input parameter par-qtd as dec.
def input parameter par-taman as char format "x(3)".
def input parameter  fila as char format "x(20)".
/*
/* USADO PARA TESTE*/
def var par-rec as recid.
def var par-qtd as dec.
def var par-taman as char form "x(03)".

find first produ where produ.procod = 10218 no-lock no-error.
if not avail produ 
then do:
       message "NAO ENCONTRADO" view-as alert-box.
       undo, retry.
end.
  
assign par-rec   = recid(produ)
       par-qtd   = 8
       par-taman = "MED".
*/
       
/*****def input parameter par-data  as char format "x(4)".*****/

def var vproant as char format "x(8)".
def var vlinha  as int.
def var wcopias as int.
def var wvezes  as int.
def var wetique as int.
def var wsobra  as int.
def var vconta  as int.
def var vpos    as int.
def var vnome1  as char.
def var vnome2  as char.
def var vdata   as char format "x(4)".
def var vdtped  as char form   "x(4)".
def var iprocod like produ.procod.

def buffer bf-produ for produ.

def temp-table wfetq
    field linha as int
    field comando as char format "x(70)".

if opsys = "UNIX"
then do:
    os-command silent /admcom/progr/cupszebra.sh  value(fila).
    os-command silent "lpr " value(fila) "/admcom/zebra/LEBES_S.GRF".
end.
else do:
    output to "c:\temp\etique.bat" append.
         put "c:\windows\command\mode com1:9600,e,7,2,r" skip
             "copy L:\zebra\LEBES_S.grf com1" skip.
    output close.
end.
/*
if opsys = "UNIX"
then input from /admcom/zebra/admcom9.ale no-echo.
else input from l:\zebra\admcom9.ale no-echo.
*/

if opsys = "UNIX"
then input from /admcom/progr/etiqueta-d.d no-echo.
else input from l:\progr\etiqueta-d.d no-echo.

vlinha = 0.


repeat:
    create wfetq.
    import
        comando.
    vlinha = vlinha + 1.
    wfetq.linha = vlinha.
end.
input close.

def var wcarac as char.

    find produ where recid(produ) = par-rec no-lock. 
    find estac where estac.etccod = produ.etccod no-lock.
    find estoq where estoq.etbcod = 1 and
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

    /* run pi-dataped. Conforme solicitacao Rafael sera utilizada data
                       da emissao no lugar de data do pedido */

    assign vdtped  = substring(string(year(today)),3,2) 
       + string(month(today),"99").

    wcopias = par-qtd.
    wvezes  = truncate(wcopias / 2,0).
    wvezes  = wvezes * 2.
    wetique = wvezes / 2.
    wsobra  = wcopias - wvezes.
    westac  = trim(
              string(estac.etcnom,"x(13)") /*  + " " +
              substring(string(year(today)),3,2) + 
              vdtped*/).
    
    wtaman =  "TAM.:" + string(par-taman,"x(3)").
    if wetique > 0
    then do:
      for each wfetq break by linha:
        
        if wfetq.linha = 6 or
           wfetq.linha = 7 or
           wfetq.linha = 8 or
           wfetq.linha = 17
        then vpos = 23.
        else if
           wfetq.linha = 18 or
           wfetq.linha = 19 or
           wfetq.linha = 20 or
           wfetq.linha = 14 or
           wfetq.linha = 26
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

        /*vtime = 0.
        vtime = time.*/

        if opsys = "UNIX"
        then do:
            varquivo = "".
            varquivo = "/admcom/zebra-fila/cris" 
                     + string(produ.procod) /*
                     + string(vtime) */.

            output to value(varquivo).
                            
                for each wfetq break by linha.
                    put unformatted wfetq.comando skip.
                end.
                
            output close.

            os-command silent /admcom/progr/cupszebra.sh  value(fila).
            os-command silent "lpr " value(fila) value(varquivo).
            
        end.
        else do:
            output to value("c:\temp\cris" + string(produ.procod) /*+ 
                                string(vtime)*/ ).
                for each wfetq break by linha.
                    put unformatted wfetq.comando skip.
                end.
            output close.

            output to "c:\temp\etique.bat" append.
                put trim(" type c:\temp\cris" 
                    + string(produ.procod) /*+ string(vtime)*/
                    + " > com1") format "x(40)" skip.
            output close.
        end.
        
    end.

    if wsobra > 0
    then do:
    
      for each wfetq break by linha:
        if wfetq.linha = 6 or
           wfetq.linha = 7 or
           wfetq.linha = 8 or
           wfetq.linha = 17
        then vpos = 23.
        else if wfetq.linha = 18 or
           wfetq.linha = 19 or
           wfetq.linha = 20 or
           wfetq.linha = 14 or
           wfetq.linha = 26
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

        /*vtime = 0.
        vtime = time.*/
        
        if opsys = "UNIX"
        then do:
            varquivo-sobra = "".
            varquivo-sobra = "/admcom/zebra-fila/crissob" 
                           + string(produ.procod) /*
                           + string(vtime).         */ .
                           
            output to value(varquivo-sobra).
                for each wfetq break by linha.
                    put unformatted wfetq.comando skip.
                end.
            output close.

            os-command silent /admcom/progr/cupszebra.sh  value(fila).
            os-command silent "lpr " value(fila) value(varquivo-sobra).

        end.
        else do:
            output to value("c:\temp\crissob" + string(produ.procod)
/*                                + string(vtime)*/ ).
            for each wfetq break by linha.
                put unformatted wfetq.comando skip.
            end.
            output close.
        
            output to "c:\temp\etique.bat" append.
                put trim(" type c:\temp\crissob" + 
                      string(produ.procod) /* + string(vtime)*/
                        + " > com1") format "x(40)" skip.
            output close.
        end.
    end.
    
    /*dos silent c:\temp\etique.bat.*/
    
/* unix silent rm cris*. */

/* ------------------------------------------------------------------------- */
procedure pi-dataped:
        
def var vdtfliped  as date form "99/99/9999".
def var vdtfpedid  as date form "99/99/9999".
def var vprocod    like produ.procod.
        
find first bf-produ where
           bf-produ.procod = iprocod no-lock no-error.
if avail bf-produ
then do:
        for each liped   of   bf-produ:
    
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
                                + string(month(vdtfpedid),"99").      
        end.
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
                                + string(month(today),"99").   
        end.            
end.

end procedure.                 
/* ------------------------------------------------------------------------- */ 
