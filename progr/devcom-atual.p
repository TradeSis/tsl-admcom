{admcab.i}
             
def new shared temp-table tt-for 
    field forcod like forne.forcod.

def new shared temp-table tt-nfref like plani.    
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
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
def var v-procod like produ.procod.
def var vobs       as char extent 9 format "x(70)".
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
    vnumant label "Numero NF Origem" colon 17
    vserant label "Serie"  
    vopccod  label "Op. Fiscal" format "9999" colon 17 
    opcom.opcnom  no-label
    vdata         label "Data"      colon 17
    vpladat       colon 17
      with frame f1 side-label color white/cyan width 80 row 4.

def var vachou-nf as log.
repeat:
    
    for each tt-plani1: delete tt-plani1. end.    

    for each tt-nfref: delete tt-nfref. end.

    for each w-movim: delete w-movim. end.

    for each tt-for. delete tt-for. end.
    
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
        find first tt-plani1 where tt-plani1.numero = plani.numero no-error. 
        if not avail tt-plani1 
        then do: 
            create tt-plani1.  
            assign tt-plani1.numero = plani.numero
                   tt-plani1.subst  = plani.icmssubst.
            create tt-nfref.
            buffer-copy plani to tt-nfref.
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
    
    /************************************************/
    find tipmov where tipmov.movtdc = 13 no-lock.
    if vetbcod = 995 or
       vetbcod = 993 or
       vetbcod = 998
    then vserie = "1".
    else vserie = "U".

    if forne.ufecod = "RS"
    then find first opcom where opcom.opccod = "5202" no-lock.
    else find last opcom where opcom.opccod = "6202"  no-lock.
    
    vopccod = opcom.opccod.


    display vopccod
            opcom.opcnom with frame f1.


    update vdata 
           vpladat with frame f1. 

    update base_icms_subst label "Base Icms Subst." format ">>>,>>9.99"
           icms_subst label "Icms Substituicao"     format ">>>,>>9.99"
           vfrete     label "Frete"                 format ">>>,>>9.99"
               with frame f2 side-label color white/cyan.
    
    hide frame f2 no-pause.  
        
    run tt-devcom.p(input forne.forcod,
                    input vetbcod).       

    vobs[1] = "NF ORIGINAL: ".
    for each tt-plani1 by tt-plani1.numero:
        vobs[1] = vobs[1] + string(tt-plani1.numero) + ",".
    end.

    vipi    = 0.
    for each w-movim where w-movim.marca = "*":
    
        vipi    = vipi    + ((w-movim.movqtm * w-movim.movpc) *
                             (w-movim.movalipi / 100)).
        
        vfrete = vfrete + (w-movim.movqtm * w-movim.movfre).
                             
    end.
    
    if vipi > 0 
    then vobs[1] = vobs[1] +  " VALOR IPI: " +  string(vipi,">>,>>9.99"). 
    
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
                           
        vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
        
        vbicms  = vbicms  + base_icms + (w-movim.movfre * w-movim.movqtm).
        
        vicms   = vicms   + valor_icms.

        w-movim.valicms = valor_icms.
        
        vipi    = vipi    + ((w-movim.movqtm * w-movim.movpc) *
                             (w-movim.movalipi / 100)).
        vdescpro = vdescpro + (w-movim.movqtm * w-movim.valdes).
    end.

    
    vplatot = vprotot + vfrete - vdescpro.
    vbicms = vprotot - vdescpro.
    if vbicms > vplatot
    then vbicms = vplatot.
    
    if forne.forcod = 100725
    then vprotot = vprotot - vdescpro.
    
    if vsubst > 0 
    then vobs[1] = vobs[1] +  " VALOR ICMS SUBS. TRBT. " 
                   +  string(vsubst).
    
    pause 0.
    
    if vbicms <= 0
    then update vbicms format ">>>,>>>,>>9.99" with frame f-obs.
    
    update vobs[1] no-label
           vobs[2] no-label
           vobs[3] no-label 
           vobs[4] no-label
           vobs[5] no-label
           vobs[6] no-label 
           vobs[7] no-label
           vobs[8] no-label
           vobs[9] no-label 
                with frame f-obs centered title "Observacoes".

    if vetbcod <> 995 and
       vetbcod <> 993 and
       vetbcod <> 998
    then do: 
    message "Confirma impressao da nota fiscal" update sresp.
    if sresp
    then do:
        bell.
        message "Prepare a Impressora". 
        pause.
    
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
                                + " "
                                + vobs[2]
                                + " "
                                + vobs[3]
                                + " "
               plani.notobs[2] = vobs[4]
                                + " "
                                + vobs[5]
                                + " "
                                + vobs[6]
                                + " "
               plani.notobs[3] = vobs[7]
                                + " "
                                + vobs[8]
                                + " "
                                + vobs[9]
               plani.hiccod   = int(opcom.opccod)
               plani.outras = plani.frete  +
                              plani.seguro +
                              plani.vlserv +
                              plani.desacess +
                              plani.ipi   +
                              plani.icmssubst
               plani.isenta = plani.platot - plani.outras - plani.bicms.
    end.

    for each w-movim where w-movim.marca = "*":
        vmovseq = vmovseq + 1.

        create movim.
        ASSIGN movim.movtdc = plani.movtdc
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
            bell.
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
    
            if  estab.etbcod = 998 or
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
                    eplani.pladat   = vpladat
                    eplani.modcod   = tipmov.modcod
                    eplani.opccod   = int(copcom.opccod)
                    eplani.notfat   = estab.etbcod
                    eplani.dtinclu  = today
                    eplani.horincl  = time
                    eplani.notsit   = no
                    eplani.nottran  = vtrans
                    eplani.dtinclu  = vdata
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
    else do:
        run emissao-NFe.
    end.
