/*  nfent993-900.p  */
{admcab.i}

setbcod = 993.
def buffer bbestab for estab.

def var tot-mov-icms as dec.
def var p1 as int.
def var p2 as int.
def var fila as char format "x(20)".
def var recimp as recid.
def temp-table etiq-pallet
    field rec as int
    field pallet as dec
    field qtd like estoq.estatual.

def var vpavpro            as   int.
/*
def buffer bwmsplani-recep for  wmsplani.
def buffer wmsplani-recep  for  wmsplani.
def buffer wmsmovim-recep  for  wmsmovim.
def var vnumero-recep      like wmsplani.numero.
*/
def var vplacod-recep      like plani.placod.

def new global shared var etq-forne as char.
def new global shared var etq-nf    as char.

def var vpedid-especial as log.
def var vsresp2 as log format "Sim/Nao".
def var vfilenc like estab.etbcod.
/*def buffer bwmsplani for wmsplani.
*/
def var vnumero-enc like plani.numero.
def var vplacod-enc like plani.placod.
def var total_nota like plani.platot.
def var desp_acess like movim.movpc.
def var vsenha as int.
def var vv     as int.
def var xx     as char.
def var vestpro as int.
def buffer bmovim for movim.

def new shared temp-table tt-proemail
    field procod like produ.procod.

def var perc_dif as dec.
def var total_custo as dec format "->>,>>9.9999".
def var valor_rateio like plani.platot.
def var soma_icm_comdesc like plani.platot.
def var soma_icm_semdesc like plani.platot.
def var total_icm_calc   like movim.movpc.
def var total_pro_calc   like movim.movpc.
def var total_ipi_calc   like movim.movpc.
def var maior_valor like movim.movpc.
def var v-kit as log format "Sim/Nao".
def var libera_nota as log.
def var tranca as log.
def var valor_desconto as dec format ">>,>>9.9999".
def var v-red like clafis.perred.
def var vsub like movim.movpc.
def buffer bestab for estab.
def var vfre as dec format ">>,>>9.99".
def var vacr as dec format ">,>>9.99".
def var voutras like plani.outras.
def buffer btitulo for titulo.
def var vfrecod like frete.frecod.
def var totped like pedid.pedtot.
def var totpen like pedid.pedtot.
def var vok as l.
def var vcusto as dec format ">>,>>9.9999".
def var vpreco like estoq.estcusto.
def var vcria as log initial no.
def new shared workfile wfped field rec  as rec.
def buffer xestoq for estoq.
def var vlechave as log.
def var vlexml   as log.
def var vchave-nfe as char.
def var vdvnfe     as int.

def workfile wprodu
    field wpro like produ.procod
    field wqtd as int.

def temp-table tt-pavpro
    field recpro as   recid
    field pavcod as int.
    
def new shared temp-table w-movim 
    field wrec      as   recid 
    field codfis    like clafis.codfis 
    field sittri    as char format "xxx"
    field opfcod    like movim.opfcod
    field movqtm    like movim.movqtm 
    field movacfin  like movim.movacfin
    field subtotal  like movim.movpc format ">>>,>>9.99" column-label "Subtot" 
    field movpc     like movim.movpc format ">,>>9.99" 
    field movalicms like movim.movalicms initial 17 
    field valicms   like movim.movicms
    field valbicms  like movim.movbicms
    field movbicms  like movim.movbicms
    field movbicms2 like movim.movbicms
    field movicms   like movim.movicms
    field movicms2  like movim.movicms
    field movalipi  like movim.movalipi 
    field movipi    like movim.movipi
    field movfre    like movim.movpc 
    field movdes    as dec format ">,>>9.9999"
    field valdes    as dec format ">,>>9.9999".
    
def workfile wetique
    field wrec as recid
    field wqtd like estoq.estatual.

def NEW shared temp-table tt-xmlretorno
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)".

def var vtipo-op as char format "x(12)" extent 2 
    initial [" Normal "," Encomenda "].    
    
def var vdesc    like plani.descprod format ">9.99 %".
def var i as i.
def var Vezes as int format ">9".
def var Prazo as int format ">>9".
def var v-ok as log.
def var vforcod like forne.forcod.
def var vsaldo    as dec.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like plani.vencod.
def var vsubtotal like  movim.movqtm.
def var vpladat   like  plani.pladat.
def var vrecdat   like  plani.pladat label "Recebimento".
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vfrete    like  plani.frete format ">>,>>9.99".
def var vtipo-frete as int label "Tipo Frete".
def var vseguro   like  plani.seguro.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vtotal    like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(03)".
def var vopccod   like  opcom.opccod.
def var vhiccod   like  plani.hiccod initial 112.
def var vprocod   like  produ.procod.
def var vbiss     like  plani.biss.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotpag      like plani.platot.
def buffer bplani for plani.
def var recpro as recid.
def var ipi_item  like plani.ipi.
def var frete_item like plani.frete.
def var vdifipi as int.
def var frete_unitario like plani.platot.
def var qtd_total as int.
def var vrec as recid.
def buffer bforne for forne.
def var cgc-admcom like forne.forcgc.
def buffer bliped for liped.
def var vtipo as int format "99".
def var vdesval like plani.platot.
def var vobs as char format "x(14)" extent 5.
def var v-ped as int.
def temp-table waux
    field auxrec as recid.
def var vnum like pedid.pednum.
def var tipo_desconto as int.

def temp-table tt-titulo like titulo.

form tt-titulo.titpar
     tt-titulo.titnum
     prazo
     tt-titulo.titdtven
        validate(tt-titulo.titdtven > tt-titulo.titdtemi,
                            "Data para vencimento deve ser maior que emissao.")
     tt-titulo.titvlcob 
     validate(tt-titulo.titvlcob <= vplatot,
                    "Valor da parcela deve ser menor ou igual ao total da NF.")
     with frame ftitulo down centered color white/cyan.
     
form produ.procod column-label "Codigo" format ">>>>>9"
     w-movim.movqtm format ">>>>>9" column-label "Qtd"
     w-movim.movpc  format ">>,>>9.99" column-label "Val.Unit."
     w-movim.subtotal  format ">>>>,>>9.99" column-label "Subtot"
     w-movim.valdes format ">>>,>>9.9999" column-label "Val.Desc"
     w-movim.movdes format ">9.9999" column-label "%Desc"
     w-movim.movalicms column-label "ICMS" format ">9.99"
     w-movim.movalipi  column-label "IPI"  format ">9.99"
     w-movim.movfre    column-label "Frete" format ">>,>>9.99"
                    help "Informe o Frete TOTAL do Item"
     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.

form w-movim.codfis label "NCM/SH" /*"Class.Fiscal"*/ format "99999999"  
     w-movim.sittri label "CST"  /*"Situacao Trib."*/ 
     w-movim.opfcod label "CFOP" format "9999"
     v-kit          label "Kit" 
     w-movim.movipi label "Total IPI" 
     with frame f-sittri side-label centered row 10 overlay.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(23)"
     vprotot1 with frame f-produ centered color message side-label
                        row 6 no-box width 81.
form estab.etbcod label "Filial" colon 15
    estab.etbnom  no-label
    vchave-nfe   label "Cod Barras NFE" colon 15 format "x(44)"
    cgc-admcom    label "Fornecedor" colon 15
    forne.forcod no-label
    forne.fornom no-label
    vopccod  label "Op. Fiscal" format "9999" colon 15 
    opcom.opcnom  no-label
    vnumero       colon 15
    vserie        label "Serie"
    vpladat colon 15
    vrecdat colon 39
    vfrecod label "Transp." colon 15
    frete.frenom no-label
    vtipo-frete
    vfrete label "Frete"
    with frame f1 side-label width 80 row 4 color white/cyan.

def var vbase_subst like plani.bsubst.
def var v_subst     like plani.icmssubst.
def var voutras_acess like plani.platot.
def var vdtaux as date.
def var simpnota as log format "Sim/Nao".
def var vpro-cod like movcon.procod.
def var ped-filenc like estab.etbcod.
def buffer xestab for estab.

form vbicms        label "Base Icms"  colon 17
     vicms         label "Valor Icms" colon 50
     vbase_subst   label "Base Icms Subst" colon 17
     v_subst       label "Valor Substituicao" colon 50
     vprotot       label "Tot.Prod."          colon 50
     vfre          label "Frete"  colon 17
     vseguro       label "Seguro" colon 50
     voutras_acess label "Desp.Acessorias" colon 17
     vipi          label "IPI" colon 50
     vplatot       label "Total" format ">>,>>>,>>9.99" colon 50
     with frame f2 overlay row 14 width 80 side-label.

do:
    clear frame f1 no-pause.
    clear frame f2 no-pause.
    clear frame f-produ no-pause.
    clear frame f-produ1 no-pause.
    clear frame f-produ2 no-pause.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause .
    hide frame f-produ2  no-pause.
    hide frame f1 no-pause.
    hide frame f2 no-pause.
    prompt-for estab.etbcod with frame f1.
    vetbcod = input frame f1 estab.etbcod.
    {valetbnf.i estab vetbcod ""Filial""}

    run p-deleta-tmp.
    
    display estab.etbcod
            estab.etbnom with frame f1.
            
    vetbcod = estab.etbcod.
    
    vserie = "01".
    
    if vetbcod <> 993
    then do:
        message "Deposito Invalido".
        pause.
        undo, leave.
    end.

    v-kit = no.
    libera_nota = no.
    
    update vchave-nfe with frame f1.
    
    if length(vchave-nfe) = 44
    then do:
        /* Digito Verificador */
        run nfe_caldvnfe11.p (input dec(substr(vchave-nfe,1,43)),
                              output vdvnfe).
        if substr(vchave-nfe,44,1) <> string(vdvnfe)
        then do.
            message "Chave da NFE invalida" view-as alert-box.
            undo.
        end.

        assign cgc-admcom = substring(vchave-nfe,7,14)
               vserie     = string(int(substring(vchave-nfe,23,3)))
               vnumero    = int(substring(vchave-nfe,26,9)).
               vlechave   = yes.
    
        display cgc-admcom
                vserie
                vnumero with frame f1.
/*** ***/
        run not_nfedistr.p(vetbcod, vchave-nfe, output sresp).
        if not sresp
        then undo.
