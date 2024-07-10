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
    field   wcontnum like contrato.contnum
    field   wdata    like plani.pladat
    field   wacrven     like plani.platot
    field   wacrout     like plani.platot
    field   wacr-99     like plani.platot
    field   wvalven     like plani.platot
    field   wvalpra     like plani.platot
        index ind-1 wclicod wcontnum
    .   
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
            
            if /*plani.movtdc <> 5 or
               plani.desti  = 1  or*/
               (plani.biss <= (plani.platot - plani.vlserv /*- plani.descprod*/))
            then next.
            
            find clien where clien.clicod = plani.desti no-lock no-error.
            if not avail clien
            then .
            
            if 
            (plani.biss - (plani.platot - plani.vlserv /*- plani.descprod*/)) 
            < 2
            then .
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

            find first envfinan where
                       envfinan.empcod = 19 and
                       envfinan.titnat = no and
                       envfinan.modcod = "CRE" and
                       envfinan.etbcod = contrato.etbcod and
                       envfinan.clifor = contrato.clicod and
                       envfinan.titnum = string(contrato.contnum)
                       no-lock no-error.
            if avail envfinan
            then next.
            
            find first wplani where
                       wplani.wclicod = contrato.clicod and
                       wplani.wcontnum = contrato.contnum
                       no-lock no-error.
            if not avail wplani
            then do:
                create wplani.
                assign
                    wplani.wclicod = contrato.clicod
                    wplani.wcontnum = contrato.contnum
                    wplani.wdata = plani.pladat.
            end.           
            
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
                    if (plani.platot - plani.vlserv /*- plani.descprod*/) 
                                < plani.biss
                    then val_fin =  
                        ((((movim.movpc * movim.movqtm) - val_dev - val_des) /
                            (plani.platot - plani.vlserv /*- plani.descprod*/))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
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
                    if plani.biss > (plani.platot - plani.vlserv)
                    then wacr = ((movim.movpc * movim.movqtm) /
                                      plani.platot) *                                                               (plani.biss - (plani.platot - plani.vlserv))
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
                             wacr-99 = wacr-99 + wacr
                             tot-99 = tot-99 +
                               (val_com - ( movim.movpc * movim.movqtm))
                             venda-99 = venda-99 + val_com
                               .
                    else if produ.pronom matches "*pneu*"
                    then assign
                        acr-pneu = acr-pneu + wacr
                        wacrout = wacrout + wacr
                        tot-pneu = tot-pneu +
                            (val_com - ( movim.movpc * movim.movqtm))
                        venda-pneu = venda-pneu + val_com /*
                                    (movim.movpc * movim.movqtm)*/.
                    else if produ.pronom begins "vivo" or
                       produ.pronom begins "tim"
                    then assign
                        acr-celular = acr-celular + wacr
                        wacrout = wacrout + wacr
                        tot-celular = tot-celular +
                            (val_com - ( movim.movpc * movim.movqtm))
                        venda-celu = venda-celu + val_com /*
                                (movim.movpc * movim.movqtm)*/  .
                    else assign
                            acr-outros = acr-outros + wacr
                            wacrout = wacrout + wacr
                            tot-outros = tot-outros +
                                (val_com - ( movim.movpc * movim.movqtm)).

                    wacrven = wacrven + wacr.
                    wvalven = val_com.
                    wvalpra = plani.biss.
                    tot-venda = tot-venda + 
                                    + (val_com - (movim.movpc * movim.movqtm)).
                    /*disp contrato.*/
                end.
            end. 
            wvalven = plani.platot - plani.vlserv.
            wvalpra = plani.biss.
        end.
    end.
    hide frame ff no-pause.
    
    acr-venda = acr-99 + acr-pneu + acr-celular + acr-outros.
    
    disp acr-venda label "Total" format ">>,>>>,>>9.99"
         acr-99    label "ST   " format ">>,>>>,>>9.99"
         acr-pneu + acr-celular + acr-outros
            label "Outros" format ">>,>>>,>>9.99"
         with frame f-1 side-label centered row 10 1 column.

    sresp = no.
    message "Relatorio analitico? " update sresp.
    if sresp
    then do:
        varquivo = "/admcom/relat/acrl_" + string(time).

        {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""acr_fin""
        &Nom-Sis   = """SISTEMA CONTABIL"""
        &Tit-Rel   = """ACRESCIMO SOBRE A VENDA A PRAZO "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "130"
        &Form      = "frame f-cabcab"}
    
         disp with frame f1.
         for each wplani where wacrout > 0:
            disp wplani.wclicod   format ">>>>>>>>>9"
                 wplani.wcontnum  format ">>>>>>>>>9"
                 wplani.wdata    column-label "Data"
                 wvalven(total) column-label "Val.Vista"  
                                format "->>,>>>,>>9.99"
                 wvalpra(total) column-label "Val.Prazo"
                                format "->>,>>>,>>9.99"
                 wacr-99(total)  column-label "Val. ST"
                                format "->>>,>>9.99"
                 wacrout(total)  column-label "Val.Out" 
                                format "->>>,>>9.99"
                 wacrven(total)  column-label "Tot.Acre"
                                format "->,>>>,>>9.99"
                 with frame f-disp down width 123.
        end.
        output close.
        run visurel.p(varquivo,"").
    end.                 
        
end.
