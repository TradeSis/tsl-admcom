{admcab.i}
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def var vok as log.

def temp-table wetique
    field wrec as recid
    field wqtd like estoq.estatual.
def var vopcao      as char format "x(10)" extent 2
                        initial [" Moveis ","Confeccao"].
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
def var valicota  like  plani.alicms format ">9,99".
def var vpladat   like  plani.pladat.
def var vrecdat   like  plani.pladat label "Recebimento".
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete.
def var vseguro   like  plani.seguro.
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vtotal    like plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(03)".
def var vopccod   like  plani.opccod.
def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotpag      like plani.platot.

def buffer bplani for plani.

def temp-table w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc
               field movpc     as decimal format ">,>>9.99".
form titulo.titpar
     titulo.titnum
     prazo
     titulo.titdtven
     titulo.titvlcob with frame ftitulo down centered color white/cyan.

form produ.procod
     produ.pronom
     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
     w-movim.movpc  format ">,>>9.99" column-label "V.Unit."

     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 6 no-box width 81.

def var v-title as char.

find tipmov where tipmov.movtdc = 15 no-lock.
find first opcom where opcom.movtdc = tipmov.movtdc no-lock no-error.
~if avail opcom
then v-title = opcom.opcnom.
 
form
    estab.etbcod  label "Filial" colon 15
    estab.etbnom  no-label
    vforcod       label "Fornecedor" colon 15
    forne.fornom no-label
    opcom.opccod label "Op. Fiscal" colon 15
    opcom.opcnom no-label
    vnumero       colon 15
    vserie label "Serie" 
    vpladat colon 15
    vrecdat colon 40
    vdesc label "Desconto"
      with frame f1 side-label width 80 row 4 color white/cyan
      title v-title.

form
    vbicms   colon 10
    vicms    colon 30
    vprotot1 colon 65
    vfrete   colon 10
    vipi     colon 30
    vdescpro colon 10
    vacfprod  colon 45
    vplatot  with frame f2 side-label row 10 width 80 overlay.

