{admcab.i}
def var indice as char.
        
def var totacr  like plani.platot.
def var acutot  like plani.platot.
def var minacr  like plani.platot.
def var varquivo as char format "x(30)".
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var v-sai    as log. 
def var tot-outros as dec.

def temp-table wplani
    field   wclicod  like clien.clicod
    field   wclinom  like clien.clinom
    field   wven     like plani.platot
    field   wacr     like plani.platot
        index ind-1 wclinom
        index ind-2 wclicod
        index ind-3 wven.
       
def var vchepres as dec. 
def var valor-av as dec.
def var vi as int.

def var dt     like plani.pladat.
def var val_fin as dec.
def var val_des as dec.   
def var val_dev as dec.   
def var val_acr as dec.
def var val_com as dec. 
def var tot-pneu as dec.
def var tot-celular as dec. 
def var tot-venda as dec.
def var venda-pneu as dec.
def var venda-celu as dec.
def var tot-99 as dec.
def var venda-99 as dec.
def var wacr as dec.
def var acr-99 as dec.
def var acr-pneu as dec.
def var acr-celular as dec.
def var acr-outros as dec.
def var acr-venda as dec.
def buffer bmovim for movim.
repeat:


    update vdti label "Periodo de"
           vdtf label "Ate"  with frame f1 centered side-label.

    do dt = vdti to vdtf:

        for each estab no-lock,
            each plani where plani.pladat = dt and
                    plani.etbcod = estab.etbcod and
                    plani.movtdc = 5 no-lock,
            first bmovim where bmovim.etbcod = plani.etbcod and
                              bmovim.placod = plani.placod and
                              bmovim.movtdc = plani.movtdc and
                              bmovim.movdat = plani.pladat
                              no-lock
                    :
            if plani.biss = ?
            then next.
            
            vchepres = 0.
            valor-av = 0.
            if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ?
            then do vi = 1 to int(acha("QTDCHQUTILIZADO",plani.notobs[3])):
                vchepres = vchepres +  dec(acha("VALCHQPRESENTEUTILIZACAO" + 
                            string(vi),plani.notobs[3])) .
            end.    
            valor-av = plani.platot -
                        (plani.vlserv + plani.descprod + vchepres).

            if valor-av < 0
            then next.
            
            if plani.biss <= valor-av
            then next.
            
            find clien where clien.clicod = plani.desti no-lock no-error.
            if not avail clien
            then .
            
            if plani.biss - valor-av < 2
            then.

            display "Processando ...>>>  " plani.pladat
                    plani.biss  
                        with frame ff 1 down centered no-label no-box.
            pause 0.
            
            find first contnf where
                       contnf.etbcod = plani.etbcod and
                       contnf.placod = plani.placod
                       no-lock no-error.
            if not avail contnf then next.
            find contrato where contrato.contnum = contnf.contnum 
                       no-lock no-error.
            if not avail contrato then next.  
                        
            for each movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat
                     no-lock.
                find produ where produ.procod = movim.procod no-lock.
                find clase where clase.clacod = produ.clacod no-lock.

                /*if produ.pronom matches "*pneu*"  or
                   produ.pronom begins "vivo" or
                   produ.pronom begins "tim"  or
                   produ.proipiper = 99
                then*/ do:            
                    val_fin = 0.                    
                    val_des = 0.   
                    val_dev = 0.   
                    val_acr = 0. 
                    val_com = 0.
                    
                    val_acr =  
                        ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.acfprod.
                    if val_acr = ? then val_acr = 0.
            
                    val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.descprod.
                    if val_des = ? then val_des = 0.
                    val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
                    if val_dev = ? then val_dev = 0.
                    if valor-av < plani.biss
                    then val_fin =  
                        ((((movim.movpc * movim.movqtm) - val_dev - val_des) /
                            valor-av) * plani.biss) 
                            - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
                    if val_fin = ? then val_fin = 0.
            
                    val_com = (movim.movpc * movim.movqtm) - 
                                val_dev - val_des + val_acr + val_fin.
                                 
                    if val_com = ? then val_com = 0.
                    /*
                    disp produ.pronom val_com movim.movpc * movim.movqtm
                    clase.clanom.
                    */
                    if plani.crecod > 0
                    then do:
                    if plani.biss > valor-av
                    then wacr = ((movim.movpc * movim.movqtm) /
                                      plani.platot) *                                                               (plani.biss - valor-av)
                                    .
                    else wacr = ((movim.movpc * movim.movqtm) /
                                      (plani.platot /*- plani.vlserv*/))
                                        * plani.acfprod.
                    end.                    
                    if wacr < 0 or wacr = ?
                    then wacr = 0.

                    if produ.proipiper = 99
                    then assign
                             acr-99 = acr-99 + wacr
                             tot-99 = tot-99 +
                               (val_com - ( movim.movpc * movim.movqtm))
                             venda-99 = venda-99 + val_com
                               .
                    else if produ.pronom matches "*pneu*"
                    then assign
                        acr-pneu = acr-pneu + wacr
                        tot-pneu = tot-pneu +
                            (val_com - ( movim.movpc * movim.movqtm))
                        venda-pneu = venda-pneu + val_com /*
                                    (movim.movpc * movim.movqtm)*/.
                    else if produ.pronom begins "vivo" or
                       produ.pronom begins "tim"
                    then assign
                        acr-celular = acr-celular + wacr
                        tot-celular = tot-celular +
                            (val_com - ( movim.movpc * movim.movqtm))
                        venda-celu = venda-celu + val_com /*
                                (movim.movpc * movim.movqtm)*/  .
                    else assign
                            acr-outros = acr-outros + wacr
                            tot-outros = tot-outros +
                                (val_com - ( movim.movpc * movim.movqtm))
                                .
                    tot-venda = tot-venda + 
                                    + (val_com - (movim.movpc * movim.movqtm)).
                    /*disp contrato.*/
                end.
            end. 
        end.
    end.
    hide frame ff no-pause.
    /*
    disp  tot-pneu label "Pneu"       format ">>,>>>,>>9.99"
          tot-celular label "Celular" format ">>,>>>,>>9.99" 
          with frame f-1 side-label centered row 14.
          
    */
    /*
    disp tot-venda label "Total" format ">>,>>>,>>9.99"
         tot-99    label "ST   " format ">>,>>>,>>9.99"
         tot-pneu + tot-celular + tot-outros
            label "Outros" format ">>,>>>,>>9.99"
         with frame f-1 side-label centered row 10 1 column.
    */
    
    acr-venda = acr-99 + acr-pneu + acr-celular + acr-outros.
    
    disp acr-venda label "Total" format ">>,>>>,>>9.99"
         acr-99    label "ST   " format ">>,>>>,>>9.99"
         acr-pneu + acr-celular + acr-outros
            label "Outros" format ">>,>>>,>>9.99"
         with frame f-1 side-label centered row 10 1 column.
       
    pause.      
    return.     
    /*
    output close.

    {mrod.i}
    */
end.
