{admcab.i}                       

/* compatib.com modulo AT */
def input parameter par-rec as recid.

find etiqseq where recid(etiqseq) = par-rec no-lock no-error.

def shared temp-table wfasstec like asstec.
def new shared temp-table tt-etiqpla
    field oscod     like etiqpla.oscod
    field etopeseq  like etiqpla.etopeseq
    field etmovcod  like etiqpla.etmovcod.
def var vassistencia as log.
def var vachou-prod  as log.
find first wfasstec no-lock no-error.
vassistencia = avail wfasstec.
/* */
        
def new shared temp-table tt-for 
    field forcod like forne.forcod.
def new shared temp-table tt-nfref like plani.    
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimaux like movimaux.
def var v-bred as dec.
def var nfe-emite like plani.emite.

def buffer copcom for opcom.
def buffer eplani for plani.
def var vdatref as date.
def var vsittri as char format "x(03)".
def var valor_icms like plani.platot.
def var base_icms  like plani.platot.
def var visenta    like plani.isenta.
def var voutras    like plani.outras.
def var v-procod   like produ.procod.
def var vobs-os    as char.
def var vobs       as char extent 9 format "x(70)".
def buffer xestab for estab.
def var vforcod like forne.forcod.
def var vetbcod like estab.etbcod.
def var vmovqtm   like  movim.movqtm.
def var vtrans    like  clien.clicod.
def var vsubtotal like  movim.movqtm.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms.
def var base_icms_subst like plani.bsubst.
def var icms_subst      like plani.icmssubst.
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vprodfrete   as decimal.
def var vfrete    like  plani.frete.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vserie    like  plani.serie.
def var vnumant   like  plani.numero format "9999999".
def var vserant   as char format "x(03)".
def var vprocod   like  produ.procod.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var vopccod     like opcom.opccod.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotal      like plani.platot.
def buffer bestab for estab.
def buffer bplani for plani.
def var vsubst like plani.platot.

def new shared temp-table tt-plani1
    field numero like plani.numero
    field subst  like plani.platot.
    
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
    field movalpis  as dec
    field movpis    as dec
    field movalcofins  as dec
    field movcofins    as dec
    field movcstpiscof as dec
    field movbpiscof   as dec
    field chave        as char
    field movcsticms   as char
    field movbicms     as dec
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

form w-movim.procod      label "Codigo"
     produ.pronom  no-label format "x(25)"
         with frame f-produ centered color message side-label
                        row 14 no-box width 81 overlay.

form
    vetbcod label "Emitente" colon 17
    estab.etbnom no-label format "x(20)"
    vforcod label "Destinatario" colon 17
    forne.fornom  no-label
    vnumant label "Numero NF Origem" format ">>>>>>9" colon 17
    vserant label "Serie"  
    vopccod  label "Op. Fiscal" format "9999" colon 17 
    opcom.opcnom  no-label
    with frame f1 side-label color white/cyan width 80 row 3.

def var vchave-nfe as char.

