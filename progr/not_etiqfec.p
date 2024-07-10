/*
Atualiza e encerra etiquetas
*/
{admcab.i}

def input parameter par-rec-etiqpla as recid.

find etiqpla where recid(etiqpla) = par-rec-etiqpla no-lock.
find etiqmov of etiqpla no-lock.

find plani where plani.etbcod = etiqpla.etbplani and
                 plani.placod = etiqpla.plaplani
           no-lock no-error.
if avail plani and plani.modcod = "CAN" /*or plani.notsit = "D"*/
then run cancela.
else run realiza.


procedure realiza.

    def var vdtincl like plani.dtincl.
    def var vdesti  like plani.desti.

    if avail plani
    then assign
            vdtincl = plani.dtincl
            vdesti  = plani.desti.
    else assign
            vdtincl = etiqpla.data
            vdesti  = etiqpla.etbplani /* 13/11/2014. Estava = 0 */.

    find asstec of etiqpla exclusive.

    if etiqmov.sigla = "Tra988"
    then do.
        assign
            asstec.etbcodatu = vdesti.
        return.
    end.
 
    find first etiqseq where etiqseq.etopecod = asstec.etopecod and
                             etiqseq.etopesup = etiqpla.etopeseq
                       no-lock no-error.
    if not avail etiqseq
    then asstec.dtsaida     = vdtincl. /* encerrar etiqueta */

    asstec.etopeseq = etiqpla.etopeseq.

    if etiqmov.sigla = "TraMat" and avail plani
    then
        assign
            asstec.etbcodatu = if vdesti = 0
                               then if asstec.datexp < 12/02/2013
                                    then 998 else 988
                               else vdesti
            asstec.dtentdep  = vdtincl.

    if etiqmov.sigla = "EnvAss"
    then assign
            asstec.dtenvass = vdtincl
            asstec.dtretass = ?
            asstec.forcod   = vdesti.

    if etiqmov.sigla = "RetAss"
    then assign
            asstec.dtretass = vdtincl.

    if etiqmov.sigla = "TraLoj"
    then assign
            asstec.dtenvfil  = vdtincl
            asstec.etbcodatu = asstec.etbcod.

    if etiqmov.sigla = "TraOut"
    then assign
            asstec.dtenvfil  = vdtincl.

    if etiqmov.sigla = "Tra998"
    then assign
        asstec.etbcodatu = vdesti.

    if asstec.etbcodatu = 993
    then asstec.etbcodatu = 998.

end procedure.


procedure cancela.
    
    find current etiqpla exclusive.
    find asstec of etiqpla exclusive.
    assign
        etiqpla.notsit = "C".

    find first etiqseq where etiqseq.etopecod = asstec.etopecod and
                             etiqseq.etopesup = etiqpla.etopeseq
                       no-lock no-error.
    if not avail etiqseq
    then asstec.dtsaida     = ?. /* DESencerrar etiqueta */

    if etiqmov.sigla = "TraMat"
    then
        assign
            asstec.etbcodatu = etiqpla.etbplani
            asstec.dtentdep  = ?.

    if etiqmov.sigla = "EnvAss"
    then assign
            asstec.dtenvass = ?
            asstec.forcod   = 0.

    if etiqmov.sigla = "RetAss"
    then assign
            asstec.dtretass = ?.

    if etiqmov.sigla = "TraLoj"
    then assign
            asstec.dtenvfil  = ?
            asstec.etbcodatu = etiqpla.etbplani.

    if etiqmov.sigla = "TraOut"
    then assign
            asstec.dtenvfil  = ?.

    if asstec.etbcodatu = 993
    then asstec.etbcodatu = 998.

end procedure.
