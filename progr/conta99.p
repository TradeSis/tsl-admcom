{admcab.i}
def var varquivo as char.
def var vmov like plani.platot.
def var vcon like plani.platot.
def var i as i.
def var vcat like produ.catcod initial 41.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vcatcod     like produ.catcod.
def var vcatcod2    like produ.catcod.
def var vdt like plani.pladat.
def var vmes as char format "X(3)" extent 12
initial["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET",
        "OUT","NOV","DEZ"].
def var vm as int extent 12.

def stream stela.
def temp-table wpro
    field wetb like estab.etbcod
    field wmes as int format "99"
    field wcat like produ.catcod
    field wqtd like movim.movqtm.

repeat:
    for each wpro:
        delete wpro.
    end.
    vcon = 0.
    vmov = 0.

    vcatcod2 = 0.

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".
    do vdt = vdti to vdtf:
        for each estab where estab.etbcod < 900 no-lock:
            for each plani where plani.movtdc = 5 and
                                 plani.pladat = vdt and
                                 plani.etbcod = estab.etbcod no-lock:
             
                /* if plani.crecod = 1
                then next. */
              
                if {conv_igual.i estab.etbcod} 
                then next.

                find last movim where movim.etbcod = plani.etbcod and
                                      movim.placod = plani.placod and
                                      movim.movtdc = plani.movtdc and
                                      movim.movdat = plani.pladat
                                                          no-lock no-error.
                if not avail movim
                then next.
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.
                find first wpro where wpro.wetb = movim.etbcod and
                                      wpro.wcat = produ.catcod no-lock no-error.
                if not avail wpro
                then do:
                    create wpro.
                    assign wpro.wetb = plani.etbcod
                           wpro.wcat = produ.catcod.
                end.
                wpro.wqtd = wpro.wqtd + 1.
                disp movim.etbcod plani.datexp format "99/99/9999" produ.catcod
                with 1 down. pause 0.
            end.
        end.
    end.

    for each estab no-lock: 
        find first wpro where wpro.wetb = estab.etbcod and
                              wpro.wcat = 31 no-error.
        if not avail wpro 
        then do: 
            create wpro. 
            assign wpro.wetb = estab.etbcod 
                   wpro.wcat = 31.
        end. 
        find first wpro where wpro.wetb = estab.etbcod and
                              wpro.wcat = 41 no-error.
        if not avail wpro 
        then do: 
            create wpro. 
            assign wpro.wetb = estab.etbcod 
                   wpro.wcat = 41.
        end. 

    end.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/conta04.txt" + string(time).            
    else varquivo = "l:\relat\conta04.txt" + string(time).
                  
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""GERAL""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """QUANTIDADE DE CONTRATOS - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}
    for each wpro break by wpro.wcat
                        by wpro.wetb
                        by wpro.wmes.

        if first-of(wpro.wcat)
        then do:
            find categoria where categoria.catcod = wpro.wcat no-lock no-error.
            if not avail categoria
            then next.
            disp categoria.catcod
                 categoria.catnom with frame f-cat side-label width 200.
        end.
        if first-of(wpro.wetb)
        then do:
            find estab where estab.etbcod = wpro.wetb no-lock.
            put skip estab.etbnom.
        end.
        put wpro.wqtd.
        if wpro.wcat = 31 or
           wpro.wcat = 35
        then vmov = vmov + wpro.wqtd.
        if wpro.wcat = 41 or
           wpro.wcat = 45
        then vcon = vcon + wpro.wqtd.
    end.

    i = 0.
    put skip(3)
    "TOTAIS...........    MOVEIS                 CONFECCOES" SKIP.
    put space(15) vmov format ">>>>>>9"
        space(15) vcon format ">>>>>>9" skip.


    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:    
    {mrod.i}
    end.
end.