repeat:

    for each tt-plani1: delete tt-plani1. end.    
    for each tt-nfref: delete tt-nfref. end.
    for each w-movim: delete w-movim. end.
    for each tt-for. delete tt-for. end.
    vchave-nfe = "".
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

    if vassistencia
    then vetbcod = setbcod.
    else update vetbcod with frame f1.
    {valetbnf.i estab vetbcod ""Emitente""}
    display vetbcod estab.etbnom with frame f1.

    if vassistencia = no and (vetbcod = 988 or vetbcod = 998)
    then do:
        message "Realize a operacao no modulo SSC".
        pause.
        undo, retry.
    end.
    
    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message "fornecedor nao cadastrado".
        undo, retry.
    end.
    display forne.fornom no-label with frame f1.
    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo, retry.

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
    
    do on error undo, retry:
        vserant = "U".
        update vnumant format ">>>>>>>>>9"
               vserant label "Serie" with frame f1.
        
        for each tt-for:

            find plani where plani.emite  = tt-for.forcod and
                             plani.etbcod = estab.etbcod and
                             plani.movtdc = 4            and
                             plani.serie  = vserant      and
                             plani.numero = vnumant no-lock no-error.
            if not avail plani
            then do:
                if estab.etbcod = 995 or estab.etbcod = 900
                then
                    find plani where plani.emite  = tt-for.forcod and
                                     plani.etbcod = 998           and
                                     plani.movtdc = 4            and
                                     plani.serie  = vserant      and
                                     plani.numero = vnumant no-lock no-error.
                else
                if estab.etbcod = 998 or
                   estab.etbcod = 930
                then do:
                    find plani where plani.emite  = tt-for.forcod and
                                     plani.etbcod = 995           and
                                     plani.movtdc = 4            and
                                     plani.serie  = vserant      and
                                     plani.numero = vnumant no-lock no-error.
                    if not avail plani
                    then do.
                        find plani where plani.emite  = tt-for.forcod and
                                         plani.etbcod = 900           and
                                         plani.movtdc = 4            and
                                         plani.serie  = vserant      and
                                         plani.numero = vnumant
                                         no-lock no-error.
                        if not avail plani
                        then
                        find plani where plani.emite  = tt-for.forcod and
                                         plani.etbcod = 993           and
                                         plani.movtdc = 4            and
                                         plani.serie  = vserant      and
                                         plani.numero = vnumant
                                         no-lock no-error.
                        if not avail plani
                        then 
                            find plani where plani.emite  = tt-for.forcod and
                                         plani.etbcod = 996          and
                                         plani.movtdc = 4            and
                                         plani.serie  = vserant      and
                                         plani.numero = vnumant
                                         no-lock no-error.
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
        if plani.bsubst > 0
        then do:
            message color red/with 
            "Nota Fiscal DEVOLUÇÃO com ST emissão em outro menu."
            view-as alert-box.
            undo, retry.
        end.

        vchave-nfe = plani.ufdes.
        find first I01_prod where
                   I01_prod.chave = vchave-nfe no-lock no-error.
        if not avail I01_prod
        then do:      
            sresp = no. 
            run chama_ws_notamax_recebimento.p
                            (vetbcod, vchave-nfe, output sresp).
            pause.
        end.

        vachou-prod = no.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
            if vassistencia
            then do.
                find first wfasstec where wfasstec.procod = movim.procod
                        no-lock no-error.
                if not avail wfasstec
                then next.
            end.
            vachou-prod = yes.

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
                       w-movim.subtotal  = movim.movpc * movim.movqtm
                       w-movim.movpc     = movim.movpc
                       w-movim.movalicms = movim.movalicms
                       w-movim.valicms   = movim.movicms / movim.movqtm 
                       w-movim.movalipi  = movim.movalipi   
                       w-movim.movipi    = movim.movipi 
                       w-movim.movdes    = movim.movpdes  
                       w-movim.valdes    = movim.movdes
                       w-movim.movfre    = movim.movdev
                       w-movim.chave     = plani.ufdes
                       w-movim.movalpis  = movim.movalpis
                       w-movim.movpis    = movim.movpis / movim.movqtm
                       w-movim.movalcofins = movim.movalcofins
                       w-movim.movcofins   = movim.movcofins / movim.movqtm 
                       w-movim.movcstpiscof = movim.movcstpiscof
                       w-movim.movbpiscof   = movim.movbpiscof / movim.movqtm
                       w-movim.movcsticms   = movim.movcsticms
                       w-movim.movbicms     = movim.movbicms / movim.movqtm
                       w-movim.sittri = 090
                       .
                      
                find first I01_prod where
                           I01_prod.chave  = plani.ufdes and
                           I01_prod.procod = movim.procod
                           no-lock no-error.
                if avail I01_prod 
                then do:
                    if I01_prod.Vfrete > 0
                    then.  
                    else w-movim.movfre = 0.
                end.
                
                find first n01_icms where n01_icms.chave = plani.ufdes and
                           n01_icms.nitem = movim.movseq
                           no-lock no-error.
                if avail n01_icms
                then assign
                          w-movim.chave = n01_icms.chave
                          w-movim.movcsticms = string(n01_icms.cst)
                          .

                            
            end.
        end.

        if not vachou-prod
        then do.
            message "Sem produtos para esta NF de compra".
            undo.
        end.
        vdatref = plani.pladat.
        find first tt-plani1 where tt-plani1.numero = plani.numero no-error. 
        if not avail tt-plani1 
        then do: 
            create tt-plani1.  
            assign tt-plani1.numero = plani.numero
                   tt-plani1.subst  = plani.icmssubst.
            create tt-nfref.
            buffer-copy plani to tt-nfref.
        end.
    end.
    
    /************************************************/
    find tipmov where tipmov.movtdc = 13 no-lock.
    if vetbcod = 995 or
       vetbcod = 993 or
       vetbcod = 996 or
       vetbcod = 998 or
       vetbcod = 999 or
       vetbcod = 900
    then vserie = "1".
    else vserie = "U".

    if forne.ufecod = "RS"
    then find first opcom where opcom.opccod = "5202" no-lock.
    else find last opcom where opcom.opccod = "6202"  no-lock.
    
    vopccod = opcom.opccod.
    display vopccod
            opcom.opcnom with frame f1.
    /*
    update base_icms_subst label "Base Icms Subst." format ">>>,>>9.99"
           icms_subst label "Icms Substituicao"     format ">>>,>>9.99"
           vfrete     label "Frete"                 format ">>>,>>9.99"
           with frame f2 side-label color white/cyan.
    */
    
    hide frame f2 no-pause.  
        
    run tt-devcom.p(input forne.forcod,
                    input vetbcod,
                    vassistencia).

    vobs[1] = "NF ORIGINAL: ".
    for each tt-plani1 by tt-plani1.numero:
        vobs[1] = vobs[1] + string(tt-plani1.numero) + ",".
    end.

    vipi    = 0.
    for each w-movim where w-movim.marca = "*":
    
        vipi    = vipi    + ((w-movim.movqtm * w-movim.movpc) *
                             (w-movim.movalipi / 100)).
        
        /* Soma o frete do item no valor de IPI */
        vipi    = vipi    + ((w-movim.movqtm * w-movim.movfre) *
                             (w-movim.movalipi / 100)).
                                     
        vfrete = vfrete + (w-movim.movqtm * w-movim.movfre).
    end.
    
    if vipi > 0 
    then vobs[1] = vobs[1] +  " VALOR IPI: " +  string(vipi,">>,>>9.99"). 
    
    if vfrete > 0
    then vobs[1] = vobs[1] +  " VALOR FRETE: " +  string(vfrete,">>,>>9.99").

    vsubst = 0.
    for each tt-plani1:
        vsubst = vsubst + tt-plani1.subst.
    end.
    
    pause 0.

    message "confirma nota fiscal" update sresp.
    if sresp = no
    then undo, return.

    find first w-movim where w-movim.marca = "*" no-error.
    if not avail w-movim
    then undo, retry.
    
    vprotot = 0.
    vplatot = 0.
    vbicms  = 0.
    vicms   = 0.
    vipi    = 0.
    vdescpro = 0.

    for each w-movim where w-movim.marca = "*":
    
        run trata_cfop.p (input opcom.opccod,  
                          input w-movim.procod, 
                          input ((w-movim.movpc - w-movim.valdes) *
                                    w-movim.movqtm),
                          input w-movim.movalicms,    
                          input w-movim.valicms,    
                          input 0, 
                          output base_icms,   
                          output visenta,   
                          output voutras,   
                          output vsittri, 
                          output valor_icms).
                           
        vprodfrete = vprodfrete + (w-movim.movfre * w-movim.movqtm).
        vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
        vbicms  = vbicms  + base_icms + (w-movim.movfre * w-movim.movqtm).
        vicms   = vicms   + valor_icms .
        w-movim.valicms = valor_icms
                          + (((w-movim.movfre * w-movim.movqtm) *
                          w-movim.movalicms) / 100).
        vipi    = vipi    + ((w-movim.movqtm * w-movim.movpc) *
                             (w-movim.movalipi / 100)).

        /* Soma o frete do item no valor de IPI */
        vipi    = vipi    + ((w-movim.movqtm * w-movim.movfre) *
                             (w-movim.movalipi / 100)).

        vdescpro = vdescpro + (w-movim.movqtm * w-movim.valdes).
    end.
    
    vplatot = vprotot + vfrete - vdescpro.
    vbicms = vprotot - vdescpro.
    if vbicms > vplatot
    then vbicms = vplatot.
    
    assign vbicms = vbicms + vfrete.

    if forne.forcod = 100725
    then vprotot = vprotot - vdescpro.
    
    if vsubst > 0 
    then vobs[1] = vobs[1] +  " VALOR ICMS SUBS. TRBT. " + string(vsubst).
    
    pause 0.
    
    if vbicms <= 0
    then update vbicms format ">>>,>>9.99" with frame f-obs.
    
    update vobs[1] no-label
           vobs[2] no-label
           vobs[3] no-label 
           vobs[4] no-label
           vobs[5] no-label
           vobs[6] no-label 