/*** ***/
    end.
    else vlechave = no.

    update cgc-admcom when vlechave = no with frame f1.
    
    find first forne where forne.forcgc = cgc-admcom
                       and forne.ativo
                     no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao Cadastrado !!".
        undo, retry.
    end.
    display forne.forcod forne.fornom with frame f1.
    
    find last cpforne where cpforne.forcod = forne.forcod no-lock no-error.
    if avail cpforne
        and date(cpforne.date-1) <> ?
        and date(cpforne.date-1) <= today
        and length(vchave-nfe) <> 44
    then do:
        message "Fornecedor NFE desde " string(cpforne.date-1,"99/99/9999") skip
                " Informe a chave de acesso do DANFE! " view-as alert-box. 
        undo,retry.
    end.

    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo, retry.

    if forne.forcod = 5027
    then do:
        message "Fornecedor Invalido".
        undo, retry.
    end.    
    
    if forne.forpai = 0
    then vrec = recid(forne).
    else do:
        find bforne where bforne.forcod = forne.forpai no-lock no-error.
        if not avail bforne
        then do:
            message "Fornecedor pai nao cadastrado".
            undo, retry.
        end.
        else vrec = recid(bforne).
    end.    

    vdesval = 0.
    vdesc   = 0.
    valor_rateio = 0.
    
    run nffped.p (input vrec,
                  0).
                  
    find first wfped no-lock no-error.
    if not avail wfped
    then do:
        message "Para continuar selecione pelo menos um pedido.".
        undo.
    end.       
                    
    ped-filenc= 0.
    for each wfped: 
        find pedid where recid(pedid) = wfped.rec no-lock no-error.
        if not avail pedid
        then next.
        ped-filenc = int(acha("Filial destino",pedid.pedobs[1])) no-error.
        find xestab where xestab.etbcod = ped-filenc no-lock no-error.
        if not avail xestab
        then next.
        leave.
    end.          
    find xestab where xestab.etbcod = ped-filenc no-lock no-error. 
    if not avail xestab
    then ped-filenc = 0.
    
    vforcod = forne.forcod.
    
    if forne.ufecod = "RS"
    then find first opcom where opcom.movtdc = 4
                            and opcom.opccod = "1102" no-lock.
    else find last opcom where opcom.movtdc = 4 no-lock.
    vopccod = opcom.opccod.

    do on error undo, retry:
        update vopccod with frame f1.
        find opcom where opcom.opccod = vopccod no-lock no-error.
        if not avail opcom
        then do:
            message "Operacao Fiscal Invalida".
            pause.
            undo, retry.
        end.
    end.                    
    
    vhiccod = int(opcom.opccod).
    display vopccod
            opcom.opcnom with frame f1.
    display vserie with frame f1.
    update vnumero validate(vnumero > 0, "Numero Invalido") when vlechave = no
           with frame f1.
    if vlechave = no
    then run valida-serie.
    disp vserie with frame f1.

    sresp = yes.
    run valida-emite-serie-numero.
    if sresp = no then undo.
    
    find first plani where plani.numero = vnumero and
                           plani.emite  = vforcod and
                           plani.desti  = estab.etbcod and
                           plani.serie  = vserie and
                           plani.etbcod = estab.etbcod and
                           plani.movtdc = 4 no-lock no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.

    assign
        vpladat = ?
        simpnota = no
        vbicms  = 0
        vicms   = 0
        vprotot1 = 0
        vipi    = 0
        vdescpro = 0
        vplatot = 0
        vtotal  = 0
        voutras = 0
        vacr    = 0
        vfre    = 0
        vseguro = 0
        vprotot = 0.
    
    find first placon where placon.movtdc = 4 and
                      placon.etbcod = estab.etbcod and
                      placon.emite = forne.forcod and
                      placon.serie = "EL" and
                      placon.numero = vnumero
                      no-lock no-error.
    if avail placon
    then do:
        simpnota = no.
        message "Importar Nota Fiscal ?" update simpnota.
        if simpnota
        then do:
            for each movcon where movcon.etbcod = placon.etbcod and
                                  movcon.placod = placon.placod.
                find produ where produ.procod = movcon.procod and
                                 produ.proindice <> ?
                            no-lock no-error.
                if not avail produ
                then do:
                    disp string(movcon.movctm,"9999999999999")
                        format "x(13)" label "Cod. EAN"
                        acha("DES-" + string(movcon.movseq,"999"),
                                placon.notobs[2]) label "Produto"
                                 format "x(30)"
                        with frame f-proean 1 down centered row 10.
                    do on error undo, retry:
                        vpro-cod = 0.
                        update vpro-cod format ">>>>>>>9"
                        with frame f-proean.
                        find produ where produ.procod = movcon.procod no-error.
                        if avail produ
                        then assign
                                movcon.procod = vpro-cod
                                produ.proindice = 
                                string(movcon.movctm,"9999999999999").
                        else undo.        
                    end.
                end. 
                find produ where produ.procod = movcon.procod no-lock no-error.
                if not avail produ then next.         
                find first w-movim where
                           w-movim.wrec = recid(produ) no-error.
                if not avail w-movim
                then do:                        
                    create w-movim.
                    assign
                        w-movim.wrec = recid(produ).
                end.
                assign
                    w-movim.movqtm = movcon.movqtm
                    w-movim.movacfin = movcon.movacfin
                    w-movim.movpc  = movcon.movpc
                    w-movim.movalicms = movcon.movalicms
                    w-movim.valicms  = movcon.movalicms
                    w-movim.movbicms = movcon.movbicms
                    w-movim.movicms  = movcon.movicms
                    w-movim.movalipi = movcon.movalipi 
                    w-movim.movipi = movcon.movipi
                    w-movim.movdes = movcon.movdes.
            end.     
            assign
                vpladat = placon.pladat
                vfrete  = placon.frete.   
            find bforne where bforne.forcod = placon.nottran no-lock no-error.
            if avail bforne
            then vfrecod = forne.forcod.   
        
        assign
            vfrecod   = 0
            vfrete    = placon.frete
            vdesval   = placon.descprod
            vbicms    = placon.bicms
            vicms     = placon.icms
            vbase_subst = placon.bsubst
            v_subst   = placon.icmssubst
            vprotot   = placon.protot
            vseguro   = placon.seguro
            voutras_acess = placon.desacess
            vipi      = placon.ipi
            vplatot   = placon.platot
            vfre      = placon.frete.
        end.             
    end.                  
    else if vlechave
    then run xml-retorno.

    find tipmov where tipmov.movtdc = 4 no-lock.
    vdesc = 0.
    vrecdat = today.
    do on error undo:
        update vpladat when vlexml = no
               with frame f1.
        {valdatnf.i vpladat vrecdat}
    end.

    tranca = yes.

    find autctb where autctb.movtdc = 4 and
                      autctb.emite  = vforcod and
                      autctb.datemi = vpladat and
                      autctb.serie  = vserie  and
                      autctb.numero = vnumero no-lock no-error.
    if avail autctb
    then tranca = no.
    

    update vfrecod with frame f1.
    find frete where frete.frecod = vfrecod no-lock.
    display frete.frenom no-label with frame f1.
    vvencod = vfrecod.
    
    repeat on endkey undo:
        update vtipo-frete format "9"
            help "Informe 0 para CIF(emitente) ou 1 para FOB(destino)"
            with frame f1.
        if vtipo-frete = 0 or
           vtipo-frete = 1
        then leave.
        else message color red/with
            "Informe 0 para CIF(emitente) ou 1 para FOB(destino)"
            view-as alert-box title " Tipo Frete ".
    end.
    
    if vtipo-frete = 0
    then do:
        update vfrete label "Valor Frete" with frame f1.
    end.
    else vfrete = 0.
    
    tipo_desconto = 1.
    display "( 1 ) Sem Desconto                           " 
            "( 2 ) Desconto Total na Nota                 " 
            "( 3 ) Percentual de Desconto por Item        " 
            "( 4 ) Valor de Desconto por Val.Unitario     " 
            "( 5 ) Valor de Desconto por Val.Total do Item"
                with frame f-des 1 column centered title "Tipo de Desconto".
                
    do on error undo, retry:
        update tipo_desconto format "9" label "Tipo Desconto"
                with frame f-des1 side-label centered no-box
                       color message.
        if tipo_desconto < 1 or
           tipo_desconto > 5
        then do:
            message "Opcao Invalida".
            undo, retry.
        end.
    end.                    
    if tipo_desconto = 2
    then do on error undo, retry:
        update vdesval label "Desconto Total da Nota"
                    with frame f-des2 side-label centered.
        if vdesval = 0
        then do:
            message "Valor Invalido".
            pause.
            undo, retry.
        end.
    end.
    hide frame f-des2 no-pause.                
    hide frame f-des1 no-pause.
    hide frame f-des  no-pause.

    disp
        vbicms 
        vicms  
        vbase_subst  
        v_subst      
        vprotot
        vfre
        vseguro
        voutras_acess
        vipi
        vplatot
        with frame f2.

    do on error undo, retry:
