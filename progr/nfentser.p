{admcab.i}

def input parameter p-movtdc like tipmov.movtdc.

def buffer bbestab for estab.

def var plaservi-descprod   like plaservi.descprod.
def var plaservi-notpis     like plaservi.notpis.
def var plaservi-notcofins  like plaservi.notcofins.
def var plaservi-iss        like plaservi.iss.
def var plaservi-csll       as dec.
def var plaservi-irrf       as dec.
def var plaservi-platot     as dec.
def var plaservi-inss       as dec.
def var tipo-pagamento   as int format "9".

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
def var vsresp2 as log format "Sim/Nao".
def var vfilenc like estab.etbcod.
def var total_nota like plaservi.platot.
def var desp_acess like movservi.movpc.
def var vsenha as int.
def var vv     as int.
def var xx     as char.
def var vestpro as int.
def buffer bmovservi for movservi.
def new shared temp-table tt-proemail
    field procod like produ.procod.

def var perc_dif as dec.
def var total_custo as dec format "->>,>>9.9999".
def var valor_rateio like plaservi.platot.
def var soma_icm_comdesc like plaservi.platot.
def var soma_icm_semdesc like plaservi.platot.
def var total_icm_calc   like movservi.movpc.
def var total_pro_calc   like movservi.movpc.
def var total_ipi_calc   like movservi.movpc.
def var maior_valor like movservi.movpc.
def var v-kit as log format "Sim/Nao".
def var libera_nota as log.
def var tranca as log.
def var valor_desconto as dec format ">>,>>9.9999".
def var v-red like suporte.clafis.perred.
def var vsub like movservi.movpc.
def buffer bestab for estab.
def var vfre as dec format ">>,>>9.99".
def var vacr as dec format ">,>>9.99".
def var voutras like plaservi.outras.
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

def new shared temp-table w-movservi 
    field wrec    as   recid 
    field codfis    like suporte.clafis.codfis 
    field sittri    like suporte.clafis.sittri
    field movqtm    like movservi.movqtm 
    field movacfin  like movservi.movacfin
    field subtotal  like movservi.movpc format ">>>,>>9.99" column-label "Subtot" 
    field movpc     like movservi.movpc format ">,>>9.99" 
    field movalicms like movservi.movalicms initial 17 
    field valicms   like movservi.movicms
    field movicms   like movservi.movicms
    field movicms2  like movservi.movicms
    field movalipi  like movservi.movalipi 
    field movipi    like movservi.movipi
    field movfre    like movservi.movpc 
    field movdes    as dec format ">,>>9.9999"
    field valdes    as dec format ">,>>9.9999".
    
def workfile wetique
    field wrec as recid
    field wqtd like estoq.estatual.

def var vtipo-op as char format "x(12)" extent 2 
    initial [" Normal "," Encomenda "].    
    
