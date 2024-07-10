{admcab.i}
{difregtab.i}

def buffer yclase for clase.

/***
def var v-catcod like produ.catcod.
def var v-clacod like produ.clacod.
def var v-fabcod like produ.fabcod.
def var v-prorefter like produ.prorefter.
def var v-pronom like produ.pronom.
def var v-pronomc like produ.pronomc.
def var v-etccod like produ.etccod.
***/

def var    vok    as   l.
def var    totpen like plani.platot.
def var    totped like plani.platot.
def buffer brepre for repre.
def buffer bfunc  for func.
def buffer bestab for estab.
def var vcatcod like produ.catcod.
def var vclacod like produ.clacod.
def var vfabcod like produ.fabcod.
def var vpedpro like produ.procod.
def var vprocod like produ.procod.
def var vrepcod like pedid.vencod.

/***
def buffer bprodu for produ.
def var vestcusto  like estoq.estcusto.
def var vestmgoper like estoq.estmgoper.
def var vestmgluc  like estoq.estmgluc.
def var vtabcod    like estoq.tabcod.
def var vestvenda  like estoq.estvenda.
def var vforcod like forne.forcod.
def var vcondat like pedid.condat.
def var vpeddat as   date.
def var vcrecod like crepl.crecod.
def var vcomcod like pedid.comcod.
def var vfrete  like pedid.condes.
def var vnfdes  like pedid.nfdes.
def var vdupdes like pedid.dupdes.          
def var vipi    as   dec.
def var vacrfin like pedid.acrfin.
def var vcondes like pedid.condes.
def var vfrecod like pedid.frecod.
def var vfobcif like pedid.fobcif.
def var vpedtot like pedid.pedtot.
def var vpedobs like pedid.pedobs.
****/

def input parameter vrec as recid.
def output parameter vrecped as recid.

def var vpednum like pedid.pednum.
def var vetbcod like estab.etbcod.
def var vdata   like pedid.peddat.
def var vlippre like liped.lippreco.
def var vlipqtd like liped.lipqtd.
def var vlipent like liped.lipent column-label "QTD".
def var vqtd    like liped.lipqtd.
def buffer      bpedid for pedid.

def temp-table wf-lip
    field lipqtd    like liped.lipqtd
    field procod    like liped.procod
    field lippre    like liped.lippreco
    field lipent    like liped.lipent.