/***
    assign vbicms  = 0
           vicms   = 0
           vprotot1 = 0
           vipi    = 0
           vdescpro = 0
           vplatot  = 0
           vtotal = 0.
           voutras = 0.
           vacr    = 0.
           vfre    = 0.
           vseguro = 0.
           vprotot = 0.
    if avail placon and simpnota
    then
        assign
            vfrecod   = 0
            vfrete    = placon.frete
            vdesval   = placon.descprod
            vbicms    = placon.bicms
            vicms     = placon.icms
            vbase_subst = placon.bsubst
            v_subst   = placon.icmssubst
            vprotot   = placon.protot
            vseguro   = placon.seguro
            voutras_acess = placon.desacess
            vipi      = placon.ipi
            vplatot   = placon.platot
            vfre      = placon.frete.
***/
    
    do on error undo:
        hide frame f-obs no-pause.
    
        if vlexml = no
        then update vbicms 
               vicms  
               vbase_subst  
               v_subst      
               vprotot with frame f2.
        
        valor_rateio = vprotot.
       
        if vbicms = 0 or
           vicms  = 0
        then do:
            vobs[1] = "ICMS DESTACADO".
            vobs[2] = "M.E.".
            vobs[3] = "GAS".
            vobs[4] = "NEW FREE".
            vobs[5] = "SUBST. TRIBUT.".

            display "1§ " TO 05 vobs[1] no-label 
                    "2§ " TO 05 vobs[2] no-label 
                    "3§ " TO 05 vobs[3] no-label 
                    "4§ " to 05 vobs[4] no-label
                    "5§ " to 05 vobs[5] no-label
                        with frame f-icms side-label row 5
                                 overlay columns 50.
           
            update vtipo label "Escolha" format "99" 
                           with frame f-icms2 side-label columns 58
                                           row 04 no-box. 
            
            if vtipo <> 1 and
               vtipo <> 2 and
               vtipo <> 3 and
               vtipo <> 4 and
               vtipo <> 5
            then do:
                message "Opcao Invalida".
                undo, retry.
            end.
            if vtipo = 1
            then do:
                vobs[1] = "N§______  DE __/__/__".
                update vobs[1] label "Obs" format "x(21)"
                        with frame f-obs side-label
                                                centered color message.
                if substring(vobs[1],04,1) = "_" or
                   substring(vobs[1],04,1) = ""  or
                   substring(vobs[1],14,1) = "_" or
                   substring(vobs[1],14,1) = ""
                then do:
                    message "Informar nota fiscal".
                    undo, retry.
                end.
            end.
        end.
        
        hide frame f-obs no-pause.
    end.

    do on error undo, retry:

        update vfre when vlexml = no with frame f2.
        /*
        if vfre > 0
        then do:
            vsenha = 0.
            xx = string(year(today),"9999")  + 
                 string(month(today),"99") +
                 string(day(today),"99").
            
            vv =  (( (int(xx) * 0.5) - (vnumero * 4))). 
             
            update vsenha label "Senha" format ">>>>>>>>9"
                    with frame f-senha centered side-label.
            if vv <> vsenha        
            then do:
                message "Senha invalida".
                pause.
                undo, retry.
            end.
        end.
        */        
    end.

    if vlexml = no
    then update vseguro with frame f2.
    
    do on error undo, retry:

        update voutras_acess when vlexml = no with frame f2.
        if voutras_acess > 0
        then do:
            vsenha = 0.
            xx = string(year(today),"9999")  + 
                 string(month(today),"99") +
                 string(day(today),"99").
            
            vv =  (( (int(xx) * 0.5) - (vnumero * 4))). 

            update vsenha label "Senha" format ">>>>>>>>9"
                    with frame f-senha centered side-label.
            if vv <> vsenha        
            then do:
                message "Senha invalida".
                pause.
                undo, retry.
            end.
        end.        
    end.
    
    hide frame f-senha no-pause.
    if vlexml = no
    then update vipi 
           vplatot with frame f2.
    
    if vplatot > 0 and vbicms > vplatot
    then do:
        message color red/with
        "Valor BASE DO ICMS nao pode ser maior que o TOTAL DOS PRODUTOS."
        view-as alert-box.
        undo, retry.
    end.        
    
    if vbicms = vplatot and
       voutras_acess > 0
    then assign vbiss = voutras_acess
                voutras_acess = 0.
        
    if tranca
    then do:
        if vforcod = 100725 
        then do: 
            if vplatot <> (vprotot + voutras_acess + vfre + vseguro
                           + vipi + v_subst) 
            then do:     
                message "Valor Total da Nota nao fecha".  
                undo, retry.
            end.
        end. 
        else do:  
            if tipo_desconto = 1 or
               tipo_desconto = 2
            then do:    
                if vplatot <> (vprotot + voutras_acess +   vfre +  
                               vseguro +  vipi +   v_subst -  vdesval)
                then do:     
                    if (vplatot - vbiss) <> 
                       (vprotot + voutras_acess + vfre + 
                        vseguro +   vipi +    v_subst)
                    then do:
                        message "Valor Total da Nota nao fecha".  
                        message vplatot (vprotot + 
                                         voutras_acess +
                                         vfre +    
                                         vseguro + 
                                         vipi +    
                                         v_subst -     
                                         vdesval).
                        pause. 
                        undo, retry.
                    end.
                    else valor_rateio = vprotot + vdesval. 
                end.
                else valor_rateio = vprotot.
            end.
        end.
    end.
    
    hide frame f-obs no-pause.
    clear frame f-produ1 no-pause.
    
    if vhiccod <> 599 and
       vhiccod <> 699
    then do:
    bl-princ:
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        vprotot1 = 0. 
        clear frame f-produ1 all no-pause.
        if simpnota = no
        then
        for each w-movim where w-movim.movqtm = 0 or
                               w-movim.movpc  = 0 or
                               w-movim.subtotal = 0:
            delete w-movim.
        end.    
        for each w-movim with frame f-produ1:
            find produ where recid(produ) = w-movim.wrec no-lock no-error.
            
            if not avail produ
            then next.
            
            display produ.procod
                    w-movim.movqtm
                    w-movim.valdes
                    w-movim.movdes
                    w-movim.subtotal
                    w-movim.movpc
                    w-movim.movalicms
                    w-movim.movalipi
                    w-movim.movfre  with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot1 = vprotot1 + (w-movim.movqtm * w-movim.movpc).
            display vprotot1 with frame f-produ.
        end.
        hide frame f-sittri no-pause.
        libera_nota = no.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4 
                                  F10 E e C c a A) with frame f-produ.
                                  
        if keyfunction(lastkey) = "end-error" 
        then do:
            /*
            hide frame f-produ no-pause.
            run difnfped.p ( input vrec ) .
            */
            sresp = no.
            message "Confirma Geracao de Nota Fiscal" update sresp.
            if not sresp
            then do:
                for each w-movim:
                    delete w-movim.
                end.
                vprocod = 0.
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
                setbcod = 900.
                undo, return.
            end.
            else do:
                find first w-movim no-error.
                if not avail w-movim and
                (opcom.opccod = "1949"  or
                 opcom.opccod = "2949"  or
                 opcom.opccod = "1922"  or
                 opcom.opccod = "2922") 
                then do:
                    if ((vicms >= soma_icm_comdesc - 1) and
                        (vicms <= soma_icm_comdesc + 1)) 
                    then do:
                        total_icm_calc = soma_icm_comdesc.
                        
                        for each w-movim:
                            w-movim.valbicms = w-movim.movbicms.
                            w-movim.valicms  = w-movim.movicms.
                        end.
                    end.
                    else do:
                        total_icm_calc = soma_icm_semdesc.
                        for each w-movim:
                            w-movim.valbicms = w-movim.movbicms2.
                            w-movim.valicms  = w-movim.movicms2.
                        end.
                    end. 
                    if ((vprotot >= vprotot1 - 1) and
                        (vprotot <= vprotot1 + 1)) 
                    then total_pro_calc = vprotot1.
                    else total_pro_calc = vprotot1 - vdesval.

                    hide frame f2 no-pause.

                    if opcom.opccod <> "1910" and
                       opcom.opccod <> "2910" and
                       opcom.opccod <> "2949"
                    then run atu-fat-finan.

                    libera_nota = yes.
                    leave bl-princ.
                end.
                else do:
                    if v-kit
                    then do:
                        if ((vprotot >= vprotot1 - 1) and
                            (vprotot <= vprotot1 + 1)) or
                           ((vprotot >= (vprotot1 - vdesval) - 1) and
                            (vprotot <= (vprotot1 - vdesval) + 1))
                        then.    
                        else do:
                            message "Total dos Produtos nao confere "
                            vprotot vprotot1 vdesval.
                            pause.
                            undo, retry.
                        end.
                    end. 
                    
                    if tranca 
                    then do:                        
                        if ((vprotot >= vprotot1 - 1) and
                            (vprotot <= vprotot1 + 1)) or
                           ((vprotot >= (vprotot1 - vdesval) - 1) and
                            (vprotot <= (vprotot1 - vdesval) + 1))
                        then.    
                        else do:
                            message "Total dos Produtos nao confere "
                            vprotot vprotot1 vdesval.
                            pause.
                            undo, retry.
                        end.

                        if (((vicms >= soma_icm_comdesc - 1) and
                            (vicms <= soma_icm_comdesc + 1)) or
                           ((vicms >= soma_icm_semdesc - 1) and
                            (vicms <= soma_icm_semdesc + 1))) or 
                           vbase_subst > 0 
                        then.
                        else do:
                            /*message soma_icm_comdesc soma_icm_semdesc.
                             pause.*/
                            message "Valor Icms Nao Confere: CAPA= " vicms  
                                    " ITEM C/Desconto= " soma_icm_comdesc 
                                    " ITEM S/DESCONTO= " soma_icm_semdesc.
                            pause. 
                            undo, retry. 
                        end.

                        if ((vipi >= ipi_item - 1) and
                            (vipi <= ipi_item + 1)) 
                        then.
                        else do:
                            message 
                            "IPI Nao Confere CAPA= " vipi " ITEM= " ipi_item. 
                            pause. 
                            undo, retry. 
                        end.
                        
                        if ((vfre >= frete_item - 1) and
                            (vfre <= frete_item + 1)) 
                        then.
                        else do:
                            message "FRETE Nao Confere CAPA= " 
                                     vfre " ITEM= " frete_item. 
                            pause. 
                            undo, retry. 
                        end.
                    end.
                    
                    if ((vicms >= soma_icm_comdesc - 1) and
                        (vicms <= soma_icm_comdesc + 1)) 
                    then do:
                        total_icm_calc = soma_icm_comdesc.
                        
                        for each w-movim:
                            w-movim.valbicms = w-movim.movbicms.
                            w-movim.valicms  = w-movim.movicms.
                        end.
                    end.
                    else do:
                        total_icm_calc = soma_icm_semdesc.
                        
                        for each w-movim:
                            w-movim.valbicms = w-movim.movbicms2.
                            w-movim.valicms  = w-movim.movicms2.
                        end.
                    end. 
                    if ((vprotot >= vprotot1 - 1) and
                        (vprotot <= vprotot1 + 1)) 
                    then total_pro_calc = vprotot1.
                    else total_pro_calc = vprotot1 - vdesval.
 
                    hide frame f2 no-pause.
                    
                    if opcom.opccod <> "1910" and
                       opcom.opccod <> "2910" and
                       opcom.opccod <> "2949"
                    then run atu-fat-finan.

                    libera_nota = yes.
                    leave bl-princ.
                end.
            end.
            tot-mov-icms = 0.
            for each w-movim:
                tot-mov-icms = tot-mov-icms + w-movim.valicms.
            end.    
            if vicms >= tot-mov-icms - 1 and
               vicms <= tot-mov-icms + 1
            then do:
                message color red/with "Valor de icms difere entre CAPA " vicms
                    " e ITENS " tot-mov-icms
                    view-as alert-box.
                next bl-princ.                
            end.
        end.
        
        if lastkey = keycode("a") or lastkey = keycode("A")
        then do:
            find produ where produ.procod = input vprocod no-lock.            
            find first w-movim where w-movim.wrec = recid(produ) no-error.

            update w-movim.movacfin label "Acrescimo Financeiro"
                    with frame f-acr side-label centered overlay. 
            
            w-movim.subtotal = w-movim.subtotal + w-movim.movacfin.
            w-movim.movpc = w-movim.subtotal / w-movim.movqtm.
            hide frame f-acr no-pause.
               
            vprotot1 = 0. 
            soma_icm_comdesc = 0. 
            soma_icm_semdesc = 0. 
            ipi_item  = 0.
            frete_item = 0.
            /*clear frame f-produ1 all no-pause.*/

            qtd_total = 0. 
            desp_acess = 0.
            for each w-movim: 
                qtd_total = qtd_total + w-movim.movqtm. 
            end.    

            desp_acess = vbiss / qtd_total.

            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock.
                display produ.procod 
                        w-movim.movqtm 
                        w-movim.valdes 
                        w-movim.movdes 
                        w-movim.subtotal 
                        w-movim.movpc 
                        w-movim.movalicms 
                        w-movim.movalipi 
                        w-movim.movfre with frame f-produ1.

                down with frame f-produ1.
                pause 0.

                w-movim.movbicms2 = (w-movim.movqtm * (w-movim.movpc + 
                                                       w-movim.movfre +
                                                       desp_acess)) *
                                    (1 - (v-red / 100)).
                w-movim.movicms2  = w-movim.movbicms2 
                                    * w-movim.movalicms / 100.
                soma_icm_semdesc  = soma_icm_semdesc + w-movim.movicms2. 
            
                if tipo_desconto < 5
                then do:
                    w-movim.movbicms = (w-movim.movqtm * (w-movim.movpc +  
                                                           desp_acess +
                                                           w-movim.movfre -
                                                       w-movim.valdes)) *
                                        (1 - (v-red / 100)).
                    w-movim.movicms  = w-movim.movbicms 
                                       * w-movim.movalicms / 100.
                    soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 

                    if w-movim.movalipi <> 0
                    then w-movim.movipi = ((w-movim.movpc + 
                                       w-movim.movfre -
                                       w-movim.valdes) * w-movim.movqtm) * 
                                     (w-movim.movalipi / 100).
                
                    ipi_item = ipi_item + w-movim.movipi.
                    frete_item = frete_item + 
                                 (w-movim.movfre * w-movim.movqtm).
                end.
                else do:
                    w-movim.movbicms = (w-movim.movqtm * (w-movim.movpc + 
                                         desp_acess +
                                         w-movim.movfre -
                                        (w-movim.valdes / w-movim.movqtm))) *
                                        (1 - (v-red / 100)).
                    w-movim.movicms  = w-movim.movbicms *
                                        (w-movim.movalicms / 100).

                    soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 

                    if w-movim.movalipi <> 0
                    then w-movim.movipi = ((w-movim.movpc + 
                                            w-movim.movfre /*-
                                           (w-movim.valdes / w-movim.movqtm)*/) 
                                           * w-movim.movqtm) * 
                                           (w-movim.movalipi / 100).

                     ipi_item = ipi_item + w-movim.movipi.
                     frete_item = frete_item + 
                                (w-movim.movfre * w-movim.movqtm).
                end.
                       
                vprotot1 = vprotot1 + w-movim.subtotal.
                display vprotot1 with frame f-produ.
            end.
            next.
        end.
        
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            run p-consulta.
        end.
        
        if lastkey = keycode("e") or lastkey = keycode("E")
        then do:
            vcria = no.
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
                    
                    find first tt-pavpro where 
                               tt-pavpro.recpro = recid(produ) no-error.
                    if avail tt-pavpro
                    then delete tt-pavpro.
                    
                end.    
                else w-movim.movqtm = w-movim.movqtm - vqtd.
                hide frame f-exclusao no-pause.
            end.
            vprotot1 = 0.
            clear frame f-produ1 all no-pause.
            for each w-movim with frame f-produ1:
                find produ where recid(produ) = w-movim.wrec no-lock.
                display produ.procod
                        w-movim.movqtm
                        w-movim.valdes
                        w-movim.movdes
                        w-movim.subtotal
                        w-movim.movpc
                        w-movim.movalicms
                        w-movim.movalipi
                        w-movim.movfre   with frame f-produ1.
                down with frame f-produ1.
                pause 0.
                vprotot1 = vprotot1 + (w-movim.movqtm * w-movim.movpc).
                display vprotot1 with frame f-produ.
            end.
            next.
        end.
        
        vant = no.
        
        find produ where produ.procod = input vprocod no-lock no-error.
        if not avail produ and (vhiccod <> 699 and vhiccod <> 599)
        then do:
            message "Produto nao Cadastrado".
            undo.
        end.
        else do:
            if produ.proseq = 99 or produ.proseq = 98
            then do:
                message color red/with
                "Entrada bloqueada para produto INATIVO."
                view-as alert-box.
                undo.
            end.

            vant = yes.
        end.
        
        display produ.pronom when avail produ with frame f-produ.
        
        /* caracteristica */
        run p-ver-caracteristica. 
        
        find estoq where estoq.etbcod = 999 and
                         estoq.procod = produ.procod no-lock no-error.
        if not available estoq
        then do:
            message "Produto Sem Registro de Armazenagem". pause. undo.
        end.
        
        display produ.pronom when avail produ with frame f-produ.
        
        vpavpro = 0.
        /*
        run p-wmspallet( input produ.procod , output vpavpro ).
        */
        find first tt-pavpro where tt-pavpro.recpro = recid(produ) no-error.
        if not avail tt-pavpro
        then do:
            create tt-pavpro.
            assign tt-pavpro.recpro = recid(produ).
        end.

        tt-pavpro.pavcod = vpavpro.
        
        vmovqtm = 0. vsubtotal = 0. vsub = 0. vcria = no.
        find first w-movim where w-movim.wrec = recid(produ) no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ).
            vcria = yes.
        end.
        
        vmovqtm = w-movim.movqtm.
        vsub    = w-movim.subtotal. 
       
        do on error undo, retry:
            display produ.procod with frame f-produ1.
           
            w-movim.codfis = produ.codfis.
            pause 0.
            
            update w-movim.codfis with frame f-sittri.
            find clafis where clafis.codfis = w-movim.codfis no-error.
            if not avail clafis
            then do:
                message "Classificacao Fiscal Nao Cadastrada".
                pause.
                undo, retry.
            end.
            
            w-movim.sittri = "999".
            
            update w-movim.sittri validate(can-find(first sittri where
                                        sittri.cst = int(w-movim.sittri)),
                                        "CST nao cadastrada")
                   w-movim.opfcod validate(can-find(first opcom where
                                            opcom.opccod = w-movim.opfcod),
                                   "CFOP nao cadastrada")
                   v-kit with frame f-sittri.
            if v-kit
            then do transaction:       
                find autctb where autctb.movtdc = 4 and
                                  autctb.emite  = vforcod and
                                  autctb.datemi = vpladat and
                                  autctb.serie  = vserie  and
                                  autctb.numero = vnumero no-lock no-error.
                if not avail autctb
                then do:
                    assign tranca = no.

                    create autctb.
                    assign autctb.emite  = vforcod 
                           autctb.desti  = estab.etbcod 
                           autctb.movtdc = 4 
                           autctb.serie  = vserie 
                           autctb.Numero = vnumero 
                           autctb.datemi = vpladat 
                           autctb.datexp = today
                           autctb.FunCod = 12
                           autctb.Motivo = "AUTORIZACAO AUTOMATICA KIT" 
                           autctb.hora   = time.
                end.
            end.       

            hide frame f-sittri no-pause.
            do transaction:
            if clafis.sittri = 0
            then clafis.sittri = int(w-movim.sittri).            
            end.
            
            run atu_fis.p( input w-movim.wrec,
                           input clafis.codfis).
        end.         
                    
        if (w-movim.codfis >= 18060000 and 
            w-movim.codfis <= 18069999) or
            w-movim.codfis = 84715010
        then update w-movim.movipi
                    with frame f-sittri.
       
        update w-movim.movqtm with frame f-produ1.
                       
        w-movim.movpc = estoq.estcusto. 
        w-movim.movqtm = vmovqtm + w-movim.movqtm. 
        display w-movim.movqtm with frame f-produ1. 
        update w-movim.subtotal with frame f-produ1.  
        
        w-movim.movpc = w-movim.subtotal / w-movim.movqtm.
        display w-movim.movpc with frame f-produ1. 

        if tipo_desconto = 2 
        then assign w-movim.movdes = ((vdesval / valor_rateio) * 100) 
                    w-movim.valdes = w-movim.movpc * 
                                     (vdesval / valor_rateio).
            
        display w-movim.valdes
                w-movim.movdes with frame f-produ1.
                    
        if tipo_desconto = 3 
        then do: 
            update w-movim.movdes with frame f-produ1. 
            w-movim.valdes = w-movim.movpc * (w-movim.movdes / 100).
            
            vdesval = vdesval + 
                      ((w-movim.movpc * (w-movim.movdes / 100)) * 
                      w-movim.movqtm).
        end.    
                
        if tipo_desconto = 4 
        then do on error undo, retry: 
            update w-movim.valdes with frame f-produ1.
            if w-movim.valdes > w-movim.movpc
            then do:
                message "Informar o Valor do Desconto Unitario". 
                pause. 
                undo, retry.
            end.    
            w-movim.movdes = ((w-movim.valdes / w-movim.movpc) * 100).
            vdesval = vdesval + (w-movim.valdes * w-movim.movqtm).
        end.
        
        if tipo_desconto = 5 
        then do on error undo, retry: 
            update w-movim.valdes with frame f-produ1.
            if w-movim.valdes > (w-movim.movpc * w-movim.movqtm)
            then do:
                message "Valor de Desconto Invalido". 
                pause. 
                undo, retry.
            end.    
            w-movim.movdes = ((w-movim.valdes / (w-movim.movpc * 
                                                 w-movim.movqtm)) * 100).
            vdesval = vdesval + w-movim.valdes.
        end.    
             
        display w-movim.valdes 
                w-movim.movdes with frame f-produ1.
             
        if forne.ufecod = "RS" 
        then
            if today < 01/01/2016
            then w-movim.movalicms = 17. 
            else w-movim.movalicms = 18.
        else w-movim.movalicms = 12. 
        
        /*
        w-movim.movfre = (w-movim.movpc - w-movim.valdes) * (vfre / vprotot).
        */
        
        repeat on endkey undo:
            update w-movim.movalicms with frame f-produ1.
            if w-movim.movalicms > 30
            then undo.
            leave.
        end. 
                    
        if (w-movim.codfis >= 18060000 and 
            w-movim.codfis <= 18069999) or 
            w-movim.codfis = 84715010
        then.
        else do: 
            w-movim.movalipi = clafis.peripi.
            update w-movim.movalipi with frame f-produ1.
        end.
        
        update w-movim.movfre with frame f-produ1.
        
        assign w-movim.movfre = w-movim.movfre / w-movim.movqtm.   
           
        vprotot1 = 0.
        soma_icm_comdesc = 0.
        soma_icm_semdesc = 0. 
        ipi_item  = 0.
        frete_item = 0.
        clear frame f-produ1 all no-pause.
        clear frame f-produ1 all no-pause.
        
        qtd_total = 0.  
        desp_acess = 0. 
        for each w-movim:  
            qtd_total = qtd_total + w-movim.movqtm.  
        end.    

        desp_acess = vbiss / qtd_total.
        
        for each w-movim:
            find produ where recid(produ) = w-movim.wrec no-lock.
            display produ.procod 
                    w-movim.movqtm 
                    w-movim.valdes 
                    w-movim.movdes 
                    w-movim.subtotal 
                    w-movim.movpc 
                    w-movim.movalicms 
                    w-movim.movalipi 
                    w-movim.movfre with frame f-produ1.

            down with frame f-produ1.
            pause 0.
            find clafis where clafis.codfis = w-movim.codfis no-lock.
            
            v-red = clafis.perred.
           
            if forne.ufecod <> "RS"
            then v-red = 0.

            w-movim.movbicms2 = (w-movim.movqtm * (w-movim.movpc + 
                                                    desp_acess +
                                                   w-movim.movfre)) *
                                (1 - (v-red / 100)).
            w-movim.movicms2  = w-movim.movbicms2 * (w-movim.movalicms / 100).
            soma_icm_semdesc  = soma_icm_semdesc + w-movim.movicms2. 
            
            if tipo_desconto < 5
            then do:
                w-movim.movbicms = (w-movim.movqtm * (w-movim.movpc +  
                                                       w-movim.movfre -
                                                       w-movim.valdes +
                                                       desp_acess)) *
                                    (1 - (v-red / 100)).
                w-movim.movicms  = w-movim.movbicms * w-movim.movalicms / 100.
                soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 

                if w-movim.movalipi <> 0
                then w-movim.movipi = ((w-movim.movpc + 
                                   w-movim.movfre -
                                   w-movim.valdes) * w-movim.movqtm) * 
                                 (w-movim.movalipi / 100).
                
                ipi_item = ipi_item + w-movim.movipi.
                frete_item = frete_item + (w-movim.movfre * w-movim.movqtm).
            end.
            else do:
                w-movim.movbicms = (w-movim.movqtm * (w-movim.movpc + 
                                                        desp_acess + 
                                                        w-movim.movfre
                                                    - (w-movim.valdes / 
                                                       w-movim.movqtm))) *
                                     (1 - (v-red / 100)).
                w-movim.movicms  = w-movim.movbicms * w-movim.movalicms / 100.
                soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 

                if w-movim.movalipi <> 0
                then w-movim.movipi = ((w-movim.movpc + 
                                    w-movim.movfre /*-
                                    (w-movim.valdes / w-movim.movqtm)*/) 
                                        * w-movim.movqtm) * 
                                   (w-movim.movalipi / 100).

                ipi_item = ipi_item + w-movim.movipi.
                frete_item = frete_item + (w-movim.movfre * w-movim.movqtm).
            end.
                       
            vprotot1 = vprotot1 + w-movim.subtotal.
            display vprotot1 with frame f-produ.
        end.
    end.
    end.
    else sresp = yes.
    if not sresp
    then undo, retry.
    end.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f2 no-pause.
    if v-ok = yes
    then undo, leave.
    if libera_nota = no
    then do: 
        for each w-movim: 
            delete w-movim.
        end. 
        vprocod = 0. 
        hide frame f-produ1 no-pause. 
        hide frame f-produ no-pause. 
        setbcod = 900.
        undo, return.             
    end.

    total_icm_calc = vicms - total_icm_calc.
    total_pro_calc = vprotot - total_pro_calc.
    total_ipi_calc = vipi - ipi_item.
    
    if ((total_icm_calc > 0 and total_icm_calc < 1) or
        (total_icm_calc < 0 and total_icm_calc > -1)) or
       ((total_pro_calc > 0 and total_pro_calc < 1) or
        (total_pro_calc < 0 and total_pro_calc > -1)) or
       ((total_ipi_calc > 0 and total_ipi_calc < 1) or
        (total_ipi_calc < 0 and total_ipi_calc > -1)) 
    then do:    
        recpro = ?.
        maior_valor = 0.
        for each w-movim:
            if w-movim.subtotal > maior_valor
            then assign maior_valor = w-movim.subtotal
                        recpro      = w-movim.wrec.
        end.

        find first w-movim where w-movim.wrec = recpro no-error.
        if avail w-movim
        then do:
            w-movim.movicms = w-movim.movicms + 
                              (total_icm_calc / w-movim.movqtm).
            w-movim.movpc   = w-movim.movpc   + 
                              (total_pro_calc / w-movim.movqtm).
            w-movim.movipi  = w-movim.movipi  + 
                              (total_ipi_calc / w-movim.movqtm).
        end.
    end.    
   
    qtd_total = 0.
    total_custo = 0.
    for each w-movim:
        qtd_total = qtd_total + w-movim.movqtm.
    end.    
    
    frete_unitario = vfre / qtd_total.  

    for each w-movim:
        find produ where recid(produ) = w-movim.wrec no-lock.
    
        if w-movim.movfre > 0
        then do:
            valor_desconto = w-movim.valdes.
            
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.
             
            /*if valor_desconto > 0
            then*/
            vcusto = (w-movim.movpc + w-movim.movfre
                       - valor_desconto) +
                      ( (w-movim.movpc + w-movim.movfre
                       /*- valor_desconto*/) *
                        (w-movim.movalipi / 100)).
            /*else
            vcusto = (w-movim.movpc + w-movim.movfre
                      ) +
                      ( (w-movim.movpc + w-movim.movfre
                       /*- valor_desconto*/) *
                        (w-movim.movalipi / 100)).
              */
        end.
        else do:
            valor_desconto = w-movim.valdes.
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.

            vcusto = (w-movim.movpc + frete_unitario
                       - valor_desconto) +
                      ( (w-movim.movpc + frete_unitario
                       - valor_desconto) *
                        (w-movim.movalipi / 100)).
        end.
        total_custo = total_custo + (vcusto * w-movim.movqtm).
        
        /*
        display produ.procod  
                w-movim.movqtm  
                w-movim.valdes  
                w-movim.movdes  
                vcusto column-label "Custo"
                w-movim.movpc  
                w-movim.movalicms  
                w-movim.movicms
                w-movim.movalipi  
                w-movim.movfre label "Frete"
                w-movim.movipi label "IPI"
                    with frame f-pro 1 column.
        */
    end.

    find first w-movim no-error.
    if avail w-movim and tranca 
    then do:
        total_nota = (vplatot - vbiss - v_subst).
        perc_dif = ( 100 - ((total_custo / total_nota) * 100)).

        if perc_dif >= 1 or
           perc_dif <= -1
        then do:
            message "Total Custo: " total_custo          
                    " Total Nota: " total_nota
                    " Diferenca:  " (total_nota - total_custo)
                    " = " ( 100 - ((total_custo / total_nota) * 100)) " % ".
            pause.        
            undo, retry.
        end.   
                 
        if total_custo >= total_nota - 1 and
           total_custo <= total_nota + 1
        then.
        else do:
            message "Total Custo: " total_custo          
                    " Total Nota: " total_nota
                    " Diferenca:  " (total_nota - total_custo)
                    " = " ( 100 - ((total_custo / total_nota) * 100)) " % ".
            pause.        
            for each w-movim:
                delete w-movim.
            end.    
            undo, retry.
        end.
    end.       
    
    /*
    message "Nota OK".
    pause.
    return. 
    */ 
    
     /*** Mini Pedidos */
    vsresp2 = yes.
                               
    disp vtipo-op[1]
         vtipo-op[2]
         with frame f-vtipo-op centered 1 down no-labels overlay row 10.
    choose field vtipo-op  with frame f-vtipo-op.
            
    hide frame f-vtipo-op no-pause.
        
    if frame-index = 1
    then vsresp2 = no.
    else do:
        do on error undo:
            vfilenc = ped-filenc.
            update vfilenc label "Encomenda para a Filial"
                   with frame f-filenc centered side-labels row 10 overlay.
                    
            find bbestab where bbestab.etbcod = vfilenc no-lock no-error.
            if not avail bbestab
            then do:
                message "Filial nao cadastrada.".
                pause 2 no-message. undo, retry.
            end.
        
            vsresp2 = yes.
            message "Voce tem certeza que e uma ENCOMENDA ?" update vsresp2.
            if not vsresp2
            then.
            /*
            find first wmsplani where wmsplani.etbcod = vfilenc 
                                  and wmsplani.movtdc = 1
                                  and wmsplani.plasit = "E" no-lock no-error.
            if avail wmsplani
            then do:
                /**
                message "Encomenda momentaneamente bloqueada.Filial em processo de expedicao.".
                pause 3 no-message.
                vsresp2 = no.
                ***/
            end.
            */
        end.
    end.

    find estab where estab.etbcod = vetbcod no-lock.
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 and
                           bplani.placod <> ? no-lock no-error.
    if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.
    
    if not sresp
    then do:
        hide frame f-produ no-pause.
        hide frame f-produ1 no-pause.
        clear frame f-produ all.
        clear frame f-produ1 all.
        for each w-movim:
            delete w-movim.
        end.
        undo, retry.
    end.
    /****
    if vsresp2
    then do:
        find last bwmsplani where bwmsplani.etbcod = setbcod 
                              and bwmsplani.emite  = setbcod 
                              and bwmsplani.serie  = "U" no-lock no-error. 
                      
        vnumero-enc = 0.  
    
        if not avail bwmsplani 
        then vnumero-enc = 1. 
        else vnumero-enc = bwmsplani.numero + 1.  
    
        {valnumnf.i vnumero-enc}  
    
        find last bwmsplani where bwmsplani.etbcod = setbcod no-lock no-error.         if not avail bwmsplani 
        then vplacod-enc = 1. 
        else vplacod-enc = bwmsplani.placod + 1.
    end.
    else do:    
        /****** Tarefa - Recepcao *********/
    
        find last bwmsplani-recep where bwmsplani-recep.etbcod = setbcod 
                                    and bwmsplani-recep.emite  = setbcod  
                                    and bwmsplani-recep.serie  = "U" 
                                    no-lock no-error. 
        vnumero-recep = 0.  
        if not avail bwmsplani-recep
        then vnumero-recep = 1. 
        else vnumero-recep = bwmsplani-recep.numero + 1.  
    
        {valnumnf.i vnumero-recep}  
    
        find last bwmsplani-recep where 
                  bwmsplani-recep.etbcod = setbcod no-lock no-error.
                      
        if not avail bwmsplani-recep
        then vplacod-recep = 1. 
        else vplacod-recep = bwmsplani-recep.placod + 1.    
    end.
    ****/
    /**********************************/
    def buffer xforne for forne.
    find xforne where xforne.forcod = vforcod no-lock no-error.
    etq-forne = "".
    etq-nf    = "".
    if avail xforne
    then do.
        etq-forne = string(vforcod) + " - " + xforne.fornom.
        etq-nf    = string(vnumero).
    end.
    vpedid-especial = no.
    do transaction:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.cxacod   = frete.forcod
               plani.placod   = vplacod
               plani.biss     = vbiss
               plani.protot   = vprotot
               plani.emite    = vforcod
               plani.bicms    = vbicms
               plani.icms     = vicms
               plani.descpro  = vprotot * (vdesc / 100)
               plani.acfprod  = vacr
               plani.frete    = vfre
               plani.seguro   = vseguro
               plani.desacess = voutras_acess
               plani.bsubst   = vbase_subst
               plani.icmssubst = v_subst
               plani.ipi      = vipi
               plani.platot   = vplatot
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = tipmov.movtdc
               plani.desti    = estab.etbcod
               plani.modcod   = tipmov.modcod
               plani.opccod   = int(opcom.opccod)
               plani.vencod   = vvencod
               plani.notfat   = vforcod
               plani.dtinclu  = vrecdat
               plani.pladat   = vpladat
               PLANI.DATEXP   = today
               plani.horincl  = time
               plani.hiccod   = int(opcom.opccod)
               plani.notsit   = yes /**Aberta**/
               plani.outras = voutras
               plani.isenta = plani.platot - plani.outras - plani.bicms
               plani.ufdes  = vchave-nfe
               plani.usercod = string(sfuncod)
               plani.respfre = if vtipo-frete = 1 then yes
                                else no 
               .

        if plani.descprod = 0
        then plani.descprod = vdesval.
        if vtipo = 0
        then plani.notobs[3] = "".
        else plani.notobs[3] = vobs[vtipo].
    
        find first planiaux where
                   planiaux.movtdc = plani.movtdc and
                   planiaux.etbcod = plani.etbcod and
                   planiaux.emite  = plani.emite  and
                   planiaux.serie  = plani.serie  and
                   planiaux.numero = plani.numero and
                   planiaux.nome_campo = "ProgramaInclusao" and
                   planiaux.valor_campo = "nfent093"
                   no-lock no-error.
        if not avail planiaux
        then do:
            create planiaux.
            assign
                planiaux.movtdc = plani.movtdc 
                planiaux.etbcod = plani.etbcod 
                planiaux.emite  = plani.emite  
                planiaux.serie  = plani.serie  
                planiaux.numero = plani.numero 
                planiaux.nome_campo = "ProgramaInclusao"
                planiaux.valor_campo = "nfent093".
        end.

        for each tt-titulo where tt-titulo.titvlcob > 0 no-lock:
            create titulo.
            buffer-copy tt-titulo to titulo.
        end.
        /****
        if vsresp2
        then do:
            create wmsplani. 
            assign wmsplani.etbcod   = setbcod 
                   wmsplani.placod   = vplacod-enc 
                   wmsplani.emite    = setbcod
                   wmsplani.serie    = "U" 
                   wmsplani.numero   = vnumero-enc
                   wmsplani.crecod   = vnumero-enc * 10 
                   wmsplani.movtdc   = 1
                   wmsplani.desti    = vfilenc
                   wmsplani.pladat   = today 
                   wmsplani.notfat   = vfilenc
                   wmsplani.dtinclu  = today 
                   wmsplani.horincl  = time 
                   wmsplani.notsit   = yes 
                   wmsplani.endpav   = 9
                   wmsplani.plasit   = "A" 
                   wmsplani.notobs[1] = "ETBCODNOTA="
                                            + string(estab.etbcod)
                                            + "|PLACODNOTA="
                                            + string(vplacod)
                                            + "|NUMERONOTA="
                                            + string(vnumero)
                                            + "|EMITENOTA="
                                            + string(vforcod)
                   wmsplani.notobs[3] = string(vnumero)
                   plani.notobs[2]    = "PEDIDO-ETBDES=" + string(vfilenc)
                   vpedid-especial = yes.

           /* tabela com a relacao entre plani e wmsplani */
           if avail wmsplani and
              avail plani 
           then do.
               create divplaniwms.  
               assign divplaniwms.plani-PlaCod     = plani.PlaCod    
                      divplaniwms.plani-EtbCod     = plani.EtbCod    
                      divplaniwms.wmsplani-EtbCod  = wmsplani.EtbCod    
                      divplaniwms.wmsplani-PlaCod  = wmsplani.PlaCod.  
           end.
               /**/   
        end.
        else do:
            /* Criando tarefa recepcao */
                                           
            create wmsplani-recep.  
            assign wmsplani-recep.etbcod    = setbcod
                   wmsplani-recep.placod    = vplacod-recep
                   wmsplani-recep.emite     = setbcod
                   wmsplani-recep.serie     = "U"
                   wmsplani-recep.numero    = vnumero-recep
                   wmsplani-recep.crecod    = vnumero-recep * 10
                   wmsplani-recep.movtdc    = 30  /*Tipo Tarefa - recepcao */
                   wmsplani-recep.desti     = setbcod
                   wmsplani-recep.pladat    = today
                   wmsplani-recep.notfat    = setbcod
                   wmsplani-recep.dtinclu   = today
                   wmsplani-recep.horincl   = time
                   wmsplani-recep.notsit    = yes
                   wmsplani-recep.endpav    = 9
                   wmsplani-recep.plasit    = "A"
                   wmsplani-recep.notobs[1] = "ETBCODNOTA=" + 
                                                           string(estab.etbcod)
                                            + "|PLACODNOTA=" + string(vplacod)
                                            + "|NUMERONOTA=" + string(vnumero)
                                            + "|EMITENOTA=" + string(vforcod)
                   wmsplani-recep.notobs[3] = string(vnumero).
           /* tabela com a relacao entre plani e wmsplani */
           create divplaniwms.  
           assign divplaniwms.plani-PlaCod     = plani.PlaCod    
                  divplaniwms.plani-EtbCod     = plani.EtbCod    
                  divplaniwms.wmsplani-EtbCod  = wmsplani-recep.EtbCod    
                  divplaniwms.wmsplani-PlaCod  = wmsplani-recep.PlaCod.  
           /**/   

        end.
        *****/
        /***************************/
    end.
    
    for each wfped:
        find pedid where recid(pedid) = wfped.rec no-lock.
        find plaped where plaped.pedetb = pedid.etbcod and
                          plaped.plaetb = estab.etbcod and
                          plaped.pedtdc = pedid.pedtdc and
                          plaped.pednum = pedid.pednum and
                          plaped.placod = vplacod      and
                          plaped.serie  = vserie
                    NO-LOCK no-error.
        if not avail plaped
        then do transaction: 
            create plaped.
            assign plaped.pedetb = pedid.etbcod 
                   plaped.plaetb = estab.etbcod 
                   plaped.pedtdc = pedid.pedtdc 
                   plaped.pednum = pedid.pednum 
                   plaped.placod = vplacod 
                   plaped.serie  = vserie 
                   plaped.numero = vnumero 
                   plaped.forcod = forne.forcod.
        end.
    end.
    
    for each wfped:
        create waux.
        assign waux.auxrec = wfped.rec.
    end.

    /****************** atualiza custos ********************/
    qtd_total = 0.
    for each w-movim:
        qtd_total = qtd_total + w-movim.movqtm.
    end.    
    
    frete_unitario = vfre / qtd_total.  
    
    for each w-movim:
    
        if w-movim.movfre > 0
        then do:
            valor_desconto = w-movim.valdes.
            
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.
             
            vcusto = (w-movim.movpc + w-movim.movfre
                       - valor_desconto) +
                      ( (w-movim.movpc + w-movim.movfre
                       - valor_desconto) *
                        (w-movim.movalipi / 100)).
        end.
        else do:
            valor_desconto = w-movim.valdes.
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.

            vcusto = (w-movim.movpc + frete_unitario
                       - valor_desconto) +
                      ( (w-movim.movpc + frete_unitario
                       - valor_desconto) *
                        (w-movim.movalipi / 100)).
        end.
        find produ where recid(produ) = w-movim.wrec no-error.
        do transaction:
            produ.codfis = w-movim.codfis.
        end.
            
        for each estoq where estoq.procod = produ.procod.
            do transaction:
                estoq.estcusto = vcusto.
            end.    
        end.
    end.
    
    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        if not avail produ
        then next.
        find first plani where plani.etbcod = estab.etbcod and
                               plani.placod = vplacod no-lock.
        create wetique.
        assign wetique.wrec = recid(produ)
               wetique.wqtd = w-movim.movqtm.
        
        create etiq-pallet.
        assign etiq-pallet.rec = produ.procod /*recid(produ)*/
               etiq-pallet.qtd = w-movim.movqtm.
        /***
        find wmspallet where wmspallet.procod = produ.procod no-lock no-error.
        if avail wmspallet
        then etiq-pallet.pallet = wmspallet.qtdpallet.
        **/
        for each wfped:
            find pedid where recid(pedid) = wfped.rec NO-LOCK no-error.
            if avail pedid
            then do:
                find first liped where liped.pedtdc = pedid.pedtdc and
                                       liped.etbcod = pedid.etbcod and
                                       liped.procod = produ.procod and
                                       liped.pednum = pedid.pednum
                                 NO-LOCK no-error.
                if avail liped
                then do:
                    find first wprodu where wprodu.wpro = liped.procod no-error.
                    if not avail wprodu
                    then do:
                        create wprodu.
                        assign wprodu.wpro = liped.procod.
                    end.
                    wprodu.wqtd = wprodu.wqtd + 1.
                end.
            end.
        end.
        for each wprodu:
            if wprodu.wqtd = 1
            then delete wprodu.
        end.
        vnum = 0.
        for each wfped:
            find pedid where recid(pedid) = wfped.rec no-lock no-error.
            if avail pedid
            then do:
                find first liped where liped.pedtdc = pedid.pedtdc and
                                       liped.etbcod = pedid.etbcod and
                                       liped.procod = produ.procod and
                                       liped.pednum = pedid.pednum no-error.
                if avail liped
                then do transaction:
                   vnum = 0.
                   sresp = yes.
                   find first wprodu where wprodu.wpro = liped.procod no-error.
                   if avail wprodu
                   then do:
                        vnum = 0.
                        message "PRODUTO EXISTE EM MAIS DE UM PEDIDO".
                        find produ where produ.procod = liped.procod no-lock.
                        display produ.procod
                                produ.pronom format "x(30)"
                                w-movim.movqtm label "Qtd"
                                    with frame f-l1 side-label width 80.
                        for each waux:
                           find pedid where recid(pedid) = waux.auxrec 
                                        NO-LOCK no-error.
                           find first bliped where
                                      bliped.pedtdc = pedid.pedtdc and
                                      bliped.etbcod = pedid.etbcod and
                                      bliped.procod = produ.procod and
                                      bliped.pednum = pedid.pednum
                                            no-lock no-error.
                           if not avail bliped
                           then next.
                           find first wprodu where wprodu.wpro =
                                            bliped.procod no-error.
                           if not avail wprodu
                           then next.
                           disp pedid.pednum
                                bliped.procod
                                produ.pronom format "x(30)"
                                bliped.lipqtd
                                with frame f-l2 centered color message 6 down.
                        end.
                        v-ped = 0.
                        vnum  = pedid.pednum.
                        update vnum label "Pedido"
                               v-ped label "Quantidade"
                               with frame f-l3 centered no-box side-label
                                                color message overlay.
                        find first liped where liped.pedtdc = pedid.pedtdc and
                                               liped.etbcod = pedid.etbcod and
                                               liped.procod = produ.procod and
                                               liped.pednum = vnum no-error.
                        if avail liped
                        then liped.lipent = liped.lipent + v-ped.
                   end.
                   else
                        liped.lipent = liped.lipent + w-movim.movqtm.
                end.
            end.
        end.
        hide frame f-l1 no-pause.
        hide frame f-l2 no-pause.
        hide frame f-l3 no-pause.
        do transaction:
            create movim.
            ASSIGN movim.movtdc = plani.movtdc
                   movim.PlaCod = plani.placod
                   movim.etbcod = plani.etbcod
                   movim.movseq = vmovseq
                   movim.procod = produ.procod
                   movim.movqtm = w-movim.movqtm
                   movim.movpc  = w-movim.movpc
                   movim.movbicms = w-movim.valbicms
                   movim.movicms  = w-movim.valicms
                   movim.movpdes  = w-movim.movdes
                   movim.movdes   = w-movim.valdes
                   movim.movacfin = w-movim.movacfin
                   movim.MovAlICMS = w-movim.movalicms
                   movim.MovAlIPI  = w-movim.movalipi
                   movim.movipi    = w-movim.movipi
                   movim.movdev    = w-movim.movfre 
                   movim.movdat    = plani.pladat
                   movim.MovHr     = int(time)
                   MOVIM.DATEXP    = plani.datexp
                   movim.desti     = plani.desti
                   movim.emite     = plani.emite
                   movim.opfcod    = w-movim.opfcod
                   movim.movcsticms = w-movim.sittri.

            if tipo_desconto = 5
            then movim.movdes = w-movim.valdes / w-movim.movqtm.       
            
            if movim.movalipi <> 0 and
               movim.movipi <> (((movim.movpc + movim.movdev - movim.movdes)
                                    * movim.movqtm) * (movim.movalipi / 100))
            then movim.movipi = (((movim.movpc + movim.movdev - movim.movdes)
                                    * movim.movqtm) * (movim.movalipi / 100)).

            if w-movim.movfre = 0
            then movim.movdev = frete_unitario.      
            
            /*
            movim.movipi    = (movim.movpc - movim.movdes + movim.movdev) * 
                              (w-movim.movalipi / 100).
            */
           /****        
           if vsresp2 
           then do:  
                create wmsmovim. 
                assign wmsmovim.movtdc = 1
                       wmsmovim.PlaCod = wmsplani.placod 
                       wmsmovim.etbcod = wmsplani.etbcod 
                       wmsmovim.movseq = vmovseq
                       wmsmovim.procod = movim.procod 
                       wmsmovim.movqtm = movim.movqtm
                       wmsmovim.movsep = movim.movqtm
                       wmsmovim.movdat = wmsplani.pladat 
                       wmsmovim.MovHr  = int(time) 
                       wmsmovim.desti  = wmsplani.desti 
                       wmsmovim.emite  = wmsplani.emite 
                       wmsmovim.movsit = "A".
           end. 
           else do: 
               /* Criando wmsmovim recepcao */
               
               find first kit where kit.procod = movim.procod no-lock no-error.
               if avail kit 
               then do:  
                   for each kit where kit.procod = movim.procod no-lock:
                       create wmsmovim-recep.  
                       assign wmsmovim-recep.movtdc = 30
                              wmsmovim-recep.PlaCod = wmsplani-recep.placod  
                              wmsmovim-recep.etbcod = wmsplani-recep.etbcod  
                              wmsmovim-recep.movseq = vmovseq 
                              wmsmovim-recep.procod = kit.itecod
                              wmsmovim-recep.movqtm = movim.movqtm 
                              wmsmovim-recep.movsep = movim.movqtm
                              wmsmovim-recep.movdat = wmsplani-recep.pladat  
                              wmsmovim-recep.MovHr  = int(time)  
                              wmsmovim-recep.desti  = wmsplani-recep.desti  
                              wmsmovim-recep.emite  = wmsplani-recep.emite  
                              wmsmovim-recep.movsit = "A".

                       /* Pavilhao endcod ou ocnum[1] ? */
               
                       find first tt-pavpro where 
                                  tt-pavpro.recpro = recid(produ) no-error.
                       if avail tt-pavpro
                       then assign   
                                wmsmovim-recep.ocnum[1] = tt-pavpro.pavcod.
           
                       /*****************************/
                   end.
               end.  
               else do:               
                       create wmsmovim-recep.  
                       assign wmsmovim-recep.movtdc = 30 
                              wmsmovim-recep.PlaCod = wmsplani-recep.placod  
                              wmsmovim-recep.etbcod = wmsplani-recep.etbcod  
                              wmsmovim-recep.movseq = vmovseq 
                              wmsmovim-recep.procod = movim.procod  
                              wmsmovim-recep.movqtm = movim.movqtm 
                              wmsmovim-recep.movsep = movim.movqtm
                              wmsmovim-recep.movdat = wmsplani-recep.pladat  
                              wmsmovim-recep.MovHr  = int(time)  
                              wmsmovim-recep.desti  = wmsplani-recep.desti  
                              wmsmovim-recep.emite  = wmsplani-recep.emite  
                              wmsmovim-recep.movsit = "A".

                       /* Pavilhao endcod ou ocnum[1] ? */
               
                       find first tt-pavpro where 
                                  tt-pavpro.recpro = recid(produ) no-error.
                       if avail tt-pavpro
                       then assign   
                                wmsmovim-recep.ocnum[1] = tt-pavpro.pavcod.
           
                       /*****************************/
               end.               
           end.
           ****/
           delete w-movim.
        end.
    end.
    run not_noticms.p (recid(plani)).
    
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock.
        vestpro = 0.
        find last bmovim where bmovim.procod = movim.procod
                           and bmovim.movdat < movim.movdat no-lock no-error.
        if avail bmovim
        then do:
            for each estoq where estoq.etbcod >= 90
                             and estoq.procod = bmovim.procod no-lock:
                             
                vestpro = vestpro + estoq.estatual.
            end.
            /*if vestpro = 0 and movim.movqtm > 1
            then do:
                find tt-proemail where 
                     tt-proemail.procod = movim.procod no-error.
                if not avail tt-proemail
                then do:
                    create tt-proemail.
                    assign tt-proemail.procod = movim.procod.
                end.
            end.*/
        end.

    end.
    
    /***** Estoque nao eh mais atualizado aqui
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock.
        do transaction:
            run atuest.p(input recid(movim),
                         input "I",
                         input 0).
        end.
    end.
    **********************************************/

    /*
    for each wfped:
        find pedid where recid(pedid) = wfped.rec no-error.
        if avail pedid
        then do:
            vok = no.
            totped = 0. totpen = 0.
            for each liped of pedid no-lock:
                do transaction:
                    if liped.lipent = 0
                    then pedid.sitped = "A".
                    if liped.lipent <> 0 and
                       liped.lipqtd <> liped.lipent
                    then do:
                        pedid.sitped = "P".
                        leave.
                        vok = yes.
                    end.
                end.
                if vok
                then leave.
            end.
            for each liped of pedid no-lock:
                totped = totped + liped.lipqtd.
                totpen = totpen + liped.lipent.
            end.
            if totped = totpen
            then do transaction:
                pedid.sitped = "F".
            end.
        end.
    end.
    */
    
    for each wfped:
        find pedid where recid(pedid) = wfped.rec no-error.
        if avail pedid
        then do:
            for each liped of pedid:
                do transaction:
                    liped.lipsit = "".
                    pedid.sitped = "".
                    if liped.lipent >= (liped.lipqtd - 
                                       (liped.lipqtd * 0.10)) and 
                       liped.lipent <= (liped.lipqtd + (liped.lipqtd * 0.10))
                    then liped.lipsit = "F".
                    else liped.lipsit = "P". 
                    
                    if liped.lipent = 0
                    then liped.lipsit = "A".
                end.
            end.
            
            for each liped of pedid:
    
                do transaction:
                    if liped.lipsit = "A"
                    then pedid.sitped = "A".
                    else if liped.lipsit = "P" and
                            pedid.sitped <> "A"
                         then pedid.sitped = "P".
                         else if liped.lipsit = "F" and
                                 pedid.sitped = "" 
                              then pedid.sitped = "F". 
                end.
            end.    
        end.
    end.        
    
    vezes = 0. prazo = 0.
    find first plani where plani.etbcod = estab.etbcod and
                           plani.placod = vplacod no-lock.
    /****
    run atu-fat-finan.
    ****/
    
    if opsys = "UNIX"
    then 
        run infrepd1.p (input-output table tt-proemail).

    if vlechave
    then run not_nfecnfrec.p (recid(plani)).

    message "Nota Fiscal Incluida". pause.
    
    for each w-movim:
        delete w-movim.
    end.
    /*******
    if (plani.desti = 996 or
       plani.desti = 999)
    then do:
        run peddis.p (input recid(plani)).
    end.

    if plani.desti = 993
    then do:
        find first wetique no-error.
        if not avail wetique
        then leave.
        message "Confirma emissao de Etiquetas de PRODUTO ?" update sresp.
        if sresp
        then do:
            /*if opsys = "UNIX"
            then do:
                find first impress where 
                        impress.codimp = setbcod no-lock no-error. 
                if avail impress
                then do:
                    run acha_imp.p (input recid(impress), 
                            output recimp).
                    find impress where 
                                recid(impress) = recimp no-lock no-error.
                    fila = string(impress.dfimp).
                end.
            end.    
            else fila = "".*/
    
            for each wetique:
                run etiq_m1.p (input wetique.wrec,
                               input wetique.wqtd,
                               input fila).
            end.
        end.
        for each wetique:
            delete wetique.
        end.

        sresp = no.
        message "Confirma emissao de Etiquetas de PALLET ?" update sresp.
        if sresp
        then do:                   
            if opsys = "UNIX"
            then do:
                find first impress where 
                        impress.codimp = setbcod no-lock no-error. 
                if avail impress
                then do:
                    run acha_imp.p (input recid(impress), 
                            output recimp).
                    find impress where 
                                recid(impress) = recimp no-lock no-error.
                    fila = string(impress.dfimp).
                end.
            end.    
            else fila = "".
           
            p1 = 0. p2 = 0.  
            for each etiq-pallet:
                
                if etiq-pallet.pallet > etiq-pallet.qtd
                then p1 = etiq-pallet.qtd.
                else p1 = truncate((etiq-pallet.qtd / etiq-pallet.pallet),0) .
                
                if etiq-pallet.pallet > etiq-pallet.qtd
                then p2 = 0.
                else p2 = etiq-pallet.qtd - ( p1 * etiq-pallet.pallet ).
                
                if p1 > 0
                then do:
                    run etiq_p1.p(etiq-pallet.rec,
                              etiq-pallet.pallet,  
                              p1, 
                              fila).
                end.
                if p2 > 0
                then do:
                    run etiq_p1.p(etiq-pallet.rec,
                              p2, 
                              1, 
                              fila).
                end.
            end.

        end.
        for each etiq-pallet:
            delete etiq-pallet.
        end.
    end.
     
    if vpedid-especial
    then do.
         sresp = YES.
         message "Confirma emissao de Etiquetas de PEDIDO ESPECIAL ?" 
                        update sresp.
         if sresp
         then do:
            if opsys = "UNIX"
            then do:
                find first impress where 
                        impress.codimp = setbcod no-lock no-error. 
                if avail impress
                then do:
                    run acha_imp.p (input recid(impress), 
                            output recimp).
                    find impress where 
                                recid(impress) = recimp no-lock no-error.
                    fila = string(impress.dfimp).
                end.
            end.    
            else fila = "".
            run wbsetiqnf.p (recid(plani)).
        end.
    end.         
     
    if plani.desti = 996 or plani.desti = 999
    then do:
        message "Confirma relatorio de distribuicao" update sresp.
        if sresp
        then run disdep.p (input recid(plani)).
    end.   
    ***/
