def temp-table tttrecid
    field recclilig as recid
    field dtprog as date
    index ind01 recclilig.
    
def var vachou as log.
def var i as int no-undo.

def buffer btitulo for titulo.

for each tttrecid.
    delete tttrecid.
end.
    
i = 0.
for each clilig no-lock.

i = i + 1.
if i mod 50000 = 0
then do:
    message "Lidos ==>" i.
end.
for each estab no-lock.
    
for each titulo where titulo.empcod = 19
                  and titulo.titnat = no
                  and titulo.modcod = "CRE"
                  and titulo.titsit = "LIB"
                  and titulo.clifor = clilig.clicod
                  and titulo.etbcod = estab.etbcod no-lock
                    by titulo.titdtven.
    /*if titulo.titdtven >= today then next.*/
    for each btitulo where btitulo.empcod = titulo.empcod
                       and btitulo.titnat = titulo.titnat
                       and btitulo.modcod = "CRE"
                       and btitulo.titdtpag = titulo.titdtemi
                       and btitulo.etbcod = titulo.etbcod
                       and btitulo.clifor = titulo.clifor no-lock.
    if btitulo.moecod = "NOV" or btitulo.etbcod > 900
    then do:
        find first tttrecid where tttrecid.recclilig = recid(clilig) no-error.
        if not avail tttrecid
        then do:
            create tttrecid.
            tttrecid.recclilig = recid(clilig).
            /*
            hide message no-pause.
            message clilig.clicod.
            */
        end.
        if tttrecid.dtprog = ? or tttrecid.dtprog > btitulo.titdtven
        then tttrecid.dtprog = btitulo.titdtven. 
    end.
    end.
    
    if vachou = no
    then next.
    
    end.
    end.
    end.    
    
    for each tttrecid.
        find clilig where recid(clilig) = tttrecid.recclilig exclusive-lock.
        clilig.modcod = "NOV".
        clilig.dtacor = tttrecid.dtprog - 1.
        if clilig.dtacor = ?
        then clilig.dtacor = clilig.dtven.
    end.    