/***
           vobs[7] no-label
           vobs[8] no-label
           vobs[9] no-label 
***/
           with frame f-obs centered title "Observacoes".

/***
    if vetbcod <> 995 and
       vetbcod <> 993 and
       vetbcod <> 996 and
       vetbcod <> 998 and
       vetbcod <> 999 and
       vetbcod <> 900
    then do: 
        message "Confirma impressao da nota fiscal" update sresp.
        if sresp
        then do:
            message "Prepare a Impressora". 
            pause.
    
            find last plani use-index numero where
                          plani.etbcod = estab.etbcod and
                          plani.emite  = estab.etbcod and
                          plani.serie  = "U" and
                          plani.movtdc <> 4  and
                          plani.movtdc <> 5 no-lock no-error.
            if not avail plani
            then vnumero = 1.
            else vnumero = plani.numero + 1.
    
            if estab.etbcod = 998 or
               estab.etbcod = 993 or
               estab.etbcod = 996
            then do: 
                vnumero = 0.
                for each xestab where xestab.etbcod = 998 or
                              xestab.etbcod = 993 or
                              xestab.etbcod = 996 no-lock,
                                 
                    last plani use-index numero 
                    where plani.etbcod = xestab.etbcod and
                          plani.emite  = xestab.etbcod and
                          plani.serie  = "u"          and
                          plani.movtdc <> 4           and
                          plani.movtdc <> 5           and
                 /*         plani.numero < 100000       and  */
                          plani.pladat >= 12/01/2006  no-lock.
                    if not avail plani 
                    then vnumero = 1. 
                    else
                        if vnumero < plani.numero
                        then vnumero = plani.numero.
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
                assign
                    plani.etbcod   = estab.etbcod
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
                    plani.seguro   = 0
                    plani.desacess = 0
                    plani.ipi      = vipi
                    plani.platot   = vplatot + vipi 
                    plani.serie    = vserie
                    plani.numero   = vnumero
                    plani.movtdc   = tipmov.movtdc
                    plani.emite    = estab.etbcod
                    plani.pladat   = today
                    plani.modcod   = tipmov.modcod
                    plani.opccod   = int(opcom.opccod)
                    plani.notfat   = estab.etbcod
                    plani.dtinclu  = today
                    plani.horincl  = time
                    plani.notsit   = no
                    plani.nottran  = vtrans
                    plani.dtinclu  = today
                    plani.notobs[1] = vobs[1] + " " + vobs[2] + " " +
                                      vobs[3] + " "
                    plani.notobs[2] = vobs[4] + " " + vobs[5] + " " +
                                      vobs[6] + " "
                    plani.notobs[3] = vobs[7] + " " + vobs[8] + " " + vobs[9]
                    plani.hiccod   = int(opcom.opccod)
                    plani.outras = plani.frete  +
                              plani.seguro +
                              plani.vlserv +
                              plani.desacess +
                              plani.ipi   +
                              plani.icmssubst
                    plani.isenta = plani.platot - plani.outras - plani.bicms.
            end.
            vmovseq = 0.
            for each w-movim where w-movim.marca = "*":
                vmovseq = vmovseq + 1.
            
                create movim.
                ASSIGN
                    movim.movtdc = plani.movtdc
                    movim.PlaCod = plani.placod
                    movim.etbcod = plani.etbcod
                    movim.movseq = vmovseq
                    movim.procod = w-movim.procod
                    movim.movqtm = w-movim.movqtm
                    movim.movpc  = w-movim.movpc
                    movim.MovAlICMS = w-movim.movalicms
                    movim.movicms   = w-movim.valicm
                    movim.MovAlIPI  = w-movim.movalipi
                    movim.movipi    = w-movim.movipi
                    movim.movdes    = w-movim.valdes
                    movim.movdat    = plani.pladat
                    movim.MovHr     = int(time)
                    movim.desti     = plani.desti
                    movim.emite     = plani.emite.
               
                run atuest.p (input recid(movim),
                      input "I",
                      input 0).
            end.

            run impdvcom.p (input recid(plani)).

            if vdatref <= 09/30/2007 and
                (forne.forcod = 104848 or
                forne.forcod = 103987)
            then do:
                message "Prepare a Impressora para SEGUNDA NF". 
                pause.

                vobs[3] = "ICMS rec. por Subst. Trib. Cfe " +
                  "Lv III, Art 25 do RICMS/RS - Dec 37699-97".

                if forne.ufecod = "RS"
                then find first copcom where copcom.opccod = "1603" no-lock.
                else find last copcom where copcom.opccod = "2603" no-lock.

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
                   estab.etbcod = 993 or
                   estab.etbcod = 996
                then do: 
                    vnumero = 0.
                    for each xestab where xestab.etbcod = 998 or
                              xestab.etbcod = 993 or
                              xestab.etbcod = 996  no-lock,
                        last plani use-index numero 
                        where plani.etbcod = xestab.etbcod and
                          plani.emite  = xestab.etbcod and
                          plani.serie  = "u"          and
                          plani.movtdc <> 4           and
                          plani.movtdc <> 5           and
                          plani.pladat >= 12/01/2006  /*no-lock*/ .
                      
                        if not avail plani 
                        then vnumero = 1. 
                        else
                            if vnumero < plani.numero
                            then vnumero = plani.numero.
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
                    create eplani.
                    assign eplani.etbcod   = estab.etbcod
                        eplani.placod   = vplacod
                        eplani.protot   = 0 
                        eplani.desti    = estab.etbcod
                        eplani.bicms    = 0
                        eplani.icms     = vbicms * .17
                        eplani.bsubst   = 0
                        eplani.icmssubst = 0
                        eplani.descpro  = 0
                        eplani.acfprod  = 0
                        eplani.frete    = 0
                        eplani.seguro   = 0
                        eplani.desacess = 0
                        eplani.ipi      = 0
                        eplani.platot   = 0 
                        eplani.serie    = vserie
                        eplani.numero   = vnumero
                        eplani.movtdc   = 27
                        eplani.emite    = estab.etbcod
                        eplani.pladat   = today
                        eplani.modcod   = tipmov.modcod
                        eplani.opccod   = int(copcom.opccod)
                        eplani.notfat   = estab.etbcod
                        eplani.dtinclu  = today
                        eplani.horincl  = time
                        eplani.notsit   = no
                        eplani.nottran  = vtrans
                        eplani.dtinclu  = today
                        eplani.notobs[1] = vobs[1]
                        eplani.notobs[2] = vobs[2]
                        eplani.notobs[3] = vobs[3]
                        eplani.hiccod   = int(copcom.opccod)
                        eplani.outras = 0
                        eplani.isenta = 0
                        eplani.bicms = 0.
                end.
    
                run impdevst.p (input recid(eplani)).
            end.
        end. /* end impressao*/
    end.
    else
    ***/
    
    run emissao-NFe.

