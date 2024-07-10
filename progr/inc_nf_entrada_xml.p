/*
#1 04/19 - Projeto ICMS Efetivo
#2 24/06/2019 - Claudir - Recebimento de KIT
#3 27.08.2019 - helio.neto - exportar arquivi recadv - neogrid
*/
{admcab.i}

def input parameter rec-tipo as char.

def var vindex-tpent as int.
def var vtpent as char extent 2 format "x(15)"
    init["  NORMAL  ","  BONIFICACAO  "].
disp vtpent with frame f0 no-label centered.
choose field vtpent with frame f0.
vindex-tpent = frame-index.

def buffer bbestab for estab.

def new shared var vALCIS-ARQ-ORECH   as int.
def new shared var vALCIS-ARQ-ORDVH   as int.

def var vtotpis as dec.
def var vtotcofins as dec.
def var vtotII as dec.
def var vtotdesc as dec.
def var vcst-icms as char.
def var recatu1 as recid.
def var tot-mov-icms as dec.
def temp-table etiq-pallet
    field rec as int
    field pallet as dec
    field qtd like estoq.estatual.

def var vpavpro            as   int.

def new global shared var etq-forne as char.
def new global shared var etq-nf    as char.

def var vpedid-especial as log.
def var vsresp2 as log format "Sim/Nao".
def var vfilenc like estab.etbcod.

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
def new shared var soma_icm_comdesc like plani.platot.
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
def var vsub  like movim.movpc.
def buffer bestab for estab.
def var vfre as dec format ">>,>>9.99".
def var vacr as dec format ">,>>9.99".
def var voutras like plani.outras.
def buffer btitulo for titulo.
def var vfrecod like com.frete.frecod.
def var totped like pedid.pedtot.
def var totpen like pedid.pedtot.
def var vok as l.
def var vcusto as dec format ">>,>>9.9999".
def var vpreco like estoq.estcusto.
def var vcria as log initial no.
def new shared workfile  wfped field rec  as rec.
def buffer xestoq for estoq.
def var vlechave as log.
def var vlexml   as log.
def var vchave-nfe as char.
def var vdvnfe     as int.

def workfile wprodu
    field wpro like produ.procod
    field wqtd as int.

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
    field valdes    as dec format ">,>>9.9999"
    field movcsticms like movim.movcsticms
    field movbsubst  like movim.movbsubst
    field movsubst   like movim.movsubst
    field movpis     like movim.movpis
    field movcofins  like movim.movcofins
    field movalpis   like movim.movalpis
    field movalcofis like movim.movalcofins
    field movbpiscof like movim.movbpiscof
    field movcstpiscof like movim.movcstpiscof.

def temp-table w_movimimp /* #1 */
    field wrec        as recid
    /* grupo N23 */
    field vBCFCPST    as dec
    field pFCPST      as dec
    field vFCPST      as dec
    /* grupo N25.1 */
    field vBCSTRet    as dec
    field pST         as dec
    field vICMSSubstituto as dec
    field vICMSSTRet  as dec
    /* grupo N27.1 */
    field vBCFCPSTRet as dec
    field pFCPSTRet   as dec
    field vFCPSTRet   as dec.

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
def new shared var ipi_item  like plani.ipi.
def var frete_item like plani.frete.
def var vdifipi as int.
def var frete_unitario like plani.platot.
def var seguro_unitario like plani.seguro.
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

{gnre.i} /* #1 */

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
     with frame f-produ1 row 9 down overlay
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
                        row 8 no-box width 81 overlay.
form estab.etbcod label "Filial" colon 15
    estab.etbnom  no-label
    vchave-nfe   label "Cod Barras NFE" colon 15 format "x(44)"
    cgc-admcom    label "Fornecedor" colon 15
    forne.forcod no-label
    forne.fornom no-label
    /*vopccod  label "Op. Fiscal" format "9999" colon 15 
    opcom.opcnom  no-label*/
    vnumero       colon 15
    vserie        label "Serie"
    vpladat colon 15
    vrecdat colon 39
    vfrecod label "Transp." colon 15
    com.frete.frenom no-label
    vtipo-frete
    vfrete label "Frete"
    with frame f1 side-label width 80 row 4 color white/cyan
    title " Recebimento Nota Fiscal " + rec-tipo + " "
    + " " + vtpent[vindex-tpent] + " ".

def var vbase_subst like plani.bsubst.
def var v_subst     like plani.icmssubst.
def var v_fcpst     like plani.icmssubst.
def var v_fcpstret  like plani.icmssubst.
def var voutras_acess like plani.platot.
def var vdtaux as date.
def var simpnota as log format "Sim/Nao".
def var vpro-cod like movcon.procod.
def var ped-filenc like estab.etbcod.
def buffer xestab for estab.

def var vdiferimento-parcial as dec.

form 
     vbicms        label "Base Icms"  colon 17          format "zz,zzz,zz9.99"
     vicms         label "Valor Icms" colon 55          format "zz,zzz,zz9.99"
     vbase_subst   label "Base Icms Subst" colon 17     format "zz,zzz,zz9.99"
     v_subst       label "Valor Substituicao" colon 55  format "zz,zzz,zz9.99"
     vprotot       label "Tot.Prod."          colon 55  format "zz,zzz,zz9.99"
     vfre          label "Frete"  colon 17              format "zz,zzz,zz9.99"
     vseguro       label "Seguro" colon 55              format "zz,zzz,zz9.99"
     voutras_acess label "Desp.Acessorias" colon 17     format "zz,zzz,zz9.99"
     vipi          label "IPI" colon 55                 format "zz,zzz,zz9.99"
     vplatot       label "Total"  colon 55              format "zz,zzz,zz9.99"
     vdiferimento-parcial label "Percentual diferimento parcial"
     with frame f2 overlay row 13 width 80 side-label
     title " Valores totais da Nota Fiscal ".

