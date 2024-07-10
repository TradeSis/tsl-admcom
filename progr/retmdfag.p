{admcab.i}

def temp-table wetique
    field wrec as recid
    field wqtd like estoq.estatual.
def buffer cprodu for produ.
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
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotpag      like plani.platot.
def var vdvnfe     as int.
def var vchave-nfe as char.

def buffer bplani for plani.

def var vcnpj-aux   as character .

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

form
    estab.etbcod  label "Filial" colon 15
    estab.etbnom  no-label
    vchave-nfe   label "Cod Barras NFE" colon 16 format "x(44)"
    vforcod       label "Fornecedor" colon 15
    forne.fornom no-label
    opcom.opccod label "Op. Fiscal" colon 15
    opcom.opcnom no-label
    vnumero       colon 15
    vserie label "Serie" 
    vpladat colon 15
    vrecdat colon 40
    vdesc label "Desconto"
      with frame f1 side-label width 80 row 4 color white/cyan.

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
    
   find tipmov where tipmov.movtdc = 74 no-lock.
   
    prompt-for estab.etbcod with frame f1.
    vetbcod = input frame f1 estab.etbcod.
    {valetbnf.i estab vetbcod ""Filial""}
    disp estab.etbcod
        estab.etbnom with frame f1.

    if (estab.etbcod >= 993 and
        estab.etbcod <= 999 and
        estab.etbcod <> 998) or
        estab.etbcod = 22 or
        estab.etbcod = 900
    then.
    else do:
        message "Emitente invalido".
        pause.
        undo, retry.
    end.
    
    vetbcod = estab.etbcod.

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
        assign vcnpj-aux = substring(vchave-nfe,7,14)
               vserie    = string(int(substring(vchave-nfe,23,3)))
               vnumero   = int(substring(vchave-nfe,26,9)).
                                 
        find first forne where forne.forcgc = vcnpj-aux no-lock  no-error.
        if avail forne
        then do:
            assign vforcod = forne.forcod.                        
                                   
            display forne.fornom when avail forne
                    vserie
                    vnumero with frame f1.
        end.
                                                          
    end.
    update vforcod with frame f1.
    find first forne where forne.forcod = vforcod no-lock  no-error.
    if not avail forne
    then do:
        message "Fornecedor nao Cadastrado !!".
        undo, retry.
    end.
    display forne.fornom when avail forne with frame f1.
    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo, retry.

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
                     plani.movtdc = tipmov.movtdc no-lock no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.

    vrecdat = today.
    do on error undo, retry:
        vdesc = 0.
        update vpladat
               /*vrecdat*/ with frame f1.
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

        find produ where produ.procod = input vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao Cadastrado".
            undo.
        end.
            
        display  produ.pronom with frame f-produ.
        find estoq where estoq.etbcod = 999 and
                         estoq.procod = produ.procod no-lock no-error.

        if not available estoq
        then do:
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


    do on error undo:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.placod   = vplacod
               plani.protot   = vprotot
               plani.emite    = vforcod
               /*
               plani.bicms    = vprotot
               plani.icms     = vprotot * (17 / 100)
               plani.frete    = vfrete
               plani.alicms   = plani.icms * 100 / (plani.bicms *
                                (1 - (0 / 100)))
               */
               plani.descpro  = vprotot * (vdesc / 100)
               plani.acfprod  = vacfprod
               plani.frete    = vfrete
               plani.seguro   = vseguro
               plani.desacess = vdesacess
               plani.ipi      = vipi
               plani.platot   = vprotot - (vprotot * (vdesc / 100))
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = tipmov.movtdc
               plani.desti    = estab.etbcod
               plani.pladat   = vpladat
               plani.modcod   = tipmov.modcod
               plani.opccod   = int(opcom.opccod)
               plani.vencod   = vvencod
               plani.notfat   = vforcod
               plani.dtinclu  = vrecdat
               plani.horincl  = time
               plani.hiccod   = int(opcom.opccod)
               plani.notsit   = no
               plani.ufdes  = vchave-nfe
               plani.outras = plani.frete  +
                              plani.seguro +
                              plani.vlserv +
                              plani.desacess +
                              plani.ipi   +
                              plani.icmssubst
              plani.isenta = plani.platot - plani.outras - plani.bicms.
    end.

    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock.
        find plani where plani.etbcod = estab.etbcod and
                         plani.placod = vplacod no-lock.
        /*
        plani.protot = plani.protot + (w-movim.movqtm * w-movim.movpc).
        */

        create movim.
        ASSIGN movim.movtdc = plani.movtdc
               movim.PlaCod = plani.placod
               movim.etbcod = plani.etbcod
               movim.movseq = vmovseq
               movim.procod = produ.procod
               movim.movqtm = w-movim.movqtm
               movim.movpc  = w-movim.movpc
               movim.movdat    = plani.pladat
               movim.emite     = plani.emite
               movim.desti     = plani.desti
               movim.MovHr     = int(time).

        run atuest.p(input recid(movim),
                     input "I",
                     input 0).

    end.
    vezes = 0.
    prazo = 0.
    message "Nota Fiscal Incluida". pause.

    for each w-movim:
        delete w-movim.
    end.

end.
