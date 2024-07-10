{admcab.i}
def var ii as i.
def var vano as i.
def var vmes as i.
def var varquivo as char format "x(20)".
def var vcusto   like estoq.estcusto.
def var vestven  like estoq.estvenda.
def var totcusto like estoq.estcusto.
def var totvenda like estoq.estvenda.
def buffer bestoq for estoq.
def var v-ac like plani.platot decimals 10.
def var v-de like plani.platot decimals 10.
def buffer bmovim for movim.
def var i as i.
def var tot-c like plani.platot.
def var tot-v like plani.platot format "->>9.99".
def var tot-m like plani.platot.
def var vacum like plani.platot format "->>9.99".
def var wnp as i.
def var vvltotal as dec.
def var vvlcont  as dec.
def var wacr     as dec.
def var wper     as dec.
def var valortot as dec.
def var vval     as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vlfinan  as dec.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvlcusto    like plani.platot column-label "Vl.Custo".
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvlmarg     like plani.platot column-label "Margem".
def var vvlperc     as dec format ">>9.99 %" column-label "Perc".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def var vcatcod2    like produ.catcod.
def var vlcontrato  like contrato.vltotal.
def var vcomcod     like compr.comcod.
def var vtotal_platot as dec.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.



def temp-table tt-curva
    field pos    like curfab.pos
    field cod    like curfab.cod
    field valven like curfab.valven 
    field qtdven like curfab.qtdven
    field valcus like curfab.valcus
    field qtdest like curfab.qtdest
    field estcus like curfab.estcus
    field estven like curfab.estven
    field giro   like curfab.giro.

def temp-table tt-catcod
    field catcod like produ.catcod.

def buffer btt-curva for tt-curva.
    