do on error undo, retry:
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

    vetbcod = setbcod.
    
    prompt-for estab.etbcod with frame f1.
    vetbcod = input estab.etbcod .
    
    {valetbnf.i estab vetbcod ""Filial""}

    run p-deleta-tmp.
    
    display estab.etbcod
            estab.etbnom with frame f1.
            
    vetbcod = estab.etbcod.
    vserie = "01".
    v-kit = no.
    libera_nota = no.

    update vchave-nfe with frame f1.
    
    vlexml = no.
    tranca = yes.
    
    if length(vchave-nfe) = 44
    then do:
        /* Digito Verificador */
        run nfe_caldvnfe11.p (input dec(substr(vchave-nfe,1,43)),
                              output vdvnfe).
        if substr(vchave-nfe,44,1) <> string(vdvnfe)
        then do.
            message color red/with
                "Chave invalida para NFE" 
                view-as alert-box.
            undo.
        end.
        assign cgc-admcom = substring(vchave-nfe,7,14)
               vserie     = string(int(substring(vchave-nfe,23,3)))
               vnumero    = int(substring(vchave-nfe,26,9)).
               vlechave   = yes.

        display cgc-admcom
                vserie
                vnumero with frame f1.
    
        find first forne where forne.forcgc = cgc-admcom
                       and forne.ativo
                     no-lock no-error.
        if not avail forne
        then do:
            message "Fornecedor nao Cadastrado !!".
            undo, retry.
        end.
        display forne.forcod forne.fornom with frame f1.
        vforcod = forne.forcod.

        find first I01_prod where
                   I01_prod.chave = vchave-nfe no-lock no-error.
        if not avail I01_prod
        then do:      
            sresp = no. 
            run chama_ws_notamax_recebimento.p
                            (vetbcod, vchave-nfe, output sresp).
            if not sresp 
            then do:
                find autctb where autctb.movtdc = ? and
                      autctb.emite  = vforcod and
                      autctb.datemi = vpladat and
                      autctb.serie  = vserie  and
                      autctb.numero = vnumero no-lock no-error.
                if avail autctb and autctb.hora = 222
                then assign
                    tranca = no
                    vlechave = no.
                else do:
                    if not avail autctb
                    then run cria-aut-ctb
                            ("NOTAMAX NAO RETORNOU O XML " + vchave-nfe).
                    message color red/with
                    "A entrada de Nota Fiscal sem uso do XML" skip
                "somente sera permitida quando autorizada pelo Setor Fiscal."
                skip
                "Solicitação gerada no sistema. Aguarde a liberação."
                view-as alert-box.
                    undo.
                end. 
            end.
        end.
        /********
        find first e01_dest where e01_dest.chave = vchave-nfe no-lock no-error.
        if avail e01_dest
        then do:
            find estab where estab.etbcgc = e01_dest.cnpj no-lock no-error.
            if avail estab
            then do:
                display estab.etbcod
                        estab.etbnom with frame f1.
                vetbcod = estab.etbcod.
            end.    
        end.
        *********/
    end.
    
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

    /** VERIFICA CADASTRO FORNECEDOR **/
    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo, retry.
    /**                              **/
    
    if forne.forcod = 5027
    then do:
        message "Fornecedor Invalido".
        undo, retry.
    end.    
    
    if forne.forpai = 0
    then vrec = recid(forne).
    else do:
        find first bforne where bforne.forcod = forne.forpai no-lock no-error.
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
    
    if rec-tipo <> "OUTRAS"
    then do:
        run nffped.p (input vrec, 0).
    
        find first wfped where wfped.rec <> ?  no-lock no-error.
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
    end.
    
    vforcod = forne.forcod.
    
    find first i01_prod where i01_prod.chave = vchave-nfe no-lock no-error.
    if avail i01_prod
    then do:
        find first n01_icms where
                   n01_icms.chave = vchave-nfe and
                   n01_icms.nitem = i01_prod.nitem
                   no-lock no-error.
        if avail n01_icms
        then vcst-icms = string(n01_icms.cst).
        vopccod = string(i01_prod.cfop).
        run valida_CFOP.
        find opcom where opcom.opccod = vopccod no-lock no-error.
        if not avail opcom
        then do:
            message color red/with
            "Nenhum registro encontrado para CFOP " vopccod  skip
            "Favor efetuar cadastro no Admcom"
            view-as alert-box.
            undo, retry.
        end.
        vhiccod = int(opcom.opccod).
    end.

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
        vprotot = 0
        vdiferimento-parcial = 0
        v_subst = 0
        v_fcpst = 0
        v_fcpstret = 0
        .
    
    find first placon where placon.movtdc = 4 and
                      placon.etbcod = estab.etbcod and
                      placon.emite = forne.forcod and
                      placon.serie = "EL" and
                      placon.numero = vnumero
                      no-lock no-error.
    if avail placon  and not vlechave
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
    
    find tipmov where tipmov.movtdc = 4 no-lock.
    vdesc = 0.
    vrecdat = today.
    vpladat = ?.
    if vlechave
    then do:
        find B01_IdeNFe where B01_IdeNFe.chave = vchave-nfe no-lock no-error.
        if avail B01_IdeNFe 
        then do:
            vpladat = B01_IdeNFe.demi.
            disp vpladat with frame f1.
        end.    
    end.
    if vpladat = ?
    then do on error undo:
        update vpladat with frame f1.
        {valdatnf.i vpladat vrecdat}
    end.

    if vlechave = no and tranca = yes
    then do:
        find autctb where autctb.movtdc = 4 and
                      autctb.emite  = vforcod and
                      autctb.datemi = vpladat and
                      autctb.serie  = vserie  and
                      autctb.numero = vnumero no-lock no-error.
        if avail autctb and autctb.hora = 222
        then tranca = no  .
        else do:
            if not avail autctb
            THEN run cria-aut-ctb ("RECEBIMENTO SEM INFORMAR CHAVE DE ACESSO").
            
            message color red/with
            "A entrada de Nota Fiscal sem uso da chave de acessos" skip
            "somente sera permitida quando autorizada pelo Setor Fiscal."
            skip
            "Solicitação gerada no sistema. Aguarde a liberação."
            view-as alert-box.  
            undo.
        end. 
    end.

    if vlechave
    then do:
        find first x01_transp where
                   x01_transp.chave = vchave-nfe and
                   x01_transp.cnpj  = ? and
                   x01_transp.cpf   = ?
                    no-lock no-error.
        if avail x01_transp
        then vtipo-frete = x01_transp.modFrete. 
    end.
    else do:
        update vfrecod with frame f1.
        find com.frete where frete.frecod = vfrecod no-lock.
        display frete.frenom no-label with frame f1.
        vvencod = vfrecod.
    end.
    /*if not vlechave then*/
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
    /*disp vtipo-frete with frame f1.*/
     
    if vtipo-frete = 0 and vlechave = no
    then do:
        update vfrete label "Valor Frete" with frame f1.
    end.
    else vfrete = 0.
    
    tipo_desconto = 1.
    find w01_total where w01_total.chave = vchave-nfe no-lock no-error.
    if avail w01_total 
    then do:
        if  w01_total.VDesc > 0
        then tipo_desconto = 2. 
        assign
            vbicms = w01_total.vBC
            vicms  = w01_total.vICMS
            vbase_subst = w01_total.vBCST
            v_subst = w01_total.vST 
            v_fcpst = w01_total.vFCPST
            v_fcpstret = w01_total.vFCPSTRet
            vprotot = w01_total.Vprod
            vfre = w01_total.Vfrete
            vseguro = w01_total.VSeg
            vipi = w01_total.vIPI
            vtotdesc = w01_total.VDesc
            vtotII = w01_total.vII
            vtotPIS = w01_total.vPIS
            vtotCOFINS = w01_total.vCOFINS
            voutras = w01_total.vOutro
            voutras_acess = w01_total.vOutro
            vplatot = w01_total.vNF. 
    end.

    find first I01_prod where
               I01_prod.chave = vchave-nfe and
               i01_prod.VDesc > 0
               no-lock no-error.
    if avail I01_prod
    then tipo_desconto = 5.           
    
    if not vlechave
    then do:
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
        vdiferimento-parcial
        with frame f2.
    pause.

    do /*on error undo, retry*/:
    
    if not vlechave then
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

    if not vlechave then
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

    if not vlechave
    then update vseguro with frame f2.
    
    if not vlechave then
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
    if vlechave = no
    then update vipi 
           vplatot with frame f2.
    
    update vdiferimento-parcial when vlechave = no with frame f2.
    
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
                           + vipi + v_subst + v_fcpst + v_fcpstret) 
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
                               vseguro +  vipi + v_subst
                                               + v_fcpst + v_fcpstret
                                -  vdesval)
                then do:     
                    if (vplatot - vbiss) <> 
                       (vprotot + voutras_acess + vfre + 
                        vseguro +   vipi + v_subst + v_fcpst + v_fcpstret)
                    then do:
                        message "Valor Total da Nota nao fecha".  
                        message vplatot (vprotot + 
                                         voutras_acess +
                                         vfre +    
                                         vseguro + 
                                         vipi +    
                                         v_subst + v_fcpst + v_fcpstret 
                                         - vdesval).
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
    
    /** ITENS XML **/
    /*message vlechave vchave-nfe.*/
    /*#1 pause 1 no-message. */
    if vlechave and vchave-nfe <> ""
    then do:
        run itens_xml_recebimento.p(input vchave-nfe, output vok).    
        if vok = no then undo.
        run gera_movim_xml.
    end.

    run trata_gnre. /* #1 */
    
    if vhiccod <> 599 and
       vhiccod <> 699
    then do:
    disp with frame f-produ.
    disp with frame f-produ1.
    bl-princ:
    repeat with 1 down:
        vprocod = 0.
        hide frame f-produ2 no-pause.
        vprotot1 = 0. 
        clear frame f-produ all no-pause.
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
            if vfre > 0
            then w-movim.movfre = 
                    (vfre * (w-movim.subtotal / vprotot)) / w-movim.movqtm.
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
            frete_item = frete_item + (w-movim.movfre * w-movim.movqtm).
            vprotot1 = vprotot1 + (w-movim.movqtm * w-movim.movpc).
            display vprotot1 with frame f-produ.
        end.
        hide frame f-sittri no-pause.
        libera_nota = no.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4 
                                  F10 E e C c a A) with frame f-produ.
        
        if vlechave and keyfunction(lastkey) <> "end-error" 
        then do: /*#2*/
            find produ where produ.procod = input frame f-produ vprocod 
                    no-lock no-error.
            if not avail produ 
            then do:
                bell.
                message color red/with
                "Produto não cadastrado."
                 view-as alert-box.
                undo.
            end.
            else do:
                find first w-movim where
                           w-movim.wrec = recid(produ) no-error.
                if not avail w-movim
                then do:
                    bell.
                    message color red/with
                    "Produto informado não encontrado no documento."
                    view-as alert-box.
                    undo.
                end.           
                else do:
                    clear frame f-produ1 all.
                    display produ.procod
                    w-movim.movqtm
                    w-movim.valdes
                    w-movim.movdes
                    w-movim.subtotal
                    w-movim.movpc
                    w-movim.movalicms
                    w-movim.movalipi
                    w-movim.movfre  with frame f-produ1.
                    update w-movim.movqtm with frame f-produ1.
                    w-movim.movpc = w-movim.subtotal / w-movim.movqtm.
                    next.
                end.    
            end.    
        end. /*#2*/
                                 
        if keyfunction(lastkey) = "end-error" 
        then do:
            /*
            hide frame f-produ no-pause.
            run difnfped.p ( input vrec ) .
            */
            sresp = no.
            message "Confirma efetivacao da Nota Fiscal" update sresp.
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
            else do:
                find first w-movim no-error.
                /*if not avail w-movim and
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
                    hide frame f-produ2 no-pause.
                    hide frame f-produ1 no-pause.
                    hide frame f-produ no-pause.
                    view frame f1 no-pause.
                    
                    if opcom.opccod <> "1910" and
                       opcom.opccod <> "2910" and
                       opcom.opccod <> "2949" and
                       opcom.opccod <> "2923"
                    then run atu-fat-finan.

                    libera_nota = yes.
                    leave bl-princ.
                end.
                else*/ do:
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
                             
                            /****
                            message "Valor Icms Nao Confere: CAPA= " vicms  
                                    " ITEM C/Desconto= " soma_icm_comdesc 
                                    " ITEM S/DESCONTO= " soma_icm_semdesc.
                            pause. 
                            ****/
                 
                 run mensagem.p (input-output sresp,
                 input "   O valor do ICMS nao confere:!"  +
                       "      ICMS CAPA= " + trim(string(vicms)) + "!" +
                       "      ICMS ITEM= " + trim(string(soma_icm_comdesc)) +
                       " C/Desconto !" +
                       "      ICMS ITEM= " + trim(string(soma_icm_semdesc)) +
                       " S/Desconto " + "!!" +
                       "   A NFE POSSUI DIFERIMENTO PARCIAL ? ",
                                    input "",
                     input "   Sim",
                                             input "  Nao").

                            if sresp
                            then do:
                                update vdiferimento-parcial 
                           label "Informe o percentual do Diferimento parcial"
                                with frame f-difp side-label 
                                overlay centered row 18 color message.
                            end.
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
                    hide frame f-produ1 no-pause.
                    hide frame f-produ no-pause.
                                        
                    if opcom.opccod <> "1910" and
                       opcom.opccod <> "2910" and
                       opcom.opccod <> "2949" and
                       opcom.opccod <> "2923"
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
                
                if vdiferimento-parcial > 0
                then w-movim.movicms2 * (100 - vdiferimento-parcial).
                
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
                    if vdiferimento-parcial > 0
                    then w-movim.movbicms * (100 - vdiferimento-parcial).
                    
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
                    
                    if vdiferimento-parcial > 0
                    then w-movim.movbicms = w-movim.movbicms *
                            (100 - vdiferimento-parcial).
                            
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
                    /*
                    find first tt-pavpro where 
                               tt-pavpro.recpro = recid(produ) no-error.
                    if avail tt-pavpro
                    then delete tt-pavpro.
                    */
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
        
        find first tt-pavpro where tt-pavpro.recpro = recid(produ) no-error.
        if not avail tt-pavpro
        then do:
            create tt-pavpro.
            assign tt-pavpro.recpro = recid(produ).
        end.

        tt-pavpro.pavcod = vpavpro.
        */
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
            if forne.forcod = 5700
            then v-red = 33.33.
            
            w-movim.movbicms2 = (w-movim.movqtm * (w-movim.movpc + 
                                                    desp_acess +
                                                   w-movim.movfre)) *
                                (1 - (v-red / 100)).
            
            w-movim.movicms2  = w-movim.movbicms2 * (w-movim.movalicms / 100).
            
            if forne.forcod = 110366
            then assign
                     v-red = 33.33
                     w-movim.movicms2  = 
                                (w-movim.movbicms2 * (1 - (v-red / 100)))
                                     * (w-movim.movalicms / 100).

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
        undo, return.             
    end.

    if not avail opcom
    then do:
        find first w-movim no-lock no-error.
        find first opcom where 
                   opcom.opccod = string(w-movim.opfcod) 
                   no-lock no-error.
        if not avail opcom then undo, retry.
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
    seguro_unitario = vseguro / qtd_total.
    def var mov_fcp_st as dec.
    mov_fcp_st = 0.
    for each w-movim:
        find produ where recid(produ) = w-movim.wrec no-lock.
        mov_fcp_st = 0.
        
        for each w_movimimp where w_movimimp.wrec = w-movim.wrec
                               no-lock .
            if avail w_movimimp
            then mov_fcp_st = w_movimimp.vFCPST / w-movim.movqtm.
        end.    
        
        if w-movim.movfre > 0
        then do:
            valor_desconto = w-movim.valdes.
            
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.
             
            vcusto = (w-movim.movpc  
                      + w-movim.movfre 
                      + w-movim.movacfin
                      + (vseguro / qtd_total)
                      - valor_desconto) 
                      + ((w-movim.movpc + w-movim.movfre 
                       /*- valor_desconto*/) *
                        (w-movim.movalipi / 100))
                        + (w-movim.movsubst / w-movim.movqtm)
                        + mov_fcp_st
                        .
        end.
        else do:
            valor_desconto = w-movim.valdes.
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.
            vcusto = (w-movim.movpc
                        + (vfre / qtd_total) 
                        + w-movim.movacfin
                        + (vseguro / qtd_total)
                       - valor_desconto) 
                       + ((w-movim.movpc + frete_unitario 
                       - valor_desconto) *
                        (w-movim.movalipi / 100))
                        + (w-movim.movsubst / w-movim.movqtm)
                        + mov_fcp_st
                        .
        end.
        
        /***
        message produ.procod
                w-movim.movpc
                frete_unitario
                w-movim.movacfin
                seguro_unitario
                valor_desconto
                w-movim.movalipi
                w-movim.movipi
                vcusto
                .
                pause.  
        ***/
        
        total_custo = total_custo + (vcusto * w-movim.movqtm).
        
    end.
    
    find first w-movim no-error.
    if avail w-movim and tranca 
    then do:
        /*total_nota = (vplatot - vbiss - v_subst).*/
        total_nota = vplatot.
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
    
    vsresp2 = no.
    
    if rec-tipo = "MOVEIS"
    then do on error undo: /*** Mini Pedidos */
                               
        disp vtipo-op[1]
         vtipo-op[2]
         with frame f-vtipo-op centered 1 down no-labels overlay row 10.
        choose field vtipo-op  with frame f-vtipo-op.
            
        hide frame f-vtipo-op no-pause.
        
        if frame-index = 1
        then do:
            sresp = yes.
            message "Voce tem certeza que e uma entrada NORMAL ?" 
            update sresp.
            if not sresp
            then undo.
        end.
        else do:
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
            then undo.
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
        assign recatu1 = recid(plani)
               plani.etbcod   = estab.etbcod
               plani.cxacod   = if avail frete then frete.forcod else 0
               plani.placod   = vplacod
               plani.biss     = vbiss
               plani.protot   = vprotot
               plani.emite    = vforcod
               plani.bicms    = vbicms
               plani.icms     = vicms
               plani.descpro  = vtotdesc /*vprotot * (vdesc / 100)*/
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
               plani.notsit   = (if rec-tipo = "MOVEIS"
                                then yes /**Aberta**/
                                else no)
               plani.outras = voutras
               plani.isenta = plani.platot - plani.outras - plani.bicms
               plani.ufdes  = vchave-nfe
               plani.usercod = string(sfuncod)
               plani.respfre = if vtipo-frete = 1 then yes
                                else no 
               plani.notpis = vtotpis
               plani.notcofins = vtotcofins.

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
                   planiaux.valor_campo = program-name(1) + "|" + rec-tipo
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
                planiaux.valor_campo = program-name(1) + "|" + rec-tipo.
        end.

        for each tt-titulo where tt-titulo.titvlcob > 0 no-lock:
            create titulo.
            buffer-copy tt-titulo to titulo.
        end.
 
        if vsresp2
        then plani.notobs[2]    = string(vfilenc).      

        run grava_gnre.
    end.
    
    find plani where recid(plani) = recatu1 no-lock no-error.
    if not avail plani then undo, retry.
    
    if opcom.opccod <> "2105"
    then 
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
    
    frete_unitario = truncate(vfre / qtd_total,4).  
    
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
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        /*do transaction:
            produ.codfis = w-movim.codfis.
        end.*/
        if opcom.opccod <> "2105"
        then    
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

        if opcom.opccod <> "2105"
        then do:
        create wetique.
        assign wetique.wrec = recid(produ)
               wetique.wqtd = w-movim.movqtm.
        
        create etiq-pallet.
        assign etiq-pallet.rec = produ.procod /*recid(produ)*/
               etiq-pallet.qtd = w-movim.movqtm.

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
                   movim.movcsticms = w-movim.sittri
                   movim.movcstpiscof = w-movim.movcstpiscof
                   movim.movbpiscof = w-movim.movbpiscof
                   movim.movalpis = w-movim.movalpis
                   movim.movalcof = w-movim.movalcof
                   movim.movpis   = w-movim.movpis
                   movim.movcofins = w-movim.movcofins.

            if tipo_desconto = 5
            then movim.movdes = w-movim.valdes / w-movim.movqtm.       

            if movim.movalipi <> 0 and
               movim.movipi <> (((movim.movpc + movim.movdev - movim.movdes)
                                    * movim.movqtm) * (movim.movalipi / 100))
            then movim.movipi = (((movim.movpc + movim.movdev - movim.movdes)
                                    * movim.movqtm) * (movim.movalipi / 100)).

            if w-movim.movfre = 0
            then movim.movdev = frete_unitario.      

            find first w_movimimp where w_movimimp.wrec = w-movim.wrec
                       no-lock no-error.
            if avail w_movimimp
            then do.
                run cria_movimimp (23,
                                   w_movimimp.vBCFCPST,
                                   w_movimimp.pFCPST,
                                   w_movimimp.vFCPST,
                                   0).

                run cria_movimimp (25,
                                   w_movimimp.vBCSTRet,
                                   w_movimimp.pSt,
                                   w_movimimp.vICMSSTRet,
                                   w_movimimp.vICMSSubstituto).

                run cria_movimimp (27,
                                   w_movimimp.vBCFCPSTRet,
                                   w_movimimp.pFCPSTRet,
                                   w_movimimp.vFCPSTRet,
                                   0).
            end.
            else if produ.proipiper = 99 and
                    w-movim.movsubst = 0 and
                    produ.al_Icms_Efet > 0
            then do:
                find first clafis where
                           clafis.codfis = produ.codfis no-lock no-error.
                if avail clafis and
                         clafis.mva_estado1 > 0
                then do:
                    run cria_movimimp (251,
                                   ((movim.movbicms + movim.movipi) +
                                   ((movim.movbicms + movim.movipi) *
                                   (clafis.mva_estado1 / 100))),
                                   produ.al_Icms_Efet,
                                   ((((movim.movbicms + movim.movipi)
                                   + ((movim.movbicms + movim.movipi) *
                                        (clafis.mva_estado1 / 100)))
                                        * (produ.al_Icms_Efet / 100))
                                        - movim.movicms),
                                   0).
 
                end.           
            end.        
            delete w-movim.
        end.
    end.

    find plani where recid(plani) = recatu1 no-lock.
    
    if opcom.opccod <> "2105"
    then do:
    run not_noticms.p (recid(plani)).

    if rec-tipo = "MOVEIS"
    then run complemento-moveis.
    else if rec-tipo = "MODA"
        then run complemento-moda.
        else if rec-tipo = "OUTRAS" 
            then run complemento-outras.
    end. 
       
   /*#3*/ run edi/exprecadv.p (recid(plani)).
       
