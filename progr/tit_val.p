{admcab_l.i}
def var i as i.
def var vcob like fin.titulo.titvlcob.
def var vpag like fin.titulo.titvlcob.
def var vforcod like forne.forcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vvalor like plani.platot.
repeat:

    vcob = 0.
    vpag = 0.
    update vdti label "Periodo"
           vdtf no-label
           vvalor label "Valor" with frame f1 side-label width 80 no-box centered.
    for each fin.titulo where titulo.empcod = 19 and
                              titulo.titnat = yes and
                              titulo.titdtpag >= vdti and
                              titulo.titdtpag <= vdtf and
                              titulo.titvlpag = vvalor no-lock:
        
        find forne where forne.forcod = titulo.clifor no-lock no-error.
        display fin.titulo.titnum
                fin.titulo.titpar
                fin.titulo.clifor
                forne.fornom when avail forne format "x(30)"
                fin.titulo.titdtemi
                fin.titulo.titdtven
                fin.titulo.titdtpag
                fin.titulo.titvlpag with frame f2 down.
                
    
    end.
    
end.
