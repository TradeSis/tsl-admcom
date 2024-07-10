{admcab.i}
def input param vetbcod like estab.etbcod.
     
def var vdt like plani.pladat.
def var zz as int.

def var tot01 as int.
def var tot02 as int.
def var tot03 as int.


def var vfase1 as dec.
def var vfase2 as dec.
def var vfase3 as dec.

def var y as int.
def var x as int.
def var vfil like estab.etbcod.
def var fil-maior like plani.platot.
def var fil-atraso like plani.pladat.
def var val-total like plani.platot.
def var data-ven like plani.pladat.
def var maior-venc like plani.pladat.
def var i as int.
def buffer btitulo for titulo.



def temp-table tt-cobrador no-undo
    field cobcod like cobfil.cobcod
    field cobnom like cobfil.cobnom
    field fase1  as int format ">>9"
    field fase2  as int format ">>9"
    field fase3  as int format ">>9"
    field conf1  as int format ">>9"
    field conf2  as int format ">>9"
    field conf3  as int format ">>9"
    index x is unique primary cobcod asc.

def temp-table tt-tempcob no-undo
    field clicod like clien.clicod
    field dias   as int format ">>>9"
    field val    like plani.platot
    index x is unique primary clicod asc.


    for each tt-tempcob.
        do transaction:
            disp tt-tempcob.clicod with frame ftemp 1 down. pause 0.
            delete tt-tempcob.
        end.
    end.
    hide frame ftemp no-pause.
    for each tt-cobrador:
        delete tt-cobrador.
    end.

    assign vfase1 = 0
           vfase2 = 0
           vfase3 = 0.


    for each cobfil where cobfil.etbcod = vetbcod no-lock:
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


    for each tt-cobrador.
        find first cobdata where cobdata.etbcod = vetbcod and
                        cobdata.cobcod = tt-cobrador.cobcod and
                        cobdata.cobgera = today
                        exclusive no-error.
        if not avail cobdata
        then                  create cobdata.
        ASSIGN
        cobdata.etbcod  = vetbcod
        cobdata.cobcod  = tt-cobrador.cobcod
        cobdata.cobqtd  = 0
        cobdata.cobgera = today
        cobdata.fase1   = tt-cobrador.fase1
        cobdata.fase2   = tt-cobrador.fase2
        cobdata.fase3   = tt-cobrador.fase3.
    end.
            
    data-ven = today.
    i = 0.

    hide message no-pause.
    MESSAGE "Aguarde..., fase 1 " .
    for each cobranca where cobranca.etbcod = vetbcod:

      
        if (today - cobranca.cobgera) <= 45 and
           cobranca.cobgera < today
        then next.

        find first titulo use-index iclicod
                where titulo.clifor = cobranca.clicod     and
                                titulo.titnat = no                  and
                                titulo.modcod = "CRE"               and
                                titulo.titdtpag >= (today - 30)     and
                                titulo.titdtpag <= today
                                no-lock no-error.
        if avail titulo
        then do:
            vdt = today + 350.
            for each btitulo 
                    use-index iclicod
                    where btitulo.clifor = cobranca.clicod no-lock:


                if titulo.titdtven < vdt
                then vdt = titulo.titdtven.
            end.
            if vdt >= (today - 30)
            then delete cobranca.
            
            next.

        end.

        display cobranca.cobcod
                cobranca.clicod with frame f-2 1 down. pause 0.
    
        delete cobranca.

    end.

    hide message no-pause.
    MESSAGE "Aguarde..., fase 1 OK" .
    for each titulo use-index titdtpag 
                        where titulo.empcod = 19    and
                              titulo.titnat = no    and
                              titulo.modcod = "CRE" and
                              titulo.titdtpag = ?   and
                              titulo.etbcod = vetbcod
                                 no-lock 
                                 break 
                                 by titulo.empcod
                                 by titulo.titnat
                                 by titulo.modcod
                                 by titulo.titdtpag
                                 by titulo.etbcod
                                 by titulo.clifor:

        if titulo.clifor <> 1
        then do:
            find cobranca where cobranca.clicod = titulo.clifor 
                                    no-lock no-error.
            if not avail cobranca
            then do:


                val-total = val-total + titulo.titvlcob.


                if titulo.titdtven < data-ven
                then data-ven = titulo.titdtven.


                if last-of(titulo.clifor)
                then do:
                    if (today - data-ven) >= 61 
                    then do:
                        fil-maior = 0.
                        vfil = titulo.etbcod.
                        fil-atraso = today.
                        for each btitulo use-index iclicod where 
                                           btitulo.clifor = titulo.clifor and
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
                                    (today - fil-atraso) >= 61
                                 then vfil = btitulo.etbcod.
                                 assign fil-atraso = today
                                        fil-maior  = 0.
                             end.
                        end.
                        if vfil = titulo.etbcod
                        then do:
                            i = i + 1.
                
                            if (today - data-ven) >= 61 and
                               (today - data-ven) <= 90
                            then vfase1 = vfase1 + 1.
        
                            if (today - data-ven) >= 91 and
                               (today - data-ven) <= 120
                            then vfase2 = vfase2 + 1.

                            if (today - data-ven) >= 121
                            then vfase3 = vfase3 + 1.
            

                            disp titulo.clifor
                                 today - data-ven
                                 val-total
                                 i
                                 vfase1
                                 vfase2
                                 vfase3
                                     with 1 down centered row 10 no-label. 
                            
                            pause 0.
                            find first tt-tempcob 
                                    where tt-tempcob.clicod = titulo.clifor 
                                                    no-error.
                            if not avail tt-tempcob
                            then do transaction:
                                create tt-tempcob.
                                assign tt-tempcob.clicod = titulo.clifor
                                       tt-tempcob.dias   = (today - data-ven)
                                       tt-tempcob.val    = val-total.
                            end.
                        end.
                    end.
                    assign data-ven  = today
                           val-total = 0. 
                
                end.
            end.
        end.
    end.

    hide message no-pause.
    MESSAGE "Aguarde..., fase 2 OK" .
    
    find first tt-cobrador.
    i = tt-cobrador.cobcod.


    find last tt-cobrador.
    x = tt-cobrador.cobcod.
    y = 0.
    zz = 0.

    assign tot01 = 0
           tot02 = 0
           tot03 = 0.

    for each tt-tempcob:
        if tt-tempcob.dias >= 61 and
           tt-tempcob.dias <= 90
        then tot01 = tot01 + 1.

        if tt-tempcob.dias >= 91 and
           tt-tempcob.dias <= 120
        then tot02 = tot02 + 1.

        if tt-tempcob.dias >= 121
        then tot03 = tot03 + 1.
    end.

    hide message no-pause.
    MESSAGE "Aguarde..., fase 3 OK" .

    for each tt-tempcob by tt-tempcob.val desc:

        y = y + 1.
        if y < i or
           y > x
        then y = i.
        
        find first tt-cobrador where tt-cobrador.cobcod = y no-error.

        if tt-tempcob.dias >= 61 and
           tt-tempcob.dias <= 90
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
            assign cobranca.etbcod  = vetbcod
                   cobranca.cobcod  = tt-cobrador.cobcod
                   cobranca.clicod  = tt-tempcob.clicod
                   cobranca.cobgera = today
                   cobranca.cobatr  = tt-tempcob.dias
                   cobranca.cobeta  = 1.
        end.

        if tt-tempcob.dias >= 91 and
           tt-tempcob.dias <= 120
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
            assign cobranca.etbcod  = vetbcod
                   cobranca.cobcod  = tt-cobrador.cobcod
                   cobranca.clicod  = tt-tempcob.clicod
                   cobranca.cobgera = today
                   cobranca.cobatr  = tt-tempcob.dias
                   cobranca.cobeta  = 2.
        end.

        if tt-tempcob.dias >= 121
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
            assign cobranca.etbcod  = vetbcod
                   cobranca.cobcod  = tt-cobrador.cobcod
                   cobranca.clicod  = tt-tempcob.clicod
                   cobranca.cobgera = today
                   cobranca.cobatr  = tt-tempcob.dias
                   cobranca.cobeta  = 3.
        end.

    
        
        
        find clien where clien.clicod = tt-tempcob.clicod no-lock.
        disp clien.clicod
             clien.clinom
             tt-tempcob.dias with frame f2 1 down. pause 0.
                        
    end.
    hide message no-pause.
    MESSAGE "Aguarde..., fase 4 OK" .