end.    

message color red/with "Nota Fiscal Incluida" view-as alert-box.


procedure cria_movimimp.

    def input parameter par-codigo as int.
    def input parameter par-base   as dec.
    def input parameter par-aliq   as dec.
    def input parameter par-valor  as dec.
    def input parameter par-vlraux as dec.

    if par-base > 0
    then do on error undo.
        create movimimp.
        assign
            movimimp.etbcod     = movim.etbcod
            movimimp.placod     = movim.placod
            movimimp.movseq     = movim.movseq
            movimimp.procod     = movim.procod
            movimimp.impcodigo  = par-codigo
            movimimp.impBaseC   = par-base
            movimimp.impaliq    = par-aliq
            movimimp.impvalor   = par-valor
            movimimp.impvlraux1 = par-vlraux.
    end.

end procedure.


procedure complemento-moveis:    
    
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
        end.

    end.
    
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
    if opsys = "UNIX"
    then 
        run infrepd1.p (input-output table tt-proemail).

    if vlechave
    then run not_nfecnfrec.p (recid(plani)).
    
    if vsresp2 /*Cross Docking*/
    then do:
        run orech-900.p(recid(plani), "PE"). 
        /*** sera enviado apos confirmação do recebimento pela WMS
        run pedido-especial. ***/

    end.
    else do:
        run orech-900.p(input recid(plani), input "LI"). 
    end.