end.

setbcod = 900.

procedure valida-emite-serie-numero.
    def buffer bb-estab for estab.
/*    for each bb-estab no-lock :   */
        find plani where plani.movtdc = 4 and
                     plani.etbcod = estab.etbcod and
                     plani.emite  = vforcod and
                     plani.serie  = vserie and
                     plani.numero = vnumero 
                     no-lock no-error.
        if avail plani
        then do:
            message color red/with
            "Nota Fiscal ja existe na Filial " estab.etbcod
            view-as alert-box.
            sresp = no.
            leave.
        end.
/*    end.                     */

end procedure.

/****
procedure man-titulo:
    vsaldo = vtotpag.
        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = estab.etbcod and
                              titulo.clifor = forne.forcod and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = plani.pladat.
            display titulo.titpar
                    titulo.titnum
                        with frame ftitulo down centered
                                color white/cyan.
            prazo = 0.
            update prazo with frame ftitulo.
            do transaction:
                titulo.titdtven = vpladat + prazo.
                titulo.titvlcob = vsaldo.
                update titulo.titdtven
                       titulo.titvlcob with frame ftitulo no-validate.
            end.
            vsaldo = vsaldo - titulo.titvlcob.
        
            find titctb where titctb.forcod = titulo.clifor and
                              titctb.titnum = titulo.titnum and
                              titctb.titpar = titulo.titpar no-error.
            if not avail titctb
            then do transaction:
                create titctb.
                ASSIGN titctb.etbcod   = titulo.etbcod
                       titctb.forcod   = titulo.clifor
                       titctb.titnum   = titulo.titnum
                       titctb.titpar   = titulo.titpar
                       titctb.titsit   = titulo.titsit
                       titctb.titvlpag = titulo.titvlpag
                       titctb.titvlcob = titulo.titvlcob
                       titctb.titdtven = titulo.titdtven
                       titctb.titdtemi = titulo.titdtemi
                       titctb.titdtpag = titulo.titdtpag.
            end.
            down with frame ftitulo.
        end.
        if vfrete > 0
        then do transaction:
            create btitulo.
            assign btitulo.etbcod   = plani.etbcod
                   btitulo.titnat   = yes
                   btitulo.modcod   = "NEC"
                   btitulo.clifor   = frete.forcod
                   btitulo.cxacod   = forne.forcod
                   btitulo.titsit   = "lib"
                   btitulo.empcod   = wempre.empcod
                   btitulo.titdtemi = vpladat
                   btitulo.titnum   = string(plani.numero)
                   btitulo.titpar   = 1
                   btitulo.titnumger = string(plani.numero)
                   btitulo.titvlcob = vfrete.
            update btitulo.titdtven label "Venc.Frete"
                   btitulo.titnum   label "Controle"
                        with frame f-frete centered color white/cyan
                                        side-label row 15 no-validate.
        end. 
end procedure.
****/