def var vt as int.
    for each tt-cobrador.
        find cobdata where 
                cobdata.etbcod = vetbcod and
                cobdata.cobcod = tt-cobrador.cobcod and
                cobdata.cobgera = today.
        vt = 0.
        for each cobranca of cobdata no-lock.
            vt = vt + 1.
        end.                        
        cobdata.cobqtd = vt.
    end.
    hide message no-pause.
    MESSAGE "Aguarde..., fase 5 OK" .
    
    /**
    find cobranca where cobranca.etbcod = vetbcod and
                        cobranca.cobcod = 99           and
                        cobranca.clicod  = -1
                            no-error.
    if not avail cobranca
    then do transaction:
        create cobranca.
        assign cobranca.etbcod  = vetbcod
               cobranca.cobcod  = 99
               cobranca.clicod  = -1.
    end.
    do transaction:
        assign cobranca.cobgera = today
               cobranca.cobatr  = tot01
               cobranca.cobeta  = 1.
    end.


    find cobranca where cobranca.etbcod = vetbcod and
                        cobranca.cobcod = 99           and
                        cobranca.clicod  = -2
                            no-error.
    if not avail cobranca
    then do transaction:
        create cobranca.
        assign cobranca.etbcod  = vetbcod
               cobranca.cobcod  = 99
               cobranca.clicod  = -2.
    end.
    do transaction:
        assign cobranca.cobgera = today
               cobranca.cobatr  = tot02
               cobranca.cobeta  = 2.
    end.


    find cobranca where cobranca.etbcod = vetbcod and
                        cobranca.cobcod = 99           and
                        cobranca.clicod  = -3
                            no-error.
    if not avail cobranca
    then do transaction:
        create cobranca.
        assign cobranca.etbcod  = vetbcod
               cobranca.cobcod  = 99
               cobranca.clicod  = -3.
    end.
    do transaction:
        assign cobranca.cobgera = today
               cobranca.cobatr  = tot03
               cobranca.cobeta  = 3.
    end.
    **/
    
     
    hide message no-pause.
    MESSAGE "            Final  OK" .
    pause 2 no-message.
    

