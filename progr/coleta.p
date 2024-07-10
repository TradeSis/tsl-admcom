{admcab.i}
def var vest like estoq.estatual.
def var vant like estoq.estatual.
def var vmes as int.
def var vano as int.
def var vprocod like produ.procod.
def var vquan   like estoq.estatual.
def var vpath as char format "x(30)".
def temp-table wcol
    field wcol as char format "x(1)".
def var vcol as char format "x(1)".

def var vlei            as char format "x(26)".
def var vetb            as i    format ">>9".
def var vcod            as i    format "9999999".
def var vcod2           as i    format "999999".
def var vqtd            as i    format "999999".
def var ac  as i.
def var tot as i.
def var de  as i.
def var vdata like plani.pladat.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var est like estoq.estatual.
def var tot1 like titulo.titvlcob format "->,>>>,>>9.99".
def var tot2 like titulo.titvlcob format "->,>>>,>>9.99".
def var vde like titulo.titvlcob format "->,>>>,>>9.99".
def var vac like titulo.titvlcob format "->,>>>,>>9.99".
repeat:
    for each wcol:
        delete wcol.
    end.
    tot1 = 0.
    tot2 = 0.
    tot  = 0.
    vde  = 0.
    vac  = 0.

    prompt-for estab.etbcod colon 20
                with frame f1 side-label centered color white/red row 7.
    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    prompt-for categoria.catcod colon 20
                with frame f1.
    update vdata label "Data da Coleta" colon 20 with frame f1.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.
    do transaction:
        for each coletor where coletor.etbcod = estab.etbcod and
                               coletor.coldat = vdata:

            find produ where produ.procod = coletor.procod no-lock no-error.
            if avail produ and produ.catcod = categoria.catcod
            then delete coletor.
        end.
    end.
    repeat:
        update vcol label "Coletor" with frame f3 side-label centered.
        find first wcol where wcol.wcol = vcol no-error.
        if not avail wcol
        then do:
            create wcol.
            assign wcol.wcol = vcol.
        end.
    end.

    {confir.i 1 "Confronto com Coletor"}
    /***********************************/
    def var vpro like produ.procod.
    def var vq like estoq.estatual.
    def var vc as char format "x(20)".

    for each wcol:
       vpath = "h:\aplic\coletor\col" + string(wcol.wcol,"x") + "\coleta99.txt".
       input from value(vpath).
        repeat:
            vqtd = 0.
            import vlei.
            assign vetb = int(substring(string(vlei),4,2))
                   vcod = int(substring(string(vlei),14,7))
                   vcod2 = int(substring(string(vlei),14,6))
                   vqtd = int(substring(string(vlei),21,6)).

            if vetb <> estab.etbcod or vcod = 0 or vcod = ? or
               vcod = 1 or vcod = 2 or vcod = 3 or vcod = 4 or vcod = 5
            then next.
            find produ where produ.procod = vcod no-lock no-error.
            if not avail produ
            then do:
                find produ where produ.procod = vcod2 no-lock no-error.
                if not avail produ
                then next.
            end.
            find coletor where coletor.etbcod = estab.etbcod and
                               coletor.procod = produ.procod and
                               coletor.coldat = vdata no-error.
            if not avail coletor
            then do transaction:
                create coletor.
                assign coletor.etbcod = estab.etbcod
                       coletor.procod = produ.procod
                       coletor.coldat = vdata.
            end.
            do transaction:
                assign  coletor.colqtd = coletor.colqtd + vqtd.
            end.
            display coletor.procod
                    coletor.etbcod
                    coletor.coldat with 1 down. pause 0.
        end.
        INPUT CLOSE.
    end.

    message "Deseja alterar produtos" update sresp.
    if sresp
    then do transaction:
        repeat:
            update vprocod with frame f4 side-label width 80.
            find produ where produ.procod = vprocod no-lock no-error.
            if avail produ
            then display produ.pronom no-label with frame f4.
            find coletor where coletor.etbcod = estab.etbcod and
                               coletor.procod = produ.procod and
                               coletor.coldat = vdata no-error.
            if not avail coletor
            then do:
                create coletor.
                assign coletor.etbcod = vetb
                       coletor.coldat = vdata
                       coletor.procod = produ.procod.
            end.
            update coletor.colqtd label "QTD" with frame f4 no-validate.
        end.
    end.

    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """COLETAG"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom + ""  "" +
                     categoria.catnom + "" Data da Coleta => "" +
                     string(vdata,""99/99/9999"")"
        &Width     = "160"
        &Form      = "frame f-cab"}

    for each produ where produ.catcod = categoria.catcod
                            no-lock by produ.pronom:
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-error.

        if not avail estoq
        then next.

        find coletor where coletor.etbcod = estab.etbcod and
                           coletor.procod = produ.procod and
                           coletor.coldat = vdata no-error.
        if not avail coletor
        then next.


        vest = estoq.estatual.
        for each movim where movim.procod = produ.procod and
                             movim.datexp > vdata no-lock:

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat
                                                     no-lock no-error.

            if not avail plani
            then next.
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.
            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.
            find tipmov of movim no-lock.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
               then do:
                   if movim.datexp >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                if movim.datexp >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.


        do transaction:
            if vest > coletor.colqtd
            then coletor.coldec = vest - coletor.colqtd.

            if vest < coletor.colqtd
            then coletor.colacr = coletor.colqtd - vest.
        end.
        if vest = coletor.colqtd
        then next.
        tot = 0.

        if coletor.colacr > 0
        then assign tot1 = tot1 + (estcusto * coletor.colacr)
                    vac  = vac  + coletor.colacr
                    tot  = coletor.colacr.

        if coletor.coldec > 0
        then assign tot2 = tot2 + (estcusto * coletor.coldec)
                    vde  = vde  + coletor.coldec
                    tot  = coletor.coldec.

        display produ.procod column-label "Codigo"
                produ.pronom FORMAT "x(35)"
                vest(TOTAL) column-label "Qtd." format "->>>>9"
                coletor.colqtd(total) column-label "Dig." format "->>>>9"
                coletor.colacr(total) when colacr > 0 column-label "Acresc."
                coletor.coldec(total) when coldec > 0 column-label "Decres."
                estoq.estcusto column-label "Pc.Custo" format ">,>>9.99"
                (colacr * estoq.estcusto)(total) when colacr > 0
                        column-label "Vl.Acresc." format "->>>,>>9.99"
                (coldec * estoq.estcusto)(total) when coldec > 0
                        column-label "Vl.Decresc." format "->>>,>>9.99"
                (estoq.estcusto * tot)(total)
                    column-label "Total Custo" format ">>,>>>,>>9.99"
                                with frame f2 down width 200.
    end.
    put skip "TOTAL VL. ACRESCIMO : " at 40 tot1
             "TOTAL ACRESCIMO     : "       vac skip
             "TOTAL VL. DECRESCIMO: " at 40 tot2
             "TOTAL DECRESCIMO    : "       vde.
    output close.
end.
