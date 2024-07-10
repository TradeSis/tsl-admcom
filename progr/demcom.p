{admcab.i}
def var wmark as dec.
def var wperven as dec.
def var i as i.
def var vdti as date label "Data Inicial Compra".
def var vdtf as date label "Data Final   Compra".
def var westtotal  like plani.platot.
def var wventotal  like plani.platot.
def var vetbcod like estab.etbcod.
def var westtotqtd as i label "Estoque".
def var wventotqtd as i label "Qtd.Ven.".
def var wvenqtd as i.
def var vmes as int format ">9".
def var vano as int format ">>>9".
def temp-table whiest
    field clacod like clase.clacod
    field clanom like clase.clanom
    field qtdcom as i format ">>>>9" label "QCom"
    field valcom like plani.platot format ">>,>>9.99" column-label "Val.Comp."
    field qtdent as i format ">>>>9" label "QEnt"
    field valent like plani.platot format ">>,>>9.99" column-label "Val.Entr."
    field estqtd as i format ">>>>9" label "Est.".

def var wqtdcom as i label "Qtd.Comp.".
def var wvalcom like plani.platot column-label "Val.Comp.".
def var wqtdent as i label "Qtd.Entr.".
def var wvalent like plani.platot column-label "Val.Entr.".
def var westqtd as i label "Estoque".
def var westtot as i label "Estoque".

do:
    vetbcod = setbcod.
    update vetbcod skip
           vdti
           vdtf with frame f1 side-label width 80.
    pause 0 before-hide.

    wqtdcom = 0.
    wvalcom = 0.
    wqtdent = 0.
    wvalent = 0.
    westqtd = 0.
    westtot = 0.


    for each produ no-lock :
        display produ.procod with 1 down centered. pause 0.
        westqtd = 0.
        if vetbcod > 0
        then do:
            find estoq where estoq.etbcod = vetbcod and
                             estoq.procod = produ.procod no-lock.
            if estoq.estatual <> ?
            then do:
                westqtd = westqtd + estoq.estatual.
                westtot = westtot + estoq.estatual.
            end.
        end.
        else do:
            for each estoq where estoq.procod = produ.procod:
                if estoq.estatual <> ?
                then do:
                    westqtd = westqtd + estoq.estatual.
                    westtot = westtot + estoq.estatual.
                end.
            end.
        end.

        find first whiest where whiest.clacod = produ.clacod no-error.
        if not avail whiest
        then do:
            create whiest.
            assign whiest.clacod = produ.clacod.
            find clase where clase.clacod = whiest.clacod.
            assign whiest.clanom = clase.clanom.
        end.

        for each liped where liped.procod = produ.procod and
                             liped.pedtdc = 1 no-lock:
            find pedid of liped no-lock.
            if pedid.peddat >= vdti and
               pedid.peddat <= vdtf
            then do:

                whiest.qtdcom = whiest.qtdcom + liped.lipqtd.
                whiest.valcom = whiest.valcom + (liped.lipqtd * liped.lippreco).
                whiest.qtdent = whiest.qtdent + liped.lipent.
            whiest.valent = whiest.valent + (liped.lipent * liped.lippreco).

                wqtdcom = wqtdcom + liped.lipqtd.
                wvalcom = wvalcom + (liped.lipqtd * liped.lippreco).
                wqtdent = wqtdent + liped.lipent.
                wvalent = wvalent + (liped.lipent * liped.lippreco).

            end.
        end.

        whiest.estqtd = whiest.estqtd + westqtd.

    end.


    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "60"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""DEMCOM""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """DEMONSTRATIVO DE COMPRAS POR CLASSE NA LOJA "" +
                     string(vetbcod) + "" - "" + string(vdti) + "" A "" +
                                                 string(vdtf)"
        &Width     = "130"
        &Form      = "frame f-cabcab"}

    for each whiest where whiest.qtdcom > 0
                           break by substring(string(whiest.clanom,"x(9)"),1,9)
                                 by whiest.clanom:

        find clase where clase.clacod = whiest.clacod.

        display clase.clacod
                clase.clanom

                whiest.qtdcom
                   (total /* by substring(string(whiest.clanom,"x(9)"),1,9) */ )
                format ">>>>9"
                ((whiest.qtdcom / wqtdcom) * 100)
                   (total /* by substring(string(whiest.clanom,"x(9)"),1,9) */ )
                         format "->>9.99%"
                        column-label "Perc."
                whiest.valcom
                   (total /* by substring(string(whiest.clanom,"x(9)"),1,9) */ )
                format ">>>,>>9.99"
                ((whiest.valcom / wvalcom) * 100)
                   (total /* by substring(string(whiest.clanom,"x(9)"),1,9) */ )
                         format "->>9.99%"
                        column-label "Perc."
                whiest.qtdent
                   (total /* by substring(string(whiest.clanom,"x(9)"),1,9) */ )
                format ">>>>9"
                ((whiest.qtdent / wqtdent) * 100)
                   (total /* by substring(string(whiest.clanom,"x(9)"),1,9) */ )
                         format "->>9.99%"
                        column-label "Perc."
                whiest.valent
                   (total /* by substring(string(whiest.clanom,"x(9)"),1,9) */ )
                   format ">>>,>>9.99"
                ((whiest.valent / wvalent) * 100)
                   (total /* by substring(string(whiest.clanom,"x(9)"),1,9) */ )
                         format "->>9.99%"
                        column-label "Perc."

                whiest.estqtd
                   (total /* by substring(string(whiest.clanom,"x(9)"),1,9) */ )
                format ">>>>9"
                ((whiest.estqtd / westtot) * 100)
                   (total /* by substring(string(whiest.clanom,"x(9)"),1,9) */ )
                         format "->>9.99%"
                        column-label "Perc."

                    with frame f-tot no-box width 130 down.
    end.
    output close.
END.
