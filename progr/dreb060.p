{admcab.i}

def var totcomi like plani.platot.
def var totrepo like plani.platot.


def var v-valor     as dec.
def var val_acr     like plani.platot.
def var val_des     like plani.platot.
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



def temp-table wfcomis field tprcod       like comis.tprcod
                     field vencod       like comis.vencod
                     field modcod       like comis.modcod
                     field vtot         as dec
                     field vcom         as dec.

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
           vdtfin colon 45.

    do vdt = vdtini to vdtfin:

        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5 and
                             plani.pladat = vdt no-lock:

            disp plani.etbcod plani.pladat plani.numero with 1 down centered
                                                        color white/red.
            pause 0.

            find first movim where movim.etbcod = plani.etbcod and
                                   movim.placod = plani.placod and
                                   movim.movtdc = plani.movtdc and
                                   movim.movdat = plani.pladat
                                                    no-lock no-error.

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
                /************* CARTAO TELEFONICO **********
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
                ******************************************/
            end.
            
            if vvencod <> 0 and
               vvencod <> plani.vencod
            then next.

            val_acr = 0.
            val_des = 0.
                        
            if plani.biss > (plani.platot - plani.vlserv)
            then assign val_acr = plani.biss -
                        (plani.platot - plani.vlserv).
            else val_acr = plani.acfprod.
                                                
            if val_acr < 0 or val_acr = ?
            then val_acr = 0.
            
            assign val_des = val_des + plani.descprod.
                        
            assign
                v-valor = (plani.platot - /* plani.vlserv -*/
                   val_des + val_acr).
                   
            if plani.crecod = 1
            then do:

                create wf-com.
                assign wf-com.etbcod  = plani.etbcod
                       wf-com.datexp  = today
                       wf-com.compra  = v-valor
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
                       wfcomis.vcom   = wfcomis.vcom  +
                                        (wf-com.compra * (tippro.vista / 100)).

                delete wf-com.

            end.

            if plani.crecod = 2
            then do:
                find finan where finan.fincod = plani.pedcod no-lock.
                /*
                find first titulo where titulo.empcod = 19             and
                                        titulo.titnat = no             and
                                        titulo.modcod = "CRE"          and
                                        titulo.etbcod = plani.etbcod   and
                                        titulo.titdtemi = plani.pladat and
                                        titulo.clifor   = plani.desti  and
                                        titulo.titpar   = 0 no-lock no-error.
                */
                if finan.finent /* and avail titulo */
                then do:
                    create wf-com.
                    assign wf-com.etbcod  = plani.etbcod
                           wf-com.vencod  = plani.vencod
                           wf-com.datexp  = today
                           wf-com.compra  = v-valor
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

                    delete wf-com.
                end.
                else do:

                    create wf-com.
                    assign wf-com.etbcod  = plani.etbcod
                           wf-com.vencod  = plani.vencod
                           wf-com.datexp  = today
                           wf-com.compra  = v-valor
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
        if not avail func
        then next.

        if first-of(wfcomis.vencod)
        then display func.funcod   column-label "Cod"
                     func.funnom   format "x(20)".

        display if wfcomis.modcod = "VVI"
                then "A Vista"
                else if wfcomis.modcod = "VCE"
                     then "Com Entrada"
                     else "Sem Entrada" format "x(11)" no-label
            wfcomis.vtot  column-label "Venda(2)"
                                        (total by wfcomis.vencod)
                with frame fcom centered color white/red width 80.
    end.

    sresp = no.
    message "Deseja Imprimir o Relatorio ?" update sresp.
    if sresp
    then do:

        {mdadmcab.i &Saida     = "printer"
                    &Page-Size = "64"
                    &Cond-Var  = "150"
                    &Page-Line = "66"
                    &Nom-Rel   = ""DREB060""
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
                         func.usercod  Column-label "Folha"
                         func.funnom   when avail func.

            if ((wfcomis.vcom / vdiatra) * vdomfer) = ?
            then vtotal = wfcomis.vcom.
            else vtotal = (wfcomis.vcom + 
                          ((wfcomis.vcom / vdiatra) * vdomfer)).


            display if wfcomis.modcod = "VVI"
                    then "A Vista"
                    else if wfcomis.modcod = "VCE"
                         then "Com Entrada"
                         else "Sem Entrada" format "x(11)" no-label
                    wfcomis.vtot  column-label "Venda(2)"
                                            (total by wfcomis.vencod)
                            with frame fpcom centered color white/red no-box
                                            width 200.
        end.
        output close.
    end.
end.