def temp-table ttpedid like pedid.

    form ttpedid.clfcod      colon 18 label "Fornecedor"
         forne.fornom      no-label format "x(30)"
         forne.forcgc      colon 18
         forne.forinest    colon 50 label "I.E" format "x(17)"
         forne.forrua      colon 18 label "Endereco"
         forne.fornum
         forne.forcomp no-label
         forne.formunic   colon 18 label "Cidade"
         forne.ufecod   label "UF"
         forne.forcep      label "Cep"
         forne.forfone        colon 18 label "Fone"
         ttpedid.regcod    colon 18 label "Local Entrega"
         bestab.etbnom   no-label
         vrepcod         colon 18
         repre.repnom    no-label
         ttpedid.condat    colon 18 label "Data Base" format "99/99/9999"
         ttpedid.peddat    colon 18 label "Data do Pedido" format "99/99/9999"
         ttpedid.peddti    colon 18 label "Prazo de Entrega" format "99/99/9999"
         ttpedid.peddtf    label "A"           format "99/99/9999"
         ttpedid.crecod       colon 18 label "Prazo de Pagto" format "9999"
         crepl.crenom       no-label
         ttpedid.comcod       colon 18 label "Comprador"
         func.funnom                 no-label
         ttpedid.frecod       label "Transport." colon 18
         ttpedid.fobcif
         ttpedid.condes       label "Frete" 
         ttpedid.nfdes        colon 18 label "Desc.Nota"
         ttpedid.dupdes       label "Desc.Duplicata"
         ttpedid.ipides       label "IPI" format ">9.99%" 
         ttpedid.acrfin       label "Acres. Financ."
         with frame f-dialogo color white/cyan overlay row 6
            side-labels centered.

    form
        ttpedid.pedobs[1] format "x(78)" 
        ttpedid.pedobs[2] format "x(78)"
        ttpedid.pedobs[3] format "x(78)"
        ttpedid.pedobs[4] format "x(78)"
        ttpedid.pedobs[5] format "x(78)"
                 with frame fobs color white/cyan overlay row 9
                      no-labels width 80 title "Observacoes".

    find pedid where recid(pedid) = vrec no-lock.
    
    create ttpedid.
    assign
        ttpedid.pedtdc    = pedid.pedtdc
        ttpedid.pednum    = pedid.pednum
        ttpedid.regcod    = pedid.regcod
        ttpedid.peddat    = pedid.peddat
        ttpedid.comcod    = pedid.comcod
        ttpedid.pedsit    = pedid.pedsit
        ttpedid.fobcif    = pedid.fobcif
        ttpedid.nfdes     = pedid.nfdes
        ttpedid.ipides    = pedid.ipides
        ttpedid.dupdes    = pedid.dupdes
        ttpedid.cusefe    = pedid.cusefe
        ttpedid.condes    = pedid.condes
        ttpedid.condat    = pedid.condat
        ttpedid.crecod    = pedid.crecod
        ttpedid.peddti    = pedid.peddti
        ttpedid.peddtf    = pedid.peddtf
        ttpedid.acrfin    = pedid.acrfin
        ttpedid.sitped    = pedid.sitped
        ttpedid.vencod    = pedid.vencod
        ttpedid.frecod    = pedid.frecod.

    assign
        ttpedid.modcod    = pedid.modcod
        ttpedid.etbcod    = pedid.etbcod
        ttpedid.pedtot    = pedid.pedtot
        ttpedid.clfcod    = pedid.clfcod
        ttpedid.pedobs[1] = pedid.pedobs[1]
        ttpedid.pedobs[2] = pedid.pedobs[2]
        ttpedid.pedobs[3] = pedid.pedobs[3]
        ttpedid.pedobs[4] = pedid.pedobs[4]
        ttpedid.pedobs[5] = pedid.pedobs[5].
    
    find estab where estab.etbcod = ttpedid.etbcod no-lock.

