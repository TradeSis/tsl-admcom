{admcab.i}                                               
             
def new shared temp-table tt-for 
    field forcod like forne.forcod.
def var v-ok as log.    
def var vcusto as dec.
def var vacr as dec.
def buffer copcom for opcom.
def buffer eplani for plani.
def var vdatref as date.
def var vsittri as char format "x(03)".
def var valor_icms like plani.platot.
def var base_icms  like plani.platot.
def var visenta    like plani.isenta.
def var voutras    like plani.outras.
def var v-procod like produ.procod.
def var vobs like plani.notobs.
def buffer xestab for estab.
def var vdata   like plani.pladat.
def var vforcod like forne.forcod.
def var vetbcod like estab.etbcod.
def var vmovqtm   like  movim.movqtm.
def var vtrans    like  clien.clicod.
def var vsubtotal like  movim.movqtm.
def var vciccgc   like  clien.ciccgc.
def var valicota  like  plani.alicms format ">9,99".
def var vpladat   like  plani.pladat.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms.
def var base_icms_subst like plani.bsubst.
def var icms_subst      like plani.icmssubst.
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete.
def var vseguro   like  plani.seguro.
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vserie    like  plani.serie.
def var vnumant   like  plani.numero.
def var vtofcod   like  plani.hiccod label "Op.Fiscal" initial 532.
def var vserant   as char format "x(03)".
def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var vopccod   like  opcom.opccod.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotal      like plani.platot.
def buffer bestab for estab.
def buffer bplani for plani.
def var vsubst like plani.platot.

def new shared temp-table tt-plani
    field numero like plani.numero
    field subst  like plani.platot.
    

def  temp-table w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc format ">>9.9999"
               field movpc     as decimal format ">,>>9.99"
               field movalicms like movim.movalicms initial 12
               field movalipi  like movim.movalipi.
/** 
def new shared temp-table w-movim
    field redbas    as char format "x(01)"
    field movdat    like movim.movdat
    field numero    like plani.numero
    field marca     as char format "x(01)"
    field etbcod    like movim.etbcod
    field procod    like produ.procod
    field codfis    like clafis.codfis 
    field sittri    like clafis.sittri
    field movqtm    like movim.movqtm 
    field subtotal  like movim.movpc format ">>>,>>9.99" column-label "Subtot" 
    field movpc     like movim.movpc format ">,>>9.99" 
    field movalicms like movim.movalicms initial 17 
    field valicms   like movim.movicms
    field movicms   like movim.movicms
    field movicms2  like movim.movicms
    field movalipi  like movim.movalipi 
    field movipi    like movim.movipi
    field movfre    like movim.movpc 
    field movdes    as dec format ">,>>9.9999"
    field valdes    as dec format ">,>>9.9999"
        index ind-1 procod.
 
     
form produ.procod column-label "Codigo" format ">>>>>9"
     w-movim.movqtm format ">>>>>9" column-label "Qtd"
     w-movim.movpc  format ">>,>>9.99" column-label "Val.Unit."
     w-movim.subtotal  format ">>>,>>9.99" column-label "Subtot"
     w-movim.valdes format ">>,>>9.9999" column-label "Val.Desc"
     w-movim.movdes format ">9.9999" column-label "%Desc"
     w-movim.movalicms column-label "ICMS" format ">9.99"
     w-movim.movalipi  column-label "IPI"  format ">9.99"
     w-movim.movfre    column-label "Frete" format ">>>,>>9.99"
     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.
**/
form produ.procod
     produ.pronom format "x(30)"
     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
     w-movim.movpc  format ">,>>9.9999" column-label "V.Unit."
     w-movim.movalicms column-label "ICMS"
     w-movim.movalipi  column-label "IPI"
     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.


form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 6 no-box width 81.

form
    vetbcod label "Emitente" colon 17
    estab.etbnom no-label format "x(20)"
    vforcod label "Destinatario" colon 17
    forne.fornom  no-label
    vnumant label "Numero NF Origem" colon 17
    vserant label "Serie"  
    vopccod  label "Op. Fiscal" format "9999" colon 17 
    opcom.opcnom  no-label
    vdata         label "Data"      colon 17
    vpladat       colon 17
      with frame f1 side-label color white/cyan width 80 row 4.

