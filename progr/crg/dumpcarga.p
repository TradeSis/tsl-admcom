
def var ptoday  as date.
def var vmenosd as int.
def var pfull as log.
ptoday = today.
vmenosd = 2. 
pfull = no.

def var vdir as char init "/admcom/helio/carga/".

def buffer bctpromoc for ctpromoc.
def var varquivo as char.
def var vi as int.
/*
germatriz.clien
germatriz.func
germatriz.estab
*/
message ptoday string(time,"HH:MM:SS") "INICIO".

varquivo = vdir + "operadoras" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each operadoras no-lock.
    export operadoras.
end.    
output close.

varquivo = vdir + "promoviv" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each promoviv no-lock.
    export promoviv.
end.    
output close.

varquivo = vdir + "planoviv" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each planoviv no-lock.
    export planoviv.
end.
output close.


varquivo = vdir + "proplaviv" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each proplaviv no-lock.
    export proplaviv.
end.    
output close.

varquivo = vdir + "bonusviv" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each bonusviv no-lock.
    export bonusviv.
end.    
output close.

varquivo = vdir + "plaviv" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each plaviv no-lock.
    export plaviv.
end.    
output close.

varquivo = vdir + "plaviv_filial" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each plaviv_filial no-lock.
    export plaviv_filial.
end.    
output close.

varquivo = vdir + "fincla" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each fincla no-lock.
    export fincla.
end.    
output close.

varquivo = vdir + "finesp" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each finesp no-lock.
    export finesp.
end.    
output close.

varquivo = vdir + "finfab" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each finfab no-lock.
    export finfab.
end.    
output close.

varquivo = vdir + "finpro" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each finpro no-lock.
    export finpro.
end.    
output close.

varquivo = vdir + "ctpromoc" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each ctpromoc where linha = 0 and   ctpromoc.dtinicio <= ptoday and (ctpromoc.dtfim >= ptoday  or ctpromoc.dtfim = ?) and ctpromoc.situacao = "L" no-lock.
    for each bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia no-lock.
            export bctpromoc.
            vi = vi + 1.
    end.
end.
output close.

varquivo = vdir + "produ" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
if pfull
then do:
    for each produ no-lock.
        export {crg/produ.i produ}.
    end.    
end.
else do:
    for each produ where produ.datexp >= ptoday - vmenosd and produ.datexp <= ptoday no-lock.
        export {crg/produ.i produ} .
    end.
end.    
output close.


varquivo = vdir + "clase" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each clase no-lock.
    export clase.
end.
output close.

varquivo = vdir + "unida" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each unida /*where unida.datexp >= ptoday - vmenosd and unida.datexp <= ptoday*/ no-lock.
    export unida.
end.
output close.

varquivo = vdir + "estoq" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
if pfull
then do:
    for each estoq no-lock.
        export estoq.
    end.    
end.
else do:
    for each estoq where estoq.datexp >= ptoday - vmenosd and estoq.datexp <= ptoday no-lock.
        export estoq.
    end.
end.
output close.


varquivo = vdir + "produaux" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
if pfull
then do:
    for each produaux no-lock.
        export produaux.
    end.    
end.
else do:
    for each produaux where produaux.datexp >= ptoday - vmenosd and produaux.datexp <= ptoday no-lock.
        export produaux.
    end.
end.
output close.

varquivo = vdir + "clafis" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
if pfull
then do:
    for each clafis no-lock.
        export clafis.
    end.    
end.
else do:
    for each clafis where clafis.datexp >= ptoday - vmenosd and clafis.datexp <= ptoday no-lock.
        export clafis.
    end.
end.
output close.


varquivo = vdir + "cpag" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each cpag no-lock.
    export cpag.
end.
output close.


varquivo = vdir + "finan" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each finan  no-lock.
    export   finan.fincod  
             finan.finnom 
             finan.finent 
             finan.finnpc 
             finan.finfat 
             finan.datexp.
                             
end.
output close.

varquivo = vdir + "func" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
if pfull
then do:
    for each func no-lock.
        export func.
    end.    
end.
else do:
    for each func where func.fundtcad >= ptoday - vmenosd and func.fundtcad <= ptoday no-lock.
        export func.
    end.
end.
output close.

varquivo = vdir + "estab" + "." + string(ptoday,"99999999") + ".d".
output to value(varquivo).
for each estab no-lock.
    export estab.
end.    
output close.
unix silent 
value("cd " + vdir + "; chmod 777 *" + string(ptoday,"99999999") + ".d").
unix silent 
value("cd " + vdir + "; zip -q carga." + string(ptoday,"99999999") + ".zip *." + string(ptoday,"99999999") + ".d; rm -f *" + string(ptoday,"99999999") + ".d").
message ptoday string(time,"HH:MM:SS") "FIM".





