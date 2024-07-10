{admcab.i}

def new shared temp-table tt-titulo
    field marca as char format "x"
    field titobs   like titulo.titobs    
    field titnum   like titulo.titnum format "x(7)"
    field titpar   like titulo.titpar format "99"
    field modcod   like titulo.modcod
    field titdtemi like titulo.titdtemi format "99/99/9999"
    field titdtven like titulo.titdtven format "99/99/9999"
    field titvlcob like titulo.titvlcob column-label "Vl.Cobrado"
                       format ">>>,>>9.99"
    field titvlpag like titulo.titvlpag format ">>>,>>9.99"
    field titdtpag like titulo.titdtpag format "99/99/9999"
    field titsit   like titulo.titsit
    field etbcod   like titulo.etbcod column-label "FL" format ">>9"
    field clifor   like titulo.clifor
    index ind-1 titdtemi desc.

def var i as i.
def var vcob like titulo.titvlcob.
def var vpag like titulo.titvlcob.
def var vforcod like forne.forcod.
repeat:

    for each tt-titulo:
        delete tt-titulo.
    end.
    vcob = 0.
    vpag = 0.
    update vforcod with frame f1 side-label width 80 no-box centered.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao cadastrato".
        undo, retry.
    end.
    disp forne.fornom no-label with frame f1 width 80 no-box.
    for each titulo where titulo.clifor = forne.forcod and
                          titulo.titnat = yes no-lock /*by titulo.modcod*/                           use-index iclicod:

        create tt-titulo.
        assign tt-titulo.titnum   =  titulo.titnum 
               tt-titulo.titpar   =  titulo.titpar 
               tt-titulo.modcod   = titulo.modcod
               tt-titulo.titdtemi = titulo.titdtemi 
               tt-titulo.titdtven = titulo.titdtven 
               tt-titulo.titvlcob = titulo.titvlcob 
               tt-titulo.titvlpag = titulo.titvlpag 
               tt-titulo.titdtpag = titulo.titdtpag 
               tt-titulo.titsit   = titulo.titsit
               tt-titulo.etbcod   = titulo.etbcod
               tt-titulo.titobs[1] = titulo.titobs[1]
               tt-titulo.titobs[2] = titulo.titobs[2]
               tt-titulo.clifor    = titulo.clifor
               .
               
        
        if titulo.titsit <> "pag"       
        then tt-titulo.titvlcob = (titulo.titvlcob + 
                                   titulo.titvljur -
                                   titulo.titvldes).
                        
                                  
        
        vcob = vcob + tt-titulo.titvlcob.
        vpag = vpag + titulo.titvlpag.
        find first lancxa where 
                   lancxa.datlan = titulo.titdtemi and
                   lancxa.titnum = titulo.titnum and
                   lancxa.forcod = titulo.clifor and
                   lancxa.etbcod = titulo.etbcod
                   no-lock no-error.
         if avail lancxa
         then tt-titulo.marca = "*".
         else tt-titulo.marca = "".          
        
    end.
    
    display vcob label "Total Cobrado"
            vpag label "Total Pago" with frame f-tot side-label row 15
                                            color white/red no-box
                                                overlay centered.
    run tt-titc.p.
end.
