{admcab.i}
def var i as i.
def var wtotal  like plani.platot.
def var vetbcod like estab.etbcod.
def var wtotqtd as i label "Estoque".
def var wqtd as i.

def var vdti as date label "Data Inicial".
def var vdtf as date label "Data Final".

def var vmes as int format ">9".
def var vano as int format ">>>9".

def temp-table whiest
    field clacod like clase.clacod
    field clanom like clase.clanom
    field valor  like plani.platot column-label "Custo C/ICMS"
    field qtd    as i label "Qtd.Ven.".

repeat:
    update vetbcod
           vdti
           vdtf with frame f1 side-label width 80.

    for each plani where plani.movtdc = 5 and
                         plani.etbcod = vetbcod and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf no-lock:

        display plani.pladat with 1 down centered. pause 0.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod no-lock:

            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.

            find first estoq where estoq.procod  = produ.procod
                                                   no-lock no-error.
            if not avail estoq
            then next.
            if estoq.estcusto = ?
            then next.

            find first whiest where whiest.clacod = produ.clacod no-error.
            if not avail whiest
            then do:
                create whiest.
                assign whiest.clacod = produ.clacod.
                find clase where clase.clacod = whiest.clacod.
                assign whiest.clanom = clase.clanom.
            end.
            whiest.valor = whiest.valor + (movim.movqtm * estoq.estcusto).
            wtotal = wtotal + (movim.movqtm * estoq.estcusto).
            whiest.qtd = whiest.qtd + movim.movqtm.
        end.
    end.
    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "60"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = ""VENCLA""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """RELATORIO DE VENDAS POR CLASSE - "" +
                       ""PERIODO - DE "" + string(vdti) + "" A "" +
                                                string(vdtf) "
        &Width     = "80"
        &Form      = "frame f-cabcab"}


    if vetbcod <> 0 then do:
        find estab where estab.etbcod = input vetbcod.
        disp space "Loja:" space(2)
        estab.etbnom no-label.
    end.
    else do:
        disp space "Loja: TODAS" space(2).
    end.

    put fill("-",80) format "x(80)" skip.

    for each whiest by whiest.clacod:
        if whiest.valor = 0 or whiest.valor = ?
        then next.
        find clase where clase.clacod = whiest.clacod.

        display clase.clacod
                clase.clanom
                whiest.qtd(total)
                whiest.valor(total) format "->,>>>,>>9.99"
                ((whiest.valor / wtotal) * 100) (total) format "->>9.99 %"
                        column-label "Perc."
                    with frame f-tot no-box width 80 down.
    end.
    output close.
END.
