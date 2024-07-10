disable triggers for load of finloja.titulo.
disable triggers for load of fin.titulo.
def input parameter tit-rec as recid.
def output parameter tit-log as char.

find fin.titulo where recid(fin.titulo) = tit-rec no-lock no-error.
if not avail fin.titulo
then do:
    tit-log = "titulo " + string(tit-rec) + " nao encontrado na matriz".
end.
find    finloja.titulo where 
        finloja.titulo.empcod = fin.titulo.empcod and
        finloja.titulo.titnat = fin.titulo.titnat and
        finloja.titulo.modcod = fin.titulo.modcod and
        finloja.titulo.etbcod = fin.titulo.etbcod and
        finloja.titulo.clifor = fin.titulo.clifor and
        finloja.titulo.titnum = fin.titulo.titnum and
        finloja.titulo.titpar = fin.titulo.titpar
                          no-error.
if not avail finloja.titulo
then do:
    tit-log = "titulo " + string(tit-rec) + " nao encontrado na filial".
end.
else if finloja.titulo.titsit = "PAG"
    then do:
        assign finloja.titulo.titsit    = "LIB"
                finloja.titulo.titdtpag  = ?
                finloja.titulo.titvlpag  = 0
                finloja.titulo.titbanpag = 0
                finloja.titulo.titagepag = ""
                finloja.titulo.titchepag = ""
                finloja.titulo.datexp    = today
                finloja.titulo.exportado = no.
        tit-log = "titulo " + string(recid(finloja.titulo))
                    + " alterado ".
    end.         
