{admcab.i}
def var vmes as i.
def var vpla like crepl.crenom format "x(25)".
def var vped like crepl.crenom.
def var i     as i.
def var vdia  as i.
def var vpar  as i.
def var despla like plani.descprod.
def var desped like plani.descprod.
def var dpla like plani.pladat.
def var dini like pedid.peddti format "99/99/9999".
def var dfin like pedid.peddtf format "99/99/9999".
def var totpla  like plani.platot.
def var totped  like plani.platot.
def var vforcod like forne.forcod.
def var vnumero like plani.numero format ">>>>>9".
def temp-table wprodu
    field wcod like produ.procod
    field qent like movim.movqtm
    field qped like movim.movqtm
    field pent like movim.movpc  format ">>,>>9.99"
    field pped like movim.movpc  format ">>,>>9.99".
repeat:
    for each wprodu.
        delete wprodu.
    end.
    update vforcod with frame f1 side-label width 80.
    find forne where forne.forcod = vforcod no-lock no-error.
    display forne.fornom no-label format "x(25)" with frame f1 width 80.
    update vnumero label "NF" with frame f1 color black/cyan.
    totpla = 0.
    totped = 0.
    despla = 0.
    desped = 0.
    dpla = ?.
    dini = ?.
    dfin = ?.
    for each plaped where plaped.forcod = forne.forcod and
                          plaped.numero = vnumero no-lock:
        find plani where plani.etbcod = plaped.plaetb and
                         plani.placod = plaped.placod and
                         plani.serie  = plaped.serie no-lock.

        totpla = plani.platot.
        find pedid where pedid.etbcod = plaped.pedetb and
                         pedid.pedtdc = plaped.pedtdc and
                         pedid.pednum = plaped.pednum no-lock.
        display pedid.pednum label "PE" with frame f1. pause.
        find crepl where crepl.crecod = pedid.crecod no-lock.

        vpar = 0.
        vdia = 0.
        vpla = "".
        vmes = 0.
        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.etbcod = plani.etbcod  and
                              titulo.titnat = yes           and
                              titulo.modcod = "DUP"         and
                              titulo.clifor = forne.forcod  and
                              titulo.titnum = string(plani.numero) no-lock:
            vpar  = vpar + 1.
            vmes  = titulo.titdtven - titulo.titdtemi.
            vpla  = vpla + string(vmes) + ", ".
            vdia  = titulo.titdtven - pedid.peddat.
        end.
        vped = crepl.crenom.

        vpla = vpla + " DIAS".

        if plani.pladat <= pedid.peddti or
           plani.pladat >= pedid.peddtf
        then assign dpla = plani.pladat
                    dini = pedid.peddti
                    dfin = pedid.peddtf.
        if plani.descprod = 0
        then if pedid.nfdes <> 0
             then assign despla = plani.descprod
                         desped = pedid.nfdes.

        if plani.descprod <> 0
        then if pedid.nfdes = 0
             then assign despla = plani.descprod
                         desped = pedid.nfdes.


        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc no-lock:
            find first wprodu where wprodu.wcod = movim.procod no-error.
            if not avail wprodu
            then do:
                create wprodu.
                assign wprodu.wcod = movim.procod.
            end.
            wprodu.qent = movim.movqtm.
            wprodu.pent = movim.movpc - movim.movdes.
            for each liped where liped.etbcod = plaped.pedetb and
                                 liped.pedtdc = plaped.pedtdc and
                                 liped.pednum = plaped.pednum and
                                 liped.procod = movim.procod no-lock:
                find first wprodu where wprodu.wcod = liped.procod no-error.
                wprodu.qped = wprodu.qped + liped.lipqtd.
                
                wprodu.pped = (liped.lippreco - 
                              (liped.lippreco * (pedid.nfdes / 100))).

                wprodu.pped = (wprodu.pped + 
                          (wprodu.pped * (pedid.ipides / 100))).

                totped = totped + (wprodu.pped * liped.lipqtd).
            end.
        end.
    end.
    display "TOTAIS....    " totpla label "NF"
                             totped label "PE" at 45
                                        with frame f2 side-label no-box.
    if dpla <> ?
    then display "DATAS.....    " dpla label "NF"
                 dini label "PE"  format "99/99/9999" at 45
                 "A " dfin no-label format "99/99/9999" 
                            with frame f3 side-label no-box.

    if despla <> 0 or
       desped <> 0
    then display "DESC......    " despla label "NF"
                 desped label "PE" at 45 with frame f4 side-label no-box.

    display "VENC......    " vpla label "NF"
             vped label "PE" at 45 with frame f5 side-label no-box.

    for each wprodu:
        if (wprodu.qent = wprodu.qped) and
           (wprodu.pent = wprodu.pped)
        then delete wprodu.
    end.
    for each wprodu:
        find produ where produ.procod = wprodu.wcod no-lock.
        display wprodu.wcod
                produ.pronom format "x(35)"
                wprodu.qent column-label "Qtd.NF"
                wprodu.qped column-label "Qtd.PE"
                wprodu.pent column-label "Pr.NF"  format ">,>>9.99"
                wprodu.pped column-label "Pr.PE"  format ">,>>9.99"
                    with frame f6 down width 80.
    end.
    pause.
end.
