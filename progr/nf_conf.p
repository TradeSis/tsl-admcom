{admcab.i}

def temp-table tt-plani like plani.

form vdti as date label "Periodo de"
     vdtf as date label "Ate"
     with frame f1 centered side-labe.


update vdti vdtf with frame f1.

for each modal no-lock:
    for each titulo where titulo.empcod = 19 and
                          titulo.titnat = yes and
                          titulo.modcod = modal.modcod and
                          titulo.titsit = "CON" and
                          titulo.titdtdes >= vdti and
                          titulo.titdtdes <= vdtf 
                          no-lock:
        find first tt-plani where tt-plani.etbcod = titulo.etbcod and
                         tt-plani.emite  = titulo.clifor and
                         tt-plani.numero = int(titulo.titnum)
                         no-lock no-error.
        if not avail tt-plani
        then do:
            find first plani where plani.etbcod = titulo.etbcod and
                         plani.emite  = titulo.clifor and
                         plani.numero = int(titulo.titnum)
                         no-lock no-error.
            if avail plani
            then do:
                create tt-plani.
                buffer-copy plani to tt-plani.
                tt-plani.datexp = titulo.titdtdes.
            end.
        end.
    end.
end.
def var varquivo as char.
if opsys = "UNIX" 
then  varquivo = "/admcom/relat/nf_conf" + string(day(today)).
else  varquivo = "l:\relat\nf_conf" + string(day(today)).
            
{mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""nf_conf""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """NOTAS DE ENTRADA CONFIRMADAS NO PERIODO "" +
                         string(vdti,""99/99/9999"") + "" A "" +
                         string(vdtf,""99/99/9999"") "
       &Width     = "100"
       &Form      = "frame f-cabcab"}
 
 
for each tt-plani,
    first forne where forne.forcod = tt-plani.emite no-lock
    break by forne.fornom by tt-plani.pladat.
    if first-of(forne.fornom)
    then do:
        disp forne.forcod
             forne.fornom
             with frame f2 down.
    end. 
    disp tt-plani.numero  format ">>>>>>>9"
         tt-plani.pladat  column-label "Emitida"
         tt-plani.dtinclu  column-label "Entrada"
         tt-plani.datexp column-label "Confimada"
         tt-plani.platot
         with frame f2 width 100.
    down with frame f2.

end.

output close.
if opsys = "UNIX"
then do: 
    run visurel.p (input varquivo, 
                   input "").     
end. 
else do: 
    {mrod.i} 
end.
