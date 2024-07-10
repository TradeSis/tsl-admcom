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
           

    for each estab no-lock:
        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 04           and
                             plani.pladat >= vdti        and
                             plani.pladat <= vdtf        and
                             plani.platot = vvalor no-lock:
                             

            find forne where forne.forcod = plani.emite no-lock no-error.
            display plani.etbcod
                    plani.emite
                    forne.fornom when avail forne
                                 format "x(30)"
                    plani.pladat
                    plani.numero
                    plani.serie
                    plani.platot
                        with frame f2 down.
        end.        
    end.
    
end.
