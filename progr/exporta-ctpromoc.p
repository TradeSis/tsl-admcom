def buffer bctpromoc for ctpromoc.
def var varquivo as char.
def var vcomando as char.
def var vfil as char format "x(16)".
def var vi as int.
varquivo = "/admcom/work/ctpromoc_" + string(today,"99999999") + ".d".

output to value(varquivo).

for each ctpromoc where linha = 0 and   ctpromoc.dtinicio <= today and (ctpromoc.dtfim >= today  or ctpromoc.dtfim = ?) and ctpromoc.situacao = "L" no-lock.

    for each bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia no-lock.
        
            export bctpromoc.
            vi = vi + 1.
    end.

end.

output close.

message "Exportados" vi "registros em" varquivo.
update vfil label "loja para envio (IP ou DNS) " colon 30
    with width 80 side-labels.

if vfil <> ""
then do:
    vcomando = "scp " + varquivo + " root@" + trim(vfil) + ":/usr/admcom/work/.".
    message vcomando. pause 5.
    unix silent value(vcomando).
end.    
return.

