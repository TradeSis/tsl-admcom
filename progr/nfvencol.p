{admcab.i}

def var vetbcod like plani.etbcod.
def var vnumero like plani.numero format ">>>>>>9".
def var vserie  like plani.serie.

repeat:
    vetbcod = setbcod.
    update vetbcod with frame f1 centered side-labels color white/red.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    update vnumero
           vserie no-label
           with frame f1.

     find first plani where plani.movtdc = 5 and
                            plani.etbcod = vetbcod and
                            plani.emite = vetbcod and
                            plani.serie = vserie and
                            plani.numero = vnumero no-error.
     if not avail plani
     then do:
        bell.
        message "Nota Fiscal nao Existe".
        pause.
     end.
     else do:
        find func where func.etbcod = plani.etbcod and
                        func.funcod = plani.vencod no-lock no-error.
        disp plani.pladat
             plani.vencod
             plani.cxacod
             func.funnom when avail func
             string(plani.horincl,"hh:mm") label "Hora" with frame f1.
        find clien where clien.clicod = plani.desti no-lock no-error.
        if avail clien
        then do:
            disp clien.clicod
                 clien.clinom no-label
                 with frame f3 centered color black/cyan side-labels.
        end.
        find finan where finan.fincod = plani.pedcod no-lock.
        disp finan.fincod label "Plano"
             finan.finnom             
             finan.finfat no-label 
             plani.vlserv label "Devolucao" 
             /*plani.biss   label "Total Contrato"*/ with frame f1.

        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movdat = plani.pladat and
                             movim.movtdc = plani.movtdc no-lock:
            find produ where produ.procod = movim.procod no-lock no-error.
            disp movim.procod
                 produ.pronom format "x(25)" when avail produ
                 movim.ocnum[8] column-label "Promo"
                 movim.ocnum[9] column-label "Plano"
                 movim.movqtm (total) column-label "Qtd." format ">>>9"
                 movim.movpc column-label "Valor!Unit." format ">>,>>9.99"
                (movim.movqtm * movim.movpc) (total) format ">>,>>9.99"
                 with frame f2 centered color white/cyan down.
        end.


    end.

end.
