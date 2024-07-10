{admcab.i}
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

def buffer bcurfab for curfab.
    
repeat:
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

    if vcatcod = 31
    then vcatcod2 = 35.
    if vcatcod = 41
    then vcatcod2 = 45.

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".

    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".
    for each curfab:
        delete curfab.
    end.
    totcusto = 0.
    totvenda = 0.
    for each produ where produ.catcod = vcatcod or
                         produ.catcod = vcatcod2
                         no-lock:
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

        find first curfab where curfab.cod = produ.fabcod no-error.
        if not avail curfab
        then do:
            create curfab.
            find last bcurfab no-error.
            if not avail bcurfab
            then curfab.pos = 1000000.
            else curfab.pos = bcurfab.pos + 1.
            curfab.cod = produ.fabcod.
        end.

        vestven = 0.
        vcusto  = 0.
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock:
            find bestoq where bestoq.etbcod = estab.etbcod and
                              bestoq.procod = produ.procod no-lock no-error.
            if not avail bestoq
            then next.
            find hiest where hiest.etbcod = estab.etbcod and
                             hiest.procod = produ.procod and
                             hiest.hiemes = month(vdtf)  and
                             hiest.hieano = year(vdtf) no-lock no-error.
            if not avail hiest
            then do:
                if month(vdtf) = 1
                then assign vano = year(vdtf) - 1
                            vmes = 12.
                else assign vano = year(vdtf)
                            vmes = month(vdtf).
                find last hiest where hiest.etbcod = estab.etbcod and
                                      hiest.procod = produ.procod and
                                      hiest.hiemes = vmes         and
                                      hiest.hieano = vano no-lock no-error.
                if not avail hiest
                then do:
                    find bestoq where bestoq.etbcod = estab.etbcod and
                                      bestoq.procod = produ.procod
                                                              no-lock no-error.
                    if avail bestoq
                    then do:
                        vestven = vestven + (bestoq.estatual * bestoq.estvenda).
                        vcusto  = vcusto  + (bestoq.estatual * bestoq.estcusto).
                        curfab.qtdest = curfab.qtdest + bestoq.estatual.
                    end.
                end.
                else do:
                    vestven = vestven + (hiest.hiestf * bestoq.estvenda).
                    vcusto  = vcusto  + (hiest.hiestf * bestoq.estcusto).
                    curfab.qtdest = curfab.qtdest + hiest.hiestf.
                end.
                       

            end.
            else do:
                vestven = vestven + (hiest.hiestf * bestoq.estvenda).
                vcusto  = vcusto  + (hiest.hiestf * bestoq.estcusto).
                curfab.qtdest = curfab.qtdest + hiest.hiestf.
            end.
        end.
        assign curfab.estven = curfab.estven + vestven
               curfab.estcus = curfab.estcus + vcusto.
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


                curfab.qtdven = curfab.qtdven + movim.movqtm.
                if v-ac = 0 and v-de = 0
                then curfab.valven = curfab.valven +
                                    (movim.movqtm * movim.movpc).
                if v-ac > 0
                then curfab.valven = curfab.valven +
                                    ((movim.movqtm * movim.movpc) * v-ac).
                if v-de > 0
                then curfab.valven = curfab.valven +
                                    ((movim.movqtm * movim.movpc) / v-de).
                curfab.valcus = curfab.valcus + (movim.movqtm *
                                estoq.estcusto).    
                v-ac = 0.
                v-de = 0.
            end.
        end.

    end.

    i = 1.
    tot-v = 0.
    tot-c = 0.
    for each curfab by curfab.valven descending:
        curfab.pos = i.
        tot-v = tot-v + curfab.valven.
        tot-c = tot-c + (curfab.valven - curfab.valcus).
        i = i + 1.
    end.

    disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
    pause.

    varquivo = "c:\temp\a" + STRING(day(today)) +
                              STRING(month(today)) +
                string(categoria.catcod,"99").

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""curfab_G""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """curfab ABC FORNECEDORES EM GERAL - DA FILIAL "" +
                                  string(vetbi,"">>9"") + "" A "" +
                                  string(vetbf,"">>9"") +
                          "" PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.
    vacum = 0.

    for each curfab by curfab.pos:

        if curfab.estcus = 0 and
           curfab.estven = 0 and
           curfab.qtdven = 0 and
           curfab.qtdest = 0
        then next.

        vacum = vacum + ((curfab.valven / tot-v) * 100).
        find fabri where fabri.fabcod = curfab.cod no-lock no-error.

        curfab.giro = (curfab.estven / curfab.valven).

        disp curfab.pos format "9999" column-label "Pos."
             curfab.cod format ">>>>>9" column-label "Codigo"
             fabri.fabnom when avail fabri format "x(27)" column-label "Nome"
             curfab.qtdven(total) format "->>>,>>9"    column-label "Qtd.Ven"
             curfab.valcus(total) format "->>>,>>9" column-label "Val.Cus"
             curfab.valven(total) format "->>>,>>9" column-label "Val.Ven"
             ((curfab.valven / tot-v) * 100)(total)
                                 format "->>9.99" column-label "%S/VEN"
             vacum               format "->>9.99" column-label "% ACUM"
             (curfab.valven - curfab.valcus)(total) format "->>>,>>9"
                                                      column-label "LUCRO"
             (((curfab.valven - curfab.valcus) / tot-c) * 100)(total)
                                 format "->>9.99"     column-label "%P/MAR"
             curfab.qtdest(total) format "->>>,>>9"    column-label "Qtd.Est"
             curfab.estcus(total) format "->,>>>,>>9" column-label "Est.Cus"
             curfab.estven(total) format "->>>,>>9" column-label "Est.Ven"
             curfab.giro when curfab.giro > 0
                                 format ">>,>>9.99" column-label "Giro"
                     with frame f-imp width 200 down.
    end.
    output close.
    dos silent value("type " + varquivo + " > prn").
end.
