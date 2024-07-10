{admcab.i}
def var vetbcod like estab.etbcod.
def var vdtini as date label "De".
def var vdtfim as date label "Ate".
def var tbonus_crm as dec.
def var vnumero_bonus_crm as char format "x(30)".
def var vtipo_bonus as char.
def var vprotot as dec.
def var vsp as char format "x" init ";".

def temp-table tt-bonus no-undo
    field etbcod like plani.etbcod
    field placod like plani.placod format ">>>>>>>>>>>>>>9"
    field procod like produ.procod
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field BONUSNRO as char format "x(30)"
    field BONUSCRM as dec decimals 2 
    index x is unique primary etbcod asc placod asc procod asc.
def var vsaida as char format "x(60)" label "Saida CSV".
repeat.
    update
        vetbcod colon 17
        with frame f1
        centered width 80
        side-labels
        title "BONUS RASPADINHA". 
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estab invalido".
            pause.
            undo.
        end.
        disp estab.etbnom no-label
            with frame f1.
    end.
    else do:
        disp "TODOS" @ estab.etbnom
            with frame f1.
    end.
    update
        vdtini colon 17 
        vdtfim
        with frame f1.   

   vsaida = "/admcom/relat/bonusraspadinha" + string(vetbcod,"999") +
                    "-" + string(vdtini,"999999") + string(vdtfim,"999999")
                    + ".csv".
     
    update
        vsaida colon 17
            with frame f1.
    hide message no-pause.
    message "Aguarde, processando vendas ...".
    pause 0 before-hide.
    form
            estab.etbcod
            plani.pladat
            with frame fcont no-labels centered no-box.
    for each estab where if vetbcod = 0 then true else estab.etbcod = vetbcod no-lock
        by estab.etbcod desc.
        disp estab.etbcod no-label
            with frame fcont.
            
        for each plani where 
            plani.movtdc = 5 and
            plani.etbcod = estab.etbcod and
            plani.pladat >= vdtini and
            plani.pladat <= vdtfim
            no-lock
                by plani.movtdc by plani.etbcod by plani.pladat.
            
            disp plani.pladat
                 with frame fcont.
                   
            tbonus_crm         = dec(acha("BONUSCRM",plani.notobs[1])).  
            vnumero_bonus_crm   = string(int64(acha("BONUSNRO",plani.notobs[1])),"9999999999") no-error.
    
           if vnumero_bonus_crm = ?
           then next.

            vprotot = 0.
            vtipo_bonus = "".
                
            find first titulo use-index por-clifor where 
                titulo.empcod = 19 and
                titulo.titnat = yes and
                titulo.modcod = "BON" and
                titulo.clifor = plani.desti and
                titulo.titnum = vnumero_bonus_crm 
                no-lock no-error.
            if avail titulo
            then do:
                vtipo_bonus = acha("BONUS",titulo.titobs[2]).
                if vtipo_bonus = "RASPADINHA"
                then do:
                    vprotot = 0.
                    for each movim where 
                        movim.etbcod = plani.etbcod and
                        movim.placod = plani.placod
                        no-lock.
                        find produ of movim no-lock.
                        if produ.catcod = 31 or
                           produ.catcod = 41
                        then.
                        else next.
                        vprotot = vprotot + (movim.movpc * movim.movqtm).
                    end.
                    for each movim where
                        movim.etbcod = plani.etbcod and
                        movim.placod = plani.placod
                        no-lock.
                        find produ of movim no-lock.
                        if produ.catcod = 31 or
                           produ.catcod = 41
                        then.
                        else next.
                                                    
                        create tt-bonus.
                        tt-bonus.etbcod = plani.etbcod.
                        tt-bonus.placod = plani.placod.
                        tt-bonus.procod = movim.procod.
                        tt-bonus.movqtm = movim.movqtm.
                        tt-bonus.movpc  = movim.movpc.
                        tt-bonus.BONUSNRO = vnumero_bonus_crm.
                        tt-bonus.bonuscrm = titulo.titvlcob / vprotot * (movim.movqtm * movim.movpc).
                     end.            
                end.
            end.    
            
            tbonus_crm        = 0.
            vnumero_bonus_crm = "".
        
             
        end.    
    end.            
    pause 0 before-hide.
    
    hide message no-pause.
    output to value(vsaida).
        put unformatted skip
            "Loja"      vsp
            "Data"      vsp
            "Serie"     vsp
            "Numero"    vsp
            "Produto"   vsp
            "Nome Produto" vsp
            "Cat" vsp
            "Classe"    vsp
            "Nome Classe" vsp
            "Qtd"       vsp
            "Valor"     vsp
            "NRO Bonus" vsp
            "Valor Bonus".
    
    
    for each tt-bonus.
        find first plani where plani.etbcod = tt-bonus.etbcod and
                         plani.placod = tt-bonus.placod
                         no-lock.
        find produ where produ.procod = tt-bonus.procod no-lock.
        find clase where clase.clacod = produ.clacod no-lock.                                 
        put unformatted skip
            plani.etbcod vsp
            plani.pladat vsp
            plani.serie  vsp
            plani.numero vsp
            produ.procod vsp
            produ.pronom vsp
            produ.catcod vsp
            clase.clacod vsp
            clase.clanom vsp
            tt-bonus.movqtm vsp
            replace(string(tt-bonus.movpc,">>>>>>>>>>>>>9.99"),".",",") vsp
            tt-bonus.bonusnro vsp
            replace(string(tt-bonus.bonuscrm,">>>>>>>>>>>>>9.99"),".",",").
                      
    end.
    
    put unformatted skip
        "FIM"
        skip.
    output close.    
    hide message no-pause.
    message "Arquivo Gerado" vsaida.
    
    pause.
    
end.                    
