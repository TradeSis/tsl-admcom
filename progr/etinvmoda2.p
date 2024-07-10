/*
 *
 * Recebe como Parametro um produto e emite etiquetas para a DREBES
 *
etiqbz03-1.p
*/
{admcab.i}

def input parameter par-rec   as recid. 
def input parameter par-qtd   as int.
def input parameter par-desti as int.
def input parameter par-model as int.
def input parameter par-fila  as char format "x(20)".

def var varquivo-sobra as char.
def var varquivo as char.
def var vgrupo   as char.
def var vlinha   as int.
def var wcopias  as int.
def var wvezes   as int.
def var wetique  as int.
def var wsobra   as int.
def var vpos     as int.
def var vexpos   as char.
def var vcor     as char.
def var vtemporada like estac.etcnom format "x(20)".

def buffer bclasse for clase.
def buffer bgrupo  for clase.

def temp-table wfetq
    field linha as int
    field comando as char format "x(70)".

if par-desti = 1 /* Arquivo */
then do.
    if opsys = "UNIX"
    then do:
        output to value("/admcom/zebra/" + par-fila + "/eti-" + par-fila +
            ".bat") append.
        put "copy c:~\drebes~\lebes2.grf prn" skip. 
        output close.
    end.
    else do:
        output to l:~\zebra~\01~\eti-01.bat append.
        put "copy c:~\drebes~\lebes2.grf prn" skip. 
        output close.
    end.
end.
else if par-desti = 2 /* Impressora */
then do.
    if opsys = "UNIX"
    then do:
        os-command silent /admcom/progr/cupszebra.sh  value(par-fila).
        os-command silent "lpr " value(par-fila) "/admcom/zebra/LEBES2.GRF".
    end.
    else do:
        os-command silent del c:\temp\etique.bat.
        output to "c:\temp\etique.bat" append.
        put "c:\windows\command\mode com1:9600,e,7,2,r" skip
             "copy L:\zebra\LEBES2.grf com1" skip.
        output close.
    end.
end.

if par-model = 1
then
    if opsys = "UNIX"
    then input from /admcom/progr/etiqueta-moda-cl.zpl no-echo.
    else input from l:\progr\etiqueta-moda-cl.zpl no-echo.
else
    if opsys = "UNIX"
    then input from /admcom/progr/etiqueta-moda-fp.zpl no-echo.
    else input from l:\progr\etiqueta-moda-fp.zpl no-echo.

vlinha = 0.
repeat:
    create wfetq.
    import comando.
    vlinha = vlinha + 1.
    wfetq.linha = vlinha.
end.
input close.

assign
    vgrupo = ""
    vexpos = ""
    vcor   = ""
    vtemporada = "".

find produ where recid(produ) = par-rec no-lock.
find cor of produ no-lock no-error.
find temporada of produ no-lock no-error.
find estoq where estoq.etbcod = estab.etbcod and
                 estoq.procod = produ.procod no-lock.
find clase of produ no-lock.
find bclasse where bclasse.clacod = clase.clasup no-lock no-error.
if avail bclasse
then do.
    find bgrupo where bgrupo.clacod = bclasse.clacod no-lock no-error.
    if avail bgrupo
    then vgrupo = bgrupo.clanom.
end.

if avail cor
then vcor = cor.cornom.

for each procaract of produ no-lock.
    find subcaract of procaract no-lock.
    if subcaract.subcod = 11
    then vexpos = subcaract.subdes.
end.

if avail temporada
then vtemporada = temporada.tempnom.

assign
    vcor   = string(vcor, "x(18)")
    vexpos = string(vexpos, "x(08)")
    vgrupo = string(vgrupo, "x(18)").
    vtemporada = string(vtemporada, "x(18)").
    
    wcopias = par-qtd.
    wvezes  = truncate(wcopias / 2,0).
    wvezes  = wvezes * 2.
    wetique = wvezes / 2.

    wsobra  = wcopias - wvezes.
                         
