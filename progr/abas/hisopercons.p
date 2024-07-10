def input parameter par-procod as int.
def input parameter par-etbcod as int.
def input parameter par-emite  as int.

def var vqtdoper like abasresoper.qtdoper.
def var vleadtime like abasresoper.leadtime.
def var vsumleadtime like abasresoper.sumleadtime.

find first abasresoper where
    abasresoper.procod = par-procod and
    abasresoper.etbcod = par-etbcod and
    abasresoper.emite  = par-emite 
    no-lock no-error.
disp
    par-procod label "Produ"
    par-etbcod label "Estab"
    abasresoper.emite when avail abasresoper label "Emi"
    abasresoper.qtdoper when avail abasresoper label "Oper"
    abasresoper.leadtime when avail abasresoper label "LT"
    with frame f1
    row 3 no-box side-labels width 80 
     color messges.
    
for each abashisoper where abashisoper.etbcod = par-etbcod and
                           abashisoper.procod = par-procod and
                           abashisoper.emite  = par-emite
                           no-lock.
    if abashisoper.etbcod >= 900
    then 
        find first plani where 
                plani.etbcod = abashisoper.etbcod and 
                plani.placod = abashisoper.placod
                         no-lock no-error.

    else 
        find first plani where 
                plani.etbcod = abashisoper.emite and 
                plani.placod = abashisoper.placod
                         no-lock no-error.
    if abashisoper.datini <> ? and
       abashisoper.datfim <> ?
    then do:   
        vqtdoper = vqtdoper + 1.
        vsumleadtime = vsumleadtime + abashisoper.leadtime.
        vleadtime    = vsumleadtime / vqtdoper.
    end. 
    disp

      AbasHisOper.pednum
      
      plani.numero when avail plani
      
      AbasHisOper.DatIni format "999999"
      AbasHisOper.DatFim format "999999"
      AbasHisOper.LeadTime label "LTOper"
      vqtdoper label "QtdOper" when abashisoper.datini <> ? and
       abashisoper.datfim <> ?
      vleadtime label "LT" when abashisoper.datini <> ? and
       abashisoper.datfim <> ?

        with
        frame ff
        row 4
        centered
        overlay
        12 down.
end.
pause.
hide frame ff no-pause.
