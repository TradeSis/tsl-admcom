/*
#1 TP
*/
def input parameter p-recid as recid.
def input-output parameter p-titpar like titulo.titpar.
def output parameter vparcial as log.

vparcial = no.

def buffer btitulo for titulo.
def buffer ctitulo for titulo. 

find titulo where recid(titulo) = p-recid no-lock no-error.
p-titpar = titulo.titpar.

if titulo.titparger <> 0 and
   titulo.titparger < 100 and
   titulo.titnumger <> "" 
then do:
    vparcial = yes.
    if titulo.titparger < titulo.titpar
    then p-titpar = titulo.titparger.
    repeat:
        find first btitulo where
            btitulo.empcod = titulo.empcod and
            btitulo.titnat = titulo.titnat and
            btitulo.modcod = titulo.modcod and
            btitulo.etbcod = titulo.etbcod and
            btitulo.clifor = titulo.clifor and
            btitulo.titnum = titulo.titnum and
            btitulo.titpar = p-titpar
            no-lock no-error.
        if avail btitulo 
        then do:
            if btitulo.titnumger = titulo.titnumger and
               btitulo.titparger <> 0 and
               btitulo.titparger <  btitulo.titpar
            then p-titpar = btitulo.titparger.
            else leave.   
        end.
        else leave.
    end. 
end.
else /*#1 do: */
    if titulo.titpar = 0 and p-titpar = 0
    then p-titpar = 1.
/*#1 else do: */

if p-titpar > 30
then do:
    find first ctitulo where
                   ctitulo.empcod = titulo.empcod and
                   ctitulo.titnat = titulo.titnat and
                   ctitulo.modcod = titulo.modcod and
                   ctitulo.etbcod = titulo.etbcod and
                   ctitulo.clifor = titulo.clifor and
                   ctitulo.titnum = titulo.titnum and
                   ctitulo.titpar = 31
                   no-lock no-error.
    if avail ctitulo
    then p-titpar = p-titpar - 30.
    else p-titpar = p-titpar - 50.
end.

/*#1 
end.
end.
*/
