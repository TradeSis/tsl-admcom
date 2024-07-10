{admcab.i}

def var valor-bonus like titulo.titvlcob.

def var vcomp   like plani.platot.
def var totcomi like plani.platot.
def var totrepo like plani.platot.
def var totven  like plani.platot.
def var v-tot01 like plani.platot.
def var v-tot02 like plani.platot.
def var vtotal1 like plani.platot.
def var varquivo as char.
def var tipo as int format "99".
def buffer bcontnf for contnf.
def buffer xplani for plani.
def var vvltotal    like contrato.vltotal.
def var vdtini      like plani.pladat.
def var vok         as log initial yes.
def var vdtfin      like plani.pladat.
def var vtotcom     as dec format ">,>>>,>>9.99".
def var vtipo       as char             format "x(11)".
def var vtprcod     like comis.tprcod.
def var vvencod     like func.funcod label "Vendedor".
def var vdomfer     as integer  label "Dom/Fer".
def var vdiatra     as integer  label "Dias Trab.".
def var vdt         as date.
def var vcatcod     as int.
def var vtotal      like plani.platot.
def var vetbcod like estab.etbcod.

def temp-table wf-com like comis.



def temp-table wfcomis field tprcod       like comis.tprcod
                       field vencod       like comis.vencod
                       field modcod       like comis.modcod
                       field vtot         as dec format ">,>>>,>>9.99"
                       field vcom         as dec format ">,>>>,>>9.99"
                       field vcom1        like plani.platot.

