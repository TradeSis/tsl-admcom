{admcab.i}

def input parameter vdisparo as char.

def buffer bbestab for estab.

def var vlechave as log.
def var vlexml   as log.

def temp-table tt-nfser
    field documento as int    label "Documento" format ">>>>>>>>9"
    field emissao as date     label "Emissao  " format "99/99/9999"
    field inclusao as date    label "Inclusao " format "99/99/9999"
    field val-ir as dec       label "IR "
    field val-iss as dec      label "ISS"
    field val-inss as dec     label "INSS"
    field val-pis as dec      label "PIS"
    field val-cofins as dec   label "COFINS"
    field val-csll as dec     label "CSLL"
    field val-total as dec    label "Valor da despesa"
    field val-liq as dec      label "Valor liquido " 
    field qtd-par as int      label "Quant. parcelas" 
    field val-icms as dec     label "ICMS"
    field val-ipi  as dec     label "IPI"
    field val-des  as dec     label "Desconto"
    field val-acr  as dec     label "Acrescimo"
    field val-juro as dec     label "Juro"
    field situacao as char
    .

def var p1 as int.
def var p2 as int.
def var fila as char format "x(20)".
def var recimp as recid.
def temp-table etiq-pallet
    field rec as int
    field pallet as dec
    field qtd like estoq.estatual.

def var vsetcod         like setaut.setcod.

def var vpavpro            as   int.
/*
def buffer bwmsplani-recep for  wmsplani.
def buffer wmsplani-recep  for  wmsplani.
def buffer wmsmovim-recep  for  wmsmovim.
def var vnumero-recep      like wmsplani.numero.
def var vplacod-recep      like wmsplani.placod.
*/
def var vsresp2 as log format "Sim/Nao".
def var vfilenc like estab.etbcod.
/*
def buffer bwmsplani for wmsplani.
def var vnumero-enc like wmsplani.numero.
def var vplacod-enc like wmsplani.placod.
*/
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
def var v-red like suporte.clafis.perred.
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
def var vped as recid.
def buffer xestoq for estoq.

def workfile wprodu
    field wpro like produ.procod
    field wqtd as int.

def temp-table tt-tipmov like tipmov.

/*
def temp-table tt-pavpro
    field recpro as   recid
    field pavcod like wmsender.endpav.
*/    

def new shared temp-table w-movim 
    field wrec    as   recid 
    field codfis    like nfe.clafis.codfis 
    field sittri    like nfe.clafis.sittri
    field movqtm    like movim.movqtm 
    field movacfin  like movim.movacfin
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
    field valdes    as dec format ">,>>9.9999".
    
def workfile wetique
    field wrec as recid
    field wqtd like estoq.estatual.

def var vtipo-op as char format "x(12)" extent 2 
    initial [" Normal "," Encomenda "].    
    
def var vtabcod    like estoq.tabcod.
def buffer cprodu for produ.
def var wetccod like produ.etccod.
def var wfabcod like produ.fabcod.
def var wprorefter like produ.prorefter.
def buffer witem for item.
def var witecod like produ.itecod.
def var vitecod like produ.itecod.
def var vresp    as log format "Sim/Nao".
def var wrsp    as log format "Sim/Nao".
def var vdesc    like plani.descprod format ">9.99 %".
def var i as i.
def var Vezes as int format ">9".
def var Prazo as int format ">>9".
def var v-ok as log.
def buffer bclien for clien.
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
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete format ">>,>>9.99".
def var vseguro   like  plani.seguro.
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vtotal    like plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(02)".
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
def var vdvnfe     as int.
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
form titulo.titpar
     titulo.titnum
     prazo
     titulo.titdtven
     titulo.titvlcob with frame ftitulo down centered color white/cyan.
     
form produ.procod column-label "Codigo" format ">>>>>9"
     w-movim.movqtm format ">>>>>9" column-label "Qtd"
     w-movim.movpc  format ">>,>>9.99" column-label "Val.Unit."
     w-movim.subtotal  format ">>>>,>>9.99" column-label "Subtot"
     w-movim.valdes format ">>>,>>9.9999" column-label "Val.Desc"
     w-movim.movdes format ">9.9999" column-label "%Desc"
     w-movim.movalicms column-label "ICMS" format ">9.99"
     w-movim.movalipi  column-label "IPI"  format ">9.99"
     w-movim.movfre    column-label "Frete" format ">>,>>9.99"
     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.

form w-movim.codfis label "Class.Fiscal" format "99999999"  
     w-movim.sittri label "Situacao Trib." format "999"
     v-kit          label "Kit" 
     w-movim.movipi label "Total IPI" 
        with frame f-sittri side-label centered row 10 overlay.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(23)"
     vprotot1 with frame f-produ centered color message side-label
                        row 6 no-box width 81.
