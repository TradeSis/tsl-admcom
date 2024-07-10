/*  bloq995.p   */
def input  parameter par-procod like produ.procod.
def output parameter par-bloq   like prodistr.lipqtd.
par-bloq = 0.
for each prodistr where prodistr.Tipo         = "BLOQ_ALCIS" and
                        prodistr.etbcod       = 995          and
                        prodistr.procod       = par-procod   and
                        prodistr.lipsit       = "A"
                        no-lock.
    par-bloq = par-bloq + (prodistr.lipqtd - prodistr.preqtent)    .
end. 

 
