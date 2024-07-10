def input param prec as recid.
find pdvmov where recid(pdvmov) = prec no-lock.

if pdvmov.ctmcod = "P7" or pdvmov.ctmcod = "BOL"
then.
else next.

def new SHARED temp-table ttcashback no-undo
    field titulo-rec as recid.

for each  pdvdoc of pdvmov no-lock.
    find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock no-error.
    if not avail contrato then next.
    find titulo where titulo.empcod = 19 and titulo.titnat = no and
        titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and titulo.clifor = contrato.clicod and
        titulo.titnum = string(contrato.contnum) and
        titulo.titpar = pdvdoc.titpar
        no-lock no-error.
    if not avail titulo then next.
    
    find first cupomcashtit where cupomcashtit.contnum = contrato.contnum and
                                  cupomcashtit.titpar  = titulo.titpar
            no-lock no-error.
    if avail cupomcashtit
    then next.
    
    create ttcashback.
    ttcashback.titulo-rec = recid(titulo).
            
end.

run api/efetivacashbackp.p (pdvmov.etbcod, pdvmov.ctmcod).

