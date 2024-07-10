{admcab.i}
             
def temp-table tt-for 
    field forcod like forne.forcod.

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

def var vobs       as char format "x(70)" extent 9.
def var vdata   like plani.pladat.
def var vforcod like forne.forcod.
def var vetbcod like estab.etbcod.
def var vpladat   like  plani.pladat.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms.
def var base_icms_subst like plani.bsubst.
def var icms_subst      like plani.icmssubst.
def var vprotot   like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete.
def var vseguro   like  plani.seguro.
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vnumant   like  plani.numero.
def var vserant   as char format "x(03)".
def var vprocod   like  produ.procod.
def var vopccod   like  opcom.opccod.
def var vmovseq     like movim.movseq.
def var vsubst like plani.platot.

def new shared temp-table w-movim
    field wrec      as   recid
    field redbas    as char format "x(01)"
    field movdat    like movim.movdat
    field numero    like plani.numero
    field marca     as char format "x(01)"
    field etbcod    like movim.etbcod
    field procod    like produ.procod
    field codfis    like clafis.codfis 
    field sittri    like clafis.sittri
    field movqtm    like movim.movqtm 
    field movpc     like movim.movpc format ">,>>9.99"
    field movbicms  like movim.movbicms
    field movalicms like movim.movalicms initial 17 
    field valicms   like movim.movicms
    field movicms   like movim.movicms
    field movalipi  like movim.movalipi 
    field movipi    like movim.movipi
    field movfre    like movim.movpc 
    field movdes    as dec format ">,>>9.9999"
    field valdes    as dec format ">,>>9.9999"
    field movcsticms like movim.movcsticms
    field predbc as dec
    field vicmsop as dec
    field pdif as dec
    field vicmsdif as dec
    field chave as char
       index ind-1 procod.
 
form vobs[1] no-label
         vobs[2] no-label
         vobs[3] no-label
         vobs[4] no-label
         vobs[5] no-label
         vobs[6] no-label
           with frame f-obs centered title "Observacoes".

form
    vetbcod label "Emitente" colon 17
    estab.etbnom no-label format "x(20)"
    vforcod label "Destinatario" colon 17
    forne.fornom  no-label
    vnumant label "Numero NF Origem" colon 17
    vserant label "Serie"  
    vopccod  label "Op. Fiscal" format "9999" colon 17 
    vobs[3] /*opcom.opcnom*/  no-label
    vdata         label "Data"      colon 17
    vpladat       colon 17
      with frame f1 side-label color white/cyan width 80 row 4.

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
    hide frame f1 no-pause.
    hide frame f2 no-pause.

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
    then undo.

    if forne.forcod = 100725 or
       forne.forcod = 110034
    then do:
        create tt-for.
        assign tt-for.forcod = 100725.
        create tt-for.
        assign tt-for.forcod = 110034.
    end.
    else do:
        create tt-for.
        assign tt-for.forcod = forne.forcod.
    end.
    
    do on error undo, retry:
        vserant = "U".
        update vnumant 
               vserant label "Serie" with frame f1.
        if vnumant <> ?
        then
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
                                         plani.etbcod = 900           and
                                         plani.movtdc = 4            and
                                         plani.serie  = vserant      and
                                         plani.numero = vnumant no-lock
                                         no-error.
                        if not avail plani
                        then 
                        find plani where plani.emite  = tt-for.forcod and
                                         plani.etbcod = 993           and
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
            if avail plani
            then do:

        find first tt-plani where tt-plani.numero = plani.numero no-error. 
        if not avail tt-plani 
        then do: 
            create tt-plani.  
            assign tt-plani.numero    = plani.numero
                   tt-plani.icmssubst = plani.icmssubst.
        end.
        
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
                             
            find first produ where produ.procod = movim.procod
                                        no-lock no-error.                 
                             
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
                       w-movim.movpc     = movim.movpc  
                       w-movim.movbicms  = movim.movbicms
                       w-movim.movalicms = movim.movalicms
                       w-movim.valicms   = movim.movicms 
                       w-movim.movalipi  = movim.movalipi   
                       w-movim.movipi    = movim.movipi 
                       w-movim.movdes    = movim.movpdes  
                       w-movim.valdes    = movim.movdes
                       w-movim.wrec      = recid(produ)
                       w-movim.movcsticms = movim.movcsticms
                       .
                find first n01_icms where n01_icms.chave = plani.ufdes and
                           n01_icms.nitem = movim.movseq
                           no-lock no-error.
                if avail n01_icms
                then assign 
                            w-movim.predbc = n01_icms.predbc
                            w-movim.vicmsop = n01_icms.vicmsop
                            w-movim.pdif = n01_icms.pdif
                            w-movim.vicmsdif = n01_icms.vicmsdif
                            w-movim.chave = n01_icms.chave
                            w-movim.movcsticms = string(n01_icms.cst)
                            .
                
            end.
            

        end.                     
        end.
        end.
    
    end.
    
    /************************************************/
    find tipmov where tipmov.movtdc = 26 no-lock.

    if forne.ufecod = "RS"
    then find first opcom where opcom.movtdc = tipmov.movtdc no-lock.
    else find last opcom where opcom.movtdc = tipmov.movtdc no-lock.
    
    vopccod = opcom.opccod.
    vobs[3] = opcom.opcnom.

   do on error undo, retry:
   
        update vopccod format "x(4)" with frame f1.

        if opcom.opccod <> vopccod
        then find last opcom where opcom.opccod = vopccod no-lock.
        
        vobs[3] = opcom.opcnom.

        display vobs[3] format "x(30)" with frame f1.
        
        update vobs[3] with frame f1.
        if vobs[3] = ""
        then undo. 
        vobs[3] = caps(vobs[3]).
        disp vobs[3] with frame f1.
        
    end.

    if opcom.opccod <> vopccod
    then find last opcom where opcom.opccod = vopccod no-lock.

    vobs[3] = opcom.opcnom.
    
    display vopccod format "x(4)"  vobs[3] format "x(30)" with frame f1.
    
    if vobs[3] = ""
    then undo.

    vdata   = today.
    vpladat = today.
    
