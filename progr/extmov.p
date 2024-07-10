{admcab.i}
def var varquivo as char.
def var vetbcod like estab.etbcod.
def var vprocod like produ.procod.
def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vdata1 like plani.pladat label "Data".
def var vdata2 like plani.pladat label "Data".
def var vtotal like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
              /**** Campo usado para guardar o no. da planilha ****/


repeat:
    vtotmovim = 0.
    vtotgeral = 0.
    update vprocod with frame f-pro centered width 80 color blue/cyan row 4
                        side-label.
    find produ where produ.procod = vprocod no-lock.
    disp produ.pronom no-label with frame f-pro.
    update vdata1
           vdata2 label "A " with frame f1 side-labe centered
           color blue/cyan  title "Periodo" row 8.


    varquivo = "../relat/extmov" + string(time).
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = ""EXTMOV""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
        &Tit-Rel   = """RELATORIO DE MOVIMENTACOES POR PRODUTO "" +
                    ""  - Data: "" + string(vdata1) + "" A "" +
                        string(vdata2)"
        &Width     = "120"
        &Form      = "frame f-cabcab"}


    disp produ.procod label "Produto"
         produ.pronom no-label with frame fp side-label.

    for each movim where movim.procod = produ.procod and
                         movim.DATEXP >= vdata1     and
                         movim.DATEXP <= vdata2 no-lock
                                 break by movim.movtdc
                                       by movim.movdat:

        if first-of(movim.movtdc)
        then do:
            find tipmov where tipmov.movtdc = movim.movtdc no-lock no-error.
            if avail tipmov
            then
            disp tipmov.movtdc format ">>"
                 tipmov.movtnom no-label with frame f-tip side-label.
        end.
        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.pladat = movim.movdat and
                               plani.movtdc = movim.movtdc
                                        no-lock no-error.
        if not avail plani
        then next.
        display
            movim.movdat
            plani.numero FORMAT "999999999"
            plani.serie
            plani.emite column-label "Emitente" format ">>>>>>>"
            plani.desti column-label "Destino" format ">>>>>>>>>9"
            movim.movqtm format ">>>9"
            movim.movpc
            (movim.movpc * movim.movqtm)(total by movim.movtdc)
            column-label "Total"
                         with frame f-val down no-box width 200.
            vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).

        /*
        if last-of(movim.movtdc)
        then do:
            put skip(1) "Total =>  " at 95 vtotmovim.
            vtotmovim = 0.
        end.
        */
    end.
    output close.
    
    
if opsys = "UNIX"
then do:
    output close.
    run visurel.p (varquivo,"").
end.
else do:
    {mrod.i}
end.    
end.

