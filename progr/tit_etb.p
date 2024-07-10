{admcab.i}

def new shared temp-table tt-titulo
    field titnum   like titulo.titnum format "x(7)"
    field titpar   like titulo.titpar format "99"
    field modcod   like titulo.modcod
    field titdtemi like titulo.titdtemi format "99/99/9999"
    field titdtven like titulo.titdtven format "99/99/9999"
    field titvlcob like titulo.titvlcob column-label "Vl.Cobrado"
                       format ">>>,>>9.99"
    field titsit   like titulo.titsit
    field clifor   like titulo.clifor column-label "FL" format "99"
    index ind-1 titdtemi desc.


def var vdtin like titulo.titdtemi.
def var vdtfi like titulo.titdtemi.

def var i as i.
def var vcob like titulo.titvlcob.
def var vpag like titulo.titvlcob.
def var vetbcod like estab.etbcod.

repeat:

    for each tt-titulo:
        delete tt-titulo.
    end.
    vcob = 0.
    vpag = 0.
    update vetbcod with frame f1 side-label width 80 no-box centered.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento nao cadastrato".
        undo, retry.
    end.
    update vdtin label "Periodo"
           vdtfi label "A" with frame f1.


    for each modal no-lock,
        each titulo where titulo.empcod = 19  and
                          titulo.titnat = yes and
                          titulo.modcod = modal.modcod and
                          titulo.etbcod = estab.etbcod and
                          titulo.titdtemi >= vdtin     and
                          titulo.titdtemi <= vdtfi no-lock:

        create tt-titulo.
        assign tt-titulo.titnum   =  titulo.titnum 
               tt-titulo.titpar   =  titulo.titpar 
               tt-titulo.modcod   = titulo.modcod
               tt-titulo.titdtemi = titulo.titdtemi 
               tt-titulo.titdtven = titulo.titdtven 
               tt-titulo.titvlcob = titulo.titvlcob 
               tt-titulo.titsit   = titulo.titsit
               tt-titulo.clifor   = titulo.clifor.
               
        vcob = vcob + titulo.titvlcob.
        vpag = vpag + titulo.titvlpag.
    end.
    
    display vcob label "Total Cobrado"
            vpag label "Total Pago" with frame f-tot side-label row 22
                                            color white/red no-box
                                                overlay centered.
    run tt-etb.p.
end.
