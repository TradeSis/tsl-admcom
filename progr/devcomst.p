{admcab.i}

def var vforcod like forne.forcod.

/* compatib.com modulo AT */
def input parameter par-rec as recid.

find etiqseq where recid(etiqseq) = par-rec no-lock no-error.

def var nfe-emite like plani.emite.
def shared temp-table wfasstec like asstec.

def new shared temp-table tt-etiqpla
    field oscod     like etiqpla.oscod
    field etopeseq  like etiqpla.etopeseq
    field etmovcod  like etiqpla.etmovcod.

def var vassistencia as log.
def var vachou-prod  as log.

find first wfasstec no-lock no-error.
if avail wfasstec
then do.
    assign
        vassistencia = yes.
    find asstec where asstec.oscod = wfasstec.oscod no-lock.
    vforcod = asstec.forcod.
end.
/* */

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimaux like movimaux.
def new shared temp-table tt-nfref like plani.
def new shared temp-table tt-nfref1 like plani.
def new shared temp-table tt-nfref2 like plani.
def new shared temp-table tt-nfref3 like plani.

def buffer btt-nfref for tt-nfref.        

def var vcont-prod-nfref   as integer.
def var vcont-prod-dev     as integer.
def var vnumero-nf-origem  as char.
def var v-mva like clafis.mva_oestado1.
def var icms-subst as dec.
def var vbsubst like plani.bsubst.

def new shared var vnum-nota-aturizada  as integer.

def var vforn-tim as logical initial no.
def var vok as log.            
def temp-table tt-for 
    field forcod like forne.forcod.
def var vicms2 as dec.
def var vicms3 as dec.    
def var vsittri as char format "x(03)".
def var valor_icms like plani.platot.
def var base_icms  like plani.platot.
def var visenta    like plani.isenta.
def var voutras    like plani.outras.
def var vobs-os    as char.
def var vobs       as char extent 9 format "x(70)".
def buffer xestab for estab.
def var vetbcod like estab.etbcod.
def var vtrans    like  clien.clicod.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms.
def var vprotot   like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vfrete    like  plani.frete.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vserie    like  plani.serie.
def var vnumant   as integer.
def var vserant   as char format "x(03)".
def var vprocod   like  produ.procod.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var vopccod   like  opcom.opccod.
def var vmovseq   like movim.movseq.
def var vsubst    like plani.icmssubst.
def buffer bestab for estab.
def buffer bplani for plani.


def new shared temp-table tt-plani1
    field numero like plani.numero
    field subst  like plani.platot
    field pladat like plani.pladat
    field dtinclu like plani.dtinclu.
    
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
 
def temp-table tt-movim1 like w-movim.     

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

def var vprotot5  like vprotot.
def var vplatot5  like vprotot.
def var vbicms5   like vbicms.
def var vicms5    like vicms.
def var vipi5     like vipi.  
def var vicms6    like vicms.
def var vdescpro5 like vdescpro.      
def var vnumero1  like plani.numero init 0.
def var vnumero2  like plani.numero init 0.
def var vnumero3  like plani.numero init 0.
def buffer bopcom for opcom.
def buffer copcom for opcom.
def buffer dplani for plani.
def buffer eplani for plani.
def var vchave-nfe as char.

