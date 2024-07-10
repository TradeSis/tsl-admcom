{admcab.i}

def input parameter par-rec as recid.
def input parameter par-campo as char.
def input parameter par-valorori as char.
def input parameter par-obs as char.

find titulo where recid(titulo) = par-rec no-lock no-error.
if avail titulo
then do on error undo:
    create titulolog.
    assign
            titulolog.empcod = titulo.empcod
            titulolog.titnat = titulo.titnat
            titulolog.modcod = titulo.modcod
            titulolog.etbcod = titulo.etbcod
            titulolog.clifor = titulo.clifor
            titulolog.titnum = titulo.titnum
            titulolog.titpar = titulo.titpar
            titulolog.data    = today
            titulolog.hora    = time
            titulolog.funcod  = sfuncod
            titulolog.campo   = par-campo
            titulolog.valor   = par-valorori
            titulolog.obs     = par-obs.
end. 