repeat:

    for each wf-lip.  delete wf-lip.  end.
    
    find forne where forne.forcod = ttpedid.clfcod no-lock no-error.
    
    display ttpedid.clfcod
            forne.fornom
            forne.forcgc
            forne.forinest
            forne.forrua
            forne.fornum
            forne.forcomp
            forne.formunic
            forne.ufecod
            forne.forcep
            forne.forfone with frame f-dialogo.
    
    update ttpedid.clfcod with frame f-dialogo.
    
    find forne where forne.forcod = ttpedid.clfcod no-lock no-error.
    
    display ttpedid.clfcod
            forne.fornom
            forne.forcgc
            forne.forinest
            forne.forrua
            forne.fornum
            forne.forcomp
            forne.formunic
            forne.ufecod
            forne.forcep
            forne.forfone with frame f-dialogo.
    
    update
        ttpedid.regcod with frame f-dialogo.
        
    find bestab where bestab.etbcod = ttpedid.regcod no-lock no-error.
    display bestab.etbnom with frame f-dialogo.

    vrepcod = ttpedid.vencod.
    
    update 
        vrepcod with frame f-dialogo no-validate.

    find repre where repre.repcod = vrepcod no-lock.
    display repre.repnom with frame f-dialogo.
    
    ttpedid.vencod = repre.repcod.
    pause 0.
    disp ttpedid.condat
         ttpedid.peddat  
         ttpedid.peddti
         ttpedid.peddtf with frame f-dialogo.
    pause 0.
    update ttpedid.condat
           /*ttpedid.peddat  corretiva 377639 */
           ttpedid.peddti
           ttpedid.peddtf with frame f-dialogo.
    
    do on error undo:
        update ttpedid.crecod  colon 18 label "Prazo de Pagto" format "9999"
                    with frame f-dialogo.
        find crepl where crepl.crecod = ttpedid.crecod no-lock no-error.
        display crepl.crenom no-label with frame f-dialogo.
    end.
    
    update ttpedid.comcod with frame f-dialogo no-validate.

    find func where func.etbcod = 990 and
                    func.funcod = ttpedid.comcod no-lock no-error.
    
    display func.funnom no-label with frame f-dialogo.
    
    update ttpedid.frecod
           ttpedid.fobcif
           ttpedid.condes
           ttpedid.nfdes
           ttpedid.dupdes
           ttpedid.ipides   
           ttpedid.acrfin
           with frame f-dialogo color white/cyan overlay row 6
                                side-labels centered.

    update
        ttpedid.pedobs[1] format "x(78)"
        ttpedid.pedobs[2] format "x(78)"
        ttpedid.pedobs[3] format "x(78)"
        ttpedid.pedobs[4] format "x(78)"
        ttpedid.pedobs[5] format "x(78)"
                 with frame fobs color white/cyan overlay row 9
                                no-labels width 80 title "Observacoes".

    for each liped of ttpedid no-lock.
        create wf-lip.
        assign wf-lip.lipqtd = liped.lipqtd
               wf-lip.procod = liped.procod
               wf-lip.lippre = liped.lippreco
               wf-lip.lipent = liped.lipent.
    end.
    
    repeat:
        hide frame f-exc no-pause.
        clear frame ff2 all no-pause.
    
        ttpedid.pedtot = 0.
        
        for each wf-lip,
            each produ where produ.procod = wf-lip.procod
                            no-lock by produ.pronom:
                            
            disp produ.procod
                 produ.pronom format "x(40)"
                 wf-lip.lippre @ vlippre
                 wf-lip.lipqtd @ vlipqtd format ">>>>9"
                 wf-lip.lipent @ vlipent format ">>>>9" with frame ff2.
            down with frame ff2.
            ttpedid.pedtot = ttpedid.pedtot + (wf-lip.lipqtd * wf-lip.lippre).
        end.

        display ttpedid.pedtot
                    with frame f-tot column 50 width 30 row 20 side-label
                                            color black/cyan no-box.
        prompt-for produ.procod
 help "F4 ou ESC  Encerra o pedido  [E] Exclui Produto [A] Qtd.Entr"
                go-on(F4 PF4 ESC e E A a)
                with no-validate frame ff2 width 80.
        /*
        vprocod = input produ.procod.
        */
        if keyfunction(lastkey) = "end-error" or
           keyfunction(lastkey) = "ESC" or
           lastkey = keycode("F4")
        then do:              
                for each wf-lip:
                    find produ where produ.procod = wf-lip.procod no-lock.
                    find first simil where simil.procod = produ.procod no-error.
                    if avail simil
                    then delete simil.      
                    find clase where clase.clacod = produ.clacod no-lock.
                    find liped where liped.etbcod = ttpedid.etbcod and
                                     liped.pedtdc = ttpedid.pedtdc and
                                     liped.pednum = ttpedid.pednum and
                                     liped.procod = produ.procod and
                                     liped.lipcor = ""           and
                                     liped.predt  = ttpedid.peddat 
                                     exclusive-lock no-error.
                    if not avail liped
                    then do:
                        create liped.
                        assign liped.pednum   = ttpedid.pednum
                               liped.pedtdc   = ttpedid.pedtdc
                               liped.predt    = ttpedid.peddat
                               liped.etbcod   = ttpedid.etbcod
                               liped.procod   = wf-lip.procod
                               liped.lippreco = wf-lip.lippre
                               liped.lipqtd   = wf-lip.lipqtd
                               liped.lipent   = wf-lip.lipent
                               liped.lipsit   = "A"
                               liped.protip   = if clase.claordem = yes
                                                then "M"
                                                else "C".
                    end.
                    else assign liped.lipqtd   = wf-lip.lipqtd
                                liped.lippreco = wf-lip.lippre
                                liped.lipent   = wf-lip.lipent
                                ttpedid.pedtot =
                                    (wf-lip.lipqtd * wf-lip.lippre).
                    if wf-lip.lipqtd = 0
                    then delete liped.
                end.
                
                totped = 0. totpen = 0.

                for each liped of ttpedid no-lock:
                    if liped.lipent = 0
                    then ttpedid.sitped = "A".
                end.
                
                for each liped of ttpedid no-lock:
                    if liped.lipent <> 0 
                    then ttpedid.sitped = "P".
                end.

                for each liped of ttpedid no-lock:
                    assign totped = totped + liped.lipqtd 
                           totpen = totpen + liped.lipent.
                end.

                if totped = totpen
                then ttpedid.sitped = "F".

                /*gravar pedid********/
                vrecped = recid(pedid).

        create table-raw.
        assign
            table-raw.char1 = string(pedid.pedtdc)
            table-raw.char2 = string(pedid.pednum).
        raw-transfer pedid to table-raw.registro1.
        run grava-tablog.p (input 1, input pedid.etbcod, input sfuncod,
                                    input recid(pedid), input "COM",
                                    input "pedid", input "ALTERA").

                find pedid where recid(pedid) = vrecped.
                
                assign  pedid.regcod    = ttpedid.regcod 
                        pedid.peddat    = ttpedid.peddat 
                        pedid.comcod    = ttpedid.comcod 
                        pedid.pedsit    = ttpedid.pedsit 
                        pedid.fobcif    = ttpedid.fobcif 
                        pedid.nfdes     = ttpedid.nfdes 
                        pedid.ipides    = ttpedid.ipides 
                        pedid.dupdes    = ttpedid.dupdes 
                        pedid.cusefe    = ttpedid.cusefe 
                        pedid.condes    = ttpedid.condes 
                        pedid.condat    = ttpedid.condat 
                        pedid.crecod    = ttpedid.crecod 
                        pedid.peddti    = ttpedid.peddti 
                        pedid.peddtf    = ttpedid.peddtf 
                        pedid.acrfin    = ttpedid.acrfin 
                        pedid.sitped    = ttpedid.sitped 
                        pedid.vencod    = ttpedid.vencod 
                        pedid.frecod    = ttpedid.frecod. 
                
                assign  pedid.modcod    = ttpedid.modcod 
                        pedid.pedtot    = ttpedid.pedtot 
                        pedid.clfcod    = ttpedid.clfcod 
                        pedid.pedobs[1] = ttpedid.pedobs[1] 
                        pedid.pedobs[2] = ttpedid.pedobs[2] 
                        pedid.pedobs[3] = ttpedid.pedobs[3] 
                        pedid.pedobs[4] = ttpedid.pedobs[4] 
                        pedid.pedobs[5] = ttpedid.pedobs[5].
                
                find pedid where recid(pedid) = vrecped no-lock.

         raw-transfer pedid to table-raw.registro2.
         run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(pedid), input "COM",
                                    input "pedid", input "ALTERA").

                /*********************/
                leave.
        end.
        
        if keyfunction(lastkey) = "A" or
           keyfunction(lastkey) = "a"
        then do:
            /* vlipent = 0. */
            update vprocod with frame f-ent side-label no-box width 81.
            find produ where produ.procod = vprocod no-lock no-error.
            if not avail produ
            then do:
                message "Produto nao Cadastrado".
                undo, retry.
            end.
            display produ.pronom no-label format "x(20)" with frame f-ent.
            find first wf-lip where wf-lip.procod = produ.procod no-error.
            if not avail wf-lip
            then do:
                message "Produto nao esta no Pedido".
                undo.
            end.
            else update vlipent label "Qtd"
                        vlippre label "Preco" with frame f-ent.

            assign wf-lip.lipent = input frame f-ent vlipent
                   wf-lip.lippre = input frame f-ent vlippre.
                   
            hide frame f-ent no-pause.
            clear frame ff2 all no-pause.
            
            for each wf-lip:
            
                find produ where produ.procod = wf-lip.procod no-lock.
                disp produ.procod
                     produ.pronom format "x(40)"
                     wf-lip.lippre @ vlippre
                     wf-lip.lipqtd @ vlipqtd format ">>>>9"
                     wf-lip.lipent @ vlipent format ">>>>9"
                           with frame ff2.
                    down with frame ff2.
                pause 0.
                ttpedid.pedtot = (wf-lip.lipqtd * wf-lip.lippre).
            end.
            next.
        end.

        if keyfunction(lastkey) = "E" or
           keyfunction(lastkey) = "e"
        then do:
            update vprocod with frame f-exc side-label no-box width 81.
            find produ where produ.procod = vprocod no-lock no-error.
            if not avail produ
            then do:
                message "Produto nao Cadastrado".
                undo, retry.
            end.
            display produ.pronom no-label format "x(20)" with frame f-exc.
            update vlippre column-label "Preco" with frame f-exc.
            find first wf-lip where wf-lip.procod = produ.procod no-error.
            if not avail wf-lip
            then do:
                message "Produto nao esta no Pedido".
                undo.
            end.
            else update vqtd label "Quant"
                        validate(vqtd <= wf-lip.lipqtd,
                                       "Quantidade Invalida") with frame f-exc.
            if vqtd = wf-lip.lipqtd
            then wf-lip.lipqtd = 0.
            else wf-lip.lipqtd = wf-lip.lipqtd - vqtd.
            wf-lip.lippre = vlippre.
            hide frame f-exc no-pause.
            clear frame ff2 all no-pause.
            for each wf-lip:
                find produ where produ.procod = wf-lip.procod no-lock.
                disp produ.procod
                     produ.pronom format "x(40)"
                     wf-lip.lippre @ vlippre
                     wf-lip.lipqtd @ vlipqtd format ">>>>9"
                     wf-lip.lipent @ vlipent format ">>>>9"
                           with frame ff2.
                    down with frame ff2.
                pause 0.
                ttpedid.pedtot = (wf-lip.lipqtd * wf-lip.lippre).
            end.
            next.
        end.
        vprocod = input produ.procod.
        if input produ.procod = 0
        then do on error undo:
            update vcatcod colon 18 with frame f-choo.
            find categoria where categoria.catcod = vcatcod no-lock.
            display categoria.catnom no-label with frame f-choo.
            
            DO ON ERROR UNDO:
                update vclacod colon 18
                       with frame f-choo centered width 80 side-label
                                            row 14 overlay color white/red.

                find first yclase where yclase.clasup = vclacod
                                        no-lock no-error.
                if avail yclase
                then do:
                    message "Classe Superior - Invalida para Cadastro".
                    undo.
                end.
            
                find clase where clase.clacod = vclacod no-lock no-error.
                display clase.clanom no-label with frame f-choo.
            END.
            
            update vfabcod colon 18
                    with frame f-choo.
    
            find fabri where fabri.fabcod = vfabcod no-lock no-error.
            display fabri.fabnom no-label with frame f-choo.

            update vpedpro colon 18
                help "[C] - Aciona Pesquisa por Nome"
                            go-on(C c return) with frame f-choo.
            
            if keyfunction(lastkey) = "C" or
               keyfunction(lastkey) = "c"
            then do:
                {zoomesq.i produ produ.procod pronom 50 Produtos
                                                   "produ.catcod = vcatcod and
                                                    produ.clacod = vclacod and
                                                    produ.fabcod = vfabcod"}
                 vpedpro = int(frame-value).
                 vprocod = int(frame-value).
            end.
            
            if keyfunction(lastkey) = "Return" and
               vpedpro = 0
            then do with frame fpro centered color white/red row 11 side-labels:
/***
                if vcatcod = 31 or vcatcod = 35
                then do:
                    find last bprodu where bprodu.procod >= 400000 and
                                           bprodu.procod <= 449999
                      exclusive-lock no-error.
                    if available bprodu
                    then assign vprocod = bprodu.procod + 1.
                    else assign vprocod = 400000.
                    find last bprodu no-lock.
                end.
                if vcatcod = 41 or vcatcod = 45
                then do:
                    find last bprodu where bprodu.procod >= 450000 and
                                           bprodu.procod <= 900000
                        exclusive-lock no-error.
                    if available bprodu
                    then assign vprocod = bprodu.procod + 1.
                    else assign vprocod = 450000.
                    find last bprodu no-lock.
                end.

                disp vprocod colon 15 skip(1).

                v-catcod = 0.
                v-clacod = 0.
                v-fabcod = 0.
                v-prorefter = "".
                v-pronom = "".
                v-pronomc = "".
                v-etccod = 0.
                
                v-catcod = vcatcod.
                update v-catcod colon 15 label "Departamento".
                find categoria where categoria.catcod = v-catcod
                                                        no-lock no-error.
                if avail categoria
                then disp categoria.catnom no-label.

                v-clacod = vclacod.
                update v-clacod colon 15 with no-validate .
                find clase where clase.clacod = v-clacod no-lock no-error.
                if avail clase
                then disp clase.clanom no-label.

                v-fabcod = vfabcod.
                update v-fabcod colon 15.
                find fabri where fabri.fabcod = v-fabcod no-lock no-error.
                if avail fabri
                then disp fabri.fabfant no-label.

                update v-prorefter colon 15 label "Ref.Terc.".

                v-pronom = clase.clanom + " " + fabri.fabfant
                                + " " + v-prorefter.

                update v-pronom colon 15 label "Descricao".

                v-pronom = CAPS(v-pronom).

                disp v-pronom.

                v-pronomc = substring(v-pronom,1,30).
        
                update v-pronomc colon 15 label "Desc.Abreviada"
                       format "x(30)".
                
                update v-etccod colon 15.
                find estac where estac.etccod = v-etccod no-lock no-error.
                if avail estac
                then disp estac.etcnom no-label.

                create produ.
                assign produ.procod = vprocod
                       produ.itecod = vprocod
                       produ.datexp = today
                       produ.catcod = vcatcod
                       produ.clacod = vclacod
                       produ.fabcod = vfabcod
                       produ.prouncom = "UN"
                       produ.prounven = "UN"
                       produ.procvcom = 1
                       produ.procvven = 1.

                produ.catcod = v-catcod.
                produ.clacod = v-clacod.
                produ.fabcod = v-fabcod.
                produ.prorefter = v-prorefter.
                produ.pronom = caps(v-pronom).
                produ.pronomc = v-pronomc.
                produ.etccod = v-etccod.
                
                produ.prozort = fabri.fabfant + "-" + produ.pronom.

                find produ where produ.procod = vprocod no-lock.

                do with frame fpre2 centered overlay color white/cyan
                                   side-labels row 15 .
                    assign vestmgoper = wempre.empmgoper
                           vestmgluc  = wempre.empmgluc.
                    update vestcusto  colon 20
                           vestmgoper colon 20
                           vestmgluc  colon 20.
                    vestvenda = (vestcusto *
                                (vestmgoper / 100 + 1)) *
                                (vestmgluc / 100 + 1).
                    update vestvenda colon 20.

                    for each estab:

                        create estoq.
                        assign estoq.etbcod    = estab.etbcod
                               estoq.procod    = produ.procod
                               estoq.estcusto  = vestcusto
                               estoq.estdtcus  = (if vestcusto <> estoq.estcusto
                                                  then today
                                                  else estoq.estdtcus)
                               estoq.estmgoper = vestmgoper
                               estoq.estmgluc  = vestmgluc
                               estoq.estvenda  = vestvenda
                               estoq.estdtven  = (if vestvenda <> estoq.estvenda
                                                  then today
                                                  else estoq.estdtven)
                               estoq.tabcod    = vtabcod
                               estoq.datexp    = today.

                    end.
                end.
***/
                /* leave */
            end.
        end.

        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao Cadastrado".
            undo, retry.
        end.
        display produ.procod
                produ.pronom format "x(40)" with frame ff2.
        update vlippre column-label "Preco" with frame ff2.
        update vlipqtd format ">>>>9" column-label "Qtd."
               validate (vlipqtd > 0, "Quantidade deve ser maior que zero")
               with frame ff2 9 down centered color blank/cyan.

        find first wf-lip where wf-lip.procod = produ.procod no-error.
        if not avail wf-lip
        then do:
            create wf-lip.
            assign wf-lip.procod = produ.procod
                   wf-lip.lipqtd = vlipqtd
                   wf-lip.lippre = vlippre
                   wf-lip.lipent = vlipent.
        end.
        else assign wf-lip.lipqtd = wf-lip.lipqtd + vlipqtd
                    wf-lip.lippre = vlippre.
        vlipqtd = 0.
        vlippre = 0.
    end.
    leave.
end.