end.

procedure emissao-NFe:

    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    
    do on error undo:
        vplacod = ?.
        vnumero = ?.
        vserie  = "1".
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
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
               tt-plani.seguro   = vseguro
               tt-plani.desacess = vdesacess
               tt-plani.ipi      = vipi
               tt-plani.platot   = vplatot + vipi 
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.emite    = estab.etbcod
               tt-plani.pladat   = vpladat
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = int(opcom.opccod)
               tt-plani.notfat   = estab.etbcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.nottran  = vtrans
               tt-plani.dtinclu  = vdata
               tt-plani.notobs[1] = vobs[1]
               tt-plani.notobs[2] = vobs[2]
               tt-plani.notobs[3] = vobs[3]
               tt-plani.hiccod   = int(opcom.opccod)
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
               tt-plani.isenta = tt-plani.platot - tt-plani.outras 
                            - tt-plani.bicms.
    end.

    tt-plani.bicms = 0.
    tt-plani.icms = 0 .
    
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
               tt-movim.MovAlICMS = w-movim.movalicms
               tt-movim.movicms   = w-movim.valicm
               tt-movim.MovAlIPI  = w-movim.movalipi
               tt-movim.movipi    = w-movim.movipi
               tt-movim.movdes    = w-movim.valdes
               tt-movim.movdat    = tt-plani.pladat
               tt-movim.MovHr     = int(time)
               tt-movim.desti     = tt-plani.desti
               tt-movim.emite     = tt-plani.emite.
        
        v-bred = 0.
        find produ where produ.procod = tt-movim.procod no-lock.       
        find first clafis where
                       clafis.codfis = produ.codfis
                       no-lock no-error.
        if avail clafis and
                 clafis.perred > 0
        then do:
            v-bred = (tt-movim.movpc * tt-movim.movqtm) -
                     ((tt-movim.movpc * tt-movim.movqtm) * 
                     (clafis.perred / 100)).
        end.
        
        if sfuncod = 101 or sfuncod = 88
        then do:
        
            display tt-movim.movpc tt-movim.movqtm clafis.perred v-bred.
            pause.
        
        end.
        
        pause.
                 
        if v-bred > 0
        then assign
                tt-movim.movicms = v-bred * (tt-movim.movalicms / 100)
                tt-plani.bicms = tt-plani.bicms + v-bred.
        else assign
                tt-movim.movicms = (tt-movim.movpc * tt-movim.movqtm) *
                                   (tt-movim.movalicms / 100)
                tt-plani.bicms = tt-plani.bicms + 
                            (tt-movim.movpc * tt-movim.movqtm).
                            
        
        tt-plani.icms  = tt-plani.icms  + tt-movim.movicms.   
                      
    end.
    
    def var p-ok as log init no.
    def var p-valor as char.
    p-valor = "".
    if vetbcod = 998
    then nfe-emite = 993.
    else nfe-emite = vetbcod.
    
    run le_tabini.p (nfe-emite, 0,
            "NFE - TIPO DOCUMENTO", OUTPUT p-valor) .
    if p-valor = "NFE"
    then do:
        
        run manager_nfe.p (input "5202",
                           input ?,
                           output p-ok).
    end.

        /*****
        if vdatref <= 09/30/2007 and
            (forne.forcod = 104848 or
            forne.forcod = 103987)
        then do:
            bell.
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
                    eplani.pladat   = vpladat
                    eplani.modcod   = tipmov.modcod
                    eplani.opccod   = int(copcom.opccod)
                    eplani.notfat   = estab.etbcod
                    eplani.dtinclu  = today
                    eplani.horincl  = time
                    eplani.notsit   = no
                    eplani.nottran  = vtrans
                    eplani.dtinclu  = vdata
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
