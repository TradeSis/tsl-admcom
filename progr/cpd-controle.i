do transaction.
    create cpd-controle.
    ASSIGN cpd-controle.etbcod   = estab.etbcod 
           cpd-controle.DtExp    = vtoday 
           cpd-controle.HrExp    = vtime 
           cpd-controle.contcli  = contcli 
           cpd-controle.conttit  = conttit 
           cpd-controle.contpro  = contpro 
           cpd-controle.contest  = contest 
           cpd-controle.contpla  = contpla 
           cpd-controle.contmov  = contmov 
           cpd-controle.DtIni    = v-DtIni 
           cpd-controle.DtFim    = v-DtFin 
           cpd-controle.ImpSit   = no.
end.           
