{admcab-batch.i new}
{/admcom/progr/tpalcis-wms.i}

setbcod = 900.

def var vtipo as char init "CONF".

message "INICIO: " string(time,"hh:mm:ss"). pause 0.

def temp-table ttarq
    field Arquivo   as char format "x(15)"
    field etbori    like wmsarq.etbori
    field etbdes    like wmsarq.etbdes
    field itens     like wmsarq.itens
    field gaiola    like wmsarq.gaiola column-label "Carga"
    field Origem    as char format "x(7)".
def var varq_aux as char.
varq_aux = "/admcom/relat/lealcis." + string(time).
unix silent value("ls " + alcis-diretorio + " > " + varq_aux).
input from value(varq_aux).
repeat transaction.
        create ttarq.
        import ttarq.
end.
input close.

for each ttarq:
    if ttarq.arquivo begins "CONF"
    then.
    else delete ttarq.
end.

for each ttarq:
    run abas/corteconfirma.p (input ttarq.arquivo,yes).
    message ttarq.arquivo. 
    pause 1.
end.

message "FIM: " string(time,"hh:mm:ss"). pause 0.

return.