repeat:
    for each tt-catcod:
        delete tt-catcod.
    end.
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

    if vcatcod = 31
    then do:
        create tt-catcod.
        assign tt-catcod.catcod = 31.
        create tt-catcod.
        assign tt-catcod.catcod = 35.
        create tt-catcod.
        assign tt-catcod.catcod = 50.
    end.
    else do:
        create tt-catcod.
        assign tt-catcod.catcod = 41.
        create tt-catcod.
        assign tt-catcod.catcod = 45.
    end.

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".

    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".

    update vcomcod label "Comprador" format ">>>9"
                with frame f-compr centered color blue/cyan row 10 side-labels.

    find first compr where compr.comcod = vcomcod
                       and vcomcod > 0  no-lock no-error.
                   
    if avail compr then display compr.comnom format "x(27)" no-label
                            with frame f-compr.                 
    else if vcomcod = 0 then display "TODOS" @ compr.comnom no-label
                             with frame f-compr.
    else do:
                    
         message "Comprador não encontrado!" view-as alert-box.
         undo, retry.
                              
    end.

    for each tt-curva:
        delete tt-curva.
    end.
    totcusto = 0.
    totvenda = 0.

    for each tt-catcod no-lock,
        each produ use-index catpro
            where produ.catcod = tt-catcod.catcod no-lock:

        if vcomcod > 0
        then do:
            release liped.
            release pedid.
            find last liped where liped.procod = produ.procod
                              and liped.pedtdc = 1
                                  no-lock use-index liped2 no-error.

            find first pedid of liped no-lock no-error.
    
            if (avail pedid and pedid.comcod <> vcomcod)
                or not avail pedid
            then next.
                    
        end.

        output stream stela to terminal.
            disp stream stela 
                        produ.catcod
                        produ.pronom
                        produ.procod 
                        produ.fabcod
                           with frame ffff centered
                                            color white/red 1 down.
            pause 0.
        output stream stela close.
        find first bmovim where bmovim.procod = produ.procod and
                                bmovim.movtdc = 5            and
                                bmovim.movdat >= vdti        and
                                bmovim.movdat <= vdtf no-lock no-error.
        if not avail bmovim
        then next.

        find first tt-curva where tt-curva.cod = produ.fabcod no-error.
        if not avail tt-curva
        then do:
            create tt-curva.
            find last btt-curva no-error.
            if not avail btt-curva
            then tt-curva.pos = 1000000.
            else tt-curva.pos = btt-curva.pos + 1.
            tt-curva.cod = produ.fabcod.
        end.

        vestven = 0.
        vcusto  = 0.
        ii = 0.
        do ii = vetbi to vetbf:
            find estoq where estoq.etbcod = ii and
                             estoq.procod = produ.procod no-lock no-error.
            if avail estoq
            then do:
                             
                vestven = vestven + (estoq.estatual * estoq.estvenda).
                vcusto  = vcusto  + (estoq.estatual * estoq.estcusto).
                tt-curva.qtdest = tt-curva.qtdest + estoq.estatual.
                
            end.
        end.
        assign tt-curva.estven = tt-curva.estven + vestven
               tt-curva.estcus = tt-curva.estcus + vcusto.
        for each movim where movim.procod = produ.procod and
                             movim.movtdc = 5 and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf no-lock:
            if movim.movqtm = 0 or
               movim.movpc  = 0
            then next.
            v-de = 0.
            v-ac = 0.
            if movim.etbcod >= vetbi and
               movim.etbcod <= vetbf
            then do:
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat and
                                       plani.platot >= 1
                                            no-lock no-error.
                if not available plani
                then next.
                vlcontrato = plani.platot - plani.vlserv.
                if avail plani and plani.crecod = 2
                then vlcontrato = plani.biss.

                if ( ( movim.movqtm * movim.movpc ) * 
                     ( vlcontrato / (plani.platot - plani.vlserv) ) ) > 0
                then do:
                    
                    tt-curva.qtdven = tt-curva.qtdven + movim.movqtm.
                    tt-curva.valven = tt-curva.valven + 
                                      ( ( movim.movqtm * movim.movpc ) * 
                                        ( vlcontrato / 
                                          (plani.platot - vlserv) ) ).
                    find estoq where estoq.etbcod = setbcod and
                                     estoq.procod = produ.procod 
                                            no-lock no-error.
                    if avail estoq
                    then assign tt-curva.valcus = tt-curva.valcus + 
                                          (movim.movqtm * estoq.estcusto).
                end.
            end.
        end.

    end.

    i = 1.
    tot-v = 0.
    tot-c = 0.
    for each tt-curva by tt-curva.valven descending:
        tt-curva.pos = i.
        tot-v = tot-v + tt-curva.valven.
        tot-c = tot-c + (tt-curva.valven - tt-curva.valcus).
        i = i + 1.
    end.

    hide frame ffff no-pause.
    hide frame f-dat no-pause.
    hide frame f-etb no-pause.
    hide frame f-dep no-pause.

    disp categoria.catcod label "Departamento"  colon 15
         categoria.catnom no-label 
            with frame f-dep2 side-label row 3 width 80.

    vacum = 0.

    for each tt-curva by tt-curva.pos:

        if tt-curva.estcus = 0 and
           tt-curva.estven = 0 and
           tt-curva.qtdven = 0 and
           tt-curva.qtdest = 0
        then next.

        vacum = vacum + ((tt-curva.valven / tot-v) * 100).
        find fabri where fabri.fabcod = tt-curva.cod no-lock no-error.

        tt-curva.giro = (tt-curva.estven / tt-curva.valven).

        disp fabri.fabfant when avail fabri format "x(30)" column-label "Nome"
             tt-curva.qtdven(total) format "->>>,>>9" column-label "Qtd.Ven"
             tt-curva.valcus(total) format "->>>,>>9" column-label "Val.Cus"
             tt-curva.valven(total) format "->>>,>>9" column-label "Val.Ven"
             tt-curva.qtdest(total) format "->>>,>>9" column-label "Qtd.Est"
             tt-curva.giro when tt-curva.giro > 0
                                 format ">>9.9" column-label "Giro"
                                   with frame f-imp width 80 down.
    end.
end.