if wetique > 0
then do:
    for each wfetq break by linha:
        run etiqueta.
    end.

    if par-desti = 1 /* Arquivo */
    then do.
        if opsys = "UNIX"
        then varquivo = "/admcom/zebra/" + par-fila + "/c" + 
                         string(produ.procod) + "." + trim(produ.protam).
        else varquivo = "l:~\zebra~\01~\c" + string(produ.procod) 
                       + "." + trim(produ.protam).
        output to value(varquivo).               
        for each wfetq break by linha.
             put unformatted wfetq.comando skip.
        end.
        output close.
        if opsys = "UNIX"
        then varquivo = "/admcom/zebra/" + par-fila + "/eti-" + par-fila +
                        ".bat".
        else varquivo = "l:~\zebra~\01~\eti-01.bat".
        output to value(varquivo) append.
        put trim(" type c:~\drebes~\c" + string(produ.procod) + "." +
                 trim(produ.protam) + " > prn") format "x(40)" skip.
        output close.
    end.
    else if par-desti = 2 /* Impressora */
    then do.
        if opsys = "UNIX"
        then do:
            varquivo = "".
            varquivo = "/admcom/zebra-fila/cris" + string(produ.procod).

            output to value(varquivo).
            for each wfetq break by linha.
                put unformatted wfetq.comando skip.
            end.
            output close.

            os-command silent /admcom/progr/cupszebra.sh  value(par-fila).
            os-command silent "lpr " value(par-fila) value(varquivo).
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
end.

if wsobra > 0
then do:
    for each wfetq break by linha:
        run etiqueta.
    end.

    if par-desti = 1 /* Arquivo */
    then do.
        if opsys = "UNIX"
        then varquivo = "/admcom/zebra/" + par-fila + "/cr" +
                        string(produ.procod) + "." + trim(produ.protam).
        else varquivo = "l:~\zebra~\01~\cr" + string(produ.procod) +
                            "." + trim(produ.protam).
        output to value(varquivo).                    
        for each wfetq break by linha.
            put unformatted wfetq.comando skip.
        end.
        output close.
        if opsys = "UNIX" /* etinn.bat */
        then varquivo = "/admcom/zebra/" + par-fila + "/eti-" + par-fila +
                        ".bat".
        else varquivo = "l:~\zebra~\01~\eti-01.bat" .
        output to value(varquivo) append.
            put trim(" type c:~\drebes~\cr" + string(produ.procod) + "." +
                     trim(produ.protam) + " > prn") format "x(40)" skip.
        output close.
    end.
    else if par-desti = 2 /* Impressora */
    then do.
        if opsys = "UNIX"
        then do:
            varquivo-sobra = "/admcom/zebra-fila/crissob" +
                             string(produ.procod).
            output to value(varquivo-sobra).
            for each wfetq break by linha.
                put unformatted wfetq.comando skip.
            end.
            output close.

            os-command silent /admcom/progr/cupszebra.sh  value(par-fila).
            os-command silent "lpr " value(par-fila) value(varquivo-sobra).
        end.
        else do:
            output to value("c:\temp\crissob" + string(produ.procod)).
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
end.

procedure etiqueta.

        if wfetq.linha = 5 or
           wfetq.linha = 6 or
           wfetq.linha = 7 or
           wfetq.linha = 8 or
           wfetq.linha = 11 or
           wfetq.linha = 12 or
           wfetq.linha = 14 or
           wfetq.linha = 17 or
           wfetq.linha = 18 or
           wfetq.linha = 19 or
           wfetq.linha = 20 or
           wfetq.linha = 23 or
           wfetq.linha = 24 or
           wfetq.linha = 26 or
           wfetq.linha = 28 or
           wfetq.linha = 29
        then vpos = 24.
        else if wfetq.linha = 15 or
                wfetq.linha = 27
        then vpos = 33.
        else if wfetq.linha = 3
        then vpos = 4.
        else vpos = 1.

        assign
            substring(wfetq.comando,vpos) = if wfetq.linha = 3
                                            then string(wetique,"9999")
                                            else if wfetq.linha = 15 or
                                                    wfetq.linha = 27
                                            then string(produ.procod,"9999999")
                                            else if wfetq.linha = 8 or
                                                    wfetq.linha = 20
                                            then string(produ.pronom,"x(30)")
                                            else if wfetq.linha = 28 or
                                                    wfetq.linha = 29
                                            then 
                                     string(substr(produ.pronom,31,30),"x(30)")
                                            else if wfetq.linha = 11 or
                                                    wfetq.linha = 23
                                            then string(estoq.estvenda,">>9.99")
                                            else if wfetq.linha = 7  or
                                                    wfetq.linha = 19
                                            then vtemporada
                                            else if wfetq.linha = 6 or
                                                    wfetq.linha = 18
                                            then vgrupo
                                            else if wfetq.linha = 5 or
                                                    wfetq.linha = 17
                                            then vexpos
                                            else if wfetq.linha = 14 or
                                                    wfetq.linha = 26
                                            then string(produ.protam,"x(2)")
                                            else if wfetq.linha = 12 or
                                                    wfetq.linha = 24
                                            then vcor
                                            else substring(wfetq.comando,vpos).

end procedure.    