def var vopcao as char format "x(10)" extent 2 initial [" Moveis ","Confeccao"].
def var vestcusto  like estoq.estcusto.
def var vestmgoper like estoq.estmgoper.
def var vestmgluc  like estoq.estmgluc.
def var vtabcod    like estoq.tabcod.
def var vestvenda  like estoq.estvenda.
def buffer cprodu for produ.
def var wetccod like produ.etccod.
def var wfabcod like produ.fabcod.
def var wprorefter like produ.prorefter.
def buffer witem for item.
def var witecod like produ.itecod.
def var vitecod like produ.itecod.
def var vresp    as log format "Sim/Nao".
def var wrsp    as log format "Sim/Nao".
def var vdesc    like plaservi.descprod format ">9.99 %".
def var i as i.
def var Vezes as int format ">9".
def var Prazo as int format ">>9".
def var v-ok as log.
def buffer bclien for clien.
def var vforcod like forne.forcod.
def var vsaldo    as dec.
def var vmovqtm   like  movservi.movqtm.
def var vvencod   like plaservi.vencod.
def var vsubtotal like  movservi.movqtm.
def var valicota  like  plaservi.alicms format ">9,99" initial 17.
def var vpladat   like  plaservi.pladat.
def var vrecdat   like  plaservi.pladat label "Recebimento".
def var vnumero   like  plaservi.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plaservi.bicms.
def var vicms     like  plaservi.icms .
def var vprotot   like  plaservi.protot.
def var vprotot1  like  plaservi.protot.
def var vdescpro  like  plaservi.descpro.
def var vacfprod  like  plaservi.acfprod.
def var vfrete    like  plaservi.frete format ">>,>>9.99".
def var vseguro   like  plaservi.seguro.
def var vdesacess like  plaservi.desacess.
def var vipi      like  plaservi.ipi.
def var vplatot   like  plaservi.platot.
def var vtotal    like plaservi.platot.
def var vetbcod   like  plaservi.etbcod.
def var vserie    as char format "x(02)".
def var vopccod   like  opcom.opccod.
def var vhiccod   like  plaservi.hiccod initial 112.
def var vprocod   like  produ.procod.
def var vbiss     like  plaservi.biss.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movservi.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movservi.movseq.
def var vplacod     like plaservi.placod.
def var vtotpag      like plaservi.platot.
def buffer bplaservi for plaservi.
def var recpro as recid.
def var ipi_item  like plaservi.ipi.
def var frete_item like plaservi.frete.
def var vdifipi as int.
def var frete_unitario like plaservi.platot.
def var qtd_total as int.
def var vrec as recid.
def buffer bforne for forne.
def var cgc-admcom like forne.forcgc.
def buffer bliped for liped.
def var vtipo as int format "99".
def var vdesval like plaservi.platot.
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
     w-movservi.movqtm format ">>>>>9" column-label "Qtd"
     w-movservi.movpc  format ">>,>>9.99" column-label "Val.Unit."
     w-movservi.subtotal  format ">>>>,>>9.99" column-label "Subtot"
     w-movservi.valdes format ">>>,>>9.9999" column-label "Val.Desc"
     w-movservi.movdes format ">9.9999" column-label "%Desc"
     w-movservi.movalicms column-label "ICMS" format ">9.99"
     w-movservi.movalipi  column-label "IPI"  format ">9.99"
     w-movservi.movfre    column-label "Frete" format ">>,>>9.99"
     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.

form w-movservi.codfis label "Class.Fiscal" format "99999999"  
     w-movservi.sittri label "Situacao Trib." format "999"
     v-kit          label "Kit" 
     w-movservi.movipi label "Total IPI" 
        with frame f-sittri side-label centered row 10 overlay.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(23)"
     vprotot1 with frame f-produ centered color message side-label
                        row 6 no-box width 81.
form estab.etbcod label "Filial" colon 15
    estab.etbnom  no-label
    cgc-admcom    label "Fornecedor" colon 15
    forne.fornom no-label
    vopccod  label "Op. Fiscal" format "9999" colon 15 
    opcom.opcnom  no-label
    vnumero       colon 15
    vserie        label "Serie"
    vpladat colon 15
    vrecdat colon 39
    /*vfrecod label "Transp." colon 15
    frete.frenom no-label
    vfrete label "Frete"*/
      with frame f1 side-label width 80 row 4 color white/cyan.

 
def var vbase_subst like plaservi.bsubst.
def var v_subst     like plaservi.icmssubst.
def var voutras_acess like plaservi.platot.
def var vdtaux as date.
def var simpnota as log format "Sim/Nao".

form vbicms        column-label "Base Icms" at 01
     vicms         column-label "Valor Icms"
     vbase_subst   column-label "Base Icms Subst" 
     v_subst       column-label "Valor Substituicao" 
     vprotot       column-label "Tot.Prod." 
        with frame f-base1 row 12 overlay width 80.

form plaservi-descprod     label "Valor DESCONTO"
     plaservi-notpis       label "Valor PIS     "
     plaservi-notcofins    label "Valor COFINS  "
     plaservi-iss          label "Valor ISS     "
     plaservi-csll         label "Valor CSLL    "
     plaservi-irrf         label "Valor IRRF    "
     plaservi-inss         label "Valor INSS    "
     plaservi-platot       label "Valor TOTAL   " 
     tipo-pagamento     label "Tipo PAGAMENTO"
     with frame f2 side-label 1 column row 10 overlay.
        
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
/****    
{setbrw.i}

def var v-sair as log.
v-sair = no.

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

hide frame f-linha.

if keyfunction(lastkey) = "END-ERROR"
then return.
    
if v-sair
then return.
****/

def var vmovtdc like tipmov.movtdc.
vmovtdc = p-movtdc.
def var tem-itens as log init no.
find first tipmovaux where tipmovaux.movtdc = vmovtdc and
                           tipmovaux.nome_campo = "TEM-ITENS"
           no-lock no-error.
if not avail tipmovaux
then tem-itens = no.
else if tipmovaux.valor_campo = "SIM"
    then tem-itens = yes.
    else tem-itens = no.

find tipmov where tipmov.movtdc = vmovtdc no-lock.