procedure valida-serie:
    def var vi as int init 0.
    def var vserie-int as int init 0.
    repeat on error undo:
        vi = vi + 1.
        disp with frame f3. pause 0.
        if vi > 1
        then leave.
        else update vserie with frame f1.
        vserie-int = int(vserie).
        vserie = string(vserie-int).
    end.
    if vserie = "0"
    then vserie = "".
end procedure.
procedure p-deleta-tmp:
    for each w-movim:
        delete w-movim.
    end.
    for each wprodu:
        delete wprodu.
    end.
    for each waux:
        delete waux.
    end.
    
    for each tt-proemail.
        delete tt-proemail.
    end.
end procedure.

procedure p-consulta:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock no-error.
                if not avail produ
                then next.
                disp produ.procod
                     produ.pronom format "x(30)"
                     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                     w-movim.movalicms column-label "ICMS"
                     w-movim.movalipi  column-label "IPI"
                            with frame f-produ2 row 5 9 down  overlay
                              centered color message width 80.
                down with frame f-produ2.
            end.
            pause. undo.
end.


procedure p-wmspallet:
    /****
    def input parameter p-procod like produ.procod.
    def output parameter vpavpro like wmsender.endpav.

    def buffer bwmsendpro for wmsendpro.
    def var vqtdpallet like wmspallet.qtdpallet format ">>>>9".

    find wmspallet where wmspallet.procod = p-procod no-lock no-error.
    if avail wmspallet
    then vqtdpallet = wmspallet.qtdpallet.
    else vqtdpallet = 0.
    
    vpavpro = 0.
    find first wmsendpro where wmsendpro.procod = p-procod no-lock no-error.
    if avail wmsendpro
    then do:
        /*comentario feito em 25/05/2009 por luciano
                nao vai mais no wms buscar o pavilhao 
        for each wmsender where wmsender.etbcod = setbcod
                            and wmsender.endtip = 2 
                            no-lock use-index i-etb-tip-pav-rua-num-and
                            break by wmsender.endrua 
                                  by wmsender.endnum 
                                  by wmsender.endand:
    
            find bwmsendpro where bwmsendpro.procod = p-procod
                              and bwmsendpro.endcod = wmsender.endcod 
                              no-lock no-error. 
    
            if avail bwmsendpro 
            then do:  
                vpavpro = wmsender.endpav. 
                leave.  
            end. 
        end. 
        final comentario */
        if vpavpro = 0 
        then do:
            /*comentario feito em   25/05/2009 por luciano
              nao vai mais no wms buscar o pavilhao
            for each wmsender where wmsender.etbcod = setbcod
                                and wmsender.endtip = 1 
                                no-lock use-index i-etb-tip-pav-rua-num-and 
                                break by wmsender.endrua 
                                      by wmsender.endnum  
                                      by wmsender.endand:  
        
                find bwmsendpro where bwmsendpro.procod = p-procod
                                  and bwmsendpro.endcod = wmsender.endcod 
                                  no-lock no-error. 
        
                if avail bwmsendpro 
                then do:  
                    vpavpro = wmsender.endpav.
                    leave.
                end. 
            end.
            final comentario            */
        end.
        
    end.
    else vpavpro = 0.    
    
    if vpavpro = 0
    then do:
        DO ON ERROR UNDO,LEAVE ON ENDKEY UNDO, retry:
    
            update skip(1)
                   space(3) vpavpro    label "Pavilhao......" space(3)
                   skip(1)  
                   with frame f-pall1 centered side-labels overlay row 8.

            if vpavpro = 0
            then do:
                message "Informe o pavilhao do produto.".
                undo.
            end.
        END.
    end.

    if vqtdpallet = 0
    then do:
    
        DO ON ERROR UNDO,LEAVE ON ENDKEY UNDO, retry:
    
            update skip(1)
                   space(3) vqtdpallet label "Qtd por Pallet" space(3) skip
                   skip(1)  
                   with frame f-pall2 centered side-labels overlay row 8.

            if vqtdpallet = 0
            then do:
                message "Informe a quantidade de produtos por pallet.".
                undo.
            end.            
        END.
 
        do transaction. 
            find wmspallet where wmspallet.procod = p-procod no-error.  
            if not avail wmspallet   
            then do: 
                create wmspallet.   
                assign wmspallet.procod    = p-procod 
                       wmspallet.qtdpallet = vqtdpallet.   
            end.  
            else wmspallet.qtdpallet = vqtdpallet. 
            
            find current wmspallet no-lock no-error. 
        end.
        
        find first kit where kit.procod = p-procod no-lock no-error.
        if avail kit  
        then do:      
        
            for each kit where kit.procod = p-procod no-lock:
    
                do transaction.
                    find wmspallet where wmspallet.procod = kit.itecod no-error. 

                    if not avail wmspallet  
                    then do:
                        create wmspallet.  
                        assign wmspallet.procod    = kit.itecod
                               wmspallet.qtdpallet = vqtdpallet.  
                    end. 
                    else wmspallet.qtdpallet = vqtdpallet.
                    
                    find current wmspallet no-lock no-error.
                end.
            end.
        end.                
        
        
    end.
    ***/
