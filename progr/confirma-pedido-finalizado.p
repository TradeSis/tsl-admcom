{admcab.i}
{tpalcis-wms.i}

setbcod = 900.

def var vtipo as char init "CONF".

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
    message "CONFIRMANDO PEDIDO FINALIZADO".
    pause 1 no-message.
    run acao-confped-wms.p(ttarq.arquivo).
end.