repeat:

    for each wfcomis.
        delete wfcomis.
    end.

    tipo = 0.
    update vtprcod  colon 20.
    tipo = vtprcod.

    find tippro where tippro.tprcod = vtprcod no-lock no-error.
    if not avail tippro
    then do:
        bell.
        message "Tipo de Produto nao Cadastrado !!".
        undo.
    end.
    display tippro.tprnom no-label colon 45.
    vetbcod = 0.
    update vetbcod label "Filial" colon 20.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    prompt-for comis.vencod label "Vendedor" colon 45 validate (true,"")
               with side-label width 80 color white/cyan.
    find func where func.etbcod = estab.etbcod and
                    func.funcod = input comis.vencod no-lock no-error.
    vvencod = if avail func
              then func.funcod
              else 0.

    update vdtini colon 20
           vdtfin colon 45
           vdiatra colon 20
           vdomfer colon 45.

    do vdt = vdtini to vdtfin:

        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5 and
                             plani.pladat = vdt no-lock:

            find tippro where tippro.tprcod = tipo no-lock no-error.

            disp plani.etbcod plani.pladat plani.numero with 1 down centered
                                                        color white/red.
            pause 0.

            find first movim where movim.etbcod = plani.etbcod and
                                   movim.placod = plani.placod and
                                   movim.movtdc = plani.movtdc and
                                   movim.movdat = plani.pladat
                                                    no-lock no-error.

            
            if vtprcod = 3
            then vtprcod = 1.

            if vtprcod = 4
            then vtprcod = 2.

 
            vcatcod = vtprcod. 
            
            if avail movim
            then do:
                find produ where produ.procod = movim.procod no-lock no-error.
                if avail produ
                then do:
                    if (produ.catcod = 31 or
                        produ.catcod = 35 or
                        produ.catcod = 50)
                    then vcatcod = 2.
                    else vcatcod = 1.
                end.
                
                if vtprcod = 3
                then vtprcod = 1.

                if vtprcod = 4
                then vtprcod = 2.

                if  vtprcod <> vcatcod
                then next.
                
                /************* CARTAO TELEFONICO ***********
                if produ.procod = 400410 or
                   produ.procod = 401695 or
                   produ.procod = 401611 or 
                   produ.procod = 400226 or 
                   produ.procod = 400730 or 
                   produ.procod = 401733 or 
                   produ.procod = 401383 or 
                   produ.procod = 401508 or 
                   produ.procod = 401487 or 
                   produ.procod = 400902 
                then next.
                *******************************************/
            
            end.
            if vvencod <> 0 and
               vvencod <> plani.vencod
            then next.

            valor-bonus = 0.
            run p-lebonus(output valor-bonus).
            
            if plani.crecod = 1
            then do:

                create wf-com.
                assign wf-com.etbcod  = plani.etbcod
                       wf-com.datexp  = today
                       wf-com.compra  = valor-bonus
                        /*(plani.protot + valor-bonus +
                                        plani.acfprod -
                                        plani.descprod )  - plani.vlserv*/
                                                          
                       wf-com.clifor  = 1
                       wf-com.contnum = 0
                       wf-com.tprcod  = vcatcod
                       wf-com.vencod  = plani.vencod
                       wf-com.modcod  = "VVI"  /** VENDA A VISTA **/.

                find first wfcomis where wfcomis.tprcod = wf-com.tprcod and
                                         wfcomis.vencod = wf-com.vencod and
                                         wfcomis.modcod = wf-com.modcod
                                         no-error.
                if not avail wfcomis
                then create wfcomis.
                assign wfcomis.tprcod = wf-com.tprcod
                       wfcomis.vencod = wf-com.vencod
                       wfcomis.modcod = wf-com.modcod
                       wfcomis.vtot   = wfcomis.vtot + wf-com.compra.
                       wfcomis.vcom   = wfcomis.vcom +
                                        (wf-com.compra * (tippro.vista / 100)).
                
                
                if tipo = 1 
                then do:
                    find tippro where tippro.tprcod = 3 no-lock.
                    wfcomis.vcom1 = wfcomis.vcom1 + 
                                    (wf-com.compra * (tippro.vista / 100)).
                end.
                if tipo = 2
                then do:
                    find tippro where tippro.tprcod = 4 no-lock.
                    wfcomis.vcom1 = wfcomis.vcom1 + 
                                    (wf-com.compra * (tippro.vista / 100)).
                end.    
                
                 

                
                delete wf-com.

            end.
            

            if plani.crecod = 2
            then do:
                find finan where finan.fincod = plani.pedcod no-lock.
                if finan.finent 
                then do:
                    create wf-com.
                    assign wf-com.etbcod  = plani.etbcod
                           wf-com.vencod  = plani.vencod
                           wf-com.datexp  = today
                           wf-com.compra  = /*(if plani.biss > plani.platot
                                             then plani.biss
                                             else plani.platot) +*/
                                             valor-bonus
                           wf-com.clifor  = plani.desti
                           wf-com.tprcod  = vtprcod
                           wf-com.modcod  = "VCE".

                    find first wfcomis where wfcomis.tprcod = wf-com.tprcod and
                                             wfcomis.vencod = wf-com.vencod and
                                             wfcomis.modcod = "VCE" no-error.
                    if not avail wfcomis
                    then create wfcomis.
                    assign wfcomis.tprcod  = wf-com.tprcod
                           wfcomis.vencod  = wf-com.vencod
                           wfcomis.modcod  = "VCE"
                           wfcomis.vtot    = wfcomis.vtot + wf-com.compra.
                           wfcomis.vcom    = wfcomis.vcom +
                                             (wf-com.compra *
                                             (tippro.coment / 100)).

                    
                    if tipo = 1 
                    then do:
                        find tippro where tippro.tprcod = 3 no-lock.
                        wfcomis.vcom1 = wfcomis.vcom1 + 
                                    (wf-com.compra * (tippro.coment / 100)).
                    end.
                    if tipo = 2
                    then do:
                        find tippro where tippro.tprcod = 4 no-lock.
                        wfcomis.vcom1 = wfcomis.vcom1 + 
                                    (wf-com.compra * (tippro.coment / 100)).
                    end.    
                

                    
                    
                    delete wf-com.
                end.
                else do:

                    create wf-com.
                    assign wf-com.etbcod  = plani.etbcod
                           wf-com.vencod  = plani.vencod
                           wf-com.datexp  = today
                           wf-com.compra  = /*(if plani.biss > plani.platot
                                             then plani.biss
                                             else plani.platot) +*/
                                              valor-bonus
                           wf-com.clifor  = plani.desti
                           wf-com.tprcod  = vtprcod
                           wf-com.modcod  = "VSE".
                    if wf-com.compra = ?
                    then wf-com.compra = 0.

                    find first wfcomis where wfcomis.tprcod = wf-com.tprcod and
                                             wfcomis.vencod = wf-com.vencod and
                                             wfcomis.modcod = "VSE" no-error.
                    if not avail wfcomis
                    then create wfcomis.
                    assign wfcomis.tprcod  = wf-com.tprcod
                           wfcomis.vencod  = wf-com.vencod
                           wfcomis.modcod  = "VSE"
                           wfcomis.vtot    = wfcomis.vtot + wf-com.compra.
                           wfcomis.vcom    = wfcomis.vcom +
                                             (wf-com.compra *
                                             (tippro.sement / 100)).

                    
                    if tipo = 1 
                    then do:
                        find tippro where tippro.tprcod = 3 no-lock.
                        wfcomis.vcom1 = wfcomis.vcom1 + 
                                        (wf-com.compra * (tippro.sement / 100)).
                    end.
                    if tipo = 2
                    then do:                                        
                        find tippro where tippro.tprcod = 4 no-lock.
                        wfcomis.vcom1 = wfcomis.vcom1 + 
                                    (wf-com.compra * (tippro.sement / 100)).
                    end.    
                

                    
                    
                    
                    delete wf-com.
                end.
            end.
        end.
    end.

    for each wfcomis break by wfcomis.tprcod
                           by wfcomis.vencod
                           by wfcomis.modcod with frame fcom.
        find func where func.etbcod = estab.etbcod and
                        func.funcod = wfcomis.vencod no-lock no-error.
        if avail func
        then do:

            if first-of(wfcomis.vencod)
            then display func.funcod   column-label "Cod"
                         func.funnom   format "x(15)".

            display if wfcomis.modcod = "VVI"
                    then "A Vista"
                    else if wfcomis.modcod = "VCE"
                         then "Com Entrada"
                         else "Sem Entrada" format "x(11)" no-label
                    wfcomis.vtot  column-label "Venda"
                                        (total by wfcomis.vencod)
                    wfcomis.vcom  column-label "Comissao"
                                        (total by wfcomis.vencod)
                    ((wfcomis.vcom / vdiatra) * vdomfer)  label "Repouso"
                                            (total by wfcomis.vencod)
                    with frame fcom centered color white/red width 80.
        end.
    end.

    sresp = no.
    message "Deseja Imprimir o Relatorio ?" update sresp.
    if sresp
    then do:


        if opsys = "UNIX"
        then varquivo = "../relat/dreb" + string(time).
        else varquivo = "..\relat\dreb" + string(time).
        
        {mdadmcab.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "150"
                &Page-Line = "66"
                &Nom-Rel   = ""DREBBON""
                &Nom-Sis   = """SISTEMA CREDIARIO"""
                &Tit-Rel   = """COMISSAO DOS VENDEDORES PERIODO DE "" +
                                string(vdtini) + "" A "" + string(vdtfin) +
                                ""                "" + 
                                    string(tipo,""99"") "
                &Width     = "150"
                &Form      = "frame f-cabcab"}

        for each wfcomis break by wfcomis.tprcod
                               by wfcomis.vencod with frame fpcom.
            
            find func where func.etbcod = estab.etbcod and
                            func.funcod = wfcomis.vencod no-lock no-error.

            if first-of(wfcomis.vencod)
            then display estab.etbcod column-label "Etb"
                         tippro.tprnom column-label "Tipo Produto" 
                                        format "x(12)"
                         wfcomis.vencod column-label "Cod"
                         func.usercod  Column-label "Folha" when avail func
                         func.funnom  format "x(15)" when avail func.

            if ((wfcomis.vcom / vdiatra) * vdomfer) = ?
            then do:
                vtotal = wfcomis.vcom.
                vtotal1 = wfcomis.vcom1 + wfcomis.vcom.
                
                v-tot01 = v-tot01 + wfcomis.vcom.
                v-tot02 = v-tot02 + wfcomis.vcom1.

            end.
            else do:
                
                vtotal = (wfcomis.vcom + 
                         ((wfcomis.vcom / vdiatra) * vdomfer)).
                         
                vtotal1 = (wfcomis.vcom1 + 
                          ((wfcomis.vcom1 / vdiatra) * vdomfer)) + 
                           (wfcomis.vcom + 
                           ((wfcomis.vcom / vdiatra) * vdomfer)).
                
                v-tot01 = v-tot01 + (wfcomis.vcom + 
                                    ((wfcomis.vcom / vdiatra) * vdomfer)).
                
                v-tot02 = v-tot02 + 
                         (wfcomis.vcom1 + 
                          ((wfcomis.vcom1 / vdiatra) * vdomfer)).

            end.


            display if wfcomis.modcod = "VVI"
                    then "A Vista"
                    else if wfcomis.modcod = "VCE"
                         then "Com Entrada"
                         else "Sem Entrada" format "x(11)" no-label
                wfcomis.vtot  column-label "Venda"
                                            (total by wfcomis.vencod)
                wfcomis.vcom  column-label "Comissao"
                                            (total by wfcomis.vencod)
                ((wfcomis.vcom / vdiatra) * vdomfer)  label "Repouso"
                                            (total by wfcomis.vencod)
                vtotal(total by wfcomis.vencod)  column-label "Total"     
                /*
                vtotal1(total by wfcomis.vencod) column-label "Total Geral"
                    when vtotal1 > 0
                */
                            with frame 
                                fpcom centered color white/red no-box
                                            width 200.
            
            if last-of(wfcomis.vencod) and vtotal1 > 0
            then do:
                find piso where piso.pismes = month(vdtfin) and
                                piso.etbcod = estab.etbcod no-lock no-error.

                if tipo = 1 or
                   tipo = 2
                then if v-tot01 < piso.pisval
                     then vcomp = piso.pisval - v-tot01.
                     else vcomp = 0.


                if tipo = 3 or
                   tipo = 4
                then do:
                     if v-tot01 < piso.pisval
                     then assign vcomp   = piso.pisval - v-tot01
                                 v-tot02 = piso.pisval.
                     else assign vcomp   = 0
                                 v-tot02 = v-tot01.
                end.

                if tipo = 1 or
                   tipo = 2
                then do:
                
                    if v-tot02 < piso.pisval
                    then v-tot02 = piso.pisval.
                
                    v-tot02 = v-tot01 - v-tot02.
                
                    if v-tot02 < 0
                    then v-tot02 = 0.
                    
                end.
                
                
                put "Compl. " at 120 
                    vcomp format "->,>>9.99"
                    "  " v-tot02 format "->>,>>9.99".
                        
                v-tot02 = 0.
                v-tot01 = 0.
            end.
                
        
        end.
        output close.
    
        if opsys = "UNIX"
        then run visurel.p (input varquivo, input "").
        else {mrod.i}.
        
    end.

    /*************
    message "Gerar Arquivo para folha" update sresp.
    if not sresp
    then next.
   
    find piso where piso.pismes = month(vdtfin) and
                    piso.etbcod = estab.etbcod no-lock no-error.
    if not avail piso
    then do:
        message "Piso nao Cadastrado".
        undo, retry.
    end.

    varquivo = "m:\folha" + string(estab.etbcod,"99") + ".txt".

    output to value(varquivo).
    
    totcomi = 0.
    totrepo = 0.
   
    for each wfcomis break by wfcomis.vencod.

        find func where func.etbcod = estab.etbcod and
                        func.funcod = wfcomis.vencod no-lock no-error.
        if not avail func
        then delete wfcomis.
        if func.usercod = "" 
        then delete wfcomis.
        
        
        if vtprcod = 3
        then do:
            if substring(func.usercod,7,1) <> "1"
            then delete wfcomis.
       end.
            
       if vtprcod = 4
       then do:
           if substring(func.usercod,7,1) <> "2"
           then delete wfcomis.
       end.
                  
    end.


    for each wfcomis break by wfcomis.vencod.
        
        find func where func.etbcod = estab.etbcod and
                        func.funcod = wfcomis.vencod no-lock no-error.
        if not avail func
        then next.
        if func.usercod = "" 
        then next.
        
        totcomi = totcomi +  wfcomis.vcom.
        totven  = totven  +  wfcomis.vtot.
        totrepo = totrepo + ((wfcomis.vcom / vdiatra) * vdomfer).

        if last-of(wfcomis.vencod)
        then do:
            if totcomi > 1
            then do:

                if substring(func.usercod,7,1) = "1"
                then do:

                    put substring(func.usercod,1,5) format "99999"
                        "008" format "999"
                        string(month(vdtfin),"99") format "99"
                        "        " format "x(09)" 
                        totcomi format "999999999.99" skip.
                         
                end. 
                else do:
                    put substring(func.usercod,1,5) format "99999"
                        "011" format "999"
                        string(month(vdtfin),"99") format "99"
                        "        " format "x(09)" 
                        totcomi format "999999999.99" skip.
                end.
                
                put substring(func.usercod,1,5) format "99999"
                    "850" format "999"
                    string(month(vdtfin),"99") format "99"
                    "        " format "x(09)" 
                    totven format "999999999.99" skip.
                            
            end.
            if totrepo > 0 and totcomi > 1
            then do:
                put substring(func.usercod,1,5) format "99999"
                    "012" format "999"
                    string(month(vdtfin),"99") format "99"
                    "        " format "x(09)"
                    totrepo format "999999999.99" skip.
            end.

            if (totcomi + totrepo) < piso.pisval and totcomi > 1
            then do:
                put substring(func.usercod,1,5) format "99999"
                    "018" format "999"
                    string(month(vdtfin),"99") format "99"
                    "        " format "x(09)" 
                   (piso.pisval - (totcomi + totrepo)) format "999999999.99" 
                             skip.
            end.
            totcomi = 0.
            totrepo = 0.
            totven  = 0.
        end.
    end.        
    output close.
    /* dos silent value("ved " + varquivo). */
    ***********/
end.

procedure p-lebonus:
    
    def output parameter p-valor-bonus like titulo.titvlcob.
    
    find first titulo where titulo.empcod   = 19
                        and titulo.titnat   = yes
                        and titulo.clifor   = plani.desti 
                        and titulo.modcod   = "BON" 
                        and titulo.titdtpag = plani.pladat    /*
                        and titulo.titvlpag = plani.descprod*/ no-lock no-error.
    if avail titulo
    then p-valor-bonus = titulo.titvlpag.
    else p-valor-bonus = 0.

end procedure.
