/* disparador - seta PROPATH */
DEF var pidrelat as int64.
DEF VAR pprog    AS CHAR.
DEF VAR vdir     AS char.
DEF VAR vpini     AS CHAR.

vdir = entry(3,SESSION:PARAMETER,",") no-error.
INPUT FROM VALUE(vdir + "tsrelat.ini").
repeat TRANSACTION:
    IMPORT UNFORMATTED vpini.
    if vpini = "" or vpini = ? then next.
   
    if ENTRY(1,vpini,"=") = "PROPATH"    THEN propath = ENTRY(2,vpini,"=").
end.
input close.

pprog = entry(2,SESSION:PARAMETER,",") no-error.
if pprog <> ? then do:
   RUN VALUE(vdir + pprog + ".p").
END.
