{admcab.i}
def var varquivo as char format "x(20)".
def var x like plani.platot.
def var y like plani.platot.
def var w like plani.platot.
def var z like plani.platot.
def temp-table wmargem
    field data like plani.pladat
    field valor like plani.platot.

def temp-table w-demo
    field cod     as i
    field etbcod  like estab.etbcod
    field wtot    like plani.platot
    field wtotal  like plani.platot
    field wtotacr like plani.platot
    field wtotser like plani.platot.
def buffer bplani for plani.
def buffer bcontnf for contnf.
def var vtot like plani.platot.
def var wacr like plani.platot.
def var vetbcod like estab.etbcod.
def var vdt1 like plani.pladat.
def var vdt2 like plani.pladat.
def var vtotal like plani.platot.
def var vtotal1 like plani.platot.
def var vtotal2 like plani.platot.
def var valortot like plani.platot.
def var vvltotal like plani.platot.
def var vtotacr like plani.platot.
def var vtotser like plani.platot.
def var vvlcont like plani.platot.
def var wper like plani.platot.
def var vvldesc like plani.platot.
def var vvlacre like plani.platot.
repeat:
    for each wmargem:
        delete wmargem.
    end.
    for each w-demo:
        delete w-demo.
    end.
    update vetbcod with frame f1 side-label width 80.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
    else display "GERAL" @ estab.etbnom with frame f1.

    update vdt1 label "Periodo"
           vdt2 no-label with frame f1.
    for each estab where ( if vetbcod = 0
                           then true
                           else estab.etbcod = vetbcod ) no-lock.
    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 5 and
                         plani.pladat >= vdt1 and
                         plani.pladat <= vdt2 no-lock break by plani.etbcod:

        vvltotal = 0.
        vvlcont = 0.
        vvldesc = 0.
        wacr = 0.
        if plani.crecod > 1
        then do:
            find first contnf where contnf.etbcod = plani.etbcod and
                                    contnf.placod = plani.placod
                                        no-lock no-error.
            if avail contnf
            then do:
                for each bcontnf where bcontnf.etbcod  = contnf.etbcod and
                                       bcontnf.contnum = contnf.contnum
                                           no-lock:
                    find first bplani where bplani.etbcod = bcontnf.etbcod and
                                      bplani.placod = bcontnf.placod and
                                      bplani.pladat = plani.pladat   and
                                      bplani.movtdc = plani.movtdc
                                          no-lock no-error.
                    if not avail bplani
                    then next.
                    vvltotal = vvltotal + (bplani.platot - bplani.vlserv).
                end.
                find contrato where contrato.contnum = contnf.contnum
                                                 no-lock no-error.
                if avail contrato
                then do:
                    vvlcont = contrato.vltotal.
                    valortot = contrato.vltotal.
                    wacr = vvlcont  - vvltotal.

                    wper = plani.platot / vvltotal.

                    wacr = wacr * wper.

                end.
                else do:
                     wacr = plani.acfprod.
                     valortot = plani.platot.
                end.

                if wacr < 0 or wacr = ?
                then wacr = 0.

                assign vvldesc  = vvldesc  + plani.descprod
                       vvlacre  = vvlacre  + wacr.
                 
            end.

            vtot = vtot + plani.platot.
            vtotal = vtotal + plani.platot - vvldesc + wacr.
            vtotacr = vtotacr + wacr.
        end.
        else do:
            vtot = vtot + plani.platot.
            vtotal = vtotal + plani.platot.
        end.
        if last-of(plani.etbcod)
        then do:
        
           vtotser = 0.      
            for each serial where serial.etbcod = plani.etbcod and
                                  serial.serdat >= vdt1 and
                                  serial.serdat <= vdt2 no-lock:
                vtotser = vtotser + serial.serval.
            end.
 
            
            create w-demo.
            assign w-demo.cod     = 1
                   w-demo.etbcod  = estab.etbcod
                   w-demo.wtot    = vtot
                   w-demo.wtotal  = vtotal
                   w-demo.wtotacr = vtotacr
                   w-demo.wtotser = vtotser.
            clear frame f2 no-pause.
            x = 0.
            y = 0.
            w = 0.
            z = 0.
            for each w-demo break by w-demo.cod:
                display w-demo.etbcod column-label "Fl"  format ">>9"
                        wtot column-label "Total Liq." format ">,>>>,>>9.99"
                        wtotacr column-label "Tot.Acre." format ">,>>>,>>9.99"
                        wtotal column-label "Total Venda"
                        (wtot - wtotser) 
                            column-label "Diferenca" format "->>,>>9.99"
                        wtotser column-label "Serial"  format ">>,>>>,>>9.9"
                        (((wtot - wtotser) / wtot) * 100) 
                                column-label "Perc %" format "->>9.99 %"
                                    with frame f2 down width 80.
                x = x + wtot.
                y = y + wtotal.
                w = w + wtotacr.
                z = z + wtotser.
                down with frame f2.
                pause 0.
            end.


            create wmargem.
            assign wmargem.data = plani.pladat
                   wmargem.valor = vtotal.
            vtotal = 0.
            vtotacr = 0.
            vvlacre = 0.
            vvldesc = 0.
            valortot = 0.
            wacr = 0.
            wper = 0.
            vvltotal = 0.
            vvlcont  = 0.
            valortot = 0.
            vtot = 0.
            vtotser = 0.
        end.
    end.
    end.
    display x label "Total Liquido"
            y label "Total Venda"
            w label "Total Acre."
            z label "Total Devolucao"
                        with frame f-tot side-label color white/red.

    varquivo = "..\relat\ctb" + STRING(month(vdt1),"99").

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""CTB-VEN""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
        &Tit-Rel   = """DEMONSTRATIVO DE VENDAS POR FILIAL - PERIODO DE "" +
                                  string(vdt1,""99/99/9999"") + "" A "" +
                                  string(vdt2,""99/99/9999"")"
        &Width     = "130"
        &Form      = "frame f-cabcab"}

        for each w-demo:
            display w-demo.etbcod column-label "Fl" format ">>9"
                   wtot(total) column-label "Total Liq." format ">,>>>,>>9.9"
                   wtotacr(total) column-label "Total Acre." format ">>>,>>9.9"
                   wtotal(total) format "->>,>>>,>>9.9"
                                column-label "Total Venda"
                   wtotser(total) column-label "Serial" format ">>,>>>,>>9.9"
                   (wtot - wtotser)(total) 
                    column-label "Diferenca" format "->,>>>,>>9.9"
                   (((wtot - wtotser) / wtot) * 100) 
                                column-label "Perc %" format "->>9.99 %"
                                    with frame f4 down width 200.
        end.
        output close.
        message "Deseja imprimir relatorio" update sresp.
        if sresp
        then dos silent value("type " + varquivo + " > prn").

end.
