{admcab.i}
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
def var est like estoq.estatual.
def var tot1 like titulo.titvlcob format "->,>>>,>>9.99".
def var tot2 like titulo.titvlcob format "->,>>>,>>9.99".
def var vde like titulo.titvlcob format "->,>>>,>>9.99".
def var vac like titulo.titvlcob format "->,>>>,>>9.99".
repeat:
    for each wcol:
        delete wcol.
    end.
    for each cotac:
        delete cotac.
    end.
    tot1 = 0.
    tot2 = 0.
    tot  = 0.
    vde  = 0.
    vac  = 0.

    prompt-for estab.etbcod
                with frame f1 side-label centered color white/red row 7.
    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label skip(1) with frame f1.

    prompt-for categoria.catcod
                with frame f1.
    update vdata with frame f1.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.
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
    /*
    message "Confirma confronto do balanco" update sresp.
    if sresp
    then do:
        input from ..\work\lebes.d.
        repeat:
            import vc.
            vpro = int(substring(string(vc),1,6)).
            vq = int(substring(string(vc),15,20)).
            find produ where produ.procod = vpro no-lock no-error.
            if not avail produ
            then next.
            find cotac where cotac.forcod = 0 and
                             cotac.procod = produ.procod no-error.
            if not avail cotac
            then do:
                create cotac.
                assign cotac.comcod   = estab.etbcod
                       cotac.forcod   = 0
                       cotac.procod   = produ.procod.
            end.
            assign  cotac.cotpreco = cotac.cotpreco + vq.
            display cotac.procod
                    cotac.forcod
                    cotac.cotpreco with 1 down. pause 0.
        end.
        INPUT CLOSE.
    end.
    */
    /***********************************/

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
            find cotac where cotac.forcod = 0 and
                             cotac.procod = produ.procod no-error.
            if not avail cotac
            then do:
                create cotac.
                assign cotac.comcod   = vetb
                       cotac.forcod   = 0
                       cotac.procod   = produ.procod.
            end.
            assign  cotac.cotpreco = cotac.cotpreco + vqtd.
            display cotac.procod
                    cotac.forcod
                    cotac.cotpreco with 1 down. pause 0.
        end.
        INPUT CLOSE.
    end.

    message "Deseja alterar produtos" update sresp.
    if sresp
    then do:
        repeat:
            update vprocod with frame f4 side-label width 80.
            find produ where produ.procod = vprocod no-lock no-error.
            if avail produ
            then display produ.pronom no-label with frame f4.
            find cotac where cotac.forcod = 0 and
                             cotac.procod = produ.procod no-error.
            if not avail cotac
            then do:
                create cotac.
                assign cotac.comcod   = vetb
                       cotac.forcod   = 0
                       cotac.procod   = produ.procod.
            end.
            update cotac.cotpreco label "QTD" with frame f4 no-validate.
        end.
    end.
    for each estoq where estoq.etbcod = estab.etbcod no-lock.
        if estinvctm = 0
        then next.
        find cotac where cotac.forcod = 0 and
                         cotac.procod = estoq.procod no-error.
            if not avail cotac
            then do:
                create cotac.
                assign cotac.comcod   = estab.etbcod
                       cotac.forcod   = 0
                       cotac.procod   = estoq.procod.
            end.
            assign  cotac.cotpreco = cotac.cotpreco + estoq.estinvctm.
    end.




    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """COLETAG"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom + ""  "" +
                                                   categoria.catnom "
        &Width     = "160"
        &Form      = "frame f-cab"}

    for each produ where produ.catcod = categoria.catcod
                            no-lock by produ.pronom:

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-error.

        if not avail estoq
        then next.
        est = estoq.estatual.
        vqtd = 0.

            find cotac where cotac.procod = produ.procod and
                             cotac.forcod = 0 no-lock no-error.
            if not avail cotac
            then vqtd = 0.
            else vqtd = cotac.cotpreco.

        for each movim where movim.procod = produ.procod and
                             movim.movdat > vdata no-lock:

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat
                                                    no-lock no-error.

            if not avail plani
            then next.
            find tipmov of movim no-lock.
            if plani.etbcod = estab.etbcod or
               plani.desti  = estab.etbcod
            then do:
                if movim.movtdc <> 6
                then do:
                    if tipmov.movtdeb
                    then est = est + movim.movqtm.
                    else est = est - movim.movqtm.
                end.
                else do:
                    if plani.etbcod = estab.etbcod
                    then est = est + movim.movqtm.
                    if plani.desti = estab.etbcod
                    then est = est - movim.movqtm.
                end.
            end.
        end.
        ac = 0.
        de = 0.
        tot = 0.

        ac = vqtd - est.
        de = est  - vqtd.


        if est = vqtd
        then next.

        if ac > 0
        then assign tot = ac
                    estoq.estmgluc = ac.
        if de > 0
        then assign tot = de
                    estoq.estmgoper = de.

        if ac >= 0
        then assign tot1 = tot1 + (estcusto * ac)
                    vac  = vac  + ac.

        if de >= 0
        then assign tot2 = tot2 + (estcusto * de)
                    vde  = vde  + de.

        display produ.procod column-label "Codigo"
                produ.pronom FORMAT "x(35)"
                est (TOTAL) column-label "Qtd." format "->>>>9"
                vqtd(total) column-label "Dig." format "->>>>9"
                ac(total) when ac > 0 column-label "Acresc."
                de(total) when de > 0 column-label "Decres."
                estoq.estcusto column-label "Pc.Custo" format ">,>>9.99"
                (ac * estoq.estcusto)(total) when ac > 0
                        column-label "Vl.Acresc." format "->>>,>>9.99"
                (de * estoq.estcusto)(total) when de > 0
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
