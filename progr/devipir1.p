{admcab.i}
             
def new shared temp-table tt-for 
    field forcod like forne.forcod.
    
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-nfref like plani.

def var vok as log.

def var vqtm like movim.movqtm. 
def var vfrete-u like plani.frete.
def buffer copcom for opcom.
def buffer eplani for plani.
def var vdatref as date.
def var vsittri as char format "x(03)".
def var valor_icms like plani.platot.
def var base_icms  like plani.platot.
def var visenta    like plani.isenta.
def var voutras    like plani.outras.
def var v-procod like produ.procod.
def var vobs like plani.notobs format "x(70)".
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
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.   
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
                       w-movim.valdes    = movim.movdes
                       w-movim.movfre    = movim.movdev.
                vqtm = vqtm + movim.movqtm.
            end.
            vfrete-u = plani.frete / vqtm.
        end.                     
        
    
    end.

    /************************************************/
    find tipmov where tipmov.movtdc = 31 no-lock.
    /* 13 -  chamado 29383*/ 
    
    vserie = "U".

    if forne.ufecod = "RS"
    then find first opcom where opcom.opccod = "5202" no-lock.
    else find last opcom where opcom.opccod = "6202"  no-lock.
    
    vopccod = opcom.opccod.


    display vopccod
            opcom.opcnom with frame f1.


    update vdata 
           vpladat with frame f1. 

    run tt-devcom.p(input forne.forcod,
                    input vetbcod).  
                    
    vipi    = 0.
    vfrete = 0.
    for each w-movim where w-movim.marca = "*":
        vfrete = vfrete + (w-movim.movfre * w-movim.movqtm).
        vipi    = vipi  + w-movim.movipi.
    end.

    update base_icms_subst label "Base Icms Subst." format ">>>,>>9.99"
           icms_subst label "Icms Substituicao"     format ">>>,>>9.99"
           vfrete     label "Frete"                 format ">>>,>>9.99"
               with frame f2 side-label color white/cyan.
    
    hide frame f2 no-pause.  
        
    vobs[1] = "NF ORIGINAL: ".
    for each tt-plani1 by tt-plani1.numero:
        vobs[1] = vobs[1] + string(tt-plani1.numero) + ",".
    end.

    if vipi > 0 
    then vobs[1] = vobs[1] +  " VAL IPI: " + trim(string(vipi,">>,>>9.99")). 
    
    if vfrete > 0
    then vobs[1] = vobs[1] + " VAL FRETE: " + trim(string(vfrete,">>,>>9.99")). 
    
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
        
       /* vbicms  = vbicms  + base_icms. 29418*/
        
        vicms   = vicms   + valor_icms.

        vdescpro = vdescpro + (w-movim.movqtm * w-movim.valdes).
    end.

    
    vplatot = vprotot + vfrete - vdescpro.
    /*vbicms = vprotot - vdescpro.
    if vbicms > vplatot
    then vbicms = vplatot.  29418*/
        
    if forne.forcod = 100725
    then vprotot = vprotot - vdescpro.
    
    vbicms = (vprotot * 70.5883) / 100.   /*29418*/
    
    if vsubst > 0 
    then vobs[1] = vobs[1] +  " VALOR ICMS SUBS. TRBT. " 
                   +  string(vsubst).
    
    pause 0.
    
    /*
    if vbicms <= 0
    then update vbicms format ">>>,>>>,>>9.99" with frame f-obs.
     */

    vobs[2] = "Nota Fiscal emitida nos termos do art. 1o   " .
    vobs[3] = "do decreto no 7.712, de 03 de abril de 2012.".

    update vobs[1] no-label  format "x(78)"
           vobs[2] no-label   format "x(78)"
           vobs[3] no-label   format "x(78)"
                with frame f-obs centered title "Observacoes".

    /*message "Confirma impressao da nota fiscal" update sresp.
    if sresp
    then*/ do:
    sresp = no.
    message "Com ICMS ?" update sresp.
      
    if sresp = no
    then assign
            vbicms = 0
            vicms = 0.

    /***
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
    ****/
    vserie = "1".
    vnumero = ?.
    vplacod = ?.
    do on error undo:
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
               tt-plani.isenta = tt-plani.platot - 
               tt-plani.outras - tt-plani.bicms.
    end.
    vmovseq = 0.
    tt-plani.bicms = 0.
    tt-plani.icms = 0.
    tt-plani.protot = 0.
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
               tt-movim.movicms   = ((tt-movim.movpc * tt-movim.movqtm)
                                        * (tt-movim.MovAlICMS / 100))
                                  + ((w-movim.movfre * w-movim.movqtm)
                                        * (w-movim.MovAlICMS / 100))
               tt-movim.MovAlIPI  = w-movim.movalipi
               tt-movim.movipi    = w-movim.movipi
               tt-movim.movdes    = w-movim.valdes
               tt-movim.movdat    = tt-plani.pladat
               tt-movim.MovHr     = int(time)
               tt-movim.desti     = tt-plani.desti
               tt-movim.emite     = tt-plani.emite
               tt-movim.movdev    = w-movim.movfre.

        tt-plani.protot = tt-plani.protot +
            (tt-movim.movpc * tt-movim.movqtm).
        
         
        /**** Quando Fornecedor está no RS reduz base... *****/        
        if forne.ufecod = "RS"
        then do:
            
            tt-plani.bicms = tt-plani.bicms +
                    (((tt-movim.movpc * tt-movim.movqtm) * 70.5883) / 100).
                
            tt-plani.icms  = tt-plani.icms +
                        ((tt-movim.movicms * 70.5883) / 100).

         end.
         else do:
                
            tt-plani.bicms = tt-plani.bicms +
                    (tt-movim.movpc * tt-movim.movqtm) +
                    (tt-movim.movdev * tt-movim.movqtm).
                
            tt-plani.icms  = tt-plani.icms + tt-movim.movicms.

         end.
                
                
        /**       
        run atuest.p (input recid(movim),
                      input "I",
                      input 0).
        **/              
    end.
    
    sresp = no.
        
    message "Deseja visualizar o total da nota antes da emissao?" update sresp.
       
    if sresp
    then do:
    
        run p-mostra-nota.

    end.
    
    message "Confirma emissao da nota fiscal" update sresp.
    if sresp
    then do:
        /*
        run impdvcom.p (input recid(plani)).
        */
        
        run manager_nfe.p (input "devipi_5202",
                           input ?,
                           output vok).
    end.

    end. 
    
end.

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
            tt-plani.outras
                with frame f-mostra-2 overlay row 12 width 80.

            pause 0.

    sresp = no.
    
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
            tt-plani.outras
                with frame f-mostra-2 overlay row 12 width 80.
    
    end.

end procedure.