def var vachou-nf as log.
repeat:
    
    for each tt-plani:
        delete tt-plani.
    end.    
        

    for each w-movim:
        delete w-movim.
    end.
    for each tt-for.
        delete tt-for.
    end.
    clear frame f1 all no-pause.
    clear frame f2 all no-pause.
    clear frame f-produ all no-pause.
    clear frame f-produ1 all no-pause.
    clear frame f-produ2 all no-pause.
    clear frame f-exclusao all no-pause.
    hide frame f1 no-pause.
    hide frame f2 no-pause.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f-produ2 no-pause.
    hide frame f-exclusao no-pause.

    update vetbcod with frame f1.
    {valetbnf.i estab vetbcod ""Emitente""}
    display estab.etbnom with frame f1.
    
    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message "fornecedor nao cadastrado".
        undo, retry.
    end.
    display forne.fornom no-label with frame f1.
    if forne.ativo = no
    then do:
        message "Fornecedor Desativado".
        pause.
        undo, retry.
    end.        
    pause 0.
    if forne.forcod = 100725 or
       forne.forcod = 110034
    then do:

        create tt-for.
        assign tt-for.forcod = 100725.
        create tt-for.
        assign tt-for.forcod = 110034.
        

    end.
    else if forne.forcod = 104666 or
            forne.forcod = 110267
    then do:
        create tt-for.
        assign tt-for.forcod = 104666.
        create tt-for.
        assign tt-for.forcod = 110267.
    end.
    else do:
       
        create tt-for.
        assign tt-for.forcod = forne.forcod.
        
    end.
    
    clear frame f-produ1 no-pause.
    bl-princ:
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4
                            F10 E e C c) with frame f-produ.

        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = yes.
            message "Confirma Geracao de Nota Fiscal" update sresp.
            if not sresp
            then do:
                for each w-movim:
                    delete w-movim.
                end.
                vprocod = 0.
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
                undo, return.
            end.
            else leave.
        end.
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock.
                disp produ.procod
                     produ.pronom format "x(30)"
                     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                     w-movim.movalicms column-label "ICMS"
                     w-movim.movalipi  column-label "IPI"
                     /*
                     w-movim.subtotal
                            format ">>,>>9.99" column-label "Total" */
                            with frame f-produ2 row 5 9 down  overlay
                              centered color message width 80.
                down with frame f-produ2.
                pause 0.
            end.
            pause.
            undo.
        end.
        if lastkey = keycode("e") or lastkey = keycode("E")
        then do:
            update v-procod
                   with frame f-exclusao row 6 overlay side-label centered
                   width 80 color message no-box.
            find produ where produ.procod = v-procod no-lock no-error.
            if not avail produ
            then do:
                message "Produto nao Cadastrado".
                undo.
            end.
            find first w-movim where w-movim.wrec = recid(produ) no-error.
            if not avail w-movim
            then do:
                message "Produto nao pertence a esta nota".
                undo.
            end.
            display produ.pronom format "x(35)" no-label with frame f-exclusao.
            if w-movim.movqtm <> 1
            then update vqtd validate( vqtd <= w-movim.movqtm,
                                       "Quantidade invalida" )
                        label "Qtd" with frame f-exclusao.
            else do:
                vqtd = 1.
                display vqtd with frame f-exclusao.
            end.
            find first w-movim where w-movim.wrec = recid(produ) no-error.
            if avail w-movim
            then do:
                if w-movim.movqtm = vqtd
                then do:
                    delete w-movim.
                end.
                else w-movim.movqtm = w-movim.movqtm - vqtd.
                hide frame f-exclusao no-pause.
            end.
            vprotot = 0.
            clear frame f-produ1 all no-pause.
            for each w-movim with frame f-produ1:
                find produ where recid(produ) = wrec no-lock.
                display produ.procod
                        produ.pronom
                        w-movim.movqtm
                        w-movim.movpc
                        w-movim.movalicms
                        w-movim.movalipi
                        with frame f-produ1.
                down with frame f-produ1.
                pause 0.
                vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
                display vprotot with frame f-produ.
            end.
            next.
        end.
        vant = no.
            find produ where produ.procod = input vprocod no-lock no-error.
            if not avail produ
            then do transaction:
                message "Produto nao Cadastrado".
                /***
                vresp = yes.
                message "Deseja Cadastrar ? " update vresp.
                if not vresp
                then undo.
                else do
                    with frame f-altera
                    row 10  centered OVERLAY SIDE-LABELS color black/cyan:

                    disp vopcao no-label with frame f-escolha
                        centered side-label overlay row 8.
                    choose field vopcao with frame f-escolha.

                    do :
                        if frame-index = 1
                        then do:
                            find last cprodu where cprodu.procod >= 400000 and
                                                   cprodu.procod <= 449999
                                exclusive-lock no-error.
                            if available cprodu
                            then assign vprocod = cprodu.procod + 1.
                            else assign vprocod = 400000.
                        end.
                        if frame-index = 2
                        then do:
                            find last cprodu where cprodu.procod >= 450000 and
                                                   cprodu.procod <= 900000
                                exclusive-lock no-error.
                            if available cprodu
                            then assign vprocod = cprodu.procod + 1.
                            else assign vprocod = 450000.
                        end.
                    end.

                    create produ.
                    assign produ.procod = vprocod
                           produ.itecod = vprocod
                           produ.datexp = today
                           produ.fabcod = forne.forcod.

                    disp produ.procod colon 15.
                    update produ.pronom colon 15 label "Descricao".
                    update produ.protam colon 15 label "Tamanho".
                    update produ.corcod colon 50 label "Cor".
                    find cor where cor.corcod = produ.corcod.
                    display cor.cornom no-label format "x(20)".
                    update produ.catcod colon 15 label "Departamento".
                    find categoria where categoria.catcod = produ.catcod.
                    disp categoria.catnom no-label.
                    produ.pronom = produ.pronom + " " + produ.protam
                                    + " " + produ.corcod.
                    produ.pronomc = produ.pronom.
                    update produ.fabcod colon 15.
                    find fabri where fabri.fabcod = produ.fabcod.
                    display fabri.fabfant no-label format "x(20)".
                    update produ.prorefter colon 50 label "Ref.".
                    update produ.clacod colon 15 with no-validate .
                    find clase where clase.clacod = produ.clacod no-error.
                    if avail clase
                    then display clase.clanom no-label format "x(20)".
                    update produ.etccod colon 50.
                    find estac where estac.etccod = produ.etccod.
                    display estac.etcnom no-label.
                    update produ.fabcod colon 15.
                    find fabri where fabri.fabcod = produ.fabcod no-lock.
                    disp fabri.fabnom no-label.
                    produ.proipiper = 18.
                    update produ.prouncom colon 15
                           produ.prounven colon 50
                           produ.procvcom colon 15
                           produ.procvven colon 50
                           produ.proipiper colon 15 label "Aliq.Icms"
                           produ.proclafis colon 50
                           WITH OVERLAY SIDE-LABELS .

                    produ.prozort = fabri.fabfant + "-" + produ.pronom.

                    do with frame fpre centered overlay color white/red
                                       side-labels row 15 .

                        assign vestmgoper = wempre.empmgoper
                               vestmgluc  = wempre.empmgluc.
                        update vestcusto  colon 20
                               vestmgoper colon 20
                               vestmgluc  colon 20.
                        vestvenda = (vestcusto *
                                    (vestmgoper / 100 + 1)) *
                                    (vestmgluc / 100 + 1).
                        update /*vtabcod colon 20*/
                               vestvenda colon 20.

                        for each estab no-lock:

                            create estoq.
                            assign estoq.etbcod    = estab.etbcod
                                   estoq.procod    = produ.procod
                                   estoq.estcusto  = vestcusto
                                   estoq.estmgoper = vestmgoper
                                   estoq.estmgluc  = vestmgluc
                                   estoq.estvenda  = vestvenda
                                   estoq.tabcod    = vtabcod
                                   estoq.datexp    = today.

                        end.
                    end.
                end.
                **/
            end.



        else vant = yes.
        display  produ.pronom with frame f-produ.
        find estoq where estoq.etbcod = 999 and
                         estoq.procod = produ.procod no-lock no-error.

        if not available estoq
        then do:
            bell.
            message "Produto Sem Registro de Armazenagem".
            pause.
            undo.
        end.

        display  produ.pronom with frame f-produ.
        display produ.pronom with frame f-produ1.

        vmovqtm = 0.
        vsubtotal = 0.
        find first w-movim where w-movim.wrec = recid(produ) no-lock no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ).
        end.

        vmovqtm = w-movim.movqtm.
        update  w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        w-movim.movpc = estoq.estCUSTO.
        w-movim.movqtm = VMOVQTM + w-movim.movqtm.
        display w-movim.movqtm with frame f-produ1.
        update w-movim.movpc with frame f-produ1.
        w-movim.movalicms = 12.
        update  w-movim.movalicms
                w-movim.movalipi
                    with frame f-produ1.
        vcusto = w-movim.movpc.
        if vbicms <> 0
        then do:
            vcusto = vcusto +
                (w-movim.movpc * ((vbicms / (vbicms - vacr)) - 1)).
        end.

        vprotot = 0.
        w-movim.subtotal = w-movim.movqtm * (((w-movim.movpc * w-movim.movalipi)
                                              / 100) + w-movim.movpc).
        /*update  w-movim.subtotal validate(w-movim.subtotal > 0,
                         "Total dos Produtos Invalido")  with frame f-produ1.*/
        clear frame f-produ1 all no-pause.


        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.movpc
                    w-movim.movalicms
                    w-movim.movalipi
                            with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
            display vprotot with frame f-produ.
        end.
    end.
    if not sresp
    then undo, retry.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f2 no-pause.
    if v-ok = yes
    then undo, leave.

     /****
    do on error undo, retry:
        vserant = "U".
        update vnumant 
               vserant label "Serie" with frame f1.
        
        vachou-nf = no.    
        for each tt-for:

            find plani where plani.emite  = tt-for.forcod and
                             plani.etbcod = estab.etbcod and
                             plani.movtdc = 4            and
                             plani.serie  = vserant      and
                             plani.numero = vnumant no-lock no-error.
            if not avail plani
            then do:
                if estab.etbcod = 995
                then do:
                    find plani where plani.emite  = tt-for.forcod and
                                     plani.etbcod = 998           and
                                     plani.movtdc = 4            and
                                     plani.serie  = vserant      and
                                     plani.numero = vnumant no-lock no-error.
                    if not avail plani
                    then. /* do:
                        message "Nota Fiscal de Compra nao encontrada".
                        pause .
                        undo, retry.
                    end. */
                    else vachou-nf = yes.
                end.
                else
                if estab.etbcod = 998
                then do:
                    find plani where plani.emite  = tt-for.forcod and
                                     plani.etbcod = 995           and
                                     plani.movtdc = 4            and
                                     plani.serie  = vserant      and
                                     plani.numero = vnumant no-lock no-error.
                    if not avail plani
                    then do:
                        find plani where plani.emite  = tt-for.forcod and
                                         plani.etbcod = 993           and
                                         plani.movtdc = 4            and
                                         plani.serie  = vserant      and
                                         plani.numero = vnumant no-lock
                                         no-error.
                        if not avail plani
                        then. /* do:
                            message "Nota Fiscal de Compra nao encontrada".
                            pause .
                            undo, retry.
                        end.*/
                        else vachou-nf = yes.                            
                    end.
                end.
            end.
            if avail plani
            then leave. 
        end.

        if not avail plani
        then do:
            message "Nota Fiscal de Compra nao encontrada".
            pause .
            undo, retry.
        end.
        vdatref = plani.pladat.
        find first tt-plani where tt-plani.numero = plani.numero no-error. 
        if not avail tt-plani 
        then do: 
            create tt-plani.  
            assign tt-plani.numero = plani.numero
                   tt-plani.subst  = plani.icmssubst.
        end.
        
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
                             
            find first w-movim where w-movim.etbcod = movim.etbcod and
                                     w-movim.procod = movim.procod no-error.
            if not avail w-movim 
            then do:  
                create w-movim. 
                assign w-movim.etbcod    = movim.etbcod 
                       w-movim.movdat    = movim.datexp
                       w-movim.numero    = plani.numero
                       w-movim.procod    = movim.procod 
                       w-movim.movqtm    = movim.movqtm  
                       w-movim.subtotal  = (movim.movpc * movim.movqtm) 
                       w-movim.movpc     = movim.movpc  
                       w-movim.movalicms = movim.movalicms
                       w-movim.valicms   = movim.movicms 
                       w-movim.movalipi  = movim.movalipi   
                       w-movim.movipi    = movim.movipi 
                       w-movim.movdes    = movim.movpdes  
                       w-movim.valdes    = movim.movdes.
            end.

        end.                     
        
    
    end.
    ***/
    /************************************************/
    find tipmov where tipmov.movtdc = 31 no-lock.
    vserie = "U".

    if forne.ufecod = "RS"
    then find first opcom where opcom.opccod = "5202" no-lock.
    else find last opcom where opcom.opccod = "6202"  no-lock.
    
    vopccod = opcom.opccod.


    display vopccod
            opcom.opcnom with frame f1.


    update vdata 
           vpladat with frame f1. 

    hide frame f2 no-pause.  
    /*    
    run tt-devcom.p(input forne.forcod,
                    input vetbcod).       
    */
    
    vipi    = 0.
    /*
    if vipi > 0 
    then vobs[1] = vobs[1] +  " VALOR IPI: " +  string(vipi,">>,>>9.99"). 
    */
    vsubst = 0.
    for each tt-plani:
        vsubst = vsubst + tt-plani.subst.
    end.
    
    pause 0.

    find first w-movim where w-movim.movqtm > 0 no-error.
    if not avail w-movim
    then do:
        message color red/with
        "Favor incluir os itens."
        view-as alert-box.
        undo, return.
    end.
    message "Confirma nota fiscal" update sresp.
    if sresp = no
    then undo, return.
    
    
    vprotot = 0.
    vplatot = 0.
    vbicms  = 0.
    vicms   = 0.
    vipi    = 0.
    vdescpro = 0.

    for each w-movim  :
    
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        if not avail produ
        then next.
        run trata_cfop.p (input opcom.opccod,  
                          input produ.procod, 
                          input (w-movim.movpc *
                                    w-movim.movqtm),
                          input w-movim.movalicms,    
                          input ((w-movim.movqtm * w-movim.movpc) * (w-movim.movalicms / 100)),    
                          input 0, 
                          output base_icms,   
                          output visenta,   
                          output voutras,   
                          output vsittri, 
                          output valor_icms).
                           
        vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
        
        vbicms  = vbicms  + base_icms.
        
        vicms   = vicms   + valor_icms.

        vipi    = vipi    + ((w-movim.movqtm * w-movim.movpc) *
                             (w-movim.movalipi / 100)).
        vdescpro = 0.
    end.
    /*
    update base_icms_subst label "Base Icms Subst." format ">>>,>>9.99"
           icms_subst label "Icms Substituicao"     format ">>>,>>9.99"
           vfrete     label "Frete"                 format ">>>,>>9.99"
               with frame f22 side-label color white/cyan.
    */
    vplatot = vprotot + vfrete - vdescpro.
    vbicms = vprotot - vdescpro.
    if vbicms > vplatot
    then vbicms = vplatot.
    
    if forne.forcod = 100725
    then vprotot = vprotot - vdescpro.
    /*
    if vsubst > 0 
    then vobs[1] = vobs[1] +  " VALOR ICMS SUBS. TRBT. " 
                   +  string(vsubst).
    */
    pause 0.
    
    if vbicms <= 0
    then update vbicms format ">>>,>>>,>>9.99" with frame f-obs.
    /*
    update vobs[1] no-label
           vobs[2] no-label
           vobs[3] no-label 
                with frame f-obs centered title "Observacoes".
    */
    /*****************/
    def var vorigem as char.
    vobs[1] = "Nota Fiscal emitida nos termos do art.3º   " .
    vobs[2] = "do Decreto nº 6.825, de 17 de abril de 2009.".

    disp vobs[1] at 1 label "Obs" format "x(45)"
     vobs[2] at 6 no-label    format "x(45)"
     with frame f-origem.
     
    repeat on endkey undo:
        update vorigem at 6 label "NF ORIGEM: "  format "x(35)"
        with frame f-origem 1 down
        centered row 10 side-label overlay.
        leave.
    end.    

    vobs[3] = "NF ORIGEM: " + vorigem.
    /******************/

    /*message "Confirma nota fiscal" update sresp.
    if sresp
    then*/ do:
    
    find last plani use-index numero where
                          plani.etbcod = estab.etbcod and
                          plani.emite  = estab.etbcod and
                          plani.serie  = "U" and
                          plani.movtdc <> 4  and
                          plani.movtdc <> 5 /*no-lock*/ no-error.
    if not avail plani
    then vnumero = 1.
    else vnumero = plani.numero + 1.
    
    if estab.etbcod = 998 or
       estab.etbcod = 993 
    then do: 
        vnumero = 0.
        for each xestab where xestab.etbcod = 998 or
                              xestab.etbcod = 993 no-lock,
                                 
            last plani use-index numero 
                    where plani.etbcod = xestab.etbcod and
                          plani.emite  = xestab.etbcod and
                          plani.serie  = "u"          and
                          plani.movtdc <> 4           and
                          plani.movtdc <> 5           and
                 /*         plani.numero < 100000       and  */
                          plani.pladat >= 12/01/2006  /*no-lock*/ .
                      
            if not avail plani 
            then vnumero = 1. 
            else do: 
                if vnumero < plani.numero
                then vnumero = plani.numero.
            end.    
        

        end.
        
        if vnumero = 1
        then.
        else vnumero = vnumero + 1.

    end.   
    {valnumnf.i vnumero}

    find last bplani where bplani.etbcod = estab.etbcod and
                                   bplani.placod <= 500000 and
                                   bplani.placod <> ? no-lock no-error.
    if not avail bplani
    then vplacod =  1. 
    else vplacod = bplani.placod + 1.
    
    do on error undo:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.placod   = vplacod
               plani.protot   = vprotot 
               plani.desti    = forne.forcod
               plani.bicms    = vbicms
               plani.icms     = vicms
               plani.bsubst   = base_icms_subst
               plani.icmssubst = icms_subst
               plani.descpro  = vdescpro
               plani.acfprod  = vacfprod
               plani.frete    = vfrete
               plani.seguro   = vseguro
               plani.desacess = vdesacess
               plani.ipi      = vipi
               plani.platot   = vplatot + vipi 
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = tipmov.movtdc
               plani.emite    = estab.etbcod
               plani.pladat   = vpladat
               plani.modcod   = tipmov.modcod
               plani.opccod   = int(opcom.opccod)
               plani.notfat   = estab.etbcod
               plani.dtinclu  = today
               plani.horincl  = time
               plani.notsit   = no
               plani.nottran  = vtrans
               plani.dtinclu  = vdata
               plani.notobs[1] = vobs[1]
               plani.notobs[2] = vobs[2]
               plani.notobs[3] = vobs[3]
               plani.hiccod   = int(opcom.opccod)
               plani.outras = plani.frete  +
                              plani.seguro +
                              plani.vlserv +
                              plani.desacess +
                              plani.ipi   +
                              plani.icmssubst
               plani.isenta = plani.platot - plani.outras - plani.bicms.
    end.

    for each w-movim :
        find produ where recid(produ) = w-movim.wrec no-lock no-error .
        if not avail produ
        then next.
        vmovseq = vmovseq + 1.

        create movim.
        ASSIGN movim.movtdc = plani.movtdc
               movim.PlaCod = plani.placod
               movim.etbcod = plani.etbcod
               movim.movseq = vmovseq
               movim.procod = produ.procod
               movim.movqtm = w-movim.movqtm
               movim.movpc  = w-movim.movpc
               movim.MovAlICMS = w-movim.movalicms
               movim.movicms   = ((w-movim.movpc * w-movim.movqtm )
                                 * (w-movim.movalicms / 100))
               movim.MovAlIPI  = w-movim.movalipi
               movim.movipi    = ((w-movim.movpc * w-movim.movqtm)
                                 * (w-movim.movalipi / 100))
               movim.movdes    = 0
               movim.movdat    = plani.pladat
               movim.MovHr     = int(time)
               movim.desti     = plani.desti
               movim.emite     = plani.emite.
       /**        
        run atuest.p (input recid(movim),
                      input "I",
                      input 0).
       **/               
    end.
    end.
    sresp = no.
    message "Imprimir Nota Fiscal ? " update sresp.
    if sresp
    then do:
        message color red/with
        "Prepare a impressora..."
        view-as alert-box.
        
        run impdvcom.p (input recid(plani)).
    end.
end.