def var vdtaux as date.
REPEAT:

    for each w-movim:
        delete w-movim.
    end.
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
    
   find tipmov where tipmov.movtdc = 15 no-lock.
   
    prompt-for estab.etbcod with frame f1.
    vetbcod = input frame f1 estab.etbcod.
    {valetbnf.i estab vetbcod ""Filial""}
    disp estab.etbcod
        estab.etbnom with frame f1.
    vetbcod = estab.etbcod.

    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-error.
    if not avail forne
    then do:
        message "Fornecedor nao Cadastrado !!".
        undo, retry.
    end.
    display forne.fornom when avail forne with frame f1.

    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo, retry.

    if forne.ufecod = "RS"
    then find first opcom where opcom.movtdc = tipmov.movtdc no-lock.
    else find last  opcom where opcom.movtdc = tipmov.movtdc no-lock.
    
    display opcom.opccod 
            opcom.opcnom with frame f1.

    vserie = "U".
    display vserie with frame f1.
    update vnumero validate( vnumero > 0, "Numero Invalido")
           vserie
            with frame f1.
    find first plani where plani.numero = vnumero and
                     plani.emite  = vforcod and
                     plani.desti  = estab.etbcod and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod and
                     plani.movtdc = 15 no-lock no-error.

    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.

    do on error undo, retry:
        vdesc = 0.
        update vpladat
               vrecdat with frame f1.
        {valdatnf.i vpladat vrecdat}
        
               
        update vdesc with frame f1.
        
    
    end.
    do on error undo, retry:
    assign vbicms  = 0
           vicms   = 0
           vfrete  = 0
           vprotot1 = 0
           vipi    = 0
           vdescpro = 0
           vacfprod = 0
           vplatot  = 0
           vtotal = 0.

    clear frame f-produ1 no-pause.
    bl-princ:
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4
                            F10 E e C c) with frame f-produ.

        if keyfunction(lastkey) = "end-error"
        then do:
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
            else leave.
        end.
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock.
                disp produ.procod
                     produ.pronom
                     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                            with frame f-produ2 row 5 9 down  overlay
                              centered color message width 80.
                down with frame f-produ2.
                pause 0.
            end.
            pause.
            undo.
        end.
        if lastkey = keycode("e") or lastkey = keycode("E")
        then do:
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
                end.
                else w-movim.movqtm = w-movim.movqtm - vqtd.
                hide frame f-exclusao no-pause.
            end.
            vprotot = 0.
            clear frame f-produ1 all no-pause.
            for each w-movim with frame f-produ1:
                find produ where recid(produ) = wrec no-lock.
                display produ.procod
                        produ.pronom
                        w-movim.movqtm
                        w-movim.movpc
                        with frame f-produ1.
                down with frame f-produ1.
                pause 0.
                vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
                display vprotot with frame f-produ.
            end.
            next.
        end.
        vant = no.
            find produ where produ.procod = input vprocod no-lock no-error.
            if not avail produ
            then do:
                message "Produto nao Cadastrado".
                vresp = yes.
                message "Deseja Cadastrar ? " update vresp.
                if not vresp
                then undo.
                else do
                    with frame f-altera
                    row 10  centered OVERLAY SIDE-LABELS color black/cyan:

                    disp vopcao no-label with frame f-escolha
                        centered side-label overlay row 8.
                    choose field vopcao with frame f-escolha.

                    do :
                        if frame-index = 1
                        then do:
                            find last cprodu where cprodu.procod >= 100000 and
                                                   cprodu.procod <= 149999
                                exclusive-lock no-error.
                            if available cprodu
                            then assign vprocod = cprodu.procod + 1.
                            else assign vprocod = 100000.
                        end.
                        if frame-index = 2
                        then do:
                            find last cprodu where cprodu.procod >= 150000 and
                                                   cprodu.procod <= 200000
                                exclusive-lock no-error.
                            if available cprodu
                            then assign vprocod = cprodu.procod + 1.
                            else assign vprocod = 150000.
                        end.
                    end.

                    create produ.
                    assign produ.procod = vprocod
                           produ.itecod = vprocod
                           produ.datexp = today.

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
                    update produ.prouncom colon 15
                           produ.prounven colon 50
                           produ.procvcom colon 15
                           produ.procvven colon 50
                           produ.proipiper colon 15
                           produ.proclafis colon 50
                           WITH OVERLAY SIDE-LABELS .

                    produ.prozort = fabri.fabfant + "-" + produ.pronom.

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
                        update /*vtabcod colon 20*/
                               vestvenda colon 20.

                        for each estab:

                            create estoq.
                            assign estoq.etbcod    = estab.etbcod
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
            end.
        else vant = yes.
        display  produ.pronom with frame f-produ.
        find estoq where estoq.etbcod = 999 and
                         estoq.procod = produ.procod no-lock no-error.

        if not available estoq
        then do:
            bell.
            message "Produto Sem Registro de Armazenagem".
            pause.
            undo.
        end.

        display  produ.pronom with frame f-produ.
        display produ.pronom with frame f-produ1.

        vmovqtm = 0.
        vsubtotal = 0.
        find first w-movim where w-movim.wrec = recid(produ) no-lock no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ).
        end.
        vmovqtm = w-movim.movqtm.
        update  w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        w-movim.movpc = estoq.estCUSTO.
        w-movim.movqtm = VMOVQTM + w-movim.movqtm.
        display w-movim.movqtm with frame f-produ1.
        update w-movim.movpc with frame f-produ1.
        vprotot = 0.
        w-movim.subtotal = w-movim.movqtm * w-movim.movpc.

        clear frame f-produ1 all no-pause.


        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.movpc
                     with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot = vprotot + w-movim.subtotal.
            display vprotot with frame f-produ.
        end.
    end.
    if not sresp
    then undo, retry.
    end.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f2 no-pause.
    if v-ok = yes
    then undo, leave.
    find estab where estab.etbcod = vetbcod no-lock.
    /*
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 and
                           bplani.placod <> ? no-lock no-error.
    if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.
    */
    
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

    vserie = "55".
    do on error undo:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = vplacod
               tt-plani.protot   = vprotot
               tt-plani.emite    = vforcod
               tt-plani.bicms    = vprotot
               tt-plani.icms     = vprotot * (17 / 100)
               /*plani.frete    = vfrete
               tt-plani.alicms   = plani.icms * 100 / (plani.bicms *
                                (1 - (0 / 100)))*/
               tt-plani.descpro  = vprotot * (vdesc / 100)
               tt-plani.acfprod  = vacfprod
               tt-plani.frete    = vfrete
               tt-plani.seguro   = vseguro
               tt-plani.desacess = vdesacess
               tt-plani.ipi      = vipi
               tt-plani.platot   = vprotot - (vprotot * (vdesc / 100))
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = 15
               tt-plani.desti    = estab.etbcod
               tt-plani.pladat   = vpladat
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = int(opcom.opccod)
               tt-plani.vencod   = vvencod
               tt-plani.notfat   = vforcod
               tt-plani.dtinclu  = vrecdat
               tt-plani.horincl  = time
               tt-plani.hiccod   = int(opcom.opccod)
               tt-plani.notsit   = no
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
              tt-plani.isenta = tt-plani.platot 
              - tt-plani.outras - tt-plani.bicms.
    end.
    vmovseq = 0.
    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock.

        create tt-movim.
        ASSIGN tt-movim.movtdc = plani.movtdc
               tt-movim.PlaCod = plani.placod
               tt-movim.etbcod = plani.etbcod
               tt-movim.movseq = vmovseq
               tt-movim.procod = produ.procod
               tt-movim.movqtm = w-movim.movqtm
               tt-movim.movpc  = w-movim.movpc
               tt-movim.movdat    = plani.pladat
               tt-movim.emite     = plani.emite
               tt-movim.desti     = plani.desti
               tt-movim.MovHr     = int(time).


    end.

    v-ok = no.
    sresp = no.
    message "Confirma Emissao da Nota " update sresp.
    if sresp
    then  run manager_nfe.p (input "1915",
                             input ?,
                             output v-ok).

    for each w-movim:
        delete w-movim.
    end.

end.