end procedure.

procedure complemento-moda:
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock.
        vestpro = 0.
        find last bmovim where bmovim.procod = movim.procod
                           and bmovim.movdat < movim.movdat no-lock no-error.
        if avail bmovim
        then do:
            for each estoq where estoq.etbcod >= 900
                             and estoq.procod = bmovim.procod no-lock:
                if {conv_igual.i estoq.etbcod} then next.
             
                vestpro = vestpro + estoq.estatual.
            end.
            if vestpro = 0 and movim.movqtm > 1
            then do:
                find tt-proemail where 
                     tt-proemail.procod = movim.procod no-error.
                if not avail tt-proemail
                then do:
                    create tt-proemail.
                    assign tt-proemail.procod = movim.procod.
                end.
            end.
        end.
    end.

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock.
        if movim.opfcod <> 2105
        then
        run atuest.p(input recid(movim),
                     input "I",
                     input 0).

    end.
    
    /* geracao para alcis */
    
    if plani.desti = 995
    then run alcis/orech.p (recid(plani)).
    else if plani.desti = 900
        then run alcis/orech-900.p (recid(plani)).

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
            
            for each liped of pedid NO-LOCK:
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

    if plani.desti = 995
    then
        for each wfped.
            run alcis/pedch.p (wfped.rec).
        end.
    else if plani.desti = 900
        then for each wfped.
                run alcis/pedch-900.p (wfped.rec).
             end.
                
    vezes = 0. prazo = 0.
    find first plani where plani.etbcod = estab.etbcod and
                           plani.placod = vplacod no-lock.
          
    simpnota = no.
    
    if opsys = "UNIX"
    then run infrepd1.p (input-output table tt-proemail). 

    if vlechave
    then run not_nfecnfrec.p (recid(plani)).

    for each w-movim:
        delete w-movim.
    end.

    if plani.desti = 996 or
       plani.desti = 995 or
       plani.desti = 999 or
       plani.desti = 900
    then do:
        run peddis.p (input recid(plani)).
        
        find first wetique no-error.
        if not avail wetique
        then leave.
        message "Confirma emissao de Etiquetas" update sresp.
        if sresp
        then do:
            if opsys = "unix"
            then do:
                if search("/admcom/relat/etique.bat") <> ?
                then do:
                    os-command silent rm -f /admcom/relat/etique.bat.
                    os-command silent rm -f /admcom/relat/cris*.* .
                end.
            end.
            else do:
                if search("c:\temp\etique.bat") <> ?
                then do:
                    dos silent del c:\temp\etique.bat.  
                    dos silent del c:\temp\cris*.* .
                end.
            end.
             
            for each wetique:
                if plani.desti = 996 or plani.desti = 995 or
                   plani.desti = 900
                then run eti_barl.p (input wetique.wrec,
                                     input wetique.wqtd).
                
                else run etique-m2.p (input wetique.wrec,
                                      input wetique.wqtd).
            end.

            if opsys = "unix"
            then os-command silent /admcom/relat/etique.bat.
            else os-command silent c:\temp\etique.bat.
        end.
        for each wetique:
            delete wetique.
        end.
        message "Confirma relatorio de distribuicao" update sresp.
        if sresp
        then run disdep.p (input recid(plani)).
    end.
