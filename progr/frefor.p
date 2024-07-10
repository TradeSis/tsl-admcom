 {admcab.i}
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vforcod like forne.forcod.
repeat:
    update vforcod label "Fornecedor" with frame f1 side-label.
    find forne where forne.forcod = vforcod no-lock no-error.
    disp forne.fornom no-label format "x(25)" with frame f1.
    update vdti label "Periodo"
           vdtf no-label with frame f1 width 80.

    {confir.i 1 "impressao Posicao Financeira"}

    {mdadmcab.i
        &Saida     = "i:\z"
        &Page-Size = "62"
        &Cond-Var  = "157"
        &Page-Line = "66"
        &Nom-Rel   = ""frefor""
        &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A PAGAR"""
        &Tit-Rel   = """PAGAMENTOS DE TRANSPORTADORAS - PERIODO DE "" +
                        string(vdti) + "" A "" + string(vdtf) "
        &Width     = "157"
        &Form      = "frame f-cabcab"}

        for each plani where plani.movtdc = 4             and
                             plani.emite  = forne.forcod  and
                             plani.datexp >= vdti         and
                             plani.datexp <= vdtf         and
                             plani.serie  = "U"  no-lock:

              for each titulo use-index cxmdat where 
                                  titulo.etbcod = plani.etbcod and
                                  titulo.cxacod = plani.emite  and
                                  titulo.titnumger = string(plani.numero) 
                                           no-lock.
                    find first frete where frete.forcod = titulo.clifor
                                    no-lock.
                    display 
                        titulo.etbcod
                        titulo.titdtven
                        titulo.titdtpag 
                        titulo.titnum column-label "Conhec."
                        plani.numero  column-label "Nota"
                       frete.frenom
                       titulo.titvlcob column-label "Vl.Cobrado" 
                       plani.platot when avail plani column-label "Vl.NFiscal"
                      ((titulo.titvlcob / plani.platot) * 100) when avail plani
                             column-label "Perc" format "->>9.99 %"  
                    with frame f2 down width 200.
             end. 
    end.
    output close.
    dos silent ved i:\z . 
end.