disp tipmov.movtnom
    with frame f-tipmov no-label no-box 
    color message centered row 3.
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
        /**
        update vsetcod label "Setor" with frame ff1 side-label width 80.
    
        find setaut where setaut.setcod = vsetcod no-lock no-error.
        if not avail setaut
        then do:
            message "Setor nao cadastrado".
            undo, retry.
        end.
        display setaut.setnom no-label with frame ff1.
        **/         
        prompt-for estab.etbcod with frame f1.
        vetbcod = input frame f1 estab.etbcod.
    end.
    else vetbcod = setbcod.
    
    {valetbnf.i estab vetbcod ""Filial""}

    run p-deleta-tmp.
    
    display estab.etbcod
            estab.etbnom with frame f1.
            
    vetbcod = estab.etbcod.
    if /* vetbcod <= 90 or */
       vetbcod >= 999
    then do:
        message "Deposito Invalido". pause.
        undo, leave.
    end.

    v-kit = no.
    libera_nota = no.
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

    find first plaservi where plaservi.numero = vnumero and
                     plaservi.emite  = vforcod and
                     plaservi.desti  = estab.etbcod and
                     plaservi.serie  = vserie and
                     plaservi.etbcod = estab.etbcod and
                     plaservi.movtdc = vmovtdc no-lock no-error.
    if avail plaservi
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
                find first w-movservi where
                           w-movservi.wrec = recid(produ) no-error.
                if not avail w-movservi
                then do:                        
                    create w-movservi.
                    assign
                        w-movservi.wrec = recid(produ)
                        /*w-movservi.codfis
                        w-movservi.sittri 
                        */.
                end.
                assign
                    w-movservi.movqtm = movcon.movqtm
                    w-movservi.movacfin = movcon.movacfin
                    /*w-movservi.subtotal
                    */
                    w-movservi.movpc  = movcon.movpc
                    w-movservi.movalicms = movcon.movalicms
                    w-movservi.valicms  = movcon.movalicms
                    w-movservi.movicms  = movcon.movicms
                    w-movservi.movalipi = movcon.movalipi 
                    w-movservi.movipi = movcon.movipi
                    w-movservi.movdes = movcon.movdes 
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
    /***
    if tipmov.movtdc <> 37 and
       tipmov.movtdc <> 38 and
       tipmov.movtdc <> 39 and
       tipmov.movtdc <> 47
    then do:   
        update vfrecod with frame f1.
        find frete where frete.frecod = vfrecod no-lock.
        display frete.frenom no-label with frame f1.
        update vfrete with frame f1.
        vvencod = vfrecod.
    end.
    ***/
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
           tipmov.movtdc <> 39 and
           tipmov.movtdc <> 47
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
    
    /***
    do on error undo, retry:
        if tipmov.movtdc <> 37 and
           tipmov.movtdc <> 38 and
           tipmov.movtdc <> 39 and
           tipmov.movtdc <> 47
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
           tipmov.movtdc <> 39 and
           tipmov.movtdc <> 47
    then do:   
            update vseguro with frame f2.
    end.
    do on error undo, retry:
        if tipmov.movtdc <> 37 and
           tipmov.movtdc <> 38 and
           tipmov.movtdc <> 39 and
           tipmov.movtdc <> 47
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
           tipmov.movtdc <> 39 and
           tipmov.movtdc <> 47
    then do:   
            update vipi  with frame f2.
    end.        
    update
           vplatot with frame f2.
    
    if tipmov.movtdc <> 37 and
           tipmov.movtdc <> 38 and
           tipmov.movtdc <> 39 and
           tipmov.movtdc <> 47
    then.
    else vprotot = vplatot.
              
    if vbicms = vplatot and
       voutras_acess > 0
    then assign vbiss = voutras_acess
                voutras_acess = 0.
    
    *****/    

    update 
        plaservi-descprod
        plaservi-notpis
        plaservi-notcofins
        plaservi-iss 
        plaservi-csll
        plaservi-irrf 
        plaservi-inss
        plaservi-platot
        tipo-pagamento 
        help "1-A vista   2-Aprazo   3-Sem pagamento"
        with frame f2 no-validate.

    /****
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
     ******/
     
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
        for each w-movservi where w-movservi.movqtm = 0 or
                               w-movservi.movpc  = 0 or
                               w-movservi.subtotal = 0:
            delete w-movservi.
        end.    
        for each w-movservi with frame f-produ1:
            find produ where recid(produ) = w-movservi.wrec no-lock no-error.
            
            if not avail produ
            then next.
            
            display produ.procod
                    w-movservi.movqtm
                    w-movservi.valdes
                    w-movservi.movdes
                    w-movservi.subtotal
                    w-movservi.movpc
                    w-movservi.movalicms
                    w-movservi.movalipi
                    w-movservi.movfre  with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot1 = vprotot1 + (w-movservi.movqtm * w-movservi.movpc).
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
                for each w-movservi:
                    delete w-movservi.
                end.
                vprocod = 0.
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
                undo, return.
            end.
            else do:
                find first w-movservi no-error.
                if not avail w-movservi and
                (opcom.opccod = "1949"  or
                 opcom.opccod = "2949"  or
                 opcom.opccod = "1922"  or
                 opcom.opccod = "2922") 
                then do:
                    
                    if ((vicms >= soma_icm_comdesc - 1) and
                        (vicms <= soma_icm_comdesc + 1)) 
                    then do:
                    
                        total_icm_calc = soma_icm_comdesc.
                        
                        for each w-movservi:
                            w-movservi.valicms = w-movservi.movicms.
                        end.
                        
                    end.
                    else do:
                        
                        total_icm_calc = soma_icm_semdesc.
                        
                        for each w-movservi:
                            w-movservi.valicms = w-movservi.movicms2.
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
                        
                        for each w-movservi:
                            w-movservi.valicms = w-movservi.movicms.
                        end.
                        
                    end.
                    else do:
                        
                        total_icm_calc = soma_icm_semdesc.
                        
                        for each w-movservi:
                            w-movservi.valicms = w-movservi.movicms2.
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
            
            find first w-movservi where w-movservi.wrec = recid(produ) no-error.

            update w-movservi.movacfin label "Acrescimo Financeiro"
                    with frame f-acr side-label centered overlay. 
            
            w-movservi.subtotal = w-movservi.subtotal + w-movservi.movacfin.
            w-movservi.movpc = w-movservi.subtotal / w-movservi.movqtm.
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
            for each w-movservi: 
                qtd_total = qtd_total + w-movservi.movqtm. 
            end.    

            desp_acess = vbiss / qtd_total.

            for each w-movservi:
                find produ where recid(produ) = w-movservi.wrec no-lock.
                display produ.procod 
                        w-movservi.movqtm 
                        w-movservi.valdes 
                        w-movservi.movdes 
                        w-movservi.subtotal 
                        w-movservi.movpc 
                        w-movservi.movalicms 
                        w-movservi.movalipi 
                        w-movservi.movfre with frame f-produ1.

                down with frame f-produ1.
                pause 0.
            
                w-movservi.movicms2 = ( (w-movservi.movqtm * (w-movservi.movpc + 
                                                       w-movservi.movfre +
                                                       desp_acess)) *
                                   (1 - (v-red / 100)) ) *
                                   (w-movservi.movalicms / 100).

                soma_icm_semdesc = soma_icm_semdesc + w-movservi.movicms2. 
            
                if tipo_desconto < 5
                then do:
 
                    w-movservi.movicms = ( (w-movservi.movqtm * (w-movservi.movpc +  
                                                           desp_acess +
                                                           w-movservi.movfre -
                                                       w-movservi.valdes)) *
                                        (1 - (v-red / 100)) ) *
                                        (w-movservi.movalicms / 100).

                    soma_icm_comdesc = soma_icm_comdesc + w-movservi.movicms. 


                    if w-movservi.movalipi <> 0
                    then
                    w-movservi.movipi = ((w-movservi.movpc + 
                                       w-movservi.movfre -
                                       w-movservi.valdes) * w-movservi.movqtm) * 
                                     (w-movservi.movalipi / 100).
                
                    ipi_item = ipi_item + w-movservi.movipi.
                    frete_item = frete_item + 
                                 (w-movservi.movfre * w-movservi.movqtm).
                 
                end.
                else do:
                 
                    w-movservi.movicms = ( (w-movservi.movqtm * (w-movservi.movpc + 
                                         desp_acess +
                                         w-movservi.movfre -
                                        (w-movservi.valdes / w-movservi.movqtm))) *
                                        (1 - (v-red / 100)) ) *
                                        (w-movservi.movalicms / 100).


                    soma_icm_comdesc = soma_icm_comdesc + w-movservi.movicms. 


                    if w-movservi.movalipi <> 0
                    then w-movservi.movipi = ((w-movservi.movpc + 
                                            w-movservi.movfre -
                                           (w-movservi.valdes / w-movservi.movqtm)) 
                                           * w-movservi.movqtm) * 
                                           (w-movservi.movalipi / 100).

                         ipi_item = ipi_item + w-movservi.movipi.
                         frete_item = frete_item + 
                                      (w-movservi.movfre * w-movservi.movqtm).
                 
                end.
                       
                vprotot1 = vprotot1 + w-movservi.subtotal.
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
            find first w-movservi where w-movservi.wrec = recid(produ) no-error.
            if not avail w-movservi
            then do:
                message "Produto nao pertence a esta nota".
                undo.
            end.

            display produ.pronom format "x(35)" no-label with frame f-exclusao.
            if w-movservi.movqtm <> 1
            then update vqtd validate( vqtd <= w-movservi.movqtm,
                                       "Quantidade invalida" )
                        label "Qtd" with frame f-exclusao.
            else do:
                vqtd = 1.
                display vqtd with frame f-exclusao.
            end.
            
            find first w-movservi where w-movservi.wrec = recid(produ) no-error.
            if avail w-movservi
            then do:
                if w-movservi.movqtm = vqtd
                then do:
                    
                    delete w-movservi.
                    /*
                    find first tt-pavpro where 
                               tt-pavpro.recpro = recid(produ) no-error.
                    if avail tt-pavpro
                    then delete tt-pavpro.
                    */
                end.    
                else w-movservi.movqtm = w-movservi.movqtm - vqtd.
                hide frame f-exclusao no-pause.
            end.
            vprotot1 = 0.
            clear frame f-produ1 all no-pause.
            for each w-movservi with frame f-produ1:
                find produ where recid(produ) = w-movservi.wrec no-lock.
                display produ.procod
                        w-movservi.movqtm
                        w-movservi.valdes
                        w-movservi.movdes
                        w-movservi.subtotal
                        w-movservi.movpc
                        w-movservi.movalicms
                        w-movservi.movalipi
                        w-movservi.movfre with frame f-produ1.
                down with frame f-produ1.
                pause 0.
                vprotot1 = vprotot1 + (w-movservi.movqtm * w-movservi.movpc).
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
        find first w-movservi where w-movservi.wrec = recid(produ) no-error.
        if not avail w-movservi
        then do:
            create w-movservi.
            assign w-movservi.wrec = recid(produ).
            vcria = yes.
        end.
        
        vmovqtm = w-movservi.movqtm.
        vsub    = w-movservi.subtotal. 
       
        do on error undo, retry:
            display produ.procod with frame f-produ1.
           
            w-movservi.codfis = produ.codfis.
            pause 0.
            
            update w-movservi.codfis with frame f-sittri.
            find suporte.clafis where clafis.codfis = w-movservi.codfis no-error.
            if not avail suporte.clafis
            then do:
                message "Classificacao Fiscal Nao Cadastrada".
                pause.
                undo, retry.
            end.
            w-movservi.sittri = suporte.clafis.sittri.
            

            update w-movservi.sittri 
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
            suporte.clafis.sittri = w-movservi.sittri.            
            end.
            /*
            if forne.ufecod = "RS"
            then if w-movservi.sittri = 20
                 then clafis.perred = 29.4117.
                 else clafis.perred = 0.
            */
            
            run atu_fis.p( input w-movservi.wrec,
                           input suporte.clafis.codfis).
                                   
        end.         
                    
        if (w-movservi.codfis >= 18060000 and 
            w-movservi.codfis <= 18069999) or
            w-movservi.codfis = 84715010
        then update w-movservi.movipi
                    with frame f-sittri.
       
        update w-movservi.movqtm 
                with frame f-produ1.
        /**               
        w-movservi.movpc = estoq.estcusto. 
        w-movservi.movqtm = vmovqtm + w-movservi.movqtm. 
        display w-movservi.movqtm with frame f-produ1. 
        **/
        update w-movservi.subtotal with frame f-produ1.  
        
        w-movservi.movpc = w-movservi.subtotal / w-movservi.movqtm.
        display w-movservi.movpc with frame f-produ1. 

        if tipo_desconto = 2 
        then assign w-movservi.movdes = ((vdesval / valor_rateio) * 100) 
                    w-movservi.valdes = w-movservi.movpc * 
                                     (vdesval / valor_rateio).
            
        display w-movservi.valdes
                w-movservi.movdes with frame f-produ1.
                    
        if tipo_desconto = 3 
        then do: 
            update w-movservi.movdes with frame f-produ1. 
            w-movservi.valdes = w-movservi.movpc * (w-movservi.movdes / 100).
            
            vdesval = vdesval + 
                      ((w-movservi.movpc * (w-movservi.movdes / 100)) * 
                      w-movservi.movqtm).
            
        end.    
                
        if tipo_desconto = 4 
        then do on error undo, retry: 
            update w-movservi.valdes with frame f-produ1.
            if w-movservi.valdes > w-movservi.movpc
            then do:
                message "Informar o Valor do Desconto Unitario". 
                pause. 
                undo, retry.
            end.    
            w-movservi.movdes = ((w-movservi.valdes / w-movservi.movpc) * 100).
            vdesval = vdesval + (w-movservi.valdes * w-movservi.movqtm).
        end.
        
        if tipo_desconto = 5 
        then do on error undo, retry: 
            update w-movservi.valdes with frame f-produ1.
            if w-movservi.valdes > (w-movservi.movpc * w-movservi.movqtm)
            then do:
                message "Valor de Desconto Invalido". 
                pause. 
                undo, retry.
            end.    
            w-movservi.movdes = ((w-movservi.valdes / (w-movservi.movpc * 
                                                 w-movservi.movqtm)) * 100).
            vdesval = vdesval + w-movservi.valdes.
        end.    
            
        display w-movservi.valdes 
                w-movservi.movdes with frame f-produ1.
            
        if forne.ufecod = "RS" 
        then w-movservi.movalicms = 17. 
        else w-movservi.movalicms = 12. 
       
        w-movservi.movfre = (w-movservi.movpc - w-movservi.valdes) * (vfre / vprotot).
        
        
        update w-movservi.movalicms with frame f-produ1.
                    
        if (w-movservi.codfis >= 18060000 and 
            w-movservi.codfis <= 18069999) or 
            w-movservi.codfis = 84715010
        then.
        else do: 
            w-movservi.movalipi = suporte.clafis.peripi.
            update w-movservi.movalipi with frame f-produ1.
        end.
        
        update w-movservi.movfre with frame f-produ1.
        
           
        vprotot1 = 0.
        soma_icm_comdesc = 0.
        soma_icm_semdesc = 0. 
        ipi_item  = 0.
        frete_item = 0.
        clear frame f-produ1 all no-pause.
        clear frame f-produ1 all no-pause.
        
        qtd_total = 0.  
        desp_acess = 0. 
        for each w-movservi:  
            qtd_total = qtd_total + w-movservi.movqtm.  
        end.    

        desp_acess = vbiss / qtd_total.

 
        
        for each w-movservi:
            find produ where recid(produ) = w-movservi.wrec no-lock.
            display produ.procod 
                    w-movservi.movqtm 
                    w-movservi.valdes 
                    w-movservi.movdes 
                    w-movservi.subtotal 
                    w-movservi.movpc 
                    w-movservi.movalicms 
                    w-movservi.movalipi 
                    w-movservi.movfre with frame f-produ1.

            down with frame f-produ1.
            pause 0.
            find suporte.clafis where clafis.codfis = w-movservi.codfis no-lock.
            
            v-red = suporte.clafis.perred.
           
            /*
            if forne.ufecod <> "RS"
            then v-red = 0.
            */
            
            w-movservi.movicms2 = ( (w-movservi.movqtm * (w-movservi.movpc + 
                                                    desp_acess +
                                                   w-movservi.movfre)) *
                              (1 - (v-red / 100)) ) *
                              (w-movservi.movalicms / 100).

            soma_icm_semdesc = soma_icm_semdesc + w-movservi.movicms2. 
            
                          
            
            if tipo_desconto < 5
            then do:
 
                w-movservi.movicms = ( (w-movservi.movqtm * (w-movservi.movpc +  
                                                       w-movservi.movfre -
                                                       w-movservi.valdes +
                                                       desp_acess)) *
                                    (1 - (v-red / 100)) ) *
                                    (w-movservi.movalicms / 100).

 
                soma_icm_comdesc = soma_icm_comdesc + w-movservi.movicms. 


                if w-movservi.movalipi <> 0
                then
                w-movservi.movipi = ((w-movservi.movpc + 
                                   w-movservi.movfre -
                                   w-movservi.valdes) * w-movservi.movqtm) * 
                                 (w-movservi.movalipi / 100).

                
                ipi_item = ipi_item + w-movservi.movipi.
                frete_item = frete_item + (w-movservi.movfre * w-movservi.movqtm).
                 
            end.
            else do:
                 
                 w-movservi.movicms = ( (w-movservi.movqtm * (w-movservi.movpc + 
                                                        desp_acess + 
                                                        w-movservi.movfre - 
                                                      (w-movservi.valdes / 
                                                       w-movservi.movqtm))) *
                                     (1 - (v-red / 100)) ) *
                                     (w-movservi.movalicms / 100).


                 soma_icm_comdesc = soma_icm_comdesc + w-movservi.movicms. 


                 if w-movservi.movalipi <> 0
                 then
                 w-movservi.movipi = ((w-movservi.movpc + 
                                    w-movservi.movfre -
                                    (w-movservi.valdes / w-movservi.movqtm)) 
                                        * w-movservi.movqtm) * 
                                   (w-movservi.movalipi / 100).

                 ipi_item = ipi_item + w-movservi.movipi.
                 frete_item = frete_item + (w-movservi.movfre * w-movservi.movqtm).
                 
           
            end.
                       
            vprotot1 = vprotot1 + w-movservi.subtotal.
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
        for each w-movservi: 
            delete w-movservi.
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
        for each w-movservi:
            if w-movservi.subtotal > maior_valor
            then assign maior_valor = w-movservi.subtotal
                        recpro      = w-movservi.wrec.
        end.

        find first w-movservi where w-movservi.wrec = recpro no-error.
        if avail w-movservi
        then do:
            
            
            w-movservi.movicms = w-movservi.movicms + 
                              (total_icm_calc / w-movservi.movqtm).
            w-movservi.movpc   = w-movservi.movpc   + 
                              (total_pro_calc / w-movservi.movqtm).
            w-movservi.movipi  = w-movservi.movipi  + 
                              (total_ipi_calc / w-movservi.movqtm).
            
        end.
    end.    
   
    qtd_total = 0.
    total_custo = 0.
    for each w-movservi:
        qtd_total = qtd_total + w-movservi.movqtm.
    end.    
    
    frete_unitario = vfre / qtd_total.  
    
    for each w-movservi:
        find produ where recid(produ) = w-movservi.wrec no-lock.
    
        if w-movservi.movfre > 0
        then do:
            valor_desconto = w-movservi.valdes.
            
            if tipo_desconto = 5
            then valor_desconto = w-movservi.valdes / w-movservi.movqtm.
             
            vcusto = (w-movservi.movpc + w-movservi.movfre
                       - valor_desconto) +
                      ( (w-movservi.movpc + w-movservi.movfre
                       - valor_desconto) *
                        (w-movservi.movalipi / 100)).
                      
        end.
        else do:
        
            valor_desconto = w-movservi.valdes.
            if tipo_desconto = 5
            then valor_desconto = w-movservi.valdes / w-movservi.movqtm.

            vcusto = (w-movservi.movpc + frete_unitario
                       - valor_desconto) +
                      ( (w-movservi.movpc + frete_unitario
                       - valor_desconto) *
                        (w-movservi.movalipi / 100)).
        end.
        total_custo = total_custo + (vcusto * w-movservi.movqtm).
        
        
    end.
    find first w-movservi no-error.
    if avail w-movservi and tranca 
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
            for each w-movservi:
                delete w-movservi.
            end.    
            undo, retry.
        end.
           
    end.       
    
    vsresp2 = no.

    find estab where estab.etbcod = vetbcod no-lock.
    find last bplaservi where bplaservi.etbcod = estab.etbcod and
                           bplaservi.placod <= 500000 and
                           bplaservi.placod <> ? no-lock no-error.
    if not avail bplaservi
    then vplacod = 1.
    else vplacod = bplaservi.placod + 1.
    
    if not sresp
    then do:
        hide frame f-produ no-pause.
        hide frame f-produ1 no-pause.
        clear frame f-produ all.
        clear frame f-produ1 all.
        for each w-movservi:
            delete w-movservi.
        end.
        undo, retry.
    end.

    do transaction:
        create plaservi.
        assign plaservi.etbcod   = estab.etbcod
               /*plaservi.cxacod   = if avail frete
                            then frete.forcod else 0 */
               plaservi.placod   = vplacod
               plaservi.biss     = vbiss
               plaservi.protot   = vprotot
               plaservi.emite    = vforcod
               plaservi.bicms    = vbicms
               plaservi.icms     = vicms
               plaservi.descpro  = vprotot * (vdesc / 100)
               plaservi.acfprod  = vacr
               plaservi.frete    = vfre
               plaservi.seguro   = vseguro
               plaservi.desacess = voutras_acess
               plaservi.bsubst   = vbase_subst
               plaservi.icmssubst = v_subst
               plaservi.ipi      = vipi
               plaservi.platot   = vplatot
               plaservi.serie    = vserie
               plaservi.numero   = vnumero
               plaservi.movtdc   = tipmov.movtdc
               plaservi.desti    = estab.etbcod
               plaservi.modcod   = tipmov.modcod
               plaservi.opccod   = int(opcom.opccod)
               plaservi.vencod   = vvencod
               plaservi.notfat   = vforcod
               plaservi.dtinclu  = vrecdat
               plaservi.pladat   = vpladat
               plaservi.DATEXP   = today
               plaservi.horincl  = time
               plaservi.hiccod   = int(opcom.opccod)
               plaservi.notsit   = yes /**Aberta**/
               plaservi.outras = voutras
               plaservi.isenta = plaservi.platot - plaservi.outras - plaservi.bicms.
               if plaservi.descprod = 0
               then plaservi.descprod = vdesval.
               if vtipo = 0
               then plaservi.notobs[3] = "".
               else plaservi.notobs[3] = vobs[vtipo].

        assign
            plaservi.descprod  = plaservi-descprod
            plaservi.valor_pis    = plaservi-notpis
            plaservi.valor_cofins = plaservi-notcofins
            plaservi.valor_iss    = plaservi-iss 
            plaservi.valor_irrf   = plaservi-irrf
            plaservi.valor_inss   = plaservi-inss
            plaservi.valor_csll   = plaservi-csll
            .
        
    end.
    
    for each w-movservi:
    
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movservi.wrec no-lock no-error.
        if not avail produ
        then next.
        find first plaservi where plaservi.etbcod = estab.etbcod and
                               plaservi.placod = vplacod no-lock.

        hide frame f-l1 no-pause.
        hide frame f-l2 no-pause.
        hide frame f-l3 no-pause.
        do transaction:

            create movservi.
            ASSIGN movservi.movtdc = plaservi.movtdc
                   movservi.PlaCod = plaservi.placod
                   movservi.etbcod = plaservi.etbcod
                   movservi.movseq = vmovseq
                   movservi.procod = produ.procod
                   movservi.movqtm = w-movservi.movqtm
                   movservi.movpc  = w-movservi.movpc
                   movservi.movicms = w-movservi.valicms
                   movservi.movpdes = w-movservi.movdes
                   movservi.movdes  = w-movservi.valdes
                   movservi.movacfin = w-movservi.movacfin
                   movservi.MovAlICMS = w-movservi.movalicms
                   movservi.MovAlIPI  = w-movservi.movalipi
                   movservi.movipi    = w-movservi.movipi
                   movservi.movdev    = w-movservi.movfre 
                   movservi.movdat    = plaservi.pladat
                   movservi.MovHr     = int(time)
                   movservi.DATEXP    = plaservi.datexp
                   movservi.desti     = plaservi.desti
                   movservi.emite     = plaservi.emite.

            if tipo_desconto = 5
            then movservi.movdes = w-movservi.valdes / w-movservi.movqtm.       
                   
            find suporte.clafis where clafis.codfis = produ.codfis no-lock no-error.
            if avail suporte.clafis
            then movservi.movsubst = suporte.clafis.persub.
                                
            
            if w-movservi.movfre = 0
            then movservi.movdev = frete_unitario.      
            
           delete w-movservi.
        end.
    end.

    vezes = 0. prazo = 0.
    find first plaservi where plaservi.etbcod = estab.etbcod and
                           plaservi.placod = vplacod no-lock.

    message "Nota Fiscal Incluida". pause.
    hide frame f-titulo no-pause.
    clear frame f-titulo all.
    
    for each w-movservi:
        delete w-movservi.
    end.
end.

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
    for each w-movservi:
        delete w-movservi.
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
            for each w-movservi:
                find produ where recid(produ) = w-movservi.wrec no-lock no-error.
                if not avail produ
                then next.
                disp produ.procod
                     produ.pronom format "x(30)"
                     w-movservi.movqtm format ">>,>>9.99" column-label "Qtd"
                     w-movservi.movpc  format ">,>>9.99" column-label "Custo"
                     w-movservi.movalicms column-label "ICMS"
                     w-movservi.movalipi  column-label "IPI"
                            with frame f-produ2 row 5 9 down  overlay
                              centered color message width 80.
                down with frame f-produ2.
            end.
            pause. undo.
end.

