/*      Rodap‚ de Encerramento de Relat¢rio      */

put unformatted chr(27) + "P" + chr(18).
put unformatted chr(27) + "2".
output close.


pause 0.

sresp = yes.

if sresp
then

    IF SEARCH("c:\custom\imp.exe") <> ? 
    THEN DO:
        output to value(varquivo + ".cab").
            scabrel = trim(varquivo)  + "@" +
                trim(wempre.emprazsoc) + "@" +
                trim(scabrel)       + "@".
            put scabrel format "x(400)" skip.
        output close.
        OS-COMMAND silent c:\custom\imp value(varquivo + ".cab").
    END.
    else do :
        dos silent value("type " + varquivo + " > prn").  
    end.