end.

procedure emissao-NFe:

    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    
    do on error undo:
        vplacod = ?.
        vnumero = ?.
        vserie  = "1".
        create tt-plani.
        assign
            tt-plani.etbcod   = estab.etbcod
            tt-plani.placod   = vplacod
            tt-plani.protot   = vprotot 
            tt-plani.desti    = forne.forcod
            tt-plani.bicms    = vbicms
            tt-plani.icms     = vicms
            tt-plani.bsubst   = base_icms_subst
            tt-plani.icmssubst = icms_subst
            tt-plani.descpro  = vdescpro
            tt-plani.acfprod  = vacfprod
            tt-plani.frete    = vfrete
            tt-plani.seguro   = 0
            tt-plani.desacess = 0
            tt-plani.ipi      = vipi
            tt-plani.platot   = vplatot + vipi 
            tt-plani.serie    = vserie
            tt-plani.numero   = vnumero
            tt-plani.movtdc   = tipmov.movtdc
            tt-plani.emite    = estab.etbcod
            tt-plani.pladat   = today
            tt-plani.modcod   = tipmov.modcod
            tt-plani.opccod   = int(opcom.opccod)
            tt-plani.notfat   = estab.etbcod
            tt-plani.dtinclu  = today
            tt-plani.horincl  = time
            tt-plani.notsit   = no
            tt-plani.nottran  = vtrans
            tt-plani.dtinclu  = today
            tt-plani.notobs[1] = vobs[1] + " " + vobs[2] + " " + vobs[3] + " "
            tt-plani.notobs[2] = vobs[4] + " " + vobs[5] + " " + vobs[6] + " "
            tt-plani.notobs[3] = vobs[7] + " " + vobs[8] + " " + vobs[9] + " "
            tt-plani.hiccod   = int(opcom.opccod)
            tt-plani.outras   = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
            tt-plani.isenta = tt-plani.platot - tt-plani.outras
                              - tt-plani.bicms.
    end.

    assign
        tt-plani.bicms = 0
        tt-plani.icms  = 0
        vmovseq = 0
        .

    for each w-movim where w-movim.marca = "*":
        vmovseq = vmovseq + 1.

        create tt-movim.
        ASSIGN tt-movim.movtdc = tt-plani.movtdc
               tt-movim.PlaCod = tt-plani.placod
               tt-movim.etbcod = tt-plani.etbcod
               tt-movim.movseq = vmovseq
               tt-movim.procod = w-movim.procod
               tt-movim.movqtm = w-movim.movqtm
               tt-movim.movpc  = w-movim.movpc
               tt-movim.MovAlIPI  = w-movim.movalipi
               tt-movim.movipi = w-movim.movipi
               tt-movim.movdes = w-movim.valdes
               tt-movim.movdat = tt-plani.pladat
               tt-movim.MovHr  = int(time)
               tt-movim.desti  = tt-plani.desti
               tt-movim.emite  = tt-plani.emite
               tt-movim.movdev = w-movim.movfre
               tt-movim.numprocimp  = w-movim.chave
               tt-movim.movalpis    = w-movim.movalpis
               tt-movim.movpis      = w-movim.movpis * w-movim.movqtm
               tt-movim.movalcofins = w-movim.movalcofins
               tt-movim.movcofins   = w-movim.movcofins * w-movim.movqtm
               tt-movim.movcstpiscof = w-movim.movcstpiscof
               tt-movim.movbpiscof   = w-movim.movbpiscof * w-movim.movqtm
               tt-movim.movcsticms   = string(w-movim.sittri,"999")
                                        /*w-movim.movcsticms*/
               tt-movim.movbicms   = w-movim.movbicms * w-movim.movqtm
               tt-movim.movalicms  = w-movim.movalicms
               tt-movim.movicms    = w-movim.movbicms *
                                    (w-movim.movalicms / 100)
               .

        v-bred = 0.
        
        find produ where produ.procod = tt-movim.procod no-lock.       
        find first clafis where clafis.codfis = produ.codfis
                       no-lock no-error.
        if tt-movim.movcsticms <> "51"
        then do: 
            if avail clafis and
                 clafis.perred > 0
            then
                v-bred = (tt-movim.movpc * tt-movim.movqtm) -
                     ((tt-movim.movpc * tt-movim.movqtm) * 
                     (clafis.perred / 100)).
                 
            if v-bred > 0
                and (opcom.opccod = "1102" or opcom.opccod = "5202")
            then assign
                tt-movim.movicms = v-bred * (tt-movim.movalicms / 100)
                tt-plani.bicms = tt-plani.bicms + v-bred + vfrete.
            else do:
                assign
                    tt-movim.movicms = (tt-movim.movpc * tt-movim.movqtm) *
                                   (tt-movim.movalicms / 100)
                    tt-plani.bicms = tt-plani.bicms + 
                            (tt-movim.movpc * tt-movim.movqtm) - 
                            (tt-movim.movdes * tt-movim.movqtm) +
                            (tt-movim.movdev * tt-movim.movqtm).
                if vforcod = 111345
                then tt-movim.movicms = (tt-movim.movpc * tt-movim.movqtm) *
                                    (12 / 100).
            end.
            if vforcod = 111345
            then 
            tt-movim.movicms = tt-movim.movicms
                              + ((tt-movim.movdev * tt-movim.movqtm)
                              - (tt-movim.movdes * tt-movim.movqtm))
                            * (12 / 100).
            else 
            tt-movim.movicms = tt-movim.movicms
                              + ((tt-movim.movdev * tt-movim.movqtm)
                              - (tt-movim.movdes * tt-movim.movqtm))
                            * (tt-movim.movalicms / 100).
                         
            tt-plani.icms  = tt-plani.icms + tt-movim.movicms.
        end.
        else assign
            tt-plani.bicms = tt-plani.bicms + tt-movim.movbicms
            tt-plani.icms = tt-plani.icms + tt-movim.movicms
               .

    end.

    sresp = no.
    message "Deseja visualizar o total da nota antes da emissao?"
        update sresp.
    if sresp
    then run p-mostra-nota.

    vobs-os = "OS:".
    for each wfasstec:
        find asstec where asstec.oscod = wfasstec.oscod no-lock.

        create tt-etiqpla.
        assign
            tt-etiqpla.oscod    = asstec.oscod
            tt-etiqpla.etopeseq = etiqseq.etopeseq
            tt-etiqpla.etmovcod = etiqseq.etmovcod.

            find first tt-movimaux where tt-movimaux.etbcod = tt-plani.etbcod
                                     and tt-movimaux.procod = asstec.procod
                                     and tt-movimaux.nome_campo = "OS"
                         no-error.
            if not avail tt-movimaux
            then do.
                create tt-movimaux.
                assign
                    tt-movimaux.movtdc = tt-plani.movtdc
                    tt-movimaux.etbcod = tt-plani.etbcod
                    tt-movimaux.placod = tt-plani.placod
                    tt-movimaux.procod = asstec.procod
                    tt-movimaux.nome_campo  = "OS"
                    tt-movimaux.valor_campo = "OS:".
            end.
            if length(tt-movimaux.valor_campo) < 65
            then tt-movimaux.valor_campo = tt-movimaux.valor_campo +
                        string(asstec.oscod) + " ".
            else vobs-os = vobs-os + string(asstec.oscod) + " ".
    end.
    if length(vobs-os) > 4 and length(vobs-os) < 400
    then tt-plani.notobs[3] = vobs-os.
    
    def var p-ok as log init no.
    if vetbcod = 998 or vetbcod = 996 or vetbcod = 930
    then nfe-emite = 900.
    else nfe-emite = vetbcod.
    
        if nfe-emite < 201
        then do:
            message "BUSCA ULTIMO NUMERO DA FILIAL.".
            run conecta-NFe-loja.p(input "BUSCA",
                                    input nfe-emite,
                                    input "filial" + string(nfe-emite,"999"),
                                    input vserie).
        end.                            

        run manager_nfe.p (input "5202",
                           input ?,
                           output p-ok).

        if p-ok and nfe-emite < 201
        then do:
            message "ENVIA ULTIMO NUMERO PARA FILIAL.".
            run conecta-NFe-loja.p(input "ENVIA",
                                    input nfe-emite,
                                    input "filial" + string(nfe-emite,"999"),
                                    input vserie).
        end.

        /*****
        if vdatref <= 09/30/2007 and
            (forne.forcod = 104848 or
            forne.forcod = 103987)
        then do:
            message "Emissao da SEGUNDA NF". 
            pause.

            vobs[3] = "ICMS rec. por Subst. Trib. Cfe " +
                  "Lv III, Art 25 do RICMS/RS - Dec 37699-97".

            if forne.ufecod = "RS"
            then find first copcom where copcom.opccod = "1603" no-lock.
            else find last copcom where copcom.opccod = "2603" no-lock.

            find last plani use-index numero where
                          plani.etbcod = estab.etbcod and
                          plani.emite  = estab.etbcod and
                          plani.serie  = "U" and
                          plani.movtdc <> 4  and
                          plani.movtdc <> 5 /*no-lock*/ no-error.
            if not avail plani
            then vnumero = 1.
            else vnumero = plani.numero + 1.
    
            if  estab.etbcod = 998 or
                estab.etbcod = 993 or 
                estab.etbcod = 996
            then do: 
                vnumero = 0.
                for each xestab where xestab.etbcod = 998 or
                              xestab.etbcod = 993 or
                              xestab.etbcod = 996  no-lock,
                    last plani use-index numero 
                    where plani.etbcod = xestab.etbcod and
                          plani.emite  = xestab.etbcod and
                          plani.serie  = "u"          and
                          plani.movtdc <> 4           and
                          plani.movtdc <> 5           and