form estab.etbcod label "Filial" colon 15
    estab.etbnom  no-label
    vchave-nfe  as char  label "Cod Barras NFE" colon 15 format "x(44)"
    cgc-admcom    label "Fornecedor" colon 15
    forne.fornom no-label
    vopccod  label "Op. Fiscal" format "9999" colon 15 
    opcom.opcnom  no-label
    vnumero       colon 15
    vserie        label "Serie"
    vpladat colon 15
    vrecdat colon 39
    vfrecod label "Transp." colon 15
    frete.frenom no-label
    vfrete label "Frete"
      with frame f1 side-label width 80 row 7 color white/cyan.

 
def var vbase_subst like plani.bsubst.
def var v_subst     like plani.icmssubst.
def var voutras_acess like plani.platot.
def var vdtaux as date.
def var simpnota as log format "Sim/Nao".

form vbicms        column-label "Base Icms" at 01
     vicms         column-label "Valor Icms"
     vbase_subst   column-label "Base Icms Subst" 
     v_subst       column-label "Valor Substituicao" 
     vprotot       column-label "Tot.Prod." 
        with frame f-base1 row 12 overlay width 80.

form vfre          column-label "Frete"  at 01
     vseguro       column-label "Seguro"
     voutras_acess column-label "Desp.Acessorias"
     vipi          column-label "IPI"
     vplatot       column-label "Total" format ">>,>>>,>>9.99"
        with frame f2 overlay row 17 width 80.
        
for each tt-tipmov:
    delete tt-tipmov.
end.    
for each tipmov no-lock:
    find tipmovaux where
         tipmovaux.movtdc = tipmov.movtdc and
         tipmovaux.nome_campo = "SITUACAO" AND
         tipmovaux.valor_campo = "inativo"
         no-lock no-error.
    if avail tipmovaux
    then next.
    find tipmovaux where
         tipmovaux.movtdc = tipmov.movtdc and
         tipmovaux.nome_campo = "PROGRAMA-NF" AND
         tipmovaux.valor_campo = "nfentall"
         no-lock no-error.
    if avail tipmovaux
    then do:
        create tt-tipmov.
        buffer-copy tipmov to tt-tipmov.
    end.
end.
    
{setbrw.i}

def var v-sair as log.
v-sair = no.

if vdisparo = ""
then do:
{sklcls.i
    &file = tt-tipmov
    &cfield = tt-tipmov.movtnom 
    &ofield = " tt-tipmov.movtdc "
    &where = true
    &Naoexiste1 = " bell.
          message color red/with
            ""Nenhum TIPO DE DOCUMENTO encontrado.""
            view-as alert-box.
            v-sair = yes.
            leave keys-loop.
            "
    &form = " frame f-linha 10 down no-label centered row 6 "
    }
end.
else find first tt-tipmov where
                tt-tipmov.movtdc = int(vdisparo)
                no-lock no-error.
                
hide frame f-linha.

if keyfunction(lastkey) = "END-ERROR"
then return.

if tt-tipmov.movtdc = 47
then do:
    run nfentser.p(input tt-tipmov.movtdc).
    v-sair = yes.
end.    

if v-sair
then return.

def var vmovtdc like tipmov.movtdc.
vmovtdc = tt-tipmov.movtdc.
def var tem-itens as log init no.
find first tipmovaux where tipmovaux.movtdc = vmovtdc and
                           tipmovaux.nome_campo = "TEM-ITENS"
           no-lock no-error.
if not avail tipmovaux
then tem-itens = no.
else if tipmovaux.valor_campo = "SIM"
    then tem-itens = yes.
    else tem-itens = no.

disp " NOTA FISCAL DE " tt-tipmov.movtnom
    with frame f-tipmov no-label no-box 
    color message centered.
