{admcab.i}
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
def var vtotal_platot as dec.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

/* ************************************************************************

Temporario

def var vcontnotas as int. /**/
def temp-table tt-notas 
    field ttrec as recid
    field ttvalor as dec
    field ttcatcod as int
    field ttnumero as int. /**/
************************************************************************* */


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
    for each tt-curva:
        delete tt-curva.
    end.
    totcusto = 0.
    totvenda = 0.


    for each tt-catcod no-lock,
        each produ use-index catpro
            where produ.catcod = tt-catcod.catcod no-lock:
                               
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
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock:
            find bestoq where bestoq.etbcod = estab.etbcod and
                              bestoq.procod = produ.procod no-lock no-error.
            if not avail bestoq
            then next.
            vestven = vestven + (bestoq.estatual * bestoq.estvenda).
            vcusto  = vcusto  + (bestoq.estatual * bestoq.estcusto).
            tt-curva.qtdest = tt-curva.qtdest + bestoq.estatual.
 
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
                then do:
                    vtotal_platot = 0.
                    /* ****************
                    for each contnf where contnf.etbcod = plani.etbcod and
                                          contnf.placod = plani.placod no-lock.
                        find contrato where contrato.contnum = contnf.contnum
                                    no-lock no-error.
                        if avail contrato
                        then do:
                            vlcontrato = contrato.vltotal.
                        end.
                    end.
                    ***************** */
                    find first bcontnf 
                        where bcontnf.etbcod = plani.etbcod and
                              bcontnf.placod = plani.placod no-lock no-error.
                    if available bcontnf
                    then do:
                        find first contnf 
                            where contnf.etbcod  =  plani.etbcod and
                                  contnf.contnum =  bcontnf.contnum and
                                  contnf.placod  <> plani.placod
                            no-lock no-error.
                        if available contnf
                        then do:
                            for each contnf no-lock 
                                where contnf.etbcod  = plani.etbcod and
                                      contnf.contnum = bcontnf.contnum:
                                find first bplani 
                                    where bplani.etbcod = contnf.etbcod and
                                          bplani.placod = contnf.placod 
                                    no-lock.
                                vtotal_platot = vtotal_platot + 
                                                bplani.platot.
                            end.
                            find contrato 
                                where contrato.contnum = bcontnf.contnum 
                                no-lock.
                            vlcontrato = ( plani.platot / vtotal_platot ) *
                                         contrato.vltotal.
                        end.
                        else do:
                            find contrato 
                                where contrato.contnum = bcontnf.contnum 
                                no-lock no-error.
                            if available contrato
                            then vlcontrato = contrato.vltotal.
                            else vlcontrato = plani.platot.
                        end.
                    end.
                end.

                find estoq where estoq.etbcod = movim.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.
                if not avail estoq
                then next.

                /* ************* TEMPORARIO ************************

                find first tt-notas where ttrec = recid( plani ) no-error.
                if not available tt-notas
                then do:
                    create tt-notas.
                    assign tt-notas.ttrec = recid( plani )
                    tt-notas.ttnumero = plani.numero.
                    vcontnotas = vcontnotas + 1.
                end. /**/
                ttvalor = ttvalor + 
                   ( ( movim.movqtm * movim.movpc ) * 
                                    ( vlcontrato / plani.platot ) ). /**/
                ************************************************* */

                if ( ( movim.movqtm * movim.movpc ) * 
                     ( vlcontrato / plani.platot  ) ) > 0
                then do:
                    tt-curva.qtdven = tt-curva.qtdven + movim.movqtm.
                    tt-curva.valven = tt-curva.valven + 
                                      ( ( movim.movqtm * movim.movpc ) * 
                                        ( vlcontrato / plani.platot ) ).
                    tt-curva.valcus = tt-curva.valcus + (movim.movqtm *
                                                         estoq.estcusto). 
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

    disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
    pause.

    varquivo = "i:\admcom\relat\a" + STRING(day(today)) +
                              STRING(month(today)) +
                string(categoria.catcod,"99").

    {mdadmcab.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""curva_G""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """curva ABC FORNECEDORES EM GERAL - DA FILIAL "" +
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

    for each tt-curva by tt-curva.pos:

        if tt-curva.estcus = 0 and
           tt-curva.estven = 0 and
           tt-curva.qtdven = 0 and
           tt-curva.qtdest = 0
        then next.

        vacum = vacum + ((tt-curva.valven / tot-v) * 100).
        find fabri where fabri.fabcod = tt-curva.cod no-lock no-error.

        tt-curva.giro = (tt-curva.estven / tt-curva.valven).

        disp tt-curva.pos format "9999" column-label "Pos."
             tt-curva.cod format ">>>>>9" column-label "Codigo"
             fabri.fabnom when avail fabri format "x(27)" column-label "Nome"
             tt-curva.qtdven(total) format "->>>,>>9"    column-label "Qtd.Ven"
             tt-curva.valcus(total) format "->>>,>>9" column-label "Val.Cus"
             tt-curva.valven(total) format "->>>,>>9" column-label "Val.Ven"
             ((tt-curva.valven / tot-v) * 100)(total)
                                 format "->>9.99" column-label "%S/VEN"
             vacum               format "->>9.99" column-label "% ACUM"
             (tt-curva.valven - tt-curva.valcus)(total) format "->>>,>>9"
                                                      column-label "LUCRO"
             (((tt-curva.valven - tt-curva.valcus) / tot-c) * 100)(total)
                                 format "->>9.99"     column-label "%P/MAR"
             tt-curva.qtdest(total) format "->>>,>>9"    column-label "Qtd.Est"
             tt-curva.estcus(total) format "->,>>>,>>9" column-label "Est.Cus"
             tt-curva.estven(total) format "->>>,>>>,>>9" 
                                                column-label "Est.Ven"
             tt-curva.giro when tt-curva.giro > 0
                                 format ">>,>>9.99" column-label "Giro"
             ((tt-curva.valven / tt-curva.valcus) - 1) * 100
                                 format "->>9.99 %" column-label "Margem"
                                   with frame f-imp width 200 down.
    end.
    output close.
    
    /* *********************** TEMPORARIO ***************************
    output to i:\admcom\work\aleg. /**/
    for each tt-notas no-lock by ttnumero by ttrec: /**/
        export tt-notas.ttnumero tt-notas.ttrec tt-notas.ttvalor. /**/
    end. /**/
    output close. /**/

    message vcontnotas. /**/
    pause. /**/
    ************************************************************* */

    dos silent value("type " + varquivo + " > prn").
end.


