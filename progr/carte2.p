{admcab.i}
def var vetbcod like estab.etbcod.
def var vok as l.
def var vcatcod  like produ.catcod.
def var vcatcod2 like produ.catcod.
def var vdt like titulo.titdtven.
def var vdti like titulo.titdtven.
def var vdtf like titulo.titdtven.
def temp-table wtit
    field wetb like titulo.etbcod
    field wvalor like titulo.titvlcob
    field wpar   like titulo.titpar format ">>>>9".

repeat:
    update vetbcod with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdti label "Data Inicial"
           vdtf label "Data Final" with frame f1 side-label width 80.
    update vcatcod  label "Departamento"     colon 20
           with frame f1 side-labels width 80 row 4 .
    find categoria where categoria.catcod = vcatcod no-lock no-error.
    display categoria.catnom no-label with frame  f1.
    if vcatcod = 41
    then vcatcod2 = 45.
    if vcatcod = 31
    then vcatcod2 = 35.

    for each wtit.
        delete wtit.
    end.
    do vdt = vdti to vdtf:
        for each titulo where titulo.empcod = 19    and
                              titulo.titnat = no    and
                              titulo.modcod = "CRE" and
                              titulo.titdtven = vdt and
                              titulo.etbcod   = vetbcod no-lock:
            vok = yes.
            if substring(string(titulo.titnum),1,1) = "M"
            then next.
            if substring(string(titulo.titnum),1,1) = "U"
            then next.
            if substring(string(titulo.titnum),1,1) = "D"
            then next.
            for each contnf where contnf.etbcod = titulo.etbcod and
                                  contnf.contnum = int(titulo.titnum) no-lock.
                find first plani where plani.etbcod = contnf.etbcod and
                                       plani.placod = contnf.placod
                                                    no-lock no-error.
                if not avail plani
                then next.

                vok = no.
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                      movim.movtdc = plani.movtdc no-lock:
                    find produ where produ.procod = movim.procod
                                                        no-lock no-error.
                    if not avail produ
                    then next.
                    if produ.catcod <> vcatcod and
                       produ.catcod <> vcatcod2
                    then do:
                        vok = no.
                        leave.
                    end.
                    else vok = yes.
                end.
                if vok = no
                then next.

                find first wtit where wtit.wetb = titulo.etbcod no-error.
                if not avail wtit
                then do:
                    create wtit.
                    assign wtit.wetb = titulo.etbcod.
                end.
                wtit.wvalor = wtit.wvalor + titulo.titvlcob.
                wtit.wpar   = wtit.wpar   + 1.
                display wtit.wetb wtit.wvalor wtit.wpar with 1 down. pause 0.
            end.
        end.
    end.
    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""CARTE2""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """MOVIMENTO DA CARTEIRA POR FILIAL - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") + ""    "" +
                                  categoria.catnom "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    for each wtit by wtit.wetb:
        disp wtit.wetb column-label "Filial"
             wtit.wvalor(total) column-label "Vl.Total"
             wtit.wpar   column-label "Tot.Par" with frame f2 down width 130.
    end.
    output close.

end.
