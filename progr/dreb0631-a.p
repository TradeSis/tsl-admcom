{admcab.i}
{ajusta-rateio-venda-def.i new}

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
def var vtotcom     as dec.
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

def temp-table wfcomis field etbcod       like estab.etbcod
                       field tprcod       like comis.tprcod
                       field vencod       like comis.vencod
                       field modcod       like comis.modcod
                       field vtot         as dec
                       field vcom         as dec
                       field vcom1        like plani.platot
                       field bonus        like plani.platot
                       field devolucao    like plani.platot
                       field G1 as dec
                       field G2 as dec
                       field G3 as dec
                       field G4 as dec
                       field G5 as dec
                       field G6 as dec
                       field acre         as dec.  

def temp-table tt-g no-undo
    field clacod like clase.clacod
    field tipo as char
    index i1 clacod.

def var vignora as log.
def var val_fin as dec.
def var val_des as dec.
def var val_dev as dec.
def var val_acr as dec.
def var val_com as dec.
def var valtotal as dec. 
def var val-recarga as dec.
def var acr-recarga as dec.
def var des-recarga as dec.

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
    if setbcod < 200
    then do:
        vetbcod = setbcod.
        disp vetbcod.
    end.
    else do:    
        update vetbcod label "Filial" colon 20.
    end.
    
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label.
    end.
    
    prompt-for comis.vencod label "Vendedor" colon 20 validate (true,"")
               with side-label width 80 color white/cyan.
    find func where func.etbcod = vetbcod and
                    func.funcod = input comis.vencod no-lock no-error.
    vvencod = if avail func
              then func.funcod
              else 0.
    /*
    if setbcod < 200 and
       vvencod = 0
    then undo.   
    */
    do on error undo:
    update vdtini label "Periodo" colon 20
           vdtfin no-label.

    if setbcod < 200 and
        vdtfin - vdtini > 60
    then do:
        bell.
        message color red/with
        "Informe periodo maximo de 60 dias."
        view-as alert-box.
        undo.
    end.
    end.
    

    do vdt = vdtini to vdtfin:

        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,
            each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5 and
                             plani.pladat = vdt no-lock:

            find tippro where tippro.tprcod = tipo no-lock no-error.

            disp plani.etbcod 
                 plani.pladat 
                 plani.numero format ">>>>>>9"
                     with 1 down centered color white/red.
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


            if vtprcod = 1
            then vcatcod = 41.
            else if vtprcod = 2
                then vcatcod = 31.
 
            valtotal = 0.
            if vcatcod <> 31
            then vignora = no.
            else vignora = yes.
            if vcatcod > 0
            then
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                     no-lock:
                find first produ where produ.procod = movim.procod
                            no-lock no-error.
                if avail produ
                then do:
                    if vcatcod <> 31
                    then if produ.catcod <> vcatcod
                         then vignora = yes.
                    if vcatcod = 31
                    then if produ.catcod = vcatcod or
                    produ.procod = 88888
                    then vignora = no. /* pelo menos 1 movel */
                end.
            end.
            if vignora = yes then next.
 
            run mercadologico(input estab.etbcod).
            
            assign
                val-recarga = 0
                acr-recarga = 0
                des-recarga = 0.
                    
            for each movim where movim.etbcod = plani.etbcod and
                                   movim.placod = plani.placod and
                                   movim.movtdc = plani.movtdc and
                                   movim.movdat = plani.pladat
                                                    no-lock .

            
                find produ where produ.procod = movim.procod no-lock no-error.
                if avail produ and
                   produ.pronom matches "*recarga*"
                   then assign
                            val-recarga = val-recarga +
                                (movim.movpc * movim.movqtm)
                            acr-recarga = ((movim.movpc * movim.movqtm) /
                                            plani.platot) * plani.acfprod
                            des-recarga = ((movim.movpc * movim.movqtm) / 
                                            plani.platot) * plani.descprod.
                        
            end.
            if val-recarga < 0 or val-recarga = ?
            then val-recarga = 0.
            if acr-recarga < 0 or acr-recarga = ?
            then acr-recarga = 0.
            if des-recarga < 0 or des-recarga = ?
            then des-recarga = 0.
                        
            if vvencod <> 0 and
               vvencod <> plani.vencod
            then next.
            vcatcod = vtprcod.
            
            val_acr = 0.
            val_des = 0.
            
            if plani.biss > (plani.platot - plani.vlserv)
            then val_acr = plani.biss -
                        (plani.platot - plani.vlserv).
            else val_acr = plani.acfprod.
            
            val_des = val_des + plani.descprod.
                
            assign
                val_acr = val_acr - acr-recarga
                val_des = val_des - des-recarga
                .
                
            if val_acr < 0 or val_acr = ?
            then val_acr = 0.

            valtotal = valtotal + ((plani.platot - val-recarga) -
                  val_des + val_acr) .
            
            run p-lebonus(output valor-bonus).

            if valtotal = 0 and
                valor-bonus = 0 then next.

            if plani.crecod = 1
            then do:

                create wf-com.
                assign wf-com.etbcod  = plani.etbcod
                       wf-com.datexp  = today
                       wf-com.compra  = valtotal + valor-bonus
                       /*
                        (plani.protot + valor-bonus +
                                        plani.acfprod -
                                        plani.descprod) - plani.vlserv
                       */
                       wf-com.clifor  = 1
                       wf-com.contnum = (val_acr * 100)
                       wf-com.tprcod  = vcatcod
                       wf-com.vencod  = plani.vencod
                       wf-com.modcod  = "VVI"  /** VENDA A VISTA **/.

                if wf-com.compra = ?
                then wf-com.compra = 0.
                find first wfcomis where wfcomis.etbcod = wf-com.etbcod and
                                         wfcomis.tprcod = wf-com.tprcod and
                                         wfcomis.vencod = wf-com.vencod and
                                         wfcomis.modcod = wf-com.modcod
                                         no-error.
                if not avail wfcomis
                then create wfcomis.
                assign wfcomis.etbcod = wf-com.etbcod
                       wfcomis.tprcod = wf-com.tprcod
                       wfcomis.vencod = wf-com.vencod
                       wfcomis.modcod = wf-com.modcod
                       wfcomis.vtot   = wfcomis.vtot + wf-com.compra.
                       wfcomis.vcom   = wfcomis.vcom +
                            (wf-com.compra * (tippro.vista / 100)).
                       wfcomis.bonus  = wfcomis.bonus + valor-bonus.
                       wfcomis.acre = wfcomis.acre + (wf-com.contnum / 100 ).
                
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
                           wf-com.compra  = valtotal + valor-bonus
                           /*
                           (if plani.biss > plani.platot
                                             then plani.biss
                                             else plani.platot) +
                                             valor-bonus
                            */
                           wf-com.clifor  = plani.desti
                           wf-com.tprcod  = vtprcod
                           wf-com.modcod  = "VCE".

                    if wf-com.compra = ?
                    then wf-com.compra = 0.
                    find first wfcomis where wfcomis.etbcod = wf-com.etbcod and
                                             wfcomis.tprcod = wf-com.tprcod and
                                             wfcomis.vencod = wf-com.vencod and
                                             wfcomis.modcod = "VCE" no-error.
                    if not avail wfcomis
                    then create wfcomis.
                    assign wfcomis.etbcod  = wf-com.etbcod
                           wfcomis.tprcod  = wf-com.tprcod
                           wfcomis.vencod  = wf-com.vencod
                           wfcomis.modcod  = "VCE"
                           wfcomis.vtot    = wfcomis.vtot + wf-com.compra.
                           wfcomis.vcom    = wfcomis.vcom +
                                             (wf-com.compra *
                                             (tippro.coment / 100)).
                           wfcomis.bonus  = wfcomis.bonus + valor-bonus.
                    
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
                           wf-com.compra  = valtotal + valor-bonus
                           /**
                           (if plani.biss > plani.platot
                                             then plani.biss
                                             else plani.platot) +
                                             valor-bonus
                           **/
                           wf-com.clifor  = plani.desti
                           wf-com.tprcod  = vtprcod
                           wf-com.modcod  = "VSE".
                    if wf-com.compra = ?
                    then wf-com.compra = 0.

                    find first wfcomis where wfcomis.etbcod = wf-com.etbcod and
                                             wfcomis.tprcod = wf-com.tprcod and
                                             wfcomis.vencod = wf-com.vencod and
                                             wfcomis.modcod = "VSE" no-error.
                    if not avail wfcomis
                    then create wfcomis.
                    assign wfcomis.etbcod  = wf-com.etbcod
                           wfcomis.tprcod  = wf-com.tprcod
                           wfcomis.vencod  = wf-com.vencod
                           wfcomis.modcod  = "VSE"
                           wfcomis.vtot    = wfcomis.vtot + wf-com.compra
                           wfcomis.vcom    = wfcomis.vcom +
                                  (wf-com.compra * (tippro.sement / 100))
                           wfcomis.bonus  = wfcomis.bonus + valor-bonus.

                    
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
            
            for each tt-plani: delete tt-plani. end.
            for each tt-movim: delete tt-movim. end.
            create tt-plani.
            buffer-copy plani to tt-plani.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                create tt-movim.
                buffer-copy movim to tt-movim.
            end.
                                     
            val_acr = 0.
            val_des = 0.
                
            run ajusta-rateio-venda-pro.p.
                
            val_com = 0.
                
            find first wfcomis where wfcomis.etbcod = plani.etbcod and
                                         /*wfcomis.tprcod = vcatcod and*/
                                         wfcomis.vencod = plani.vencod /*and
                                         wfcomis.modcod = wf-com.modcod*/
                                         no-error.
            if avail wfcomis
            then
            for each tt-movim no-lock:
                find produ where produ.procod = tt-movim.procod
                            no-lock no-error.
                if not avail produ then next.

                    val_acr = 0.
                    val_des = 0.
                    val_dev = 0.
                    val_fin = 0.

                    if tt-movim.movtot <> ?
                    then val_com = val_com + tt-movim.movtot.
 
                    if (produ.procod = 559910 or
                        produ.procod = 559911 or
                        produ.procod = 578790 or
                        produ.procod = 579359 or
                        produ.procod = 569131 or
                        produ.procod = 569133 or
                        produ.procod = 569134) 
                    then assign
                         /*acum-sq = acum-sq + 1
                         acum-sv = acum-sv + 
                         (if vcatcod = 31 then tt-movim.movtot
                         else tt-movim.movpc)
                         tt-metacomis.rseguro = tt-metacomis.rseguro + 1
                         */
                         wfcomis.g5 = wfcomis.g5 + tt-movim.movtot.
                         /*
                                (if vcatcod = 31 then tt-movim.movtot
                                                 else tt-movim.movpc)
                         . */
                    else if produ.catcod = 31 or
                            produ.catcod = 41 or
                            produ.catcod = 35 or
                            produ.catcod = 45
                    then wfcomis.g3 = wfcomis.g3 + 
                                   (if tt-movim.movtot <> ?
                                    then (tt-movim.movtot - 
                                         (tt-movim.movpc * tt-movim.movqtm))
                                    else 0).
                    else if produ.catcod = 81
                    then assign
                             wfcomis.g1 = wfcomis.g1 +
                                (if tt-movim.movtot <> ?
                                then tt-movim.movtot else 0)
                             wfcomis.g4 = wfcomis.g4 +
                                (if tt-movim.movtot <> ?
                                then tt-movim.movtot -
                                (tt-movim.movpc * tt-movim.movqtm)
                                else 0).
                           
                    find first tt-g where
                               tt-g.clacod = produ.clacod no-error.
                    if avail tt-g
                    then do:
                        if tt-g.tipo = "G1"
                        then wfcomis.g1 = wfcomis.g1 +
                                    (if tt-movim.movtot <> ?
                                    then tt-movim.movtot else 0).
                        else if tt-g.tipo = "G2"
                        then wfcomis.g2 = wfcomis.g2 +
                                    (if tt-movim.movtot <> ?
                                    then tt-movim.movtot else 0).
             
                    end.           
                end.

                /*if (vcatcod = 31 or
                    vcatcod = 35)
                then do:
                    /*
                    acum-m = acum-m + val_com.
                    if plani.pladat = vdtimp
                    then dia-m = dia-m + val_com.
                    tt-metacomis.rvenda = tt-metacomis.rvenda + val_com.
                    */
                 end.
                else*/ if (produ.catcod = 41 or
                         produ.catcod = 45)
                then do:
                     /*acum-c = acum-c + val_com.
                     if plani.pladat = vdtimp
                     then dia-c = dia-c + val_com.
                     tt-metacomis.rvenda = tt-metacomis.rvenda + val_com.
                     */
                     wfcomis.g6 = wfcomis.g6 + val_com.
                end.
        end.
        run devolucao-venda.
        
    end.
    
    find tippro where tippro.tprcod = vtprcod no-lock no-error.
    
    for each wfcomis:

        if wfcomis.vtot < wfcomis.devolucao
        then do:
            wfcomis.vcom = 0.
            next.
        end.        
            
        find tippro where tippro.tprcod = wfcomis.tprcod no-lock no-error.

        if wfcomis.modcod = "VVI"
        then wfcomis.vcom = ((wfcomis.vtot - wfcomis.devolucao )
                                *  (tippro.vista / 100)).
        else if wfcomis.modcod = "VCE" 
            then wfcomis.vcom   = ((wfcomis.vtot - wfcomis.devolucao )
                                *  (tippro.coment / 100)).
            else if wfcomis.modcod = "VSE"
                then wfcomis.vcom   = ((wfcomis.vtot - wfcomis.devolucao )
                                     *  (tippro.sement / 100)).
 
    end.

    if setbcod = 999
    then do:
    sresp = no.
    message "Deseja Imprimir o Relatorio ?" update sresp.
    end.
    else sresp = yes.
    if sresp
    then do:

        if opsys = "UNIX"
        then varquivo = "/admcom/relat/dreb1" + string(time).
        else varquivo = "l:~\relat~\dreb1" + string(time).
        
        {mdadmcab.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "180"
                &Page-Line = "66"
                &Nom-Rel   = ""DREB062""
                &Nom-Sis   = """SISTEMA CREDIARIO"""
                &Tit-Rel   = """COMISSAO DOS VENDEDORES PERIODO DE "" +
                                string(vdtini) + "" A "" + string(vdtfin) +
                                ""                "" + 
                                    string(tipo,""99"") "
                &Width     = "180"
                &Form      = "frame f-cabcab"}

        if setbcod = 999
        then
        for each wfcomis break by wfcomis.etbcod 
                               by wfcomis.tprcod
                               by wfcomis.vencod with frame fpcom.

            find piso where piso.pismes = month(vdtfin) and
                            piso.etbcod = wfcomis.etbcod no-lock no-error.
            if avail piso
            then assign vdiatra = piso.pisdia
                        vdomfer = piso.pisrep.
            else do:
            
                find first piso where piso.pismes = month(vdtfin) 
                                no-lock no-error.
                if avail piso
                then assign vdiatra = piso.pisdia
                            vdomfer = piso.pisrep.

            end.
                        
                        
            
            find func where func.etbcod = wfcomis.etbcod and
                            func.funcod = wfcomis.vencod no-lock no-error.

            if first-of(wfcomis.vencod)
            then display wfcomis.etbcod column-label "Etb"
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
                wfcomis.vtot - wfcomis.bonus  column-label "Venda(2)"
                                            (total by wfcomis.vencod)
                wfcomis.devolucao column-label "Devolucao"
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
                wfcomis.G1(total by wfcomis.vencod) column-label "G1"
                wfcomis.G2(total by wfcomis.vencod) column-label "G2"
                wfcomis.G3(total by wfcomis.vencod) column-label "G3"
                wfcomis.G4(total by wfcomis.vencod) column-label "G4"
                wfcomis.G5(total by wfcomis.vencod) column-label "G5"
                wfcomis.G6(total by wfcomis.vencod) column-label "G6"
                             with frame 
                                fpcom centered color white/red no-box
                                            width 200.
            
            if last-of(wfcomis.vencod) and vtotal1 > 0
            then do:
                find piso where piso.pismes = month(vdtfin) and
                                piso.etbcod = wfcomis.etbcod no-lock no-error.
                if avail piso
                then do:
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
                end.
                /*
                put "Compl. " at 120 
                    vcomp format "->,>>9.99"
                    "  " v-tot02 format "->>,>>9.99".
                */        
                v-tot02 = 0.
                v-tot01 = 0.
            end.
                
        
        end.
        else
        for each wfcomis break by wfcomis.etbcod 
                               by wfcomis.tprcod
                               by wfcomis.vencod with frame fpcom1.

            find piso where piso.pismes = month(vdtfin) and
                            piso.etbcod = wfcomis.etbcod no-lock no-error.
            if avail piso
            then assign vdiatra = piso.pisdia
                        vdomfer = piso.pisrep.
            else do:
            
                find first piso where piso.pismes = month(vdtfin) 
                                no-lock no-error.
                if avail piso
                then assign vdiatra = piso.pisdia
                            vdomfer = piso.pisrep.

            end.
                        
                        
            
            find func where func.etbcod = wfcomis.etbcod and
                            func.funcod = wfcomis.vencod no-lock no-error.

            if first-of(wfcomis.vencod)
            then display wfcomis.etbcod column-label "Etb"
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
                wfcomis.vtot - wfcomis.bonus  column-label "Venda(2)"
                                            (total by wfcomis.vencod)
                wfcomis.devolucao column-label "Devolucao"
                               (total by wfcomis.vencod)
                /*
                wfcomis.vcom  column-label "Comissao"
                                            (total by wfcomis.vencod)
                
                ((wfcomis.vcom / vdiatra) * vdomfer)  label "Repouso"
                                            (total by wfcomis.vencod)
                vtotal(total by wfcomis.vencod)  column-label "Total"     
                */
                /*
                vtotal1(total by wfcomis.vencod) column-label "Total Geral"
                    when vtotal1 > 0
                */
                wfcomis.G1(total by wfcomis.vencod) column-label "G1"
                wfcomis.G2(total by wfcomis.vencod) column-label "G2"
                wfcomis.G3(total by wfcomis.vencod) column-label "G3"
                wfcomis.G4(total by wfcomis.vencod) column-label "G4"
                wfcomis.G5(total by wfcomis.vencod) column-label "G5"
                wfcomis.G6(total by wfcomis.vencod) column-label "G6"
                            with frame 
                                fpcom1 centered color white/red no-box
                                            width 140.
            
            if last-of(wfcomis.vencod) and vtotal1 > 0
            then do:
                find piso where piso.pismes = month(vdtfin) and
                                piso.etbcod = wfcomis.etbcod no-lock no-error.
                if avail piso
                then do:
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
                end.
                /*
                if setbcod = 999
                then
                put "Compl. " at 120 
                    vcomp format "->,>>9.99"
                    "  " v-tot02 format "->>,>>9.99".
                */        
                v-tot02 = 0.
                v-tot01 = 0.
            end.
                
        
        end.

        output close.
        if opsys = "UNIX"
        then do:
            run visurel.p (varquivo, "").
        end.
        else do:    
            {mrod.i}
        end.
    end.

    /********************
    if setbcod < 200
    then next.
    
    message "Gerar Arquivo para folha" update sresp.
    if not sresp
    then next.
   
    /*
    if vetbcod = 0
    then varquivo = "m:\folha00.txt".
    else varquivo = "m:\folha" + string(estab.etbcod,"99") + ".txt".
    */
    
    if opsys = "UNIX"
    then varquivo = "/admcom/import/folha/folha" + string(vetbcod,"99") 
                        + ".txt".
    else varquivo = "m:~\folha" + string(vetbcod,"99") + ".txt".            

    output to value(varquivo).
    
    totcomi = 0.
    totrepo = 0.
   
    for each wfcomis:

        find func where func.etbcod = wfcomis.etbcod and
                        func.funcod = wfcomis.vencod no-lock no-error.
                        
        if not avail func
        then do:
            delete wfcomis.
            next.
        end.
        
        if func.usercod = "" 
        then do:
            delete wfcomis.
            next.
        end.

        if vtprcod = 3
        then do:
            if substring(func.usercod,7,1) <> "1"
            then do:
                delete wfcomis.
                next.
            end.
       end.
            
       if vtprcod = 4
       then do:
           if substring(func.usercod,7,1) <> "2"
           then do:
               delete wfcomis.
               next.
           end.
       end.
                  
        
    end.


    for each wfcomis break by wfcomis.etbcod
                           by wfcomis.vencod.
        
        
        find piso where piso.pismes = month(vdtfin) and
                        piso.etbcod = wfcomis.etbcod no-lock no-error.
        if not avail piso
        then next.
       
        assign vdiatra = piso.pisdia
               vdomfer = piso.pisrep.
        
        
        find func where func.etbcod = wfcomis.etbcod and
                        func.funcod = wfcomis.vencod no-lock no-error.
        if not avail func
        then next.

        if func.usercod = "" 
        then next.
        
        totcomi = totcomi +  wfcomis.vcom.
        totven  = totven  +  (wfcomis.vtot - wfcomis.devolucao).
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

    if opsys = "UNIX"
    then unix silent value("unix2dos " + varquivo). 
    *************/
    
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

procedure devolucao-venda:

    def buffer cplani for plani.
    def buffer dplani for plani.
    def buffer cmovim for movim.
    def buffer dmovim for movim.
    
    def var vtotal-dev as dec.
    vtotal-dev = 0.
    for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,
        each dplani where dplani.etbcod = estab.etbcod and
                             dplani.movtdc = 12 and
                             dplani.pladat = vdt and
                             dplani.serie = "1" no-lock:

        for each ctdevven where
                     ctdevven.etbcod = dplani.etbcod and
                     ctdevven.placod = dplani.placod and
                     ctdevven.movtdc = dplani.movtdc
                     no-lock .

            find first cplani where
                           cplani.etbcod = ctdevven.etbcod-ori and
                           cplani.placod = ctdevven.placod-ori and
                           cplani.movtdc = ctdevven.movtdc-ori
                           no-lock no-error.
            if not avail cplani then next.

            vtotal-dev = 0.
            for each dmovim where 
                     dmovim.etbcod = dplani.etbcod and
                     dmovim.placod = dplani.placod and
                     dmovim.movtdc = dplani.movtdc
                     no-lock:
                     
                find first cmovim where
                           cmovim.etbcod = cplani.etbcod and
                           cmovim.placod = cplani.placod and
                           cmovim.movtdc = cplani.movtdc and
                           cmovim.procod = dmovim.procod
                           no-lock no-error.
                if avail cmovim
                then do:
                    if dmovim.movqtm > cmovim.movqtm
                    then vtotal-dev = vtotal-dev + 
                            (cmovim.movpc * cmovim.movqtm).
                    else vtotal-dev = vtotal-dev +
                            (cmovim.movpc * dmovim.movqtm).
                end.
            end.
            
            find tippro where tippro.tprcod = tipo no-lock no-error.

            disp cplani.etbcod 
                 cplani.pladat 
                 cplani.numero format ">>>>>>9"
                     with 1 down centered color white/red.
            pause 0.

            find first cmovim where cmovim.etbcod = cplani.etbcod and
                                   cmovim.placod = cplani.placod and
                                   cmovim.movtdc = cplani.movtdc and
                                   cmovim.movdat = cplani.pladat
                                                    no-lock no-error.

            
            if vtprcod = 3
            then vtprcod = 1.

            if vtprcod = 4
            then vtprcod = 2.


            if vtprcod = 1
            then vcatcod = 41.
            else vcatcod = 31.
 
            valtotal = 0.
            if vcatcod <> 31
            then vignora = no.
            else vignora = yes.
            if vcatcod > 0
            then
            for each cmovim where cmovim.etbcod = cplani.etbcod and
                                 cmovim.placod = cplani.placod and
                                 cmovim.movtdc = cplani.movtdc and
                                 cmovim.movdat = cplani.pladat
                                     no-lock:
                find first produ where produ.procod = cmovim.procod
                            no-lock no-error.
                if avail produ
                then do:
                    if vcatcod <> 31
                    then if produ.catcod <> vcatcod
                         then vignora = yes.
                    if vcatcod = 31
                    then if produ.catcod = vcatcod or
                    produ.procod = 88888
                    then vignora = no. /* pelo menos 1 movel */
                end.
            end.
            if vignora = yes then next.
 
            assign
                val-recarga = 0
                acr-recarga = 0
                des-recarga = 0.
                    
            for each cmovim where cmovim.etbcod = cplani.etbcod and
                                   cmovim.placod = cplani.placod and
                                   cmovim.movtdc = cplani.movtdc and
                                   cmovim.movdat = cplani.pladat
                                                    no-lock .

            
                find produ where produ.procod = cmovim.procod no-lock no-error.
                if avail produ and
                   produ.pronom matches "*recarga*"
                   then assign
                            val-recarga = val-recarga +
                                (cmovim.movpc * cmovim.movqtm)
                            acr-recarga = ((cmovim.movpc * cmovim.movqtm) /
                                            cplani.platot) * cplani.acfprod
                            des-recarga = ((cmovim.movpc * cmovim.movqtm) / 
                                            cplani.platot) * cplani.descprod.
                        
            end.
            if val-recarga < 0 or val-recarga = ?
            then val-recarga = 0.
            if acr-recarga < 0 or acr-recarga = ?
            then acr-recarga = 0.
            if des-recarga < 0 or des-recarga = ?
            then des-recarga = 0.
                        
            if vvencod <> 0 and
               vvencod <> cplani.vencod
            then next.
            vcatcod = vtprcod.
            
            val_acr = 0.
            val_des = 0.
            
            if cplani.biss > (cplani.platot - cplani.vlserv)
            then val_acr = cplani.biss -
                        (cplani.platot - cplani.vlserv).
            else val_acr = cplani.acfprod.
            
            val_des = val_des + cplani.descprod.
                
            assign
                val_acr = val_acr - acr-recarga
                val_des = val_des - des-recarga
                .
                
            if val_acr < 0 or val_acr = ?
            then val_acr = 0.

            valtotal = valtotal + ((cplani.platot - val-recarga) -
                  val_des + val_acr) .
            
            valtotal = valtotal * (vtotal-dev / valtotal).
            
            run p-lebonus(output valor-bonus).

            if valtotal = 0 and
                valor-bonus = 0 then next.

            if cplani.crecod = 1
            then do:
                find first wfcomis where wfcomis.etbcod = cplani.etbcod and
                                         wfcomis.tprcod = vcatcod and
                                         wfcomis.vencod = cplani.vencod and
                                         wfcomis.modcod = "VVI"
                                         no-error.
                if not avail wfcomis
                then do:
                    create wfcomis.
                    assign wfcomis.etbcod = cplani.etbcod
                       wfcomis.tprcod = vcatcod
                       wfcomis.vencod = cplani.vencod
                       wfcomis.modcod = "VVI"
                       .
                end.
if valtotal = ?
then valtotal = 0.
if valor-bonus = ?
then valor-bonus = 0.
                wfcomis.devolucao =     wfcomis.devolucao +
                                        (valtotal - valor-bonus). 

            end.
            

            if cplani.crecod = 2
            then do:
                find finan where finan.fincod = cplani.pedcod no-lock.
                if finan.finent 
                then do:
                    
                    find first wfcomis where wfcomis.etbcod = cplani.etbcod and
                                             wfcomis.tprcod = vcatcod and
                                             wfcomis.vencod = cplani.vencod and
                                             wfcomis.modcod = "VCE" no-error.
                    if not avail wfcomis
                    then do:
                        create wfcomis.
                        assign wfcomis.etbcod  = cplani.etbcod
                           wfcomis.tprcod  = vcatcod
                           wfcomis.vencod  = cplani.vencod
                           wfcomis.modcod  = "VCE"
                           .
                    end.       
if valtotal = ?
then valtotal = 0.
if valor-bonus = ?
then valor-bonus = 0.                    
                    wfcomis.devolucao =     wfcomis.devolucao  +
                                            (valtotal - valor-bonus).
                    
                end.
                else do:
                    
                    find first wfcomis where wfcomis.etbcod = cplani.etbcod and
                                             wfcomis.tprcod = vcatcod and
                                             wfcomis.vencod = cplani.vencod and
                                             wfcomis.modcod = "VSE" no-error.
                    if not avail wfcomis
                    then do:
                        create wfcomis.
                        assign wfcomis.etbcod  = cplani.etbcod
                           wfcomis.tprcod  = vcatcod
                           wfcomis.vencod  = cplani.vencod
                           wfcomis.modcod  = "VSE"
                           .
                    end.
if valtotal = ?
then valtotal = 0.
if valor-bonus = ?
then valor-bonus = 0.                    
                    wfcomis.devolucao =     wfcomis.devolucao +
                                            (valtotal - valor-bonus).
                           
                end.
            end.
        end.
    end.
end procedure.

procedure mercadologico:
    def input parameter p-etbcod like estab.etbcod.
    def var vclasse like clase.clacod.
    def var vtipo as char.
    def var vi as int.
    def buffer bclase for clase.
    def buffer cclase for clase.
    def buffer dclase for clase.
    find tabmeta where tabmeta.codtm  = 1 and
                   tabmeta.anoref = 0 and
                   tabmeta.mesref = 0 and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = p-etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   no-lock no-error.
    if avail tabmeta
    then do vi = 1 to 10:
        if valger1[vi] = 0 and valger2[vi] = 0
        then leave.   
        if valger1[vi] > 0
        then do: 
            find clase where clase.clacod = int(valger1[vi]) no-lock no-error.
            if avail clase
            then do:
                if clase.clagrau = 4
                then do:
                    create tt-g.
                    assign
                        tt-g.clacod = clase.clacod
                        tt-g.tipo  = "G1".
                end.
                else do:
                    for each bclase where bclase.clasup = clase.clacod
                                            no-lock:
                        if bclase.clagrau = 4
                        then do:
                            create tt-g.
                            assign
                                tt-g.clacod = bclase.clacod
                                tt-g.tipo  = "G1".
                        end.
                        else do:
                            for each cclase where cclase.clasup = bclase.clacod
                                                no-lock.
                                if cclase.clagrau = 4
                                then do:
                                    create tt-g.
                                    assign
                                        tt-g.clacod = cclase.clacod
                                        tt-g.tipo  = "G1".
                                end.
                                else do:
                                    for each dclase where 
                                             dclase.clasup = cclase.clacod
                                             no-lock:
                                        if dclase.clagrau = 4
                                        then do:
                                            create tt-g.
                                            assign
                                                tt-g.clacod = dclase.clacod
                                                tt-g.tipo  = "G1".
                                        end.        
                                    end.         
                                end.
                            end.    
                        end.
                    end.                        
                end.
            end.
        end.
        if valger2[vi] > 0
        then do: 
            find clase where clase.clacod = int(valger2[vi]) no-lock no-error.
            if avail clase
            then do:
                if clase.clagrau = 4
                then do:
                    create tt-g.
                    assign
                        tt-g.clacod = clase.clacod
                        tt-g.tipo  = "G2".
                end.
                else do:
                    for each bclase where bclase.clasup = clase.clacod
                                            no-lock:
                        if bclase.clagrau = 4
                        then do:
                            create tt-g.
                            assign
                                tt-g.clacod = bclase.clacod
                                tt-g.tipo  = "G2".
                        end.
                        else do:
                            for each cclase where cclase.clasup = bclase.clacod
                                                no-lock.
                                if cclase.clagrau = 4
                                then do:
                                    create tt-g.
                                    assign
                                        tt-g.clacod = cclase.clacod
                                        tt-g.tipo  = "G2".
                                end.
                                else do:
                                    for each dclase where 
                                             dclase.clasup = cclase.clacod
                                             no-lock:
                                        if dclase.clagrau = 4
                                        then do:
                                            create tt-g.
                                            assign
                                                tt-g.clacod = dclase.clacod
                                                tt-g.tipo  = "G2".
                                        end.        
                                    end.         
                                end.
                            end.    
                        end.
                    end.                        
                end.
            end.
        end.     
    end.
end procedure.

