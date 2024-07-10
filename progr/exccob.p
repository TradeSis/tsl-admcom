{admcab.i}
def var vetbcod like estab.etbcod.
repeat:
   
    update vetbcod label "Filial" with frame f1 side-label.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f1 width 80.
    message "Confirma Exclusao" update sresp.
    if not sresp 
    then next.
    for each cobranca where cobranca.etbcod = estab.etbcod:
        if (today - cobranca.cobgera) <= 45
        then next.
        find first titulo where titulo.clifor = cobranca.clicod     and
                                titulo.titnat = no                  and
                                titulo.modcod = "CRE"               and
                                titulo.titdtpag >= cobranca.cobgera and
                                titulo.titdtpag <= (cobranca.cobgera + 45)
                                no-lock no-error.
        if avail titulo
        then next.
        display cobranca.cobcod
                cobranca.clicod with frame f2 down. pause 0.
        delete cobranca.
    end.

end.


