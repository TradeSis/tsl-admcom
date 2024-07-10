{admcab.i}
def var vnumero like plani.numero.
def var vetbcod like plani.etbcod.
def var vforcod like forne.forcod.
repeat:
    update vnumero label "Numero" with frame f1 side-label width 80.
    update vforcod label "Forne" with frame f1.
    if vforcod = 0
    then disp "TODOS" @ forne.fornom with frame f1.
    else do:
        find forne where forne.forcod = vforcod no-lock.
        disp forne.fornom no-label with frame f1.
    end.
    for each estab where estab.etbcod >= 900 no-lock:
        if {conv_igual.i estab.etbcod} then next.

         for each plani where plani.etbcod = estab.etbcod and
                              (if vforcod = 0  
                               then true
                               else plani.emite  = vforcod) and
                              plani.movtdc = 4            and
                              plani.serie  = "U"          and
                              plani.numero = vnumero no-lock.
            vforcod = plani.emite.
            find forne where forne.forcod = plani.emite no-lock.
            display estab.etbcod
                    estab.etbnom 
                    forne.forcod label "Forne" colon 16
                    forne.fornom
                    no-label with frame f4
                            side-label color white/cyan centered.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod no-lock:
                find produ of movim no-lock.
                display produ.procod
                        produ.pronom format "x(25)"
                        movim.movpc
                        movim.movqtm with frame f3 down color
                                                    message centered.
            end.
            for each titulo where titulo.empcod = 19 and
                                  titulo.etbcod = plani.etbcod and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DUP" and
                                  titulo.clifor = vforcod and
                                  titulo.titnum = string(plani.numero) no-lock:
                display titulo.titnum   format "x(10)"
                        titulo.titpar   format ">>9"
                        titulo.modcod
                        titulo.titdtemi format "99/99/9999"
                                    column-label "Dt.Emis"
                        titulo.titvlcob format ">>>,>>9.99"
                                                    column-label "Cobrado"
                        titulo.titdtven format "99/99/9999"
                                                    column-label "Dt.Vecto"
                        titulo.titdtpag format "99/99/9999"
                                                    column-label "Dt.Pagto"
                        titulo.titvlpag when titulo.titvlpag > 0
                                format ">>>,>>9.99" column-label "Vl Pago"
                        titulo.titsit with frame frame-b 10 down
                                           centered color white/red width 80.
            end.
        end.
     end.
end.
