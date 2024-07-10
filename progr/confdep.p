{admcab.i}

def new shared temp-table tt-dep
   field  deprec      as recid
   field  Etbcod      like estab.Etbcod
   field  pladat      like plani.pladat
   field  cheque-dia  like plani.platot
   field  cheque-pre  like plani.platot
/* field  cheque-glo  like plani.platot */
   field  pagam       like plani.platot
   field  deposito    like plani.platot
   field  situacao    as l format "Sim/Nao".

def var varquivo as char format "x(30)".
def var vdata   as date format "99/99/9999".
def stream stela.

repeat:
    update vdata label "Data"
            with frame f-data centered color blue/cyan side-label width 80.
    for each tt-dep:
        delete tt-dep.
    end.

    for each estab no-lock:
        find first plani where plani.movtdc = 5             and
                               plani.etbcod = estab.etbcod  and
                               plani.pladat = vdata         and
                               plani.seguro > 0 no-lock no-error.
        if not avail plani
        then next.
        create tt-dep.
        assign tt-dep.deprec      = recid(plani)
               tt-dep.pladat      = plani.pladat
               tt-dep.etbcod      = plani.etbcod
               tt-dep.deposito    = plani.seguro
               tt-dep.cheque-dia  = plani.iss
               tt-dep.cheque-pre  = plani.notpis
           /*  tt-dep.cheque-glo  = plani.cusmed */
               tt-dep.pagam       = plani.notcofins
               tt-dep.situacao    = plani.tmovdev.
    end.

    run wdep.p.

end.