end procedure.

procedure p-ver-caracteristica.

def var v-aux as log init no format "Sim/Nao".
def var vcarcod like caract.carcod.
def var vsubcod like subcaract.subcar.

    for each procaract  where procaract.procod = produ.procod no-lock,
        first subcaract where subcaract.subcod = procaract.subcod no-lock,
        first caract    where caract.carcod = subcaract.carcod no-lock.
        v-aux = yes.
    end.        

    if v-aux = yes
    then return "".

    message "Deseja incluir/alterar caracteristica?"
                update v-aux.

    if v-aux = yes
    then do on error undo:
          update vcarcod label "Caracteristica" colon 20 
          with frame f-caract side-label.
          find caract where caract.carcod = vcarcod no-lock no-error.
          if not avail caract
          then do:
               message "Caracteristica nao cadastrada" view-as alert-box.
               undo.
            end.
           disp caract.cardes no-label format "x(15)" with frame f-caract.
           
           update vsubcod colon 20 label "Sub-Caract" with frame f-caract.
           find subcaract where subcaract.carcod = caract.carcod and
                                 subcaract.subcar = vsubcod
                                 no-lock no-error.
           if not avail subcaract
           then do:
                message "sub-caracteristica nao cadastrada" 
                        view-as  alert-box.
                undo.
             end.
           disp subcaract.subdes no-label format "x(15)" with frame f-caract.

           if vcarcod > 0 and vsubcod > 0
           then do:
                find first procaract where 
                           procaract.procod = produ.procod and
                           procaract.subcod = vsubcod
                                      no-error.
                if not avail procaract
                then do:
                     create procaract.
                     assign procaract.procod = produ.procod
                            procaract.subcod = vsubcod.
                 end.       
                 
                 find first procaract where 
                            procaract.procod = produ.procod
                                                no-lock no-error.
              end.        
        end.      
     hide frame f-caract no-pause.

