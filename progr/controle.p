
def input parameter par-tip     as char.
def input parameter contcli     as int.  
def input parameter contcon     as int.
def input parameter conttit     as int.
def input parameter contpro     as int.
def input parameter contest     as int.
def input parameter contpla     as int.
def input parameter contmov     as int.
def input parameter v-dtini     as date.
def input parameter v-dtfin     as date.
def input parameter vtoday      as date.
def input parameter vtime       as int.
def input parameter vetbcod     like estab.etbcod.

if par-tip = "cri"
then do transaction.
    create cpd-controle.
    ASSIGN cpd-controle.etbcod   = vetbcod 
           cpd-controle.DtExp    = vtoday 
           cpd-controle.HrExp    = vtime 
           cpd-controle.contcli  = contcli 
           cpd-controle.contcon  = contcon
           cpd-controle.conttit  = conttit 
           cpd-controle.contpro  = contpro 
           cpd-controle.contest  = contest 
           cpd-controle.contpla  = contpla 
           cpd-controle.contmov  = contmov 
           cpd-controle.DtIni    = v-DtIni 
           cpd-controle.DtFim    = v-DtFin 
           cpd-controle.ImpSit   = no.
end.           
