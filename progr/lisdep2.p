{admcab.i}
def var xx as char.
def var vdata like pedid.peddat.
def temp-table wpro
    field wcod as int format ">>>>>9"
    field wqtd as dec format ">>,>>9.99".
repeat:
    update vdata label "Data Ped."
            with frame f1 side-label width 80.
    for each wpro:
        delete wpro.
    end.


    for each liped where liped.pedtdc = 3 and
                         liped.predt  = vdata no-lock break by liped.etbcod:
        find produ where produ.procod = liped.procod no-lock no-error.
        if not avail produ
        then next.
        if produ.fabcod <> 45 and
           produ.fabcod <> 44
        then next.
        find first wpro where wpro.wcod = liped.procod no-lock no-error.
        if not avail wpro
        then do:
            create wpro.
            assign wpro.wcod = liped.procod.
        end.
        wpro.wqtd = wpro.wqtd + liped.lipqtd.
        disp wpro.wcod
             liped.lipqtd with 1 down. pause 0.
    end.

    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """LISDEP2"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """PEDIDOS DE MERCADORIAS PARA O DEPOSITO"""
        &Width     = "160"
        &Form      = "frame f-cab"}

    for each wpro by wpro.wcod:
        find produ where produ.procod = wpro.wcod no-lock no-error.
        disp produ.procod
             produ.pronom
             wpro.wqtd(total) column-label "Qtd" with frame fb down.
    end.
    output close.

end.
