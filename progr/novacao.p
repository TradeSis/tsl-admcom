def var i as i.
def stream stela.
def stream sarq.
def var totdiv like titulo.titvlcob.    
def var fildiv like titulo.titvlcob.
def var venc1  like titulo.titdtven.
def var venc2  like titulo.titdtven.
def var val1   like titulo.titvlcob.
def var val2   like titulo.titvlcob.
def var vetb   like titulo.etbcod.
def var totjur like titulo.titvljur.
def temp-table tt-nova
    field etbcod like estab.etbcod
    field clicod like clien.clicod
    field saldo  like titulo.titvlcob
    field juros  like titulo.titvlcob.

    for each tt-nova:
        delete tt-nova.
    end.
    output stream sarq to ..\relat\novacao.
    output stream stela to terminal.
    for each clien no-lock.
        display stream stela 
                "Gerando Novacao......" 
                i no-label 
                clien.clicod with frame f1 side-label centered row 10.
        pause 0.
        if clicod = 1
        then next.
        totdiv = 0.
        venc2  = today.
        val2 = 0.
        vetb = 0.
        totjur = 0.
        for each titulo use-index iclicod 
                        where titulo.clifor = clien.clicod and
                              titulo.titnat = no           and
                              titulo.modcod = "CRE"        and
                              titulo.titsit = "LIB"        and
                              titulo.titpar < 50
                                    no-lock break by titulo.etbcod.
            
            totdiv = totdiv + titulo.titvlcob.
            find tabjur where tabjur.nrdias = today - titulo.titdtven
                         no-lock no-error.
            
            if avail tabjur
            then totjur = totjur + 
               ( ( (titulo.titvlcob * tabjur.fator) - titulo.titvlcob) / 3).

    
            fildiv = fildiv + titulo.titvlcob.
            if last-of(titulo.etbcod)
            then do:
                val1 = fildiv.
                if val2 < val1
                then assign val2 = val1
                            vetb = titulo.etbcod.
                fildiv = 0.
            end.
            
            venc1 = titulo.titdtven.
            if venc2 > venc1
            then venc2 = venc1.

        end.
        if totdiv = 0 or ( today - venc2) < 180
        then next.
        
        /*
        create tt-nova.
        assign tt-nova.etbcod = vetb
               tt-nova.clicod = clien.clicod
               tt-nova.saldo  = totdiv
               tt-nova.juros  = totjur.
        */
        i = i + 1.
        put stream sarq 
            chr(34) vetb chr(34)
            chr(34) clien.clicod chr(34)   
            chr(34) totdiv chr(34)
            chr(34) totjur chr(34) skip.

        
    end.
    output stream sarq close.
    output stream stela close.
                    
