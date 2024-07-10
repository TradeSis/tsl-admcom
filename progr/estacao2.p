{admcab.i}

def var qtd-0 like estoq.estatual.
def var qtd-1 like estoq.estatual.
def var qtd-2 like estoq.estatual.

def var val-0 like movim.movpc.
def var val-1 like movim.movpc.
def var val-2 like movim.movpc.

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
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.
def var vmes like hiest.hiemes.
def var vano like hiest.hieano.
def var vetccod like produ.etccod.

repeat:

    assign 
         qtd-0 = 0
         qtd-1 = 0
         qtd-2 = 0
         val-0 = 0
         val-1 = 0
         val-2 = 0.

    update vetbi label "Filial"
           with frame f-etb centered color blue/cyan row 10
                                     side-label.
    find estab where estab.etbcod = vetbi no-lock.
    disp estab.etbnom no-label with frame f-etb.
    update vetccod label "Estacao"
                with frame f-etb.
    find estac where estac.etccod = vetccod no-lock no-error.
    disp estac.etcnom no-label with frame f-etb.

    update vmes
           vano
           with frame f-per centered color blue/cyan row 15.

        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""estacao2""
            &Nom-Sis   = """SISTEMA DE ESTOQUE  FILIAL  "" + 
                            string(estab.etbcod,"">>9"")"
            &Tit-Rel   = """CONTROLE DE ESTOQUE   FILIAL  ""  +
                            string(estab.etbcod,"">>9"") + "" "" +
                            estac.etcnom"
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    disp vmes
         vano with frame ffff side-labels centered.

    for each produ where produ.etccod = vetccod no-lock:
        find estoq where estoq.etbcod = estab.etbcod and    
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.

        vtot31 = 0.
        vtot41 = 0.

        assign  qtd-0 = 0
                qtd-1 = 0
                qtd-2 = 0
                val-0 = 0
                val-1 = 0
                val-2 = 0.

            vqtd = 0.
            vok = no.

            if produ.catcod <> 31 and
               produ.catcod <> 41
            then next.

            find first hiest where hiest.etbcod = estab.etbcod and
                                   hiest.procod = produ.procod and
                                   hiest.hiemes = vmes and
                                   hiest.hieano = vano no-lock no-error.
            if avail hiest
            then do:
                vqtd = hiest.hiestf.
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

            if vok = no
            then vqtd = estoq.estatual.

            output stream stela to terminal.
            disp stream stela
                 estab.etbcod
                 produ.procod with frame fffpla centered color white/red.
            pause 0.
            output stream stela close.

            if vqtd <= 0
            then next.

            if produ.catcod = 41
            then qtd-0 = qtd-0 + vqtd.
            
            find last movim use-index datsai
                      where movim.procod = produ.procod and
                            movim.movtdc = 4 no-lock no-error.

            if avail movim
            then do:
                if produ.catcod = 31
                then vtot31 = vtot31 + (vqtd * movim.movpc).
                if produ.catcod = 41
                then vtot41 = vtot41 + (vqtd * movim.movpc).
                
                if produ.catcod = 41
                then val-0 = val-0 + (vqtd * movim.movpc).
                
            end.
            else do:
                if produ.catcod = 31
                then vtot31 = vtot31 + (vqtd * estoq.estcusto).
                if produ.catcod = 41
                then vtot41 = vtot41 + (vqtd * estoq.estcusto).
              
                if produ.catcod = 41
                then  val-0 = val-0 + (vqtd * estoq.estcusto).
            end.

        disp produ.procod
             produ.pronom
             qtd-0(total) column-label "Quantidade"
             val-0(total) column-label "Valor"   
             with frame f-imp width 200 down.
    end.
    output close.
end.