/*                          plani.numero < 100000       and  */
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
                create eplani.
                assign eplani.etbcod   = estab.etbcod
                    eplani.placod   = vplacod
                    eplani.protot   = 0 
                    eplani.desti    = estab.etbcod
                    eplani.bicms    = 0
                    eplani.icms     = vbicms * .17
                    eplani.bsubst   = 0
                    eplani.icmssubst = 0
                    eplani.descpro  = 0
                    eplani.acfprod  = 0
                    eplani.frete    = 0
                    eplani.seguro   = 0
                    eplani.desacess = 0
                    eplani.ipi      = 0
                    eplani.platot   = 0 
                    eplani.serie    = vserie
                    eplani.numero   = vnumero
                    eplani.movtdc   = 27
                    eplani.emite    = estab.etbcod
                    eplani.pladat   = today
                    eplani.modcod   = tipmov.modcod
                    eplani.opccod   = int(copcom.opccod)
                    eplani.notfat   = estab.etbcod
                    eplani.dtinclu  = today
                    eplani.horincl  = time
                    eplani.notsit   = no
                    eplani.nottran  = vtrans
                    eplani.dtinclu  = today
                    eplani.notobs[1] = vobs[1]
                    eplani.notobs[2] = vobs[2]
                    eplani.notobs[3] = vobs[3]
                    eplani.hiccod   = int(copcom.opccod)
                    eplani.outras = 0
                    eplani.isenta = 0
                    eplani.bicms = 0.
            end.
    
            run impdevst.p (input recid(eplani)).
       end.
       ***/

