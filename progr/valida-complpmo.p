def input parameter p-dataref as date.
def input parameter p-etbcod as int.
def input parameter p-forcod as int.
def input parameter p-setcod as int.
def input parameter p-vencod as int.
def input parameter p-modcod as char.
def output parameter p-retorno as log. 
def var p-situacao as char.  
p-situacao = "A".
for each complpmo where 
           complpmo.anocomp = year(p-dataref) and
           complpmo.mescomp = month(p-dataref) and
           complpmo.dtlanini <= p-dataref and
           complpmo.dtlanfim >= p-dataref 
           no-lock:
    p-situacao = complpmo.situacao.
    if complpmo.etbcod = p-etbcod
    then p-situacao = complpmo.situacao.
    if complpmo.forcod = p-forcod
    then p-situacao = complpmo.situacao.
    if complpmo.setcod = p-setcod
    then p-situacao = complpmo.situacao.
    if complpmo.vencod = p-vencod
    then p-situacao = complpmo.situacao.
    if complpmo.modcod = p-modcod
    then p-situacao = complpmo.situacao.
end.

p-retorno = p-situacao = "A".           