end procedure.

procedure complemento-outras:

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock.
        
        run atuest.p(input recid(movim),
                     input "I",
                     input 0).

    end.
    
end procedure.

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

    /***
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
    ****/
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
    def var vnumdup as char.
    
    vdtemi = today.

    vi = 0.
    if vchave-nfe <> ""
    then do:
        for each y01_cobr where y01_cobr.chave = vchave-nfe and
                                y01_cobr.ndup <> "" and
                                y01_cobr.dvenc <> ? and
                                y01_cobr.vdup > 0 no-lock:
            vi = vi + 1.
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
                tt-titulo.titvlcob = dec(y01_cobr.vdup) 
                tt-titulo.titdtven = date(y01_cobr.dvenc)
                vezes = vi        
                vtotpag = vtotpag + tt-titulo.titvlcob
                .
  
        end.
        repeat on endkey undo:
            if vtotpag = 0
            then vtotpag = vplatot.
            vsaldo = vtotpag. 
            disp vezes vtotpag label "Total Faturamento" with frame f-pagx.
            if vi = 0
            then do:
                update vezes label "Parcelas"
                validate(vezes > 0,"Favor informar quantidade de parcelas.")
                vtotpag 
                with frame f-pagx width 80 side-label centered color white/red
                row 9 overlay
                title " Informe os dados para faturamento  ".

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
                     
            end.
            repeat on error undo:
                for each tt-titulo where tt-titulo.empcod = wempre.empcod and
                              tt-titulo.titnat = yes and
                              tt-titulo.modcod = "DUP" and
                              tt-titulo.etbcod = estab.etbcod and
                              tt-titulo.clifor = forne.forcod and
                              tt-titulo.titnum = string(vnumero) and
                              tt-titulo.titdtemi = vdtemi.
                    prazo = tt-titulo.titdtven - vpladat.
                    display tt-titulo.titpar
                        tt-titulo.titnum
                        prazo
                        tt-titulo.titdtven
                        tt-titulo.titvlcob
                        with frame ftitulox down centered
                                color white/cyan.
                    repeat on endkey undo, retry:
                        update prazo with frame ftitulox.
                        tt-titulo.titdtven = vpladat + prazo.
                        /*tt-titulo.titvlcob = vsaldo.*/
                        repeat on endkey undo, retry:
                            update tt-titulo.titdtven
                            tt-titulo.titvlcob 
                            with frame ftitulox no-validate.
                            leave.       
                        end.
                        leave.
                    end.
                    vsaldo = vsaldo - tt-titulo.titvlcob.
        
                    down with frame ftitulox.
                end. 
                leave.
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
    end.    
    else if simpnota
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
                row 9 overlay
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

