{admcab.i}
def var vok as log.
def var vqtd as dec.
def var vtot31 as dec.
def var vtot41 as dec.
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
def var vetbcod   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvlcusto    like plani.platot column-label "Vl.Custo".
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvlmarg     like plani.platot column-label "Margem".
def var vvlperc     as dec format ">>9.99 %" column-label "Perc".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def stream stela.
def var vtot like plani.platot.
def buffer bcontnf for contnf.
def buffer bplani for plani.
def var vmes like hiest.hiemes.
def var vano like hiest.hieano.
def temp-table tt-estoq
    field etbcod like estoq.etbcod
    field est41  like estoq.estatual
    field est31  like estoq.estatual.
    

repeat:
    for each tt-estoq.
        delete tt-estoq.
    end.

    update vetbcod 
           with frame f-etb centered color blue/cyan row 10
                                    title " Filial " side-label.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-etb.
    update vmes
           vano
           with frame f-per centered color blue/cyan row 15.
    update vcatcod label "Departamento"
            with frame f-dep side-label centered.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.
        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

        {mdadmcab.i
            &Saida     = "\admcom\relat\cusme1"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""CUSME1""
            &Nom-Sis   = """SISTEMA DE ESTOQUE  DEPARTAMENTO "" +
                            string(vcatcod,""99"")"
            &Tit-Rel   = """CONTROLE DE ESTOQUE FILIAL "" + 
                            string(vetbcod,"">>9"")"
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    disp vmes
         vano with frame ffff side-labels centered.

    for each produ use-index catpro
            where produ.catcod = vcatcod no-lock:

            vtot = 0.

            vqtd = 0.
            vok = no.

            find first hiest where hiest.etbcod = estab.etbcod and
                                   hiest.procod = produ.procod and
                                   hiest.hiemes = vmes and
                                   hiest.hieano = vano no-lock no-error.
            if avail hiest
            then do:
                assign vqtd = hiest.hiestf
                       vok = yes.
            end.
            else do:
                find last hiest where hiest.etbcod = estab.etbcod and
                                      hiest.procod = produ.procod and
                                      hiest.hieano = vano
                                      no-lock no-error.
                if avail hiest
                then do:
                    vqtd = hiest.hiestf.
                    vok = yes.
                end.
            end.

            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.

            if vok = no
            then vqtd = estoq.estatual.

            output stream stela to terminal.
            disp stream stela
                 produ.procod 
                 produ.pronom
                 with frame fffpla centered color white/red.
            pause 0.
            output stream stela close.

            if vqtd <= 0
            then next.

            find last movim use-index datsai
                      where movim.procod = produ.procod and
                            movim.movtdc = 4 no-lock no-error.

            if avail movim
            then vtot = (vqtd * movim.movpc).
            else vtot = (vqtd * estoq.estcusto).

        disp produ.procod
             produ.pronom
             vqtd(total) column-label "Quantidade"
             vtot(total) column-label "Sub-Total" 
                           format ">>,>>>,>>9.99" 
         with frame f-imp width 200 down.
    end.
    
    output close.
    dos silent value("type \admcom\relat\cusme1 > prn"). 
end.
