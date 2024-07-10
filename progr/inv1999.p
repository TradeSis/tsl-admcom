{admcab.i}

def var vqtd as dec.
def var vok as l.
def var totest as dec format ">,>>>,>>9.99".

def var vtotal as dec format ">,>>>,>>9.99" .
def var vetbcod   like estab.etbcod.
def stream stela.
def var vmes like hiest.hiemes.
def var vano like hiest.hieano.
def stream stela.

repeat:
    vtotal = 0.
    totest = 0.
    vok = no.

    update vetbcod label "Filial"
           with frame f-etb centered color blue/cyan side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-etb.
    update vmes
           vano
           vtotal label "Total"
           with frame f-per centered color blue/cyan row 15.

        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

        {mdcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "150"
            &Page-Line = "66"
            &Nom-Rel   = """."""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """INVENTARIO DE ESTOQUE"""
            &Width     = "150"
            &Form      = "frame f-cab"}

    disp vmes
         vano
         estab.etbcod
         estab.etbnom no-label
                with frame ffff side-labels centered.
    vok = no.
    for each estoq where estoq.etbcod = estab.etbcod no-lock.

        if vok 
        then leave.
        find produ where produ.procod = estoq.procod no-lock no-error.
        if not avail produ
        then next.
        if estoq.estatual <= 0
        then next.
        /*
        if produ.clacod = 226
        then next.
        */
        
        
        output stream stela to terminal.
       
        disp stream stela
             produ.procod
             totest with frame ftela side-label centered row 10.
            
        pause 0.
        output stream stela close.



        totest = totest + (estoq.estatual * estoq.estcusto).
        if totest > vtotal
        then do:
            totest = totest - (estoq.estatual * estoq.estcusto).
            next.
        end.
        if totest = vtotal
        then vok = yes.
        disp 
             produ.pronom
             "UN"  column-label "UN.Venda"
             estoq.estatual column-label "Quant."
             estoq.estcusto column-label "Custo Medio"
             (estoq.estatual * estoq.estcusto)  column-label "Sub-Total"
                    with frame f-imp width 200 down.
    end.
    put skip(1) "TOTAL........" at 67
            vtotal format ">>,>>>,>>9.99".
    output close.
    /* dos silent ved c:\inv. */

end.
