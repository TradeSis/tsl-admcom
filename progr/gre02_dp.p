{admcab.i}

def var valor-bonus like titulo.titvlcob.
def var varquivo as char.
def var vdt  like plani.pladat.
def var i as int.
def var vdtini      like titulo.titdtemi    label "Data Inicial".
def var vdtfin      like titulo.titdtemi    label "Data Final".
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var vetbcod like estab.etbcod.
def workfile wfresumo
    field etbcod    like estab.etbcod       column-label "Loja"
    field compra    like titulo.titvlcob    column-label "Tot.Compra"
                                                  format ">>,>>>,>>9.99"
    field bonus     like titulo.titvlcob    column-label "Bonus"
                                                  format ">>,>>>,>>9.99"
    field vlpago1   like titulo.titvlpag format ">,>>>,>>9.99".

def var val_fin as dec.
def var val_des as dec.
def var val_dev as dec.
def var val_acr as dec.
def var val_com as dec.
def var valtotal as dec. 

repeat with 1 down side-label width 80 row 3:

    update vdtini colon 20
           vdtfin colon 20.
           i = 0.

    for each wfresumo.
        delete wfresumo.
    end.
    
    update vetbcod label "Filial" colon 20.
    
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label.
    end.
   
    
    for each estab where if vetbcod = 0
                         then true 
                         else estab.etbcod = vetbcod no-lock,
        each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 5 and
                         plani.pladat >= vdtini and
                         plani.pladat <= vdtfin no-lock:

        find first wfresumo where wfresumo.etbcod = plani.etbcod no-error.
        if not avail wfresumo
        then do:
            create wfresumo.
            assign wfresumo.etbcod  = plani.etbcod.
        end.
        find first movim where movim.etbcod = plani.etbcod and
                                   movim.placod = plani.placod and
                                   movim.movtdc = plani.movtdc and
                                   movim.movdat = plani.pladat
                                                    no-lock no-error.

            /*
            if vtprcod = 3
            then vtprcod = 1.

            if vtprcod = 4
            then vtprcod = 2.
 
            vcatcod = vtprcod. 
            */
            
            valtotal = 0.
            if avail movim
            then do:
                for each movim where movim.etbcod = plani.etbcod and
                                   movim.placod = plani.placod and
                                   movim.movtdc = plani.movtdc and
                                   movim.movdat = plani.pladat
                                                    no-lock .

            
                find produ where produ.procod = movim.procod no-lock no-error.
                /*if avail produ
                then do:
                    if (produ.catcod = 31 or
                        produ.catcod = 35 or
                        produ.catcod = 50)
                    then vcatcod = 2.
                    else vcatcod = 1.
                end.
                     */
                val_fin = 0.                    
                val_des = 0.   
                val_dev = 0.   
                val_acr = 0. 
                val_com = 0.
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.acfprod.
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.descprod.
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
    
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                    val_fin =  ((((movim.movpc * movim.movqtm) 
                        - val_dev - val_des)~ /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).

                val_com = (movim.movpc * movim.movqtm) 
                        - val_dev - val_des + val_acr + val_fin. 
                /*if  vtprcod = vcatcod
                then*/  valtotal = valtotal + val_com.
                end.
            end.
            else valtotal = plani.platot.
            /*
            if vvencod <> 0 and
               vvencod <> plani.vencod
            then next.

            vcatcod = vtprcod.
            */
            if valtotal = 0
            then next.

 
        run p-lebonus(output valor-bonus).
        
        /*if plani.biss > 0
        then wfresumo.compra = wfresumo.compra + plani.biss + valor-bonus.
        else wfresumo.compra = wfresumo.compra /*+ valor-bonus*/ +
                               (plani.platot - plani.vlserv) .*/
                               
        if plani.crecod = 1
        then wfresumo.compra = wfresumo.compra +  valtotal.
        /*
        (plani.protot + /*valor-bonus +*/
                                             plani.acfprod -
                                             plani.descprod ) - plani.vlserv.
        */
        else
        if plani.crecod = 2
        then wfresumo.compra = wfresumo.compra + valtotal.
            /*
        (if plani.biss > plani.platot
                                             then plani.biss
                                             else plani.platot) /*+
                                             valor-bonus*/ .
              */
                               
                               
        wfresumo.bonus = wfresumo.bonus + valor-bonus.
        
        display "Vendas... "
                estab.etbcod
                plani.pladat
                plani.platot with 1 down. pause 0.
         
            
    end.        
    do vdt = vdtini to vdtfin:
    for each estab where if vetbcod = 0
                         then true 
                         else estab.etbcod = vetbcod no-lock,
        each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = "CRE" and
                          titulo.titdtpag = vdt and
                          titulo.etbcod = estab.etbcod no-lock:
        
        if titulo.moecod = "nov"
        then next.
        
        
        if titulo.titpar = 0
        then next.

        find first wfresumo where wfresumo.etbcod = estab.etbcod no-error.
        if not avail wfresumo 
        then do: 
            create wfresumo. 
            assign wfresumo.etbcod = estab.etbcod. 
        end.
        if titulo.clifor = 1 
        then next.
        wfresumo.vlpago1  = wfresumo.vlpago1 + titulo.titvlcob.
        
        display "Pagamentos...."
                titulo.etbcod
                titulo.titdtpag
                titulo.titvlcob with 1 down. pause 0.
    end.
        
        
    end.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/cre02_dp." + string(time).
    else varquivo = "l:\relat\cre02_dp." + string(time).
    
    {mdadmcab.i
         &Saida     = "value(varquivo)"
         &Page-Size = "64"
         &Cond-Var  = "120"
         &Page-Line = "66"
         &Nom-Rel   = """cre02_dp"""
         &Nom-Sis   = """SISTEMA CREDIARIO"""
         &Tit-Rel   = """RESUMO MENSAL DE CAIXA  -  PERIODO DE "" +
                            string(vdtini)  + "" A "" + string(vdtfin) "
         &Width     = "120"
         &Form      = "frame f-cab"}

    for each wfresumo break by wfresumo.etbcod:
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
        display wfresumo.etbcod     column-label "Etb."
                wfresumo.vlpago1    column-label "Recebimentos"   (total)
                wfresumo.compra     column-label "Valor Venda "  (total)
                wfresumo.bonus      column-label "Bonus" (total)
                    with frame flin
                         width 160 down no-box.
    end.
    output close.

    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else {mrod.i}.
    
end.

procedure p-lebonus:
    
    def output parameter p-valor-bonus like titulo.titvlcob.
    
    find first titulo where titulo.empcod   = 19
                        and titulo.titnat   = yes
                        and titulo.clifor   = plani.desti 
                        and titulo.modcod   = "BON" 
                        and titulo.titdtpag = plani.pladat 
                        and titulo.titvlpag = plani.descprod no-lock no-error.

    if avail titulo
    then p-valor-bonus = titulo.titvlpag.
    else p-valor-bonus = 0.

end procedure.

