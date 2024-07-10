{admcab.i}

def var yy as char.
def var xx as char.
def var vfase1 as int.
def var vfase2 as int.
def var vfase3 as int.
def var vfil like estab.etbcod.
def var fil-maior like plani.platot.
def var fil-atraso like plani.pladat.
def var val-total like plani.platot.
def var data-ven like plani.pladat.
def var maior-venc like plani.pladat.
def var i as int.
def var vetbcod like estab.etbcod.
def buffer btitulo for titulo.



def temp-table tt-cobrador
    field cobcod like cobfil.cobcod
    field cobnom like cobfil.cobnom
    field fase1  as int format ">>9"
    field fase2  as int format ">>9"
    field fase3  as int format ">>9".

def temp-table tt-cobra
    field clicod like clien.clicod
    field dias   as int format ">>>>9".



repeat:
    for each tt-cobra:
        delete tt-cobra.
    end.
    for each tt-cobrador:
        delete tt-cobrador.
    end.
    
    
    update vetbcod label "Filial"with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    for each cobfil where cobfil.etbcod = estab.etbcod no-lock:
        create tt-cobrador.
        assign tt-cobrador.cobcod = cobfil.cobcod
               tt-cobrador.cobnom = cobfil.cobnom.
        display cobfil.cobcod
                cobfil.cobnom with frame f5 down centered color white/cyan.
        update tt-cobrador.fase1 column-label "Fase 1"
               tt-cobrador.fase2 column-label "Fase 2"
               tt-cobrador.fase3 column-label "Fase 3"
                with frame f5.
    end.

    message "Gerar Cobranca" update sresp.
    if not sresp
    then undo, retry.

    data-ven = today.
    i = 0.

    for each titulo use-index titdtpag where titulo.empcod = 19    and
                                             titulo.titnat = no    and
                                             titulo.modcod = "CRE" and
                                             titulo.titdtpag = ?   and
                                             titulo.etbcod = estab.etbcod 
                                                no-lock break by titulo.clifor:
        
        if titulo.clifor = 1
        then next.
        find cobranca where cobranca.clicod = titulo.clifor no-lock no-error.
        if avail cobranca
        then next.

        val-total = val-total + titulo.titvlcob.
        
        if titulo.titdtven < data-ven
        then data-ven = titulo.titdtven.

        if last-of(titulo.clifor)
        then do:
            if (today - data-ven) >= 45 and val-total >= 30
            then do:
                fil-maior = 0.
                vfil = titulo.etbcod.
                fil-atraso = today.
                for each btitulo where btitulo.clifor = titulo.clifor and
                                       btitulo.titsit = "LIB"         
                                            no-lock break by btitulo.etbcod.
                     
                    if btitulo.etbcod <> titulo.etbcod
                    then do:
                        if btitulo.titdtven < fil-atraso
                        then fil-atraso = btitulo.titdtven.
                        fil-maior = fil-maior + btitulo.titvlcob.
                    end.
                 
                     if last-of(btitulo.etbcod)  
                     then do:
                         if fil-maior > val-total and 
                            (today - fil-atraso) >= 45 
                         then vfil = btitulo.etbcod.
                         assign fil-atraso = today
                                fil-maior  = 0.
                     end.
                end.
                if vfil = titulo.etbcod 
                then do:
                    i = i + 1.
                    disp titulo.clifor 
                         today - data-ven 
                         val-total
                         i with 1 down centered row 10 no-label. pause 0.
                    find first tt-cobra where tt-cobra.clicod = titulo.clifor
                                                            no-error.
                    if not avail tt-cobra
                    then do:
                        create tt-cobra.
                        assign tt-cobra.clicod = titulo.clifor
                               tt-cobra.dias   = (today - data-ven).
                    end.
                end.
            end.
            data-ven  = today.
            val-total = 0.
        end.
    end.
    
    for each tt-cobrador:
        vfase1 = 0.
        vfase2 = 0.
        vfase3 = 0.
        xx = "".
        yy = "".
        for each tt-cobra:
            find cobranca where cobranca.clicod = tt-cobra.clicod 
                                            no-lock no-error.
            if avail cobranca
            then next.
            if tt-cobra.dias >= 45 and
               tt-cobra.dias <= 90
            then do transaction:
                vfase1 = vfase1 + 1.
                if vfase1 > tt-cobrador.fase1
                then next.
                create cobranca.
                assign cobranca.etbcod  = estab.etbcod
                       cobranca.cobcod  = tt-cobrador.cobcod
                       cobranca.clicod  = tt-cobra.clicod
                       cobranca.cobgera = today
                       cobranca.cobatr  = tt-cobra.dias
                       cobranca.cobeta  = 1.
            end.

            if tt-cobra.dias >= 91 and
               tt-cobra.dias <= 150
            then do transaction:
                vfase2 = vfase2 + 1.
                if vfase2 > tt-cobrador.fase2
                then next.
                create cobranca.
                assign cobranca.etbcod  = estab.etbcod
                       cobranca.cobcod  = tt-cobrador.cobcod
                       cobranca.clicod  = tt-cobra.clicod
                       cobranca.cobgera = today
                       cobranca.cobatr  = tt-cobra.dias
                       cobranca.cobeta  = 2.
            end.

            if tt-cobra.dias > 151
            then do transaction:
                vfase3 = vfase3 + 1.
                if vfase3 > tt-cobrador.fase3
                then next.
                create cobranca.
                assign cobranca.etbcod  = estab.etbcod
                       cobranca.cobcod  = tt-cobrador.cobcod
                       cobranca.clicod  = tt-cobra.clicod
                       cobranca.cobgera = today
                       cobranca.cobatr  = tt-cobra.dias
                       cobranca.cobeta  = 3.
            end.

            if vfase1 = tt-cobrador.fase1 and
               vfase2 = tt-cobrador.fase2 and
               vfase3 = tt-cobrador.fase3
            then leave.

            find clien where clien.clicod = tt-cobra.clicod no-lock.
            disp clien.clicod
                 clien.clinom
                 tt-cobra.dias with frame f2 down.
        end.
    end.
end.
    