procedure pedido-especial:
    def buffer bpedid for pedid.
    def buffer bliped for liped.
    def var log-qtd-registros as int.
    log-qtd-registros = 0.
    def var vmovseq as int.
    vmovseq = 0.
    
    for each plaped where plaped.forcod = plani.emite and
                          plaped.numero = plani.numero
                          no-lock,
        first pedid where pedid.etbcod = plaped.pedetb and
                          /*pedid.pedtdc = plaped.pedtdc and*/
                          pedid.pednum = plaped.pednum and
                          pedid.pedtdc = 1
                          no-lock:
        find first bpedid where 
                   (bpedid.pedtdc = 4 or
                    bpedid.pedtdc = 6) and
                   bpedid.pedsit = yes and
                   bpedid.comcod = pedid.pednum
                   no-lock no-error.
        if avail bpedid           
        then do:
            def var par-numcod as int.
            /*
            par-numcod = next-value(SeqDocbase).
            */
            find first tab_box where
                       tab_box.etbcod = bpedid.etbcod
                       no-lock no-error.
            run tdocbase-dcbcod.p(output par-numcod).
            do on error undo.
                create  tdocbase.
                ASSIGN  tdocbase.dcbcod    = par-numcod
                        
                        tdocbase.geraraut   = no
                        
                        tdocbase.dcbnum    = par-numcod
                        tdocbase.tdcbcod   = "ESP"
                        tdocbase.chave-ext = ? 
                        tdocbase.DtDoc     = today
                        tdocbase.DtEnv     = today
                        tdocbase.HrEnv     = time
                        tdocbase.Etbdes    = (if bpedid.condes > 0
                        then bpedid.condes else bpedid.etbcod)
                        tdocbase.plani-etbcod = ?
                        tdocbase.box  = if avail tab_box 
                                        then tab_box.box else 0
                        tdocbase.ordem = 1
                        tdocbase.RomExterno     = yes
                        tdocbase.plani-placod = ?
                        tdocbase.campo_int1 = plani.numero
                        tdocbase.campo_int2 = bpedid.etbcod
                        .
          
                /*   gravar o tty do usuário    */  
                tdocbase.cod_barra_nf = string(tdocbase.dcbnum) + "_" +
                                          string(sfuncod) .
                if bpedid.etbcod = 200 
                then do. 
                    tdocbase.Ecommerce = yes.
                    tdocbase.clfcod    = ?.
                end.                
            end.
            for each bliped of bpedid no-lock:
                    
                do on error undo:        
                    create  tdocbpro.
                    assign
                    log-qtd-registros = log-qtd-registros + 1
                    vmovseq = vmovseq + 1
                    tdocbpro.dcbcod  = tdocbase.dcbcod 
                    tdocbpro.dcbpseq = vmovseq          
                    tdocbpro.predt   = today
                    tdocbpro.etbdes  = (if bpedid.condes > 0
                        then bpedid.condes else bpedid.etbcod)
                    tdocbpro.campo_int3 = tdocbase.etbdes
                    tdocbpro.procod  = bliped.procod 
                    tdocbpro.movqtm  = bliped.lipqtd
                    /*tdocbpro.endpav = if avail wbsprodu
                                    then wbsprodu.endpav
                                    else ?*/
                    tdocbpro.pednum  = bliped.pednum
                    tdocbpro.campo_char1 = plani.serie
                    tdocbpro.campo_int1 = plani.numero
                    tdocbpro.campo_int2 = bpedid.etbcod
                    .
                end.
            end.
        end.
    end.
    for each tdocbase where 
         tdocbase.tdcbcod = "ESP" and
         tdocbase.situacao = "A"
         no-lock:

        run ordvh-993.p(recid(tdocbase), "PESP").

    end.  