end procedure.

/****/

def var vdtemi as date.

procedure atu-fat-finan:
    
    def var vi as int.
    def var i as int.
    def var vezes as int.
    def var vtotpag as dec format ">>,>>>,>>9.99".
    def var vdesval as dec.
    def var prazo as dec.
    def var vtot-tit as dec.
    def var vtot-par as int.
    
    vdtemi = today.
    
    if simpnota
    then do:
        
        for each tt-titulo:
            delete tt-titulo.
        end.    
                do vi = 1 to 20:
                    if acha("DUP-" + string(vi,"999"),placon.notobs[1]) = ?
                    then leave.
                    do transaction:
                        create tt-titulo.
                        assign 
                            tt-titulo.etbcod = estab.etbcod
                            tt-titulo.titnat = yes
                            tt-titulo.modcod = "DUP"
                            tt-titulo.clifor = forne.forcod
                            tt-titulo.titsit = "LIB"
                            tt-titulo.empcod = wempre.empcod
                            tt-titulo.titdtemi = vdtemi
                            tt-titulo.titnum = string(vnumero)
                            tt-titulo.titpar = vi  
                            tt-titulo.titvlcob = dec(acha("VAL-" + 
                                string(vi,"999"),placon.notobs[1])) 
                            titulo.titdtven = date(acha("DTV-" + 
                                string(vi,"999"),placon.notobs[1])) 
                            vezes = vi        
                            vtotpag = vtotpag + tt-titulo.titvlcob
                            .
                    end.
                end.
                run man-titulo.
    end.
    else repeat on endkey undo:
    
        vtotpag = vplatot.

        disp vezes vtotpag label "Total Faturamento" with frame f-pag.
        update vezes label "Parcelas"
                validate(vezes > 0,"Favor informar quantidade de parcelas.")
                with frame f-pag width 80 side-label centered color white/red
                row 6
                title " Informe os dados para faturamento  ".
    
        do on error undo, retry:
            update vtotpag with frame f-pag.
    
            if vtotpag < vplatot
            then do:
                message "Verifique os valores da nota".
                undo, retry.
            end.
            vsaldo = 0.
            
            for each tt-titulo: delete tt-titulo. end.
            
            do i = 1 to vezes:
                
                create tt-titulo.
                assign 
                    tt-titulo.etbcod = estab.etbcod
                    tt-titulo.titnat = yes
                    tt-titulo.modcod = "DUP"
                    tt-titulo.clifor = forne.forcod
                    tt-titulo.titsit = "LIB"
                    tt-titulo.empcod = wempre.empcod
                    tt-titulo.titdtemi = vdtemi
                    tt-titulo.titnum = string(vnumero)
                    tt-titulo.titpar = i.
                    if prazo <> 0
                    then assign 
                             tt-titulo.titvlcob = vtotpag
                             tt-titulo.titdtven = tt-titulo.titdtemi + prazo.
                    else assign 
                             tt-titulo.titvlcob = vtotpag / vezes
                             tt-titulo.titdtven = tt-titulo.titdtemi + 
                                        (30 * i).
                    vsaldo = vsaldo + tt-titulo.titvlcob.
            end.
                     
            hide frame ftitulo no-pause.
            clear frame ftitulo all.
            run man-titulo.
                    
        end.
        vtot-tit = 0.
        vtot-par = 0.
        for each tt-titulo where tt-titulo.empcod = wempre.empcod and
                              tt-titulo.titnat = yes and
                              tt-titulo.modcod = "DUP" and
                              tt-titulo.etbcod = estab.etbcod and
                              tt-titulo.clifor = forne.forcod and
                              tt-titulo.titnum = string(vnumero) and
                              tt-titulo.titdtemi = vdtemi
                              no-lock.
                    vtot-tit = vtot-tit + tt-titulo.titvlcob.
                    if tt-titulo.titvlcob > 0
                    then vtot-par = vtot-par + 1.
        end.
        if vtot-par <> vezes
        then do:
            message color red/with
                    "Numero de parcelas " vtot-par 
                    "difere do valor informdo " vezes
                    view-as alert-box.
        end.
        else if vtot-tit = vtotpag
             then leave.
             else do:
                 message color red/with
                        "Total informado " vtotpag
                        "Difere do total parcelado " vtot-tit
                        view-as alert-box.
                        next.
             end.
    end.