repeat:    
    assign vfrete = 0.

    for each tt-plani1: delete tt-plani1. end.    
    for each tt-movim1: delete tt-movim1. end.    
    for each w-movim: delete w-movim. end.
    for each tt-for. delete tt-for. end.
    for each tt-nfref: delete tt-nfref. end.
    for each tt-nfref1: delete tt-nfref1. end.
    
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
    else do:
        if forne.forcod = 110267
        then do:
            create tt-for.
            assign tt-for.forcod = 110267.
            create tt-for.
            assign tt-for.forcod = 104666.
        end.
        else do:
            create tt-for.
            assign tt-for.forcod = forne.forcod.
        end.
    end.    
    
    do on error undo, retry:
        vserant = "U".
        
        update vnumant  format ">>>>>>9"
               vserant label "Serie" with frame f1.
        
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
                    then do:
                        message "Nota Fiscal de Compra nao encontrada".
                        pause .
                        undo, retry.
                    end.
                end.
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
                    then do:
                        find plani where plani.emite  = tt-for.forcod and
                                         plani.etbcod = 993           and
                                         plani.movtdc = 4            and
                                         plani.serie  = vserant      and
                                         plani.numero = vnumant no-lock
                                         no-error.
                        if not avail plani
                        then do:
                            find plani where plani.emite  = tt-for.forcod and
                                             plani.etbcod = 900           and
                                             plani.movtdc = 4            and
                                             plani.serie  = vserant      and
                                             plani.numero = vnumant no-lock
                                                 no-error.
                            if not avail plani
                            then do:
                                message "Nota Fiscal de Compra nao encontrada".
                                pause .
                                undo, retry.
                            end.
                        end.                            
                    end.
                end.
            end.
            if avail plani
            then leave.
        end.

        if plani.bsubst = 0
        then do:
            message color red/with 
            "Nota Fiscal DEVOLUÇÃO sem ST emissão em outro menu."
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
        end.

        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:

            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next.

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
                       w-movim.subtotal  = (movim.movpc * movim.movqtm) 
                       w-movim.movpc     = movim.movpc  
                       w-movim.movalicms = movim.movalicms
                       w-movim.valicms   = (movim.movicms / movim.movqtm)  
                       w-movim.movalipi  = movim.movalipi   
                       w-movim.movipi    = movim.movipi 
                       w-movim.movdes    = movim.movpdes  
                       w-movim.valdes    = movim.movdes
                       w-movim.codfis    = produ.codfis
                       w-movim.movfre    = movim.movdev
                       w-movim.sittri    = 90
                       w-movim.chave     = plani.ufdes
                       w-movim.movalpis  = movim.movalpis
                       w-movim.movpis    = movim.movpis / movim.movqtm
                       w-movim.movalcofins  = movim.movalcofins
                       w-movim.movcofins    = movim.movcofins / movim.movqtm
                       w-movim.movcstpiscof = movim.movcstpiscof
                       w-movim.movbpiscof   = movim.movbpiscof / movim.movqtm
                       w-movim.movcsticms   = movim.movcsticms
                       w-movim.movbicms     = movim.movbicms / movim.movqtm
                       .
              
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

        find first tt-plani1 where tt-plani1.numero = plani.numero no-error. 
        if not avail tt-plani1 
        then do: 
            create tt-plani1.  
            assign tt-plani1.numero = plani.numero
                   tt-plani1.subst  = plani.icmssubst
                   tt-plani1.pladat = plani.pladat
                   tt-plani1.dtinclu = plani.dtinclu.
            create tt-nfref.
            buffer-copy plani to tt-nfref.
        end.
    end.
    
    find tipmov where tipmov.movtdc = 13 no-lock.

    if forne.ufecod = "RS"
    then find first opcom where opcom.opccod = "5411" no-lock.
    else find last opcom where opcom.opccod = "6411" no-lock.
    
    vopccod = opcom.opccod.
    display vopccod
            opcom.opcnom with frame f1.

    /**
    update base_icms_subst label "Base Icms Subst." format ">>>,>>9.99"
           icms_subst label "Icms Substituicao"     format ">>>,>>9.99"
           vfrete     label "Frete"                 format ">>>,>>9.99"
               with frame f2 side-label color white/cyan.
    **/
    hide frame f2 no-pause.  
        
    run tt-devcomst.p(input forne.forcod,
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
                                                     
        /**************************
        message "Qtd: " w-movim.movqtm
                " Preco "  w-movim.movpc
                " Ali IPI " w-movim.movalipi
                " Frete " w-movim.movfre.
        *************************/
                                                      
        vfrete = vfrete + (w-movim.movqtm * w-movim.movfre).
    end.
    
    if vipi > 0 
    then vobs[1] = vobs[1] + " VALOR IPI: " + string(vipi,">>,>>9.99"). 
    
    if vfrete > 0
    then vobs[1] = vobs[1] + " VALOR FRETE: " + string(vfrete,">>,>>9.99").

    vsubst = 0.
    for each tt-plani1:
        vsubst = vsubst + tt-plani1.subst.
    end.
    /*    
    if vsubst > 0 
    then vobs[1] = vobs[1] +  " VALOR ICMS SUBS. TRBT. " 
                   +  string(vsubst).
    */
    pause 0.
    message "Confirma nota fiscal?" update sresp.
    if sresp = no
    then return.
    
    find first w-movim where w-movim.marca = "*" no-error.
    if not avail w-movim
    then undo, retry.
    
    assign
        vprotot5 = 0
        vplatot5 = 0
        vbicms5  = 0
        vicms5   = 0
        vipi5    = 0
        vdescpro5 = 0
        vicms6   = 0.

    for each w-movim where w-movim.marca = "*":
        create tt-movim1.
        buffer-copy w-movim to tt-movim1.
        run trata_cfop.p (input opcom.opccod,  
                          input w-movim.procod, 
                          input (w-movim.movpc * w-movim.movqtm),
                          input w-movim.movalicms,    
                          input w-movim.valicms,    
                          input 0, 
                          output base_icms,   
                          output visenta,   
                          output voutras,   
                          output vsittri, 
                          output valor_icms).
                           
        vprotot5 = vprotot5 + (w-movim.movqtm * w-movim.movpc).        
        vbicms5  = vbicms5 + base_icms /*+ (w-movim.movfre * w-movim.movqtm)*/.
        vicms5   = vicms5   + valor_icms.
        /*
        w-movim.valicms = valor_icms
                         + (((w-movim.movfre * w-movim.movqtm)
                         * w-movim.movalicms) / 100).
        */
        vipi5    = vipi5    + ((w-movim.movqtm * w-movim.movpc) *
                             (w-movim.movalipi / 100)).
                                                       /*
        /* Soma o frete do item no valor de IPI */
        vipi5   = vipi5   + ((w-movim.movqtm * w-movim.movfre) *
                             (w-movim.movalipi / 100)).
                                                         */
        vdescpro5 = vdescpro5 + (w-movim.movqtm * w-movim.valdes).        
    end.
    vbicms5 = vprotot5 - vdescpro5.
    vicms6 = vbicms5 * .17 .
    /*
    assign vbicms5  = vbicms5  + vfrete.
    */
    assign
        vprotot = 0
        vplatot = 0
        vbicms  = 0
        vicms   = 0
        vipi    = 0
        vdescpro = 0.

    for each w-movim where w-movim.marca = "*":
        base_icms  = 0.
        valor_icms = 0.
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
        /*
        w-movim.movicms = vicms.
        w-movim.movalicms = (vicms / vbicms) * 100.
        */
        vbicms  = vbicms + base_icms /*+ (w-movim.movfre * w-movim.movqtm)*/.
        vicms   = vicms  + valor_icms.
        vipi    = vipi   + ((w-movim.movqtm * w-movim.movpc) *
                            (w-movim.movalipi / 100)).
        
        /* Soma o frete do item no valor de IPI */
        vipi   = vipi   + ((w-movim.movqtm * w-movim.movfre) *
                             (w-movim.movalipi / 100)).
                             
        vdescpro = vdescpro + (w-movim.movqtm * w-movim.valdes).
    end.
    if vbicms < 0
    then vbicms = 0.
    
    vplatot = vprotot + vfrete - vdescpro.
    
    /**
    if vbicms > vplatot
    then vbicms = vplatot.
    message "Total da NF = " vplatot "   Base Icms =" update vbicms.
    **/
    
    if forne.forcod = 100725
    then vprotot = vprotot - vdescpro.
    
    if forne.fornom matches "*VIVO*" or
       forne.fornom matches "*BCP*" 
    then do:
        vobs[2] = "IMPOSTO PAGO CFE. ART. 16 DECR. 45260/07.".
        vobs[3] = "".
    end.
    else do:
        vobs[1] = vobs[1] + " " + forne.fornom.
        vobs[3] = "ICMS rec. por Subst. Trib. Cfe " +
                  "Lv III, Art 25 do RICMS/RS - Dec 37699-97".
    end.
    pause 0.

    vicms2 = vicms5.
    vicms3 = vbicms5 * .05.

    run emissao-NFe.
end.


procedure emissao-NFe:

    def var nfe-numero like plani.numero.
    
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    
    vserie  = "1".
    
    message "Tecle ENTER para emitir a PRIMEIRA NF" view-as alert-box.         
    do on error undo:
        create tt-plani.
        assign
            tt-plani.etbcod   = estab.etbcod
            tt-plani.placod   = ?
            tt-plani.protot   = vprotot 
            tt-plani.desti    = forne.forcod
            tt-plani.bicms    = vbicms
            tt-plani.icms     = vicms
            tt-plani.descpro  = vdescpro
            tt-plani.frete    = vfrete
            tt-plani.seguro   = 0
            tt-plani.desacess = 0
            tt-plani.ipi      = vipi
            tt-plani.platot   = vplatot + vipi
            tt-plani.serie    = vserie
            tt-plani.numero   = ?
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
            tt-plani.hiccod   = int(opcom.opccod)
            tt-plani.outras   = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
            tt-plani.isenta = tt-plani.platot - tt-plani.outras
                              - tt-plani.bicms.
            
        if forne.fornom matches "*TIM CELULAR*"
        then assign
                tt-plani.bicms = vbicms5
                tt-plani.icms  = vicms5.
 
        vsubst  = 0.
        vbsubst = 0.
        tt-plani.bsubst    = 0.
        tt-plani.icmssubst = 0.
        tt-plani.bicms = 0.
        tt-plani.icms = 0.
            
        assign vcont-prod-nfref = 0
               vmovseq = 0 
                .
            
        for each w-movim where w-movim.marca = "*":
            vmovseq = vmovseq + 1.

            assign vcont-prod-dev = vcont-prod-dev + 1.
            
            create tt-movim.
            ASSIGN
                tt-movim.movtdc = tt-plani.movtdc
                tt-movim.PlaCod = tt-plani.placod
                tt-movim.etbcod = tt-plani.etbcod
                tt-movim.movseq = vmovseq
                tt-movim.procod = w-movim.procod
                tt-movim.movqtm = w-movim.movqtm
                tt-movim.movpc  = w-movim.movpc
                tt-movim.MovAlICMS = w-movim.movalicms
                tt-movim.movbicms  = w-movim.movbicms * w-movim.movqtm 
                tt-movim.movicms   = w-movim.valicms /* w-movim.movqtm*/ 
                tt-movim.movcsticms = string(w-movim.sittri)
                tt-movim.MovAlIPI  = w-movim.movalipi
                tt-movim.movipi    = w-movim.movipi
                tt-movim.movdes    = w-movim.valdes
                tt-movim.movdat    = tt-plani.pladat
                tt-movim.MovHr     = tt-plani.horincl
                tt-movim.desti     = tt-plani.desti
                tt-movim.emite     = tt-plani.emite
                tt-movim.movdev    = w-movim.movfre
                tt-movim.numprocimp  = w-movim.chave
                tt-movim.movalpis    = w-movim.movalpis
                tt-movim.movpis      = w-movim.movpis * w-movim.movqtm
                tt-movim.movalcofins = w-movim.movalcofins
                tt-movim.movcofins   = w-movim.movcofins * w-movim.movqtm
                tt-movim.movcstpiscof = w-movim.movcstpiscof
                tt-movim.movbpiscof   = w-movim.movbpiscof * w-movim.movqtm
                /*tt-movim.movcsticms   = w-movim.movcsticms*/
                tt-movim.movalicms  = w-movim.movalicms
                tt-plani.bicms = tt-plani.bicms + tt-movim.movbicms
                tt-plani.icms  = tt-plani.icms + tt-movim.movicms
                .
        
            /***    
            if w-movim.movfre > 0
            then assign
                    tt-movim.movbicms = tt-movim.movbicms +
                                        (w-movim.movfre * w-movim.movqtm)
                    tt-movim.movicms  = tt-movim.movicms +
                                    ((w-movim.movfre * w-movim.movqtm) *
                                    (w-movim.movalicms / 100)).
            **/

            find first clafis where clafis.codfis = w-movim.codfis
                       no-lock no-error.
            if avail clafis
            then
                if forne.ufecod = "RS"
                then v-mva = clafis.mva_estado1.
                else v-mva = clafis.mva_oestado1.
            
            icms-subst = 0.
            
            
            if v-mva > 0
            then do:
                icms-subst
                       = (((w-movim.movpc * w-movim.movqtm) + w-movim.movipi 
                        + (w-movim.movfre * w-movim.movqtm)
                        - (w-movim.valdes * w-movim.movqtm))
                     +
                         (((w-movim.movpc * w-movim.movqtm) + w-movim.movipi 
                         + (w-movim.movqtm * w-movim.movfre)
                         - (w-movim.valdes * w-movim.movqtm)) *
                              (v-mva / 100))).


                vbsubst = vbsubst + icms-subst.
                tt-movim.movbsubst = icms-subst.
                    
                icms-subst = (icms-subst * .18).
                
                icms-subst = icms-subst - 
                        ((((w-movim.movpc * w-movim.movqtm)
                             * w-movim.movalicms) / 100)
                        + (((w-movim.movfre * w-movim.movqtm)
                             * w-movim.movalicms) / 100)
                        - (((w-movim.valdes * w-movim.movqtm)
                             * w-movim.movalicms) / 100)).
                vsubst = vsubst + icms-subst.
                tt-movim.movsubst = icms-subst.
            end.      
        end.
            
        if vsubst > 0 
        then
            if vobs[2] = ""
            then assign vobs[2] = "VALOR ICMS SUBS. TRBT. " 
                                                     +  string(vsubst).
            else assign vobs[2] = vobs[2] + ", VALOR ICMS SUBS. TRBT. "
                                                     +  string(vsubst).

        /* Fornecedor TIM emitirá a primeira nota com Valor de ST */
/***26/08/2014

        if forne.forcgc matches("*04206050*") /* TIM */
        then do:                 
            assign
                tt-plani.outras = tt-plani.outras + vsubst
                tt-plani.platot = tt-plani.platot + vsubst
                vobs[1] = vobs[1]   + ", BASE ICMS/ST: "
                                    + trim(string(vbsubst,">>>,>>>,>>9.99"))
                                    + ", VALOR ICMS/ST: "
                                    + trim(string(vsubst,">>>,>>>,>>9.99"))
                 vforn-tim = yes.
            
            assign vnumero-nf-origem = ""
                   vcont-prod-nfref = 0.
                       
            for each btt-nfref no-lock.
                       
                if vnumero-nf-origem = ""
                then assign vnumero-nf-origem = string(btt-nfref.numero).
                else assign vnumero-nf-origem = vnumero-nf-origem + ", "
                                                    + string(btt-nfref.numero).
                    
                for each movim where movim.etbcod = btt-nfref.etbcod
                                 and movim.placod = btt-nfref.placod
                                 and movim.movdat = btt-nfref.pladat
                                 and movim.movtdc = btt-nfref.movtdc
                               no-lock.
                    assign vcont-prod-nfref = vcont-prod-nfref + 1.
                end.                       
            end.       
                                    
            if vcont-prod-nfref > vcont-prod-dev
            then
                assign vobs[4] = vobs[4] 
                                       + "Devolucao parcial da NF de Origem: " 
                                       + vnumero-nf-origem
                                       + ".".
        end.
        else 
        26/08/2014***/

            assign
                tt-plani.bsubst = 0
                tt-plani.icmssubst = 0
                vforn-tim = no.
         
        update vobs[1] no-label
               vobs[2] no-label
               vobs[3] no-label
               vobs[4] no-label
               vobs[5] no-label
               vobs[6] no-label
               with frame f-obs centered title "Observacoes" width 110.
   
        assign 
            tt-plani.notobs[1] = vobs[1] + " " + vobs[2] + " " + vobs[3] + " "
            tt-plani.notobs[2] = vobs[4] + " " + vobs[5] + " " + vobs[6].

        sresp = no.            
    end.

    sresp = yes.
    message "Deseja visualizar o total da nota antes da emissao? 1.0"
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
        then assign
                tt-movimaux.valor_campo = tt-movimaux.valor_campo +
                   string(asstec.oscod) + " ".
        else vobs-os = vobs-os + string(asstec.oscod) + " ".
    end.
    if length(vobs-os) > 4 and length(vobs-os) < 400
    then tt-plani.notobs[3] = vobs-os.
        
    vok = no.        
    
    if vetbcod = 998 or vetbcod = 996 or vetbcod = 930
    then nfe-emite = 900.
    else nfe-emite = vetbcod.

    run manager_nfe.p (input "5411",
                       input ?,
                       output vok).

    /***
        SEGUNDA NFE
    ***/

    /**** pega numero da primeira emissao ****/
    vnumero1 = 0.
    if vok
    then do:
        find first tt-nfref1 where tt-nfref1.numero > 0 no-error.
        if avail tt-nfref1
        then vnumero1 = tt-nfref1.numero.        
    end.
    /*message "Numero da primeira NF: " vnumero1. pause.
    */
    /**********/    

    for each tt-plani. delete tt-plani. end.
    for each tt-movim. delete tt-movim. end.
        
    find first tt-plani1 no-error.
        
    if forne.fornom matches "*VIVO*" or
       forne.fornom matches "*BCP*"  or
       forne.forcod = 110678 /* CLARO S/A */
    then
        message "NAO EMITIRA SEGUNDA NF" view-as alert-box.


    do:
        /* Nao he TIM => apartir de 26/08 Tim tb entra aqui */
        for each tt-plani: delete tt-plani. end.
        for each tt-movim: delete tt-movim. end.

        do on error undo with frame f-5603 side-label 1 col row 8.
            update
                vbsubst validate (vbsubst > 0, "")
                vsubst  validate (vsubst > 0, "").
        end.

        if vsubst = 0
        then do:
            message
                "Valor de Substituicao ZERADO, a SEGUNDA NF nao sera emitida!"
                view-as alert-box. 
            leave.
        end.
        else
            message "Tecle ENTER para iniciar emissão da SEGUNDA NF"
                view-as alert-box. 
        
        /**
        vobs[2] = "E NF DEVOLUCAO " + string(vnumero1).
        **/
        
        if vnum-nota-aturizada > 0
        then assign vobs[2] = vobs[2] + " REFERENTE A MINHA NF DE DEVOLUCAO:"
                                    + string(vnum-nota-aturizada).

        find first tt-plani1 no-error.
        if tt-plani1.pladat < 10/01/07
        then do:
            if estab.ufecod = "RS"
            then find first copcom where copcom.opccod = "1603" no-lock.
            else find last copcom where copcom.opccod = "2603" no-lock.

            vserie  = "1".
            
            do on error undo:
                create tt-plani.
                assign
                    tt-plani.etbcod   = estab.etbcod
                    tt-plani.placod   = ?
                    tt-plani.protot   = 0 
                    tt-plani.desti    = estab.etbcod
                    tt-plani.bicms    = vbicms
                    tt-plani.icms     = vicms
                    tt-plani.bsubst   = 0
                    tt-plani.icmssubst = 0
                    tt-plani.descpro  = 0
                    tt-plani.acfprod  = 0
                    tt-plani.frete    = 0
                    tt-plani.seguro   = 0
                    tt-plani.desacess = 0
                    tt-plani.ipi      = 0
                    tt-plani.platot   = 0 
                    tt-plani.serie    = vserie
                    tt-plani.numero   = ?
                    tt-plani.movtdc   = 27
                    tt-plani.emite    = estab.etbcod
                    tt-plani.pladat   = today
                    tt-plani.modcod   = tipmov.modcod
                    tt-plani.opccod   = int(bopcom.opccod)
                    tt-plani.notfat   = estab.etbcod
                    tt-plani.dtinclu  = today
                    tt-plani.horincl  = time
                    tt-plani.notsit   = no
                    tt-plani.nottran  = vtrans
                    tt-plani.notobs[1] = vobs[1]
                    tt-plani.notobs[2] = vobs[2]
                    tt-plani.notobs[3] = vobs[3]
                    tt-plani.hiccod   = int(bopcom.opccod)
                    tt-plani.outras = 0
                    tt-plani.isenta = 0
                    tt-plani.notass = vnumero1.

                create tt-movim.
                ASSIGN 
                    tt-movim.movtdc = tt-plani.movtdc
                    tt-movim.PlaCod = tt-plani.placod
                    tt-movim.etbcod = tt-plani.etbcod
                    tt-movim.movseq = 1
                    tt-movim.procod = 418905
                    tt-movim.movqtm = 1
                    tt-movim.movpc  = 0
                    tt-movim.movdat = tt-plani.pladat
                    tt-movim.MovHr  = tt-plani.horincl
                    tt-movim.desti  = tt-plani.desti
                    tt-movim.emite  = tt-plani.emite
                    tt-movim.movicms = vicms.             
            end.
            
            run p-mostra-nota-limitado.
            sresp = no.
            message "Deseja visualizar o total da nota antes da emissao? 4.0"
                        update sresp.
            if sresp
            then run p-mostra-nota.


            if vetbcod = 998 or vetbcod = 996 or vetbcod = 930
            then nfe-emite = 900.
            else nfe-emite = vetbcod.
            vok = no.            
            run manager_nfe.p (input "1603",
                               input ?,
                               output vok).
            if vok
            then do:
                find first tt-nfref2 where tt-nfref2.numero > 0 no-error.
                if avail tt-nfref2
                then vnumero2 = tt-nfref2.numero.           
            end.
        end.
        else do:
            if forne.ufecod = "RS"
            then find first copcom where copcom.opccod = "5603" no-lock.
            else find last copcom where copcom.opccod = "6603" no-lock.

            do on error undo:
                create tt-plani.
                assign
                   tt-plani.etbcod  = estab.etbcod
                   tt-plani.placod  = ?
                   tt-plani.protot  = vsubst
                   tt-plani.desti   = if avail tt-plani1 and
                                         tt-plani1.pladat > 09/30/07
                                      then forne.forcod else estab.etbcod
                   tt-plani.bicms   = 0
                   tt-plani.icms    = 0
                   tt-plani.bsubst  = 0
                   tt-plani.icmssubst = 0
                   tt-plani.descpro = 0
                   tt-plani.acfprod = 0
                   tt-plani.frete   = 0
                   tt-plani.seguro  = 0
                   tt-plani.desacess = 0
                   tt-plani.ipi     = 0
                   tt-plani.platot  = vsubst 
                   tt-plani.serie   = vserie
                   tt-plani.numero  = ?
                   tt-plani.movtdc  = 27
                   tt-plani.emite   = estab.etbcod
                   tt-plani.pladat  = today
                   tt-plani.modcod  = tipmov.modcod
                   tt-plani.opccod  = int(copcom.opccod)
                   tt-plani.notfat  = estab.etbcod
                   tt-plani.dtinclu = today
                   tt-plani.horincl = time
                   tt-plani.notsit  = no
                   tt-plani.nottran = vtrans
                   tt-plani.notobs[1] = vobs[1]
                   tt-plani.notobs[2] = vobs[2]
                   tt-plani.notobs[3] = vobs[3]
                   tt-plani.hiccod  = int(copcom.opccod)
                   tt-plani.outras  = 0
                   tt-plani.isenta  = 0
                   tt-plani.notass = vnumero1
                   .

                find first w-movim where w-movim.marca = "*" no-lock no-error.

                create tt-movim.
                ASSIGN 
                    tt-movim.movtdc = tt-plani.movtdc
                    tt-movim.PlaCod = tt-plani.placod
                    tt-movim.etbcod = tt-plani.etbcod
                    tt-movim.movseq = 1
                    tt-movim.procod = 418905
                    tt-movim.movqtm = 1
                    tt-movim.movpc  = vsubst
                    tt-movim.movdat = tt-plani.pladat
                    tt-movim.MovHr  = tt-plani.horincl
                    tt-movim.desti  = tt-plani.desti
                    tt-movim.emite  = tt-plani.emite
                    tt-movim.movsubst = 0
                    tt-movim.movcsticms = "90".
                /*    
                if avail w-movim
                then tt-movim.movcsticms = string(w-movim.sittri).
                */
            end.

            if vetbcod = 998 or vetbcod = 996 or vetbcod = 930
            then nfe-emite = 900.
            else nfe-emite = vetbcod.
            vok = no.
            run manager_nfe.p (input "5603",
                           input ?,
                           output vok).
            if vok
            then do:
                find first tt-nfref3 where tt-nfref3.numero > 0 no-error.
                if avail tt-nfref3
                then vnumero3 = tt-nfref3.numero.
            end.
        end.
    end.
        
end procedure.


procedure p-mostra-nota:

    display tt-plani.bicms  
            tt-plani.icms 
            tt-plani.bsubst
            tt-plani.icmssubst
            tt-plani.protot   
            with frame f-mostra-1 overlay row 8 1 col.
                
    pause 0.

    display tt-plani.frete 
            tt-plani.seguro 
            tt-plani.desacess
            tt-plani.outras
            tt-plani.ipi     
            tt-plani.platot  
            with frame f-mostra-2 overlay row 8 col 45 1 col.

    pause 0.

    for each tt-movim.
        display tt-movim.procod
                tt-movim.movpc
                tt-movim.movdes
                tt-movim.movipi
                tt-movim.movalipi     
                tt-movim.movicms
                tt-movim.movalicms 
                tt-movim.movdev label "Frete"
                tt-movim.movsubst
                tt-movim.movsubst / 17 * 100 with 1 col.
    end.

    sresp = yes.
    message "Deseja alterar as informacoes?" update sresp.
    if sresp
    then do:
        update tt-plani.bicms  
               tt-plani.icms 
               tt-plani.bsubst
               tt-plani.icmssubst
               with frame f-mostra-1 overlay row 8.

        update tt-plani.frete 
               tt-plani.seguro 
               tt-plani.desacess
               tt-plani.outras
               tt-plani.ipi     
               tt-plani.platot  
               with frame f-mostra-2 overlay row 12.

        for each tt-movim.
            update tt-movim.movpc
                   tt-movim.movdes
                   tt-movim.movipi
                   tt-movim.movalipi
                   tt-movim.movicms
                   tt-movim.movalicms
                   tt-movim.movdev label "Frete"
                   tt-movim.movsubst with 1 col.
        end.
    end.

end procedure.

 
procedure p-mostra-nota-limitado:
        
    update tt-plani.bsubst
           tt-plani.icmssubst
           tt-plani.platot   
           with frame f-mostra-1 overlay row 8
                        title "AJUSTAR ICMS SUBSTITUICAO MP DO BEM".

    assign tt-movim.movsubst = tt-plani.icmssubst.

end procedure.

