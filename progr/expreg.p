{admcab.i}
def var vregcod like estab.regcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def stream stela .

repeat:

    update vregcod label "Regiao" with frame f1 side-label width 80.

    find regiao where regiao.regcod = vregcod no-lock no-error.
    display regiao.regnom no-label with frame f1.

    update vdti label "Periodo" 
           vdtf no-label with frame f1.
 
    output stream stela to terminal.
    output to value("l:\export\cpd" + string(vregcod,"99") + "\titluc.d").

    for each estab where estab.regcod = vregcod no-lock:
        for each titulo where titulo.empcod = 19           and
                              titulo.titnat = no           and
                              titulo.modcod = "CRE"        and
                              titulo.etbcod = estab.etbcod and
                              titulo.datexp >= vdti        and
                              titulo.datexp <= vdtf no-lock:
                              
            display stream stela 
                    titulo.etbcod
                    titulo.titnum
                    titulo.titsit with frame f2 1 down centered row 10.
            pause 0.
            export titulo.
        end.
    end.
    output stream stela close.
    output close.
    
end.        
        
                              