end procedure.


procedure p-mostra-nota:

    display tt-plani.bicms  
            tt-plani.icms 
            tt-plani.bsubst
            tt-plani.icmssubst
            tt-plani.protot   
                with frame f-mostra-1 overlay row 8 width 80.
    pause 0.

    display tt-plani.frete 
            tt-plani.seguro 
            tt-plani.desacess
            tt-plani.ipi     
            tt-plani.platot  
                with frame f-mostra-2 overlay row 12 width 80.

    pause 0.

    sresp = no.

    for each tt-movim.
        display tt-movim.procod
                tt-movim.movipi
                tt-movim.movalipi
                tt-movim.movicms
                tt-movim.movalicms
                tt-movim.movdev label "Frete" with 1 col.                
    end.
                    
    message "Deseja alterar as informacoes? " update sresp.
    if sresp
    then do:
        update tt-plani.bicms  
               tt-plani.icms 
               tt-plani.bsubst
               tt-plani.icmssubst
               tt-plani.protot   
                    with frame f-mostra-1 overlay row 8 width 80.

        update tt-plani.frete 
               tt-plani.seguro 
               tt-plani.desacess
               tt-plani.ipi     
               tt-plani.platot  
                    with frame f-mostra-2 overlay row 12 width 80.
    
        for each tt-movim.
            update /***tt-movim.procod***/
                   tt-movim.movipi
                   tt-movim.movalipi
                   tt-movim.movicms
                   tt-movim.movalicms
                   tt-movim.movdev label "Frete" with 1 col.
        end.

    end.

end procedure.