end procedure.

procedure valida_CFOP:
    def var vind as int.
    def var vdec as int.
    vind = int(substr(vopccod,1,1)).
    vdec = int(substr(vopccod,4,1)).
    if vind = 5 then vind = 1.
    else if vind = 6 then vind = 2.
    else if vind = 7 then vind = 3.

    if vcst-icms = "10" or vcst-icms = "60"
    then vdec = 3.
    else if vdec = 1
         then vdec = 2.

    vopccod = string(vind) + substr(vopccod,2,2) + string(vdec).
    if vcst-icms = "10"
    then vcst-icms = "60".
    
    if vindex-tpent = 2
    then vopccod = string(vind) + "910".
    else if vcst-icms = "10" or vcst-icms = "60" or vcst-icms = "70"
    then vopccod = string(vind) + "403". /* #1 */

end procedure.


procedure gera_movim_xml:
    for each I01_prod where I01_prod.chave = vchave-nfe no-lock.
        find produ where produ.procod = I01_prod.procod no-lock no-error.
        if not avail produ then next.         
        find first n01_icms where
                   n01_icms.chave = I01_prod.chave and
                   n01_icms.nitem = I01_prod.nitem
                   no-lock no-error.

        find first w-movim where w-movim.wrec = recid(produ) no-error.
        if not avail w-movim
        then do:                        
            if avail n01_icms
            then assign
                    vcst-icms = string(n01_icms.cst)
                    vopccod = string(i01_prod.cfop).
            else vcst-icms = "".

            run valida_CFOP.

            create w-movim.
            assign
                w-movim.wrec = recid(produ)
                w-movim.opfcod = int(vopccod).

            if avail n01_icms
            then assign
                    w-movim.movcsticms = string(n01_icms.orig) + vcst-icms
                    w-movim.movalicms  = n01_icms.picms
                    w-movim.sittri     = w-movim.movcsticms /* #1 */.
        end.
        assign
            w-movim.movqtm = w-movim.movqtm + i01_prod.qcom
            w-movim.movpc  = w-movim.movpc + i01_prod.vprod
            w-movim.movacfin = w-movim.movacfin + 
                    (i01_prod.voutro / w-movim.movqtm)
            w-movim.valdes = w-movim.valdes + i01_prod.vdesc.
        if avail n01_icms
        then assign             
            w-movim.movbicms = w-movim.movbicms + n01_icms.vbc
            w-movim.movicms  = w-movim.movicms + n01_icms.vicms
            w-movim.movbsubst = w-movim.movbsubst + n01_icms.vbcst
            w-movim.movsubst = w-movim.movsubst + n01_icms.vicmsst.

        if avail n01_icms and (vcst-icms = "10" or vcst-icms = "60"
                               or vcst-icms = "70")
            
        then do.
            find first w_movimimp where w_movimimp.wrec = recid(produ)
                                 no-error.
            if not avail w_movimimp
            then do:                        
                create w_movimimp.
                assign
                    w_movimimp.wrec      = recid(produ)
                    w_movimimp.pFCPST    = n01_icms.pFCPST
                    w_movimimp.pST       = n01_icms.pST
                    w_movimimp.pFCPSTRet = n01_icms.pFCPSTRet.
            end.
            assign
                /* grupo N23 */
                w_movimimp.vBCFCPST = w_movimimp.vBCFCPST + n01_icms.vBCFCPST
                w_movimimp.vFCPST   = w_movimimp.vFCPST   + n01_icms.vFCPST
                /* grupo N25.1 */
                w_movimimp.vBCSTRet = w_movimimp.vBCSTRet + n01_icms.vBCSTRet
                w_movimimp.vICMSSubstituto = w_movimimp.vICMSSubstituto + 
                                        n01_icms.vICMSSubstituto
                w_movimimp.vICMSSTRet =  w_movimimp.vICMSSTRet +
                                        n01_icms.vICMSSTRet
                /* grupo N27.1 */
                w_movimimp.vBCFCPSTRet = w_movimimp.vBCFCPSTRet +
                                        n01_icms.vBCFCPSTRet
                w_movimimp.vFCPSTRet = w_movimimp.vFCPSTRet +
                                        n01_icms.vFCPSTRet.
        end.

        find o01_ipi where o01_ipi.chave = i01_prod.chave and
                           o01_ipi.nitem = i01_prod.nitem 
                           no-lock no-error.
        if avail o01_ipi
        then assign
                w-movim.movalipi = o01_ipi.pipi
                w-movim.movipi = w-movim.movipi + o01_ipi.vipi.

        find q01_pis where q01_pis.chave = i01_prod.chave and
                           q01_pis.nitem = i01_prod.nitem 
                           no-lock no-error.
        if avail q01_pis
        then assign
                w-movim.movcstpiscof = q01_pis.CST
                w-movim.movalpis = dec(q01_pis.pPIS)
                w-movim.movbpiscof = w-movim.movbpiscof + dec(q01_pis.vBC)
                w-movim.movpis = w-movim.movpis + dec(q01_pis.vPIS).

        find s01_cofins where s01_cofins.chave = i01_prod.chave and
                              s01_cofins.nitem = i01_prod.nitem 
                              no-lock no-error.
        if avail s01_cofins
        then assign
                w-movim.movalcof  = dec(s01_cofins.pCOFINS)
                w-movim.movcofins = w-movim.movcofins + dec(s01_cofins.vCOFINS)
                .
        
        if w-movim.movcstpiscof = 01
        then w-movim.movcstpiscof = 50.
        else if w-movim.movcstpiscof = 02 or
                w-movim.movcstpiscof = 04
            then w-movim.movcstpiscof = 70.
            else if w-movim.movcstpiscof = 05
                then w-movim.movcstpiscof = 75.
                else if w-movim.movcstpiscof = 49
                    then w-movim.movcstpiscof = 98.
    end.

    soma_icm_comdesc = 0.
    for each w-movim:
        w-movim.subtotal = w-movim.movpc.
        w-movim.movpc = w-movim.movpc / w-movim.movqtm.
        soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms.
        ipi_item = ipi_item + w-movim.movipi.
    end.    



end procedure.


procedure cria-aut-ctb:

    def input parameter p-motivo as char.
    
    create autctb.
    assign
        autctb.emite = vforcod
        autctb.desti = estab.etbcod
        autctb.movtdc = ?
        autctb.serie = vserie
        autctb.numero = vnumero
        autctb.datemi = vpladat
        autctb.datexp = ?
        autctb.motivo = p-motivo
        autctb.hora   = 111.

end procedure.