end procedure.

procedure man-titulo:

        for each tt-titulo where tt-titulo.empcod = wempre.empcod and
                              tt-titulo.titnat = yes and
                              tt-titulo.modcod = "DUP" and
                              tt-titulo.etbcod = estab.etbcod and
                              tt-titulo.clifor = forne.forcod and
                              tt-titulo.titnum = string(vnumero) and
                              tt-titulo.titdtemi = vdtemi.
            display tt-titulo.titpar
                    tt-titulo.titnum
                        with frame ftitulo down centered
                                color white/cyan.
            prazo = 0.
            repeat on endkey undo, retry:
                update prazo with frame ftitulo.
                tt-titulo.titdtven = vpladat + prazo.
                tt-titulo.titvlcob = vsaldo.
                repeat on endkey undo, retry:
                    update tt-titulo.titdtven
                       tt-titulo.titvlcob 
                       with frame ftitulo no-validate.
                    leave.       
                end.
                leave.
            end.
            vsaldo = vsaldo - tt-titulo.titvlcob.
        
            down with frame ftitulo.
        end.        
        
end procedure.


/***********************************************
procedure atu-fat-finan:
    
    def var vi as int.
    def var i as int.
    def var vezes as int.
    def var vtotpag as dec format ">>,>>>,>>9.99".
    def var vdesval as dec.
    def var prazo as dec.
    def var vtot-tit as dec.
    def var vtot-par as int.
    
    if month(today) <> month(plani.dtinclu)
    then vdtemi = today.
    else vdtemi = plani.dtinclu.
    
    find first titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi
                              no-lock no-error.
    if not avail titulo
    then do: 
        if plani.hiccod <> 599 and
           plani.hiccod <> 699
        then do:
            if simpnota
            then do:
                do vi = 1 to 20:
                    if acha("DUP-" + string(vi,"999"),placon.notobs[1]) = ?
                    then leave.
                    do transaction:
                        create titulo.
                        assign 
                            titulo.etbcod = plani.etbcod
                            titulo.titnat = yes
                            titulo.modcod = "DUP"
                            titulo.clifor = forne.forcod
                            titulo.titsit = "LIB"
                            titulo.empcod = wempre.empcod
                            titulo.titdtemi = vdtemi
                            titulo.titnum = string(plani.numero)
                            titulo.titpar = vi  
                            titulo.titvlcob = dec(acha("VAL-" + 
                                string(vi,"999"),placon.notobs[1])) 
                            titulo.titdtven = date(acha("DTV-" + 
                                string(vi,"999"),placon.notobs[1])) 
                            vezes = vi        
                            vtotpag = vtotpag + titulo.titvlcob
                            .
                    end.
                end.
                run man-titulo.
            end.
            /*else do on error undo:*/
            else repeat on endkey undo:
    
                for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi
                              .
                    delete titulo.
                end.          
                release titulo no-error.    

                if plani.platot = 0
                then vtotpag = plani.protot.
                else vtotpag = plani.platot.

                disp vezes vtotpag label "Total Faturamento" with frame f-pag.
                    update vezes label "Parcelas"
                validate(vezes > 0,"Favor informar quantidade de parcelas.")
                with frame f-pag width 80 side-label centered color white/red
                row 7
                title " Informe os dados para faturamento  ".
    
                find first movim where movim.placod = plani.placod and
                           movim.etbcod = plani.etbcod no-lock no-error.
                           
                if avail movim 
                then do on error undo, retry:
                    update vtotpag with frame f-pag.
    
                    if vtotpag < 
                        (plani.protot + plani.ipi - vdesval - plani.descprod)
                    then do:
                        message "Verifique os valores da nota".
                        undo, retry.
                    end.
                    vsaldo = 0.
                    do i = 1 to vezes:
                        do transaction:
                            create titulo.
                            assign 
                                titulo.etbcod = plani.etbcod
                                titulo.titnat = yes
                                titulo.modcod = "DUP"
                                titulo.clifor = forne.forcod
                                titulo.titsit = "LIB"
                                titulo.empcod = wempre.empcod
                                titulo.titdtemi = vdtemi
                                titulo.titnum = string(plani.numero)
                                titulo.titpar = i.
                            if prazo <> 0
                            then assign 
                                    titulo.titvlcob = vtotpag
                                    titulo.titdtven = titdtemi + prazo.
                            else assign 
                                    titulo.titvlcob = vtotpag / vezes
                                    titulo.titdtven = titulo.titdtemi + 
                                        (30 * i).
                            vsaldo = vsaldo + titulo.titvlcob.
                        end.
                    end.
                    hide frame ftitulo no-pause.
                    clear frame ftitulo all.
                    run man-titulo.
                    
                end.
                vtot-tit = 0.
                vtot-par = 0.
                for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi
                              no-lock.
                    vtot-tit = vtot-tit + titulo.titvlcob.
                    if titulo.titvlcob > 0
                    then vtot-par = vtot-par + 1.
                end.
                if vtot-par <> vezes
                then do:
                    message color red/with
                    "Numero de parcelas " vtot-par 
                    "difere do valor informdo " vezes
                    view-as alert-box.
                end.
                else if vtot-tit = vtotpag
                    then leave.
                    else do:
                        message color red/with
                        "Total informado " vtotpag
                        "Difere do total parcelado " vtot-tit
                        view-as alert-box.
                        next.
                    end.
            end.
        end.
    end.
    else repeat on endkey undo:
        
        vtotpag = plani.platot.
        
        hide frame ftitulo no-pause.
        clear frame ftitulo all.
                            
        run man-titulo.
       
        vtot-tit = 0.
                
                for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi
                              no-lock.
                    vtot-tit = vtot-tit + titulo.titvlcob.
                end.
                if vtot-tit = vtotpag
                then leave.
                else do:
                    message color red/with
                    "Total informado " vtotpag
                    "Difere do total parcelado " vtot-tit
                    view-as alert-box.
                end.

    end.
end procedure.

procedure man-titulo:

        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi.
            display titulo.titpar
                    titulo.titnum
                        with frame ftitulo down centered
                                color white/cyan.
            prazo = 0.
            repeat on endkey undo, retry:
                update prazo with frame ftitulo.
                titulo.titdtven = plani.pladat + prazo.
                titulo.titvlcob = vsaldo.
                repeat on endkey undo, retry:
                
                    update titulo.titdtven
                       titulo.titvlcob 
                       with frame ftitulo no-validate.
                    leave.       
                end.
                leave.
            end.
            vsaldo = vsaldo - titulo.titvlcob.
        
            find titctb where titctb.forcod = titulo.clifor and
                              titctb.titnum = titulo.titnum and
                              titctb.titpar = titulo.titpar no-error.
            if not avail titctb
            then do transaction:
                create titctb.
                ASSIGN titctb.etbcod   = titulo.etbcod
                       titctb.forcod   = titulo.clifor
                       titctb.titnum   = titulo.titnum
                       titctb.titpar   = titulo.titpar
                       titctb.titsit   = titulo.titsit
                       titctb.titvlpag = titulo.titvlpag
                       titctb.titvlcob = titulo.titvlcob
                       titctb.titdtven = titulo.titdtven
                       titctb.titdtemi = titulo.titdtemi
                       titctb.titdtpag = titulo.titdtpag.
            end.
            down with frame ftitulo.
        end.        
        
        /**
        if plani.frete > 0
        then do transaction:
            create btitulo.
            assign btitulo.etbcod   = plani.etbcod
                   btitulo.titnat   = yes
                   btitulo.modcod   = "NEC"
                   btitulo.clifor   = plani.emite
                   btitulo.cxacod   = plani.emite
                   btitulo.titsit   = "lib"
                   btitulo.empcod   = wempre.empcod
                   btitulo.titdtemi = vdtemi
                   btitulo.titnum   = string(plani.numero)
                   btitulo.titpar   = 1
                   btitulo.titnumger = string(plani.numero)
                   btitulo.titvlcob = plani.frete.
            update btitulo.titdtven label "Venc.Frete"
                   btitulo.titnum   label "Controle"
                        with frame f-frete centered color white/cyan
                                        side-label row 15 no-validate.
        end.
        **/
end procedure.
****************************/

procedure xml-retorno.

    def var vdata  as char.
    def var vvalor as dec.
    for each tt-xmlretorno where tt-xmlretorno.root = "ide" no-lock.
        case tt-xmlretorno.tag.
            when "dEmi"
            then do.
                vdata   = tt-xmlretorno.valor. /* Ex:2013-03-21 */
                vpladat = date (int(substr(vdata, 6, 2)),
                                int(substr(vdata, 9, 2)),
                                int(substr(vdata, 1, 4))).
            end.
            when "dhEmi"
            then do.
                vdata   = tt-xmlretorno.valor. /* Ex:2013-03-21 */
                vpladat = date (int(substr(vdata, 6, 2)),
                                int(substr(vdata, 9, 2)),
                                int(substr(vdata, 1, 4))).
            end.
        end case.
    end.

    for each tt-xmlretorno where tt-xmlretorno.root = "ICMSTot" no-lock.
 /***       vlexml = yes.***/
        vvalor = dec(tt-xmlretorno.valor).
        case tt-xmlretorno.tag.
            when "vBC"    then vbicms  = vvalor.
            when "vICMS"  then vicms   = vvalor.
            when "vBCST"  then vbase_subst = vvalor.
            when "vST"    then v_subst = vvalor.
            when "vProd"  then vprotot = vvalor.
            when "vSeg"   then vseguro = vvalor.
            when "vFrete" then vfre    = vvalor.
            when "vIPI"   then vipi    = vvalor.
            when "vOutro" then voutras_acess = vvalor.
 /*           when "vDesc"  then vdesval = vvalor.*/
            when "vNF"    then vplatot = vvalor.
        end case.
    end.

end procedure.

