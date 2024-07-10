{admcab.i}

disable triggers for load of asstec.

def input parameter par-recid-asstec as recid.

def var vdata as date.
def buffer petiqseq for etiqseq.

/* Verifica se o registro nao esta locado */
find asstec where recid(asstec) = par-recid-asstec
             exclusive no-wait no-error.
if not avail asstec
then next. 

if asstec.etopeseq = -1 /* Cancelada */
then return.

find asstec_aux where asstec_aux.oscod = asstec.oscod
                  and (asstec_aux.nome_campo = "CANCELA" or
                       asstec_aux.nome_campo = "Encerra")
                no-lock no-error.
if avail asstec_aux
then do.
    vdata = date(acha("Data", asstec_aux.valor_campo)).
    if vdata = ?
    then vdata = today.
    assign
        asstec.etopeseq = -1
        asstec.dtsaida  = vdata.
    return.
end.

if asstec.dtsaida <> ? and asstec.dtsaida > 01/01/2013
then asstec.dtsaida = ?.

find current asstec no-lock.

for each etiqpla of asstec
                 where etiqpla.notsit   <> "C"
                 use-index guiaseq
                 no-lock.
    run not_etiqfec.p (recid(etiqpla)).
end.

/* nem todos os etiqpla estao criados */
if asstec.datexp < 03/01/2013 and asstec.dtsaida = ?
then do on error undo.
    vdata = asstec.datexp.
    if asstec.dtenvass > vdata
    then vdata = asstec.dtenvass.
    if asstec.dtretass > vdata
    then vdata = asstec.dtretass.
    if asstec.dtenvfil > vdata
    then vdata = asstec.dtenvfil.
    
    find current asstec exclusive.
    if asstec.etopecod = 1
    then do.
        /* Proprio */
        if asstec.dtenvfil <> ?
        then assign
                asstec.etopeseq = 4
                asstec.dtsaida  = vdata.
        else if asstec.dtretass <> ?
        then asstec.etopeseq = 3.
        else if asstec.dtenvass <> ?
        then asstec.etopeseq = 2.
    end.
    else
        /* Terceiro */
        if asstec.dtenvfil <> ?
        then assign
                asstec.etopeseq  = 6
                asstec.etbcodatu = asstec.etbcod.

        else if asstec.dtretass <> ? and asstec.dtenvfil = ?
        then asstec.etopeseq = 5.

        else if asstec.dtenvass <> ? and asstec.dtretass = ?
        then asstec.etopeseq = 3.

    find first petiqseq where petiqseq.etopecod = asstec.etopecod and
                              petiqseq.etopesup = asstec.etopeseq
                       no-lock no-error.
    if not avail petiqseq
    then asstec.dtsaida = vdata /*plani.dtincl*/. /* encerrar etiqueta */

    find current asstec no-lock.
end.