repeat:

    clear frame f1 no-pause.
    clear frame f2 no-pause.
    clear frame f-base1 no-pause.
    clear frame f-produ no-pause.
    clear frame f-produ1 no-pause.
    clear frame f-produ2 no-pause.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause .
    hide frame f-produ2  no-pause.
    hide frame f1 no-pause.
    hide frame f2 no-pause.
    hide frame f-base1 no-pause.
    if setbcod = 999
    then do:
        
        update vsetcod label "Setor" with frame ff1 side-label width 80.
    
        find setaut where setaut.setcod = vsetcod no-lock no-error.
        if not avail setaut
        then do:
            message "Setor nao cadastrado".
            undo, retry.
        end.
        display setaut.setnom no-label with frame ff1.
                 
        prompt-for estab.etbcod with frame f1.
        vetbcod = input frame f1 estab.etbcod.
    end.
    else vetbcod = setbcod.
    
    {valetbnf.i estab vetbcod ""Filial""}

    run p-deleta-tmp.
    
    display estab.etbcod
            estab.etbnom with frame f1.
            
    vetbcod = estab.etbcod.
    /**
    if /* vetbcod <= 90 or */
       vetbcod >= 999
    then do:
        message "Deposito Invalido". pause.
        undo, leave.
    end.
    **/
    
    v-kit = no.
    libera_nota = no.

    update vchave-nfe with frame f1.
    
    if length(vchave-nfe) = 44
    then do:
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
        run not_nfedistr.p(vetbcod, vchave-nfe, output sresp).
        if not sresp
        then undo.
    end.
    else vlechave = no.

    update cgc-admcom with frame f1.
    find first forne where forne.forcgc = cgc-admcom no-lock no-error.
    if not avail forne
    then do:
        bell.
        message color red/with 
        "Fornecedor nao Cadastrado."
        view-as alert-box.
        undo, retry.
    end.
    if forne.forcgc = ""
    then do:
        message color red/with 
        "CNPJ nao existe ou nao cadatrado"
        view-as alert-box.
        undo, retry.
    end.
    if forne.ativo = no
    then do:
        message color red/with "Fornecedor Desativado."
        view-as alert-box .
        undo, retry.
    end.     

    display forne.fornom when avail forne with frame f1.
    if forne.forcod = 5027
    then do:
        message color red/with "Fornecedor Invalido."
        view-as alert-box.
        undo, retry.
    end.    
    
    if forne.forpai = 0
    then vrec = recid(forne).
    else do:
        find bforne where bforne.forcod = forne.forpai no-lock no-error.
        if not avail bforne
        then do:
            message color red/with "Fornecedor pai nao cadastrado."
            view-as alert-box.
            undo, retry.
        end.
        else vrec = recid(bforne).
    end.    
    find first foraut where
               foraut.forcod = forne.forcod
               no-lock no-error.
    if not avail foraut
    then do:
        bell.
        message color red/with
               "Fornecedor não liberado para Despesa/Modalidade"
               view-as alert-box.
        undo, retry.
    end.           
    vdesval = 0.
    vdesc   = 0.
    valor_rateio = 0.
    /***         
    run nffped.p (input vrec,
                  output vped).
    if vped = ?
    then do:
        message "Para continuar selecione pelo menos um pedido.".
        undo.
    end.       
    **/
    vforcod = forne.forcod.
    find cpforne of forne no-lock no-error.
    vserie = "U".
    if forne.ufecod = "RS"
    then find first opcom where opcom.movtdc = vmovtdc no-lock no-error.
    else find last opcom where opcom.movtdc = vmovtdc no-lock no-error.
    if not avail opcom
    then do:
        bell.
        message color red/with 
            "Operacao Comercial nao cadatrada."
            view-as alert-box.
        undo, retry.
    end.        
    vopccod = opcom.opccod.

    do on error undo, retry:
        if vmovtdc = 32
        then vopccod = "1551".
        update vopccod with frame f1.
        find opcom where opcom.opccod = vopccod no-lock no-error.
        if not avail opcom
        then do:
            message "Operacao Fiscal Invalida".
            pause.
            undo, retry.
        end.
    end.                    
    find cpforne of forne no-lock no-error.
    vhiccod = int(opcom.opccod).
    display vopccod
            opcom.opcnom with frame f1.
    display vserie with frame f1.

    update vnumero validate( vnumero > 0, "Numero Invalido")
             with frame f1.
    run valida-serie.
    disp vserie with frame f1.

    find first plani where plani.numero = vnumero and
                     plani.emite  = vforcod and
                     plani.desti  = estab.etbcod and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod and
                     plani.movtdc = vmovtdc no-lock no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.

    vpladat = ?.
    def var vpro-cod like movcon.procod.
    simpnota = no.
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
                              movcon.placod = placon.placod
                              .
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
                        update vpro-cod 
                            format ">>>>>>>9"
                        with frame f-proean.
                        find produ where produ.procod = movcon.procod
                            no-error.
                        if avail produ
                        then assign
                                movcon.procod = vpro-cod
                                produ.proindice = 
                                string(movcon.movctm,"9999999999999").
                        else undo.        
                    end.
                end. 
                find produ where produ.procod = movcon.procod no-lock
                         no-error.
                if not avail produ then next.         
                find first w-movim where
                           w-movim.wrec = recid(produ) no-error.
                if not avail w-movim
                then do:                        
                    create w-movim.
                    assign
                        w-movim.wrec = recid(produ)
                        /*w-movim.codfis
                        w-movim.sittri 
                        */.
                end.
                assign
                    w-movim.movqtm = movcon.movqtm
                    w-movim.movacfin = movcon.movacfin
                    /*w-movim.subtotal
                    */
                    w-movim.movpc  = movcon.movpc
                    w-movim.movalicms = movcon.movalicms
                    w-movim.valicms  = movcon.movalicms
                    w-movim.movicms  = movcon.movicms
                    w-movim.movalipi = movcon.movalipi 
                    w-movim.movipi = movcon.movipi
                    w-movim.movdes = movcon.movdes 
                    .
 
            end.     
            assign
                vpladat = placon.pladat
                vrecdat = today 
                vfrete  = placon.frete.   
            find bforne where bforne.forcod = placon.nottran
                    no-lock no-error.
            if avail bforne
            then vfrecod = forne.forcod.   
        end.             
    end.                  
    find tipmov where tipmov.movtdc = vmovtdc no-lock.
    vdesc = 0.
    do on error undo:
        update vpladat
               vrecdat with frame f1.
        if vpladat = ? or
           vpladat > today or
           vpladat < today - 90 or
           vrecdat = ? or
           vrecdat > today or
           vrecdat < today - 90
         then do:
           bell.
           message color red/with
           "Data invalida." view-as alert-box.
           undo.
        end.
           
        /*
        {valdatnf.i vpladat vrecdat}
        */
    end.

    tranca = yes.

    find autctb where autctb.movtdc = 4 and
                      autctb.emite  = vforcod and
                      autctb.datemi = vpladat and
                      autctb.serie  = vserie  and
                      autctb.numero = vnumero no-lock no-error.
    if avail autctb
    then tranca = no.
    if tipmov.movtdc <> 37 and
       tipmov.movtdc <> 38 and
       tipmov.movtdc <> 39
    then do:   
        update vfrecod with frame f1.
        find frete where frete.frecod = vfrecod no-lock.
        display frete.frenom no-label with frame f1.
        update vfrete with frame f1.
        vvencod = vfrecod.
    end.
    tipo_desconto = 1.
    /**
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
    **/
    hide frame f-des2 no-pause.                
    hide frame f-des1 no-pause.
    hide frame f-des  no-pause.
    
    do on error undo, retry:
    assign vbicms  = 0
           vicms   = 0
           vprotot1 = 0
           vipi    = 0
           vdescpro = 0
           vacfprod = 0
           vplatot  = 0
           vtotal = 0.
           voutras = 0.
           vacr    = 0.
           vfre    = 0.
           vseguro = 0.
           vprotot = 0.
    if avail placon and simpnota
    then do:
        assign
            vfrecod   = 0
            vfrete    = placon.frete
            vdesval   = placon.descprod
            vbicms    = placon.bicms
            vicms     = placon.icms
            vbase_subst = placon.bsubst
            v_subst   = placon.icmssubst
            vprotot  = placon.protot
            vseguro  = placon.seguro
            voutras_acess = placon.desacess
            vipi    = placon.ipi
            vplatot = placon.platot
            vfre = placon.frete
            .
    end.
    do on error undo:
        hide frame f-obs no-pause.
        if tipmov.movtdc <> 37 and
           tipmov.movtdc <> 38 and
           tipmov.movtdc <> 39
        then do:   
            update vbicms 
               vicms  
               vbase_subst  
               v_subst 
               vprotot with frame f-base1.
        end.

         valor_rateio = vprotot.
        /**
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
        ***/
        hide frame f-obs no-pause.

    end.
    
    do on error undo, retry:
        if tipmov.movtdc <> 37 and
           tipmov.movtdc <> 38 and
           tipmov.movtdc <> 39
        then do:   
        update vfre with frame f2.
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
    end.
    
    if tipmov.movtdc <> 37 and
           tipmov.movtdc <> 38 and
           tipmov.movtdc <> 39
    then do:   
            update vseguro with frame f2.
    end.
    do on error undo, retry:
        if tipmov.movtdc <> 37 and
           tipmov.movtdc <> 38 and
           tipmov.movtdc <> 39
        then do:   
             update voutras_acess with frame f2.
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
    end.
    
    hide frame f-senha no-pause.
    if tipmov.movtdc <> 37 and
           tipmov.movtdc <> 38 and
           tipmov.movtdc <> 39
    then do:   
            update vipi  with frame f2.
    end.        
    update
           vplatot with frame f2.
    
    if tipmov.movtdc <> 37 and
           tipmov.movtdc <> 38 and
           tipmov.movtdc <> 39
    then.
    else vprotot = vplatot.
              
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
    if /*vhiccod <> 599 and
       vhiccod <> 699*/
       tem-itens
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
                            w-movim.valicms = w-movim.movicms.
                        end.
                        
                    end.
                    else do:
                        
                        total_icm_calc = soma_icm_semdesc.
                        
                        for each w-movim:
                            w-movim.valicms = w-movim.movicms2.
                        end.
                    
                    end. 
                    if ((vprotot >= vprotot1 - 1) and
                        (vprotot <= vprotot1 + 1)) 
                    then do:
                        total_pro_calc = vprotot1.
                    end.    
                    else do:
                        total_pro_calc = vprotot1 - vdesval.
                    end.   
 
 
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
                            message  "Valor Icms Nao Confere: CAPA= " 
                                     vicms  
                                     " ITEM C/Desconto= " 
                                     soma_icm_comdesc 
                                     " ITEM S/DESCONTO= "
                                     soma_icm_semdesc.
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
                            message  "FRETE Nao Confere CAPA= " 
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
                            w-movim.valicms = w-movim.movicms.
                        end.
                        
                    end.
                    else do:
                        
                        total_icm_calc = soma_icm_semdesc.
                        
                        for each w-movim:
                            w-movim.valicms = w-movim.movicms2.
                        end.
                    
                    end. 
                    if ((vprotot >= vprotot1 - 1) and
                        (vprotot <= vprotot1 + 1)) 
                    then do:
                        total_pro_calc = vprotot1.
                    end.    
                    else do:
                        total_pro_calc = vprotot1 - vdesval.
                    end.   
 
                    libera_nota = yes.
                    leave bl-princ.
                end.
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
            /* clear frame f-produ1 all no-pause.
            clear frame f-produ1 all no-pause. */

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
            
                w-movim.movicms2 = ( (w-movim.movqtm * (w-movim.movpc + 
                                                       w-movim.movfre +
                                                       desp_acess)) *
                                   (1 - (v-red / 100)) ) *
                                   (w-movim.movalicms / 100).

                soma_icm_semdesc = soma_icm_semdesc + w-movim.movicms2. 
            
                if tipo_desconto < 5
                then do:
 
                    w-movim.movicms = ( (w-movim.movqtm * (w-movim.movpc +  
                                                           desp_acess +
                                                           w-movim.movfre -
                                                       w-movim.valdes)) *
                                        (1 - (v-red / 100)) ) *
                                        (w-movim.movalicms / 100).

                    soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 


                    if w-movim.movalipi <> 0
                    then
                    w-movim.movipi = ((w-movim.movpc + 
                                       w-movim.movfre -
                                       w-movim.valdes) * w-movim.movqtm) * 
                                     (w-movim.movalipi / 100).
                
                    ipi_item = ipi_item + w-movim.movipi.
                    frete_item = frete_item + 
                                 (w-movim.movfre * w-movim.movqtm).
                 
                end.
                else do:
                 
                    w-movim.movicms = ( (w-movim.movqtm * (w-movim.movpc + 
                                         desp_acess +
                                         w-movim.movfre -
                                        (w-movim.valdes / w-movim.movqtm))) *
                                        (1 - (v-red / 100)) ) *
                                        (w-movim.movalicms / 100).


                    soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 


                    if w-movim.movalipi <> 0
                    then w-movim.movipi = ((w-movim.movpc + 
                                            w-movim.movfre -
                                           (w-movim.valdes / w-movim.movqtm)) 
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
                        w-movim.movfre with frame f-produ1.
                down with frame f-produ1.
                pause 0.
                vprotot1 = vprotot1 + (w-movim.movqtm * w-movim.movpc).
                display vprotot1 with frame f-produ.
            end.
            next.
        end.
        
        vant = no.
        find produ where produ.procod = input vprocod no-lock no-error.

        /**
        if not avail produ and (vhiccod <> 699 and vhiccod <> 599)
        then do:
            message "Produto nao Cadastrado".
            vresp = yes.
            message "Deseja Cadastrar ? " update vresp.
            if not vresp
            then undo.
            else do with frame f-altera
                        row 10  centered OVERLAY SIDE-LABELS color black/cyan:
                disp vopcao no-label with frame f-escolha
                                centered side-label overlay row 8.
                                    choose field vopcao with frame f-escolha.
                if frame-index = 1
                then do transaction:
                    find last cprodu where cprodu.procod >= 400000 and
                                           cprodu.procod <= 449999
                    exclusive-lock no-error.
                    if available cprodu
                    then assign vprocod = cprodu.procod + 1.
                    else assign vprocod = 400000.
                end.
                if frame-index = 2
                then do transaction:
                    find last cprodu where cprodu.procod >= 450000 and
                                           cprodu.procod <= 900000
                    exclusive-lock no-error.
                    if available cprodu
                    then assign vprocod = cprodu.procod + 1.
                    else assign vprocod = 450000.
                end.
            end.
            do transaction:
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
                       produ.proipiper colon 15  label "Ali.Icms"
                       produ.proclafis colon 50  label "Para Montagem"
                                    format "x(3)"
                                  WITH OVERLAY SIDE-LABELS .
                       produ.prozort = fabri.fabfant + "-" + produ.pronom.
                if produ.proclafis = ""
                then produ.proclafis = "NAO".
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
                           update vestvenda colon 20.
                end.
            end.
            for each bestab:
                do transaction:
                    create estoq.
                    assign estoq.etbcod    = bestab.etbcod
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
        else vant = yes.
        
        display produ.pronom when avail produ with frame f-produ.
        
        /* caracteristica */
        run p-ver-caracteristica. 
        
        find estoq where estoq.etbcod = 999 and
                         estoq.procod = produ.procod no-lock no-error.
        if not available estoq
        then do:
            message "Produto Sem Registro de Armazenagem". pause. undo.
        end.
        *****/
        
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
            find nfe.clafis where nfe.clafis.codfis = w-movim.codfis
                    NO-LOCK no-error.
            if not avail nfe.clafis
            then do:
                message "Classificacao Fiscal Nao Cadastrada".
                pause.
                undo, retry.
            end.
            w-movim.sittri = nfe.clafis.sittri.

            update w-movim.sittri 
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
            nfe.clafis.sittri = w-movim.sittri.            
            end.
            /*
            if forne.ufecod = "RS"
            then if w-movim.sittri = 20
                 then nfe.clafis.perred = 29.4117.
                 else nfe.clafis.perred = 0.
            */
            
            run atu_fis.p( input w-movim.wrec,
                           input nfe.clafis.codfis).
                                   
        end.         
                    
        if (w-movim.codfis >= 18060000 and 
            w-movim.codfis <= 18069999) or
            w-movim.codfis = 84715010
        then update w-movim.movipi
                    with frame f-sittri.
       
        update w-movim.movqtm 
                with frame f-produ1.
        /**               
        w-movim.movpc = estoq.estcusto. 
        w-movim.movqtm = vmovqtm + w-movim.movqtm. 
        display w-movim.movqtm with frame f-produ1. 
        **/
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
        then w-movim.movalicms = 17. 
        else w-movim.movalicms = 12. 
       
        w-movim.movfre = (w-movim.movpc - w-movim.valdes) * (vfre / vprotot).
        
        
        update w-movim.movalicms with frame f-produ1.
                    
        if (w-movim.codfis >= 18060000 and 
            w-movim.codfis <= 18069999) or 
            w-movim.codfis = 84715010
        then.
        else do: 
            w-movim.movalipi = nfe.clafis.peripi.
            update w-movim.movalipi with frame f-produ1.
        end.
        
        update w-movim.movfre with frame f-produ1.
        
           
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
            find nfe.clafis where nfe.clafis.codfis = w-movim.codfis no-lock.
            
            v-red = nfe.clafis.perred.
           
            /*
            if forne.ufecod <> "RS"
            then v-red = 0.
            */
            
            w-movim.movicms2 = ( (w-movim.movqtm * (w-movim.movpc + 
                                                    desp_acess +
                                                   w-movim.movfre)) *
                              (1 - (v-red / 100)) ) *
                              (w-movim.movalicms / 100).

            soma_icm_semdesc = soma_icm_semdesc + w-movim.movicms2. 
            
                          
            
            if tipo_desconto < 5
            then do:
 
                w-movim.movicms = ( (w-movim.movqtm * (w-movim.movpc +  
                                                       w-movim.movfre -
                                                       w-movim.valdes +
                                                       desp_acess)) *
                                    (1 - (v-red / 100)) ) *
                                    (w-movim.movalicms / 100).

 
                soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 


                if w-movim.movalipi <> 0
                then
                w-movim.movipi = ((w-movim.movpc + 
                                   w-movim.movfre -
                                   w-movim.valdes) * w-movim.movqtm) * 
                                 (w-movim.movalipi / 100).

                
                ipi_item = ipi_item + w-movim.movipi.
                frete_item = frete_item + (w-movim.movfre * w-movim.movqtm).
                 
            end.
            else do:
                 
                 w-movim.movicms = ( (w-movim.movqtm * (w-movim.movpc + 
                                                        desp_acess + 
                                                        w-movim.movfre - 
                                                      (w-movim.valdes / 
                                                       w-movim.movqtm))) *
                                     (1 - (v-red / 100)) ) *
                                     (w-movim.movalicms / 100).


                 soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 


                 if w-movim.movalipi <> 0
                 then
                 w-movim.movipi = ((w-movim.movpc + 
                                    w-movim.movfre -
                                    (w-movim.valdes / w-movim.movqtm)) 
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
    else do:
        sresp = yes.
        libera_nota = yes.
    end.    
    if not sresp
    then undo, retry.
    end.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f2 no-pause.
    hide frame f-base1 no-pause.
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
                    " = " ( 100 - ((total_custo / total_nota) * 100))
                    " % ".
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
                    " = " ( 100 - ((total_custo / total_nota) * 100))
                    " % ".
            pause.        
            for each w-movim:
                delete w-movim.
            end.    
            undo, retry.
        end.
           
    end.       
    
    vsresp2 = no.

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

    do transaction:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.cxacod   = if avail frete
                            then frete.forcod else 0
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
               plani.isenta = plani.platot - plani.outras - plani.bicms.
               if plani.descprod = 0
               then plani.descprod = vdesval.
               if vtipo = 0
               then plani.notobs[3] = "".
               else plani.notobs[3] = vobs[vtipo].

        if avail cpforne and
            date(cpforne.date-1) <> ? and
            date(cpforne.date-1) <= today
        then do:
            create planiaux.
            assign
                planiaux.etbcod = plani.etbcod
                planiaux.movtdc = plani.movtdc 
                planiaux.emite  = plani.emite
                planiaux.serie  = plani.serie
                planiaux.numero = plani.numero
                planiaux.placod = plani.placod
                planiaux.nome_campo  = "TIPO-NF"
                planiaux.valor_campo = "ELETRONICA"
                planiaux.tipo_campo = "char"
                .
        end.
    end.
    
    /****************** atualiza custos ********************
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
            /*
            find nfe.clafis where nfe.clafis.codfis = w-movim.codfis NO-LOCK no-error.
            if avail nfe.clafis
            then assign nfe.clafis.perred = 0.
                        nfe.clafis.sittri = 0.
             */           
        end.
            
        for each estoq where estoq.procod = produ.procod.
            do transaction:
                estoq.estcusto = vcusto.
            end.    
        end.

    end.
    ****************************/
    
    for each w-movim:
    
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        if not avail produ
        then next.
        find first plani where plani.etbcod = estab.etbcod and
                               plani.placod = vplacod no-lock.

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
                   movim.movicms = w-movim.valicms
                   movim.movpdes = w-movim.movdes
                   movim.movdes  = w-movim.valdes
                   movim.movacfin = w-movim.movacfin
                   movim.MovAlICMS = w-movim.movalicms
                   movim.MovAlIPI  = w-movim.movalipi
                   movim.movipi    = w-movim.movipi
                   movim.movdev    = w-movim.movfre 
                   movim.movdat    = plani.pladat
                   movim.MovHr     = int(time)
                   MOVIM.DATEXP    = plani.datexp
                   movim.desti     = plani.desti
                   movim.emite     = plani.emite.

            if tipo_desconto = 5
            then movim.movdes = w-movim.valdes / w-movim.movqtm.       
                   
            find nfe.clafis where nfe.clafis.codfis = produ.codfis no-lock no-error.
            if avail nfe.clafis
            then movim.movsubst = nfe.clafis.persub.
            
            if w-movim.movfre = 0
            then movim.movdev = frete_unitario.      
            
           delete w-movim.
        end.
    end.

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

    
    vezes = 0. prazo = 0.
    find first plani where plani.etbcod = estab.etbcod and
                           plani.placod = vplacod no-lock.
    find first titulo where
               titulo.empcod = wempre.empcod and
               titulo.titnat = yes and
               titulo.modcod = foraut.modcod and
               titulo.etbcod = vetbcod and
               titulo.clifor = plani.emite and
               titulo.titnum = string(plani.numero)
               no-lock no-error.
               
    /***/                       
    if not avail titulo
    then do:
    if simpnota = yes
    then do:
        do vi = 1 to 20:
            if acha("DUP-" + string(vi,"999"),placon.notobs[1]) = ?
            then leave.
            do transaction:
                create titulo.
                assign titulo.etbcod = plani.etbcod
                       titulo.titnat = yes
                       titulo.modcod = foraut.modcod
                       titulo.clifor = forne.forcod
                       titulo.titsit = "LIB"
                       titulo.empcod = wempre.empcod
                       titulo.titdtemi = plani.pladat
                       titulo.titnum = string(plani.numero)
                       titulo.titpar = vi  
                       titulo.titbanpag = vsetcod.
                       
                titulo.titvlcob =
                        dec(acha("VAL-" + string(vi,"999"),placon.notobs[1])) 
                       .
                titulo.titdtven =
                        date(acha("DTV-" + string(vi,"999"),placon.notobs[1])) 
                        .
                vezes = vi.        
                vtotpag = vtotpag + titulo.titvlcob.
            end.
        end.
        run man-titulo.
    end.
    else  do on error undo:
    
    vezes = 1.
    update vezes label "Vezes"
                with frame f-tit width 80 side-label centered color white/red.
    
    if plani.platot = 0
    then vtotpag = plani.protot.
    else vtotpag = plani.platot.

    do on error undo:
        update vtotpag with frame f-tit.
    
        if  vtotpag = 0 or
            vtotpag < (plani.protot + plani.ipi - vdesval - plani.descprod)
        then do:
            message "Verifique os valores da nota".
            undo, retry.
        end.
        
        if plani.platot = 0
        then assign
                plani.platot = vtotpag
                plani.protot = vtotpag
                .

        if plani.opccod = 1551
        then do:
                    find first fatudesp where
                        /*fatudesp.etbcod = vetbcod and*/
                         fatudesp.clicod = plani.emite and
                         fatudesp.fatnum = plani.numero
                        no-error.
                    if not avail fatudesp
                    then do:
                        create fatudesp.
                        assign
                            fatudesp.etbcod     = plani.desti
                            fatudesp.fatnum     = plani.numero
                            fatudesp.clicod     = plani.emite
                            fatudesp.situacao   = "A" 
                            fatudesp.setcod = vsetcod
                            fatudesp.modcod = "DUP"
                            fatudesp.modctb = "DUP"
                            .

                    end.
                    assign
                        fatudesp.emissao    = plani.pladat
                        fatudesp.inclusao   = plani.dtincl
                        fatudesp.val-total  = plani.protot
                        fatudesp.val-icms   = plani.icms
                        fatudesp.val-ipi    = plani.ipi
                        fatudesp.val-acr    = plani.acfprod
                        fatudesp.val-des    = plani.descprod
                        fatudesp.val-ir     = 0
                        fatudesp.val-iss    = 0 
                        fatudesp.val-inss   = 0
                        fatudesp.val-pis    = 0 
                        fatudesp.val-cofins = 0
                        fatudesp.val-csll   = 0
                        fatudesp.val-liquido = vtotpag 
                        fatudesp.qtd-parcela = vezes
                        fatudesp.char1 = "FILIAL=" + string(setbcod,"999") +
                             "|FUNC=" + string(sfuncod,"9999999999")
                             .
                    end.
        end.

        do i = 1 to vezes:
            if setbcod <> vetbcod  or
               vetbcod = 999
            then do transaction:
                
                create titulo.
                assign titulo.etbcod = plani.etbcod
                       titulo.titnat = yes
                       titulo.modcod = foraut.modcod
                       titulo.clifor = forne.forcod
                       titulo.titsit = "lib"
                       titulo.empcod = wempre.empcod
                       titulo.titdtemi = plani.pladat
                       titulo.titnum = string(plani.numero)
                       titulo.titpar = i
                       titulo.titbanpag = vsetcod.
                if prazo <> 0
                then assign titulo.titvlcob = vtotpag
                            titulo.titdtven = titdtemi + prazo.
                else assign titulo.titvlcob = vtotpag / vezes
                            titulo.titdtven = titulo.titdtemi + (30 * i).
            end.
            else do transaction:
                create titluc.
                assign titluc.etbcod = plani.etbcod
                       titluc.titnat = yes
                       titluc.modcod = foraut.modcod
                       titluc.clifor = forne.forcod
                       titluc.titsit = "BLO"
                       titluc.empcod = wempre.empcod
                       titluc.titdtemi = plani.pladat
                       titluc.titnum = string(plani.numero)
                       titluc.titpar = i
                       titluc.cobcod = 1
                       titluc.evecod = 4
                       titluc.titbanpag = vsetcod.
                if prazo <> 0
                then assign titluc.titvlcob = vtotpag
                            titluc.titdtven = titluc.titdtemi + prazo.
                else assign titluc.titvlcob = vtotpag / vezes
                            titluc.titdtven = titluc.titdtemi + (30 * i).
            end.

        end.
        if setbcod <> vetbcod
        then run man-titulo.
        else run man-titluc.
    end.
    end.
    message "Nota Fiscal Incluida". pause.
    hide frame f-titulo no-pause.
    clear frame f-titulo all.
    for each w-movim:
        delete w-movim.
    end.
end.

procedure man-titulo:
    vsaldo = vtotpag.
        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = foraut.modcod and
                              titulo.etbcod = estab.etbcod and
                              titulo.clifor = forne.forcod and
                              titulo.titnum = string(plani.numero).
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
        /***
        if vfrete > 0
        then do transaction:
            create btitulo.
            assign btitulo.etbcod   = plani.etbcod
                   btitulo.titnat   = yes
                   btitulo.modcod   = "NEC"
                   btitulo.clifor   = if avail frete
                         then frete.forcod  else forne.forcod
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
         ***/
    do on error undo: 
        find current plani.
        plani.notsit = no.
    end.         
end procedure.

procedure man-titluc:
    vsaldo = vtotpag.
        for each titluc where titluc.empcod = wempre.empcod and
                              titluc.titnat = yes and
                              titluc.modcod = foraut.modcod and
                              titluc.etbcod = estab.etbcod and
                              titluc.clifor = forne.forcod and
                              titluc.titnum = string(plani.numero).
            display titluc.titpar
                    titluc.titnum
                        with frame ftitluc down centered
                                color white/cyan.
            prazo = 0.
            /*
            update prazo with frame ftitluc.
            */
            do transaction:
                titluc.titdtven = vpladat + prazo.
                titluc.titvlcob = vsaldo.
                update titluc.titdtven
                       titluc.titvlcob with frame ftitluc no-validate.
            end.
            vsaldo = vsaldo - titluc.titvlcob.
        
            down with frame ftitluc.
        end.
        do on error undo:
            find current plani.
            plani.notsit = no.
        end.
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

/***
procedure p-wmspallet:

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

end procedure.
**/

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

procedure lancamento-ctb:
    def var vcompl like lancxa.comhis format "x(50)" init "".
    def var vlanhis like lancxa.lanhis init 0.
    def var vnumlan as int init 0.
    def var vlancod as int init 0.

    find last lancxa where lancxa.forcod = forne.forcod
                      and  lancxa.etbcod = titulo.etbcod
                      and  lancxa.lantip = "C"
                       no-lock no-error.
    if avail lancxa
    then assign 
            vlancod = lancxa.lancod
            vlanhis = lancxa.lanhis
            vcompl  = lancxa.comhis.
                     
    if titulo.clifor = 533
    then vlanhis = 5.
                    
    if titulo.clifor = 100071
    then vlanhis = 4.
    if titulo.clifor = 100072
    then vlanhis = 3.
                        
    find lanaut where lanaut.etbcod = titulo.etbcod and
                      lanaut.forcod = titulo.clifor
                      no-lock no-error.
    if avail lanaut
    then do:
        assign vlancod = lanaut.lancod
               vlanhis = lanaut.lanhis.
    end.
                     
    if vlancod = 0 or
       vlanhis = 0
    then do:
        bell.
        message color red/with
        "Codigo para lançamento contábil não encontrado." skip
        "Favor comunicar o SETOR CONTÁBIL."
        view-as alert-box.
    end.
    else do:
        if vlanhis = 150
        then vcompl = tablan.landes.
        else if vlanhis <> 2
        then vcompl = titulo.titnum + "-" + string(titulo.titpar)
                                    + " " + forne.fornom.
        else vcompl = forne.fornom.

        assign
            titulo.vencod = vlancod
            titulo.titnumger = vcompl
            titulo.titparger = vlanhis.
    end.
end procedure.

