/*  alcis/sinc_prodistr.p */
def input parameter par-procod  like produ.procod. 
def var vqtd         as dec.
def var vqtdent      as dec.
def var rec          as recid.
def buffer xprodistr for prodistr.
vqtd = 0. 
vqtdent = 0.
for each prodistr where 
            prodistr.procod       = par-procod and 
            prodistr.Tipo         = "BLOQ_ALCIS" no-lock. 
    rec = recid(prodistr).
    vqtd = prodistr.lipqtd. 
    vqtdent = 0.
    for each hprodistr where hprodistr.etbabast = prodistr.etbabast and     
                             hprodistr.lipseq   = prodistr.lipseq 
                             no-lock.
        vqtdent = vqtdent + hprodistr.preqtent.
    end.
    if prodistr.preqtent <> vqtdent
    then do on error undo. 
        find xprodistr where recid(xprodistr) = rec.    
        xprodistr.preqtent = vqtdent.    
        if xprodistr.preqtent >= xprodistr.lipqtd 
        then xprodistr.lipsit = "F".
    end.
end.
