def input  parameter par-nome as char.
def output parameter par-ret  as char init "".
def var mletrade   as int  extent 3 init [128, 132, 138 ].
def var mletrapara as char extent 3 init ["c", "a", "C" ].
def var vletra as char.
def var vct    as int.
def var vi     as int.

par-nome = caps(trim(replace(par-nome, "~\"," "))).

do vi = 1 to length(par-nome).
    vletra = substring(par-nome, vi, 1).

    find tab_asc where
         tab_asc.dec = asc(vletra) no-lock no-error.
    if avail tab_asc and
             tab_asc.usa <> ""
    then do:
        vletra = tab_asc.usa.
        par-ret = par-ret + vletra.
    end.
    else do:         
    do vct = 1 to 3.
        if asc(vletra) = mletrade[vct]
        then vletra = mletrapara[vct].
    end.
    if vletra = ","
    then par-ret = par-ret.
    else
    if vletra = "-"
    then par-ret = par-ret.
    else
    if vletra = "<" 
    then par-ret = par-ret + "&lt;".
    else if vletra = ">" 
        then par-ret = par-ret + "&gt;".
        else if vletra = "&" 
            then par-ret = par-ret + "&amp;".
            else if asc(vletra) = 34 
                then par-ret = par-ret + "&quot;". /* " */
                else if asc(vletra) = 39 
                    then par-ret = par-ret + "&#39;".  /* ' */
                    else if length(vletra) = 1 and
                            asc(vletra) > 31   and
                            asc(vletra) < 123
                   then par-ret = par-ret + vletra.

    end.
end.
