{admcab.i}
def var zz as int.

def var tot01 as int.
def var tot02 as int.
def var tot03 as int.


def var fase1 as dec.
def var fase2 as dec.
def var fase3 as dec.

def var y as int.
def var x as int.
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
    field fase3  as int format ">>9"
    field conf1  as int format ">>9"
    field conf2  as int format ">>9"
    field conf3  as int format ">>9"
        index ind-1 cobcod.

def temp-table tt-cobra
    field clicod like clien.clicod
    field dias   as int format ">>>>9"
    field val    like plani.platot.



repeat:
    for each tt-cobra:
        delete tt-cobra.
    end.
    for each tt-cobrador:
        delete tt-cobrador.
    end.
    
    assign fase1 = 0
           fase2 = 0
           fase3 = 0.
    
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
    for each cobranca where cobranca.etbcod = vetbcod:
        
        if today - cobranca.cobgera < 45
        then next.

        find first titulo where titulo.etbcod   = cobranca.etbcod   and
                                titulo.titnat   = no                and
                                titulo.clifor   = cobranca.clicod   and
                                titulo.titsit   = "PAG"             and
                                titulo.titdtpag >= cobranca.cobgera 
                                        no-error.
        if not avail titulo
        then do transaction:
            delete cobranca.
        end.
    end.



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
                    
                    if (today - data-ven) >= 45 and
                       (today - data-ven) <= 90
                    then fase1 = fase1 + 1.

                    if (today - data-ven) >= 91 and
                       (today - data-ven) <= 150
                    then fase2 = fase2 + 1.
                    
                    if (today - data-ven) >= 151
                    then fase3 = fase3 + 1.



                    
                    disp titulo.clifor 
                         today - data-ven 
                         val-total
                         i 
                         fase1
                         fase2
                         fase3
                         with 1 down centered row 10 no-label. pause 0.
                    find first tt-cobra where tt-cobra.clicod = titulo.clifor
                                                            no-error.
                    if not avail tt-cobra
                    then do:
                        create tt-cobra.
                        assign tt-cobra.clicod = titulo.clifor
                               tt-cobra.dias   = (today - data-ven)
                               tt-cobra.val    = val-total.
                    end.
                end.
            end.
            data-ven  = today.
            val-total = 0.
        end.
    end.


    find first tt-cobrador use-index ind-1.
    i = tt-cobrador.cobcod.

    
    find last tt-cobrador use-index ind-1.
    x = tt-cobrador.cobcod.
    y = 0.
    zz = 0.

    assign tot01 = 0
           tot02 = 0
           tot03 = 0.

    for each tt-cobra:
        if tt-cobra.dias >= 45 and
           tt-cobra.dias <= 90
        then tot01 = tot01 + 1.
        
        if tt-cobra.dias >= 91 and
           tt-cobra.dias <= 150
        then tot02 = tot02 + 1.

        if tt-cobra.dias >= 151
        then tot03 = tot03 + 1.
    end.

    for each tt-cobra by tt-cobra.val desc:
        
        y = y + 1.
        if y < i or
           y > x
        then y = i.
        find first tt-cobrador where tt-cobrador.cobcod = y no-error.

        if tt-cobra.dias >= 45 and
           tt-cobra.dias <= 90
        then do transaction:
            tt-cobrador.conf1 = tt-cobrador.conf1 + 1.
            if tt-cobrador.conf1 > tt-cobrador.fase1
            then do:
                find first tt-cobrador where tt-cobrador.conf1 < 
                                            tt-cobrador.fase1 no-error.
                if not avail tt-cobrador
                then next.
                else assign tt-cobrador.conf1 = tt-cobrador.conf1 + 1.
            end.
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
            tt-cobrador.conf2 = tt-cobrador.conf2 + 1.
            if tt-cobrador.conf2 > tt-cobrador.fase2
            then do:
                find first tt-cobrador where tt-cobrador.conf2 < 
                                            tt-cobrador.fase2 no-error.
                if not avail tt-cobrador
                then next.
                else assign tt-cobrador.conf2 = tt-cobrador.conf2 + 1.
            end.

            create cobranca.
            assign cobranca.etbcod  = estab.etbcod
                   cobranca.cobcod  = tt-cobrador.cobcod
                   cobranca.clicod  = tt-cobra.clicod
                   cobranca.cobgera = today
                   cobranca.cobatr  = tt-cobra.dias
                   cobranca.cobeta  = 2.
        end.

        if tt-cobra.dias >= 151
        then do transaction:
            tt-cobrador.conf3 = tt-cobrador.conf3 + 1.
            if tt-cobrador.conf3 > tt-cobrador.fase3
            then do:
                find first tt-cobrador where tt-cobrador.conf3 < 
                                            tt-cobrador.fase3 no-error.
                if not avail tt-cobrador
                then next.
                else assign tt-cobrador.conf3 = tt-cobrador.conf3 + 1.
            end.

            create cobranca.
            assign cobranca.etbcod  = estab.etbcod
                   cobranca.cobcod  = tt-cobrador.cobcod
                   cobranca.clicod  = tt-cobra.clicod
                   cobranca.cobgera = today
                   cobranca.cobatr  = tt-cobra.dias
                   cobranca.cobeta  = 3.
        end.
         
        find clien where clien.clicod = tt-cobra.clicod no-lock.
        disp clien.clicod
             clien.clinom
             tt-cobra.dias with frame f2 1 down. pause 0.
         
    end.
    
    find cobranca where cobranca.etbcod = estab.etbcod and
                        cobranca.cobcod = 99           and
                        cobranca.clicod  = 
                            int(string(string(estab.etbcod,">>9") + "1"))
                            no-error.
    if not avail cobranca
    then do transaction:
        create cobranca.
        assign cobranca.etbcod  = estab.etbcod
               cobranca.cobcod  = 99
               cobranca.clicod  = 
                   int(string(string(estab.etbcod,">>9") + "1")).
    end.
    do transaction:
        assign cobranca.cobgera = today
               cobranca.cobatr  = tot01
               cobranca.cobeta  = 1.
    end.
    
    
    find cobranca where cobranca.etbcod = estab.etbcod and
                        cobranca.cobcod = 99           and
                        cobranca.clicod  = 
                            int(string(string(estab.etbcod,">>9") + "2"))
                            no-error.
    if not avail cobranca
    then do transaction:
        create cobranca.
        assign cobranca.etbcod  = estab.etbcod
               cobranca.cobcod  = 99
               cobranca.clicod  = 
                   int(string(string(estab.etbcod,">>9") + "2")).
    end.
    do transaction:
        assign cobranca.cobgera = today
               cobranca.cobatr  = tot02
               cobranca.cobeta  = 2.
    end.
    
    
    find cobranca where cobranca.etbcod = estab.etbcod and
                        cobranca.cobcod = 99           and
                        cobranca.clicod  = 
                            int(string(string(estab.etbcod,">>9") + "3"))
                            no-error.
    if not avail cobranca
    then do transaction:
        create cobranca.
        assign cobranca.etbcod  = estab.etbcod
               cobranca.cobcod  = 99
               cobranca.clicod  = 
                   int(string(string(estab.etbcod,">>9") + "3")).
    end.
    do transaction:
        assign cobranca.cobgera = today
               cobranca.cobatr  = tot03
               cobranca.cobeta  = 3.
    end.
    
end.
    

