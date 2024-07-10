{admcab.i}
def temp-table tt-curpro
  field pos     like curpro.pos
  field cod     like curpro.cod
  field valven  like curpro.valven
  field qtdven  like curpro.qtdven
  field valcus  like curpro.valcus
  field qtdest  like curpro.qtdest
  field estcus  like curpro.estcus
  field estven  like curpro.estven
  field giro    like curpro.giro.

def var vano as i.
def var vmes as i.
def var varquivo as char format "x(20)".
def var vcusto   like estoq.estcusto.
def var vestven  like estoq.estvenda.
def var totcusto like estoq.estcusto.
def var totvenda like estoq.estvenda.
def buffer bestoq for estoq.
def var v-ac like plani.platot.
def var v-de like plani.platot.
def buffer btt-curpro for tt-curpro.
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
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

repeat:
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

    if vcatcod = 31
    then vcatcod2 = 35.
    if vcatcod = 41
    then vcatcod2 = 45.

    vdti = today - 30.
    vdtf = today.
    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".
    vetbi = 1.
    vetbf = 999.
    
    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".
    for each tt-curpro:
        delete tt-curpro.
    end.
    totcusto = 0.
    totvenda = 0.
    for each produ where produ.catcod = vcatcod or
                         produ.catcod = vcatcod2 no-lock:
        output stream stela to terminal.
        disp stream stela produ.procod produ.fabcod
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

        find first tt-curpro where tt-curpro.cod = produ.procod no-error.
        if not avail tt-curpro
        then do:
            create tt-curpro.
            find last btt-curpro no-error.
            if not avail btt-curpro
            then tt-curpro.pos = 1000000.
            else tt-curpro.pos = btt-curpro.pos + 1.
            tt-curpro.cod = produ.procod.
        end.

        vestven = 0.
        vcusto  = 0.
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock:
            find bestoq where bestoq.etbcod = estab.etbcod and
                              bestoq.procod = produ.procod no-lock no-error.
            if not avail bestoq
            then next.
            vestven = vestven + (bestoq.estatual * bestoq.estvenda).
            vcusto  = vcusto  + (bestoq.estatual * bestoq.estcusto).
            tt-curpro.qtdest = tt-curpro.qtdest + bestoq.estatual.
        end.
        assign tt-curpro.estven = tt-curpro.estven + vestven
               tt-curpro.estcus = tt-curpro.estcus + vcusto.
        for each movim where movim.procod = produ.procod and
                             movim.movtdc = 5 and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf no-lock:
            v-de = 0.
            v-ac = 0.
            if movim.etbcod >= vetbi and
               movim.etbcod <= vetbf
            then do:
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                            no-lock no-error.
                if avail plani and plani.crecod = 2
                then do:
                for each contnf where contnf.etbcod = plani.etbcod and
                                      contnf.placod = plani.placod no-lock.
                    find contrato where contrato.contnum = contnf.contnum
                                no-lock no-error.
                    if avail contrato
                    then do:
                        if contrato.vltotal > (plani.platot - plani.vlserv)
                        then v-ac = contrato.vltotal /
                                              (plani.platot - plani.vlserv).
                        if contrato.vltotal < (plani.platot - plani.vlserv)
                        then v-de = (plani.platot - plani.vlserv)
                                              / contrato.vltotal.
                    end.
                end.

                if plani.platot < 1
                then assign v-de = 0
                            v-ac = 0.
                end.


                find estoq where estoq.etbcod = movim.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.
                if not avail estoq
                then next.


                tt-curpro.qtdven = tt-curpro.qtdven + movim.movqtm.
                if v-ac = 0 and v-de = 0
                then tt-curpro.valven = tt-curpro.valven +
                                    (movim.movqtm * movim.movpc).
                if v-ac > 0
                then tt-curpro.valven = tt-curpro.valven +
                                    ((movim.movqtm * movim.movpc) * v-ac).
                if v-de > 0
                then tt-curpro.valven = tt-curpro.valven +
                                    ((movim.movqtm * movim.movpc) / v-de).
                tt-curpro.valcus = tt-curpro.valcus + (movim.movqtm *
                                   estoq.estcusto).  
                v-ac = 0.
                v-de = 0.
            end.
        end.

    end.

    i = 1.
    tot-v = 0.
    tot-c = 0.
    for each tt-curpro by tt-curpro.valven descending:
        tt-curpro.pos = i.
        tot-v = tot-v + tt-curpro.valven.
        tot-c = tot-c + (tt-curpro.valven - tt-curpro.valcus).
        i = i + 1.
    end.
    hide frame f-dep no-pause.
    hide frame f-etb no-pause.
    hide frame ffff  no-pause.
    hide frame f-dat no-pause.
    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label row 3
                                        width 80.
    vacum = 0.

    for each tt-curpro by tt-curpro.pos:

        if tt-curpro.estcus = 0 and
           tt-curpro.estven = 0 and
           tt-curpro.qtdven = 0 and
           tt-curpro.qtdest = 0
        then next.

        vacum = vacum + ((tt-curpro.valven / tot-v) * 100).
        find produ where produ.procod = tt-curpro.cod no-lock no-error.

        tt-curpro.giro = (tt-curpro.estven / tt-curpro.valven).

        disp produ.procod column-label "Codigo" 
             produ.pronom when avail produ format "x(30)" column-label "Nome"
             tt-curpro.qtdven(total) format "->>>9"    column-label "Qtd!Ven"
             tt-curpro.valcus(total) format ">>>,>>9" column-label "Vl.Cus"
             tt-curpro.valven(total) format ">>>,>>9" column-label "Vl.Ven"
             tt-curpro.qtdest(total) format "->>>9"    column-label "Qtd!Est"
             tt-curpro.giro when tt-curpro.giro > 0 
                                 format ">>>>9" column-label "Giro"
                     with frame f-imp width 80 down.
    end.
end.