/***
    update vdata
           vpladat with frame f1. 
***/
    update base_icms_subst label "Base Icms Subst." format ">>>,>>9.99"
           icms_subst label "Icms Substituicao"     format ">>>,>>9.99"
           vfrete     label "Frete"                 format ">>,>>9.99"
           with frame f2 side-label color white/cyan.       
        
    run tt-outsai.p(input forne.forcod,
                    input vetbcod).       

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
    if vsubst > 0 
    then vobs[1] = vobs[1] +  " VALOR ICMS SUBS. TRBT. "  +  string(vsubst).

    pause 0.
    
    display vobs[3] with frame f-obs centered title "Observacoes".
    
    update vobs[1] no-label
           vobs[2] no-label
           vobs[3] no-label 
           vobs[4] no-label
           vobs[5] no-label
           vobs[6] no-label
                with frame f-obs centered title "Observacoes".

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
    
/***
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
***/
        vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
        vbicms  = vbicms  + w-movim.movbicms.
        vicms   = vicms   + w-movim.valicms.
/***
        vbicms  = vbicms  + base_icms.        
        vicms   = vicms   + valor_icms.
***/
        vipi    = vipi    + ((w-movim.movqtm * w-movim.movpc) *
                             (w-movim.movalipi / 100)).
        vdescpro = vdescpro + (w-movim.movqtm * w-movim.valdes).
    end.

    vplatot = vprotot + vfrete - vdescpro.

    if forne.forcod = 100725
    then vprotot = vprotot - vdescpro.

    sresp = no.
    message "Confirma a emissao da Nota Fiscal?" update sresp.
    if sresp
    then run emissao-NFe.
    else undo, retry.
                    
end.
        
procedure emissao-NFe:
        
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.

    do on error undo:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = ?
               tt-plani.protot   = vprotot
               tt-plani.emite    = estab.etbcod
               tt-plani.bicms    = vbicms
               tt-plani.icms     = vicms
               tt-plani.frete    = vfrete
               tt-plani.alicms   = tt-plani.icms * 100 / (tt-plani.bicms *
                                (1 - (0 / 100)))
               tt-plani.descpro  = vdescpro
               tt-plani.acfprod  = vacfprod
               tt-plani.frete    = vfrete
               tt-plani.seguro   = vseguro
               tt-plani.desacess = vdesacess
               tt-plani.ipi      = vipi
               tt-plani.platot   = vprotot
               tt-plani.serie    = "1"
               tt-plani.numero   = ?
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = forne.forcod
               tt-plani.pladat   = vpladat
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = int(opcom.opccod)
               tt-plani.hiccod   = int(opcom.opccod)
               tt-plani.notfat   = forne.forcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.notobs[1] = vobs[1] + " " + vobs[2] + " "
               tt-plani.notobs[2] = vobs[3]
               tt-plani.notobs[3] = vobs[4] + " " + vobs[5] + " " + vobs[6]
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
              tt-plani.isenta = tt-plani.platot - tt-plani.outras
                                    - tt-plani.bicms.

        for each w-movim where w-movim.marca = "*":
            vmovseq = vmovseq + 1.

            find produ where recid(produ) = w-movim.wrec no-lock no-error.
            if not avail produ 
            then find first produ where 
                        produ.procod = w-movim.procod no-lock no-error.

            create tt-movim.
            ASSIGN 
                tt-movim.movtdc = tt-plani.movtdc
                tt-movim.PlaCod = tt-plani.placod
                tt-movim.etbcod = tt-plani.etbcod
                tt-movim.movseq = vmovseq
                tt-movim.procod = produ.procod
                tt-movim.movqtm = w-movim.movqtm
                tt-movim.movpc  = w-movim.movpc
                tt-movim.movdat = tt-plani.pladat
                tt-movim.MovHr  = tt-plani.horincl
                tt-movim.desti  = tt-plani.desti
                tt-movim.emite  = tt-plani.emite
                tt-movim.numprocimp = w-movim.chave
                .
            assign
                tt-movim.movbicms   = w-movim.movbicms
                tt-movim.movalicms  = w-movim.movalicms
                tt-movim.movicms    = w-movim.movbicms *
                    (w-movim.movalicms / 100)
                tt-movim.movcsticms = w-movim.movcsticms /* if tt-movim.movicms = 0
                                      then "90" else "00"*/.
        end.        
    end.

    sresp = yes.
    message "Deseja visualizar o total da nota antes da emissao?"
    update sresp.
    if sresp
    then run p-mostra-nota.

    def var p-ok as log init no.
    
    run manager_nfe.p (input "5949",
                       input ?,
                       output p-ok).
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
            with frame f-mostra-2 overlay row 12 width 80.
    pause 0.

    for each tt-movim.
        display tt-movim.procod
                tt-movim.movipi
                tt-movim.movalipi
                tt-movim.movbicms
                tt-movim.movicms
                tt-movim.movalicms
                tt-movim.movdev label "Frete" with 1 col.                
    end.
                    
    sresp = no.
    message "Deseja alterar as informacoes?" update sresp.
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
            update tt-movim.procod when false
                   tt-movim.movipi
                   tt-movim.movalipi
                   tt-movim.movicms
                   tt-movim.movalicms
                   tt-movim.movdev label "Frete" with 1 col.
        end.
    end.

end procedure.

