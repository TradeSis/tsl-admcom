{admcab.i}

def new shared temp-table tt-plani like plani.
 
def new shared temp-table tt-titulo
    field titnum   like titulo.titnum format "x(7)"
    field titpar   like titulo.titpar format "99"
    field modcod   like titulo.modcod
    field titdtemi like titulo.titdtemi 
                        column-label "Dt.Emis."format "99/99/99"
    field titdtven like titulo.titdtven format "99/99/99"
                        column-label "Dt.Venc."
    field titvlcob like titulo.titvlcob column-label "Vl.Cobrado"
                       format ">,>>>,>>9.99"
    field titvlpag like titulo.titvlpag format ">,>>>,>>9.99"
    field titdtpag like titulo.titdtpag format "99/99/999"
                                column-label "Dt.Paga."
    field titvljur like titulo.titvljur 
    field titvldes like titulo.titvldes
    field titsit   like titulo.titsit
    field etbcod   like titulo.etbcod column-label "FL" format ">>9"
    field clifor   like titulo.clifor
    field titbanpag like titulo.titbanpag
    field marca as char
    index ind-1 titdtemi desc.

def buffer bplani for plani.
def var i as i.
def var vcob like titulo.titvlcob.
def var vpag like titulo.titvlcob.
def var vforcod like forne.forcod.
def var i-serie as int.
def var vdtini as date format "99/99/9999".
def var vdtfim as date format "99/99/9999".

vdtini = date(month(today),1,year(today)).
vdtfim = today.

message "Considera a data de emissao".

repeat:

    for each tt-titulo:
        delete tt-titulo.
    end.
    vcob = 0.
    vpag = 0.
    update vforcod 
           vdtini label "Data ini"
           vdtfim label "Data fim"
    with frame f1 side-label width 80 no-box centered.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao cadastrato".
        undo, retry.
    end.

    disp forne.fornom no-label with frame f1 width 80 no-box.

    for each tt-plani: delete tt-plani. end.
    
    for each titulo where titulo.clifor = forne.forcod and
                          titulo.titnat = yes and 
                          titulo.titdtemi >= vdtini and
                          titulo.titdtemi <= vdtfim no-lock :
        if titulo.modcod = "BON" or
           titulo.modcod = "DEV" or
           titulo.modcod = "CHP" then next.

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
               tt-titulo.clifor   = titulo.clifor
               tt-titulo.titbanpag = titulo.titbanpag
               .
               
        
        if titulo.titsit <> "pag"       
        then tt-titulo.titvlcob = (titulo.titvlcob + 
                                   titulo.titvljur -
                                   titulo.titvldes).
                        
                                  
        
        vcob = vcob + tt-titulo.titvlcob.
        vpag = vpag + titulo.titvlpag.

        if titulo.clifor = 111782 and
           titulo.clifor = 111768 and
           titulo.clifor = 103444
        then do:
            find plani where  plani.movtdc = 37 and
                          plani.etbcod = titulo.etbcod and
                          plani.emite  = titulo.clifor and
                          plani.serie  = "1" and
                          plani.numero = int(titnum)
                          no-lock no-error.
            if not avail plani
            then find plani where  plani.movtdc = 37 and
                          plani.etbcod = titulo.etbcod and
                          plani.emite  = titulo.clifor and
                          plani.serie  = "U" and
                          plani.numero = int(titnum)
                          no-lock no-error.
 
            if avail plani
            then do:
                find first tt-plani where 
                           tt-plani.etbcod = plani.etbcod and
                           tt-plani.placod = plani.placod and
                           tt-plani.serie  = plani.serie
                           no-error.
                if not avail tt-plani
                then do:
                    create tt-plani.
                    buffer-copy plani to tt-plani.
                end.
            end.
         end.
        else do:   
        find plani where  plani.movtdc = 4 and
                          plani.etbcod = titulo.etbcod and
                          plani.emite  = titulo.clifor and
                          plani.serie  = "1" and
                          plani.numero = int(titnum)
                          no-lock no-error.
        if avail plani and plani.dtinclu = titulo.titdtemi
        then do:
            find first tt-plani where 
                           tt-plani.etbcod = plani.etbcod and
                           tt-plani.placod = plani.placod and
                           tt-plani.serie  = plani.serie
                           no-error.
            if not avail tt-plani
            then do:
            create tt-plani.
            buffer-copy plani to tt-plani.
            tt-titulo.titdtemi = plani.pladat.
            end.
        end.
        else do:
 
        find last bplani use-index pladat where bplani.movtdc = 4 and
                               bplani.emite = titulo.clifor  and
                               bplani.etbcod = titulo.etbcod and
                               bplani.pladat <= titulo.titdtemi
                               no-lock no-error.
        if not avail bplani
        then                       
        do i-serie = 1 to 50:
        find last plani where  plani.movtdc = 4 and
                          plani.etbcod = titulo.etbcod and
                          plani.emite  = titulo.clifor and
                          plani.serie  = string(i-serie) and
                          plani.numero = int(titnum)
                          no-lock no-error.
        if avail plani
        then do:
            find first tt-plani where 
                           tt-plani.etbcod = plani.etbcod and
                           tt-plani.placod = plani.placod and
                           tt-plani.serie  = plani.serie
                           no-error.
            if not avail tt-plani
            then do:
            create tt-plani.
            buffer-copy plani to tt-plani.
            tt-titulo.titdtemi = plani.pladat.                  
            leave.
            end.
        end.
        end.
        else do:
            find last plani where  plani.movtdc = 4 and
                                    plani.etbcod = titulo.etbcod and
                                    plani.emite  = titulo.clifor and
                                    plani.serie  = bplani.serie and
                                    plani.numero = int(titnum)
                                    no-lock no-error.
            if avail plani
            then do:
                find first tt-plani where 
                           tt-plani.etbcod = plani.etbcod and
                           tt-plani.placod = plani.placod and
                           tt-plani.serie  = plani.serie
                           no-error.
                if not avail tt-plani
                then do:
                create tt-plani.
                buffer-copy plani to tt-plani.
                tt-titulo.titdtemi = plani.pladat.    
                end.
            end.
       end.                   
       end.
        end.
    end.
    
    display vcob label "Total Cobrado"
            vpag label "Total Pago" with frame f-tot side-label row 22
                                            color white/red no-box
                                                overlay centered.
    run tt-tit.p.
end.
