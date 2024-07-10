{admcab.i}

def shared temp-table tt-plani    like plani.
def shared temp-table tt-movim    like movim.

find first tt-plani no-lock no-error.
if avail tt-plani
then do.
    /***
    find tipmov of tt-plani no-lock no-error.
    if avail tipmov and tipmov.piscofins
    then***/ run piscofins.p.
end.

