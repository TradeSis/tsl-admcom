{admcab.i}
             
def new shared temp-table tt-for 
    field forcod like forne.forcod.
    
def buffer copcom for opcom.
def buffer eplani for plani.
def buffer emovim for movim.
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

def new shared temp-table tt-plani like plani.
    

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

    create tt-for.
    tt-for.forcod = forne.forcod.
    
    do on error undo, retry:
        vserant = "U".
        update vnumant 
               vserant label "Serie" with frame f1.
        
        vachou-nf = no.    
        for each tt-for:

            find plani where plani.desti  = tt-for.forcod and
                             plani.etbcod = estab.etbcod and
                             plani.movtdc = 13            and
                             plani.serie  = vserant      and
                             plani.numero = vnumant no-lock no-error.
            if not avail plani
            then do:
                if estab.etbcod = 995
                then do:
                    find plani where plani.desti  = tt-for.forcod and
                                     plani.etbcod = 998           and
                                     plani.movtdc = 13            and
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
                    find plani where plani.desti  = tt-for.forcod and
                                     plani.etbcod = 995           and
                                     plani.movtdc = 13            and
                                     plani.serie  = vserant      and
                                     plani.numero = vnumant no-lock no-error.
                    if not avail plani
                    then do:
                        find plani where plani.desti  = tt-for.forcod and
                                         plani.etbcod = 993           and
                                         plani.movtdc = 13            and
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
            buffer-copy plani to tt-plani.
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
                       w-movim.marca = "*".
            end.
        end.                     
    end.
    
    /************************************************/
    find tipmov where tipmov.movtdc = 11 no-lock.
    vserie = "U".
    if forne.ufecod = "RS"
    then 
    find first opcom where opcom.opccod = "1949" no-lock.
    else find last opcom where opcom.opccod = "2949"  no-lock.
    
    vopccod = opcom.opccod.


    display vopccod
            opcom.opcnom with frame f1.


    update vdata 
           vpladat with frame f1. 
    /*
    update base_icms_subst label "Base Icms Subst." format ">>>,>>9.99"
           icms_subst label "Icms Substituicao"     format ">>>,>>9.99"
           vfrete     label "Frete"                 format ">>>,>>9.99"
               with frame f2 side-label color white/cyan.
    */
    hide frame f2 no-pause.  
    /**    
    run tt-emient.p(input forne.forcod,
                    input vetbcod).       
    **/
    vobs[1] = "NF ORIGINAL: ".
    for each tt-plani by tt-plani.numero:
        vobs[1] = vobs[1] + string(tt-plani.numero) + ",".
    end.

    vipi    = 0.
    for each w-movim where w-movim.marca = "*":
    
        vipi    = vipi    + ((w-movim.movqtm * w-movim.movpc) *
                             (w-movim.movalipi / 100)).
    end.
    
    if vipi > 0 
    then vobs[1] = vobs[1] +  " VALOR IPI: " +  string(vipi,">>,>>9.99"). 
    
    vsubst = 0.
    for each tt-plani:
        vsubst = vsubst + tt-plani.icmssubst.
    end.
    
    pause 0.

    for each w-movim:
        find produ where produ.procod = w-movim.procod no-lock.
        disp w-movim.redbas column-label "R" 
         w-movim.marca no-label 
         w-movim.numero column-label "Nota"
         w-movim.procod column-label "Codigo" format ">>>>>9"
         produ.pronom   column-label "Produto" format "x(17)"
        w-movim.movqtm format ">>>>9" column-label "Qtd"
        w-movim.movpc  format ">>,>>9.99" column-label "Val.Unit."
        w-movim.valdes format ">>,>>9.9999" column-label "Val.Desc"
        w-movim.movdes format ">9.9999" column-label "%Desc"
        w-movim.movalicms column-label "ICMS" format ">9.99"
         with frame frame-a  down overlay
                    centered color white/cyan width 80.
    end.


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
        w-movim.valicms = (w-movim.movqtm * w-movim.movpc) *
                            (w-movim.movalicms / 100).
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
                           
        vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
        
        vbicms  = vbicms  + base_icms.
        
        vicms   = vicms   + valor_icms.

        vipi    = vipi    + ((w-movim.movqtm * w-movim.movpc) *
                             (w-movim.movalipi / 100)).
        vdescpro = vdescpro + (w-movim.movqtm * w-movim.valdes).
    end.
    
    vplatot = vprotot + vfrete - vdescpro.

    vobs[1] = vobs[1] +  " NF " + string(vnumant) +
                    " NAO RECEBIDA PELO DESTINATARIO ".
    
    pause 0.
    
    if vbicms <= 0
    then update vbicms format ">>>,>>>,>>9.99" with frame f-obs.
    
    update vobs[1] no-label
           vobs[2] no-label
           vobs[3] no-label 
                with frame f-obs centered title "Observacoes".

    def var vatuest as log format "Sim/Nao" init no. 
    
    message "ATUALIZAR ESTOQUES ? " update vatuest.
    
    message "Confirma impressao da nota fiscal" update sresp.
    if sresp
    then do:
        find first tt-plani.
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
   /*                       plani.numero < 100000       and  */
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
                                   bplani.placod <> ? /*no-lock*/ no-error.
        if not avail bplani
        then vplacod =  1. 
        else vplacod = bplani.placod + 1.
    
        do on error undo:
            create eplani.
            assign eplani.etbcod   = estab.etbcod
               eplani.placod   = vplacod
               eplani.protot   = tt-plani.protot 
               eplani.emite    = estab.etbcod /*forne.forcod*/
               eplani.bicms    = tt-plani.bicms
               eplani.icms     = tt-plani.icms
               eplani.bsubst   = base_icms_subst
               eplani.icmssubst = icms_subst
               eplani.descpro  = vdescpro
               eplani.acfprod  = vacfprod
               eplani.frete    = vfrete
               eplani.seguro   = vseguro
               eplani.desacess = vdesacess
               eplani.ipi      = tt-plani.ipi
               eplani.platot   = tt-plani.platot 
               eplani.serie    = vserie
               eplani.numero   = vnumero
               eplani.movtdc   = tipmov.movtdc
               eplani.desti    = estab.etbcod
               eplani.pladat   = vpladat
               eplani.modcod   = tipmov.modcod
               eplani.opccod   = int(opcom.opccod)
               eplani.notfat   = estab.etbcod
               eplani.dtinclu  = today
               eplani.horincl  = time
               eplani.notsit   = no
               eplani.nottran  = vtrans
               eplani.dtinclu  = vdata
               eplani.notobs[1] = vobs[1]
               eplani.notobs[2] = vobs[2]
               eplani.notobs[3] = vobs[3]
               eplani.hiccod   = int(opcom.opccod)
               eplani.outras = eplani.frete  +
                              eplani.seguro +
                              eplani.vlserv +
                              eplani.desacess +
                              eplani.ipi   +
                              eplani.icmssubst
               eplani.isenta = eplani.platot - eplani.outras - eplani.bicms.
        end.
        for each w-movim where w-movim.marca = "*":
            vmovseq = vmovseq + 1.

            create emovim.
            ASSIGN emovim.movtdc = eplani.movtdc
               emovim.PlaCod = eplani.placod
               emovim.etbcod = eplani.etbcod
               emovim.movseq = vmovseq
               emovim.procod = w-movim.procod
               emovim.movqtm = w-movim.movqtm
               emovim.movpc  = w-movim.movpc
               emovim.MovAlICMS = w-movim.movalicms
               emovim.movicms   = w-movim.valicm
               emovim.MovAlIPI  = w-movim.movalipi
               emovim.movipi    = w-movim.movipi
               emovim.movdes    = w-movim.valdes
               emovim.movdat    = eplani.pladat
               emovim.MovHr     = int(time)
               emovim.desti     = eplani.desti
               emovim.emite     = eplani.emite.
            if vatuest
            then do:   
            run atuest.p (input recid(emovim),
                      input "I",
                      input 0).
            end.
        end.
        run impemient.p(recid(eplani)).
    end.
end.
