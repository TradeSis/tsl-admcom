{admcab.i}
def var vlog as log.
define variable wcon like contluc.contnum format ">>>>>>>>>9".
repeat with frame f1:
    wcon = 0.
    do with 1 column width 80 frame f1 title " contluc ":
        update wcon.
        find contluc where contluc.contnum = wcon no-error.
        if not available contluc
        then do: 
            message "contluc nao cadastrado".
            undo,retry.
        end.
        display contluc.clicod.
        find clien of contluc no-error.
        display clien.clinom when avail clien.
        display dtinicial format "99/99/9999" etbcod banco.
    end.
    do with side-label width 31 frame f2 title " Valores ":
        display skip(1) vltotal label "Vlr Total" skip(1).
        display vlentra label "Vlr Entrada" skip(1).
        display vltotal - vlentra label "Vlr liquido" format ">>>,>>>,>>9.99"
          skip(1).
    end.
    for each titluc where titluc.empcod = 19 and
                          titluc.titnum = string(contluc.contnum) and
                          titluc.titnat = no and
                          titluc.clifor = contluc.clicod and
                          titluc.modcod = "CRE" and
                          titluc.etbcod = contluc.etbcod
        with column 32 width 48 frame f3 5 down title " Parcelas ":

        display titluc.etbcod     column-label "Etb"
                titluc.etbcobra   column-label "Cob"
                titluc.titpar
                titluc.titsit
                if titluc.titdtpag <> ?
                then titluc.titdtpag
                else titluc.titdtven  @ titluc.titdtpag 
                    column-label "Vecto/Pagto"
                if titluc.titdtpag <> ?
                then titluc.titvlpag
                else titluc.titvlcob @ titluc.titvlcob column-label "Valor".
    end.
    message "Consultar Nota Fiscal ?" update sresp.
    if sresp
    then do:
        hide frame f3 no-pause.
        hide frame f1 no-pause.
        for each contnf where contnf.contnum = contluc.contnum and
                              contnf.etbcod  = contluc.etbcod no-lock
                                                with frame fnota overlay
                                                    centered row 15 3 down
                                                    color white/cyan.
            find first plani where plani.placod = contnf.placod and
                                   plani.etbcod = contnf.etbcod
                                        no-lock no-error.
            if not avail plani
            then do:
                message "Nota nao encontrada".
                undo, retry.
            end.
            find func where func.etbcod = plani.etbcod and
                            func.funcod = plani.vencod no-lock no-error.
            disp plani.pladat
                 plani.vencod
                 func.funnom when avail func
                 string(plani.horincl,"hh:mm") label "Hora" 
                    with frame f11 centered side-labels color white/red.
                    
            find finan where finan.fincod = plani.pedcod no-lock.
            disp finan.fincod label "Plano"
                 finan.finnom
                 finan.finfat no-label 
                 plani.vlserv label "Devolucao" 
                 plani.biss   label "Total contluc" with frame f11.
        
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movdat = plani.pladat no-lock:
                find produ where produ.procod = movim.procod no-lock no-error.
                disp movim.procod
                     produ.pronom format "x(25)" when avail produ
                     movim.movqtm (total)
                     movim.movpc
                    (movim.movqtm * movim.movpc) (total)
                     with frame f22 centered color white/cyan down.
            end.



        end.
    end.
end.
