{admcab.i new}

def var vtipo as int format "99".


def var vdesval as dec format ">,>>9.99".
def var vobs as char format "x(14)" extent 4.
def var vcusto like estoq.estcusto.
def var vfre as dec format ">,>>9.99".
def var vacr as dec format ">,>>9.99".
def buffer btitulo for titulo.
def buffer xestoq for estoq.
def temp-table wetique
    field wrec as recid
    field wqtd like estoq.estatual.
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
def var vdesc    like plani.descprod format ">9.99 %".
def var i as i.
def var Vezes as int format ">9".
def var Prazo as int format ">>9".
def var v-ok as log.
def buffer bclien for clien.
def var vforcod like forne.forcod.
def var vcnpj-aux   as character .
def var vsaldo    as dec.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like plani.vencod.
def var vsubtotal like  movim.movqtm.
def var valicota  like  plani.alicms format ">9,99" initial 12.
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
def var vfrecod   like  frete.frecod.
def var vseguro   like  plani.seguro.
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vtotal    like plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char.
/*
def var vopccod   like  plani.opccod.
*/

def var vopccod   like  plani.hiccod.
def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotpag      like plani.platot.
def var voutras      like plani.outras.

def var vchave-acesso-danfe as char.

def buffer bplani for plani.

def  temp-table w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc format ">>9.9999"
               field movpc     as decimal format ">,>>9.99"
               field movalicms like movim.movalicms initial 12
               field movalipi  like movim.movalipi.
form titulo.titpar
     titulo.titnum
     prazo
     titulo.titdtven
     titulo.titvlcob with frame ftitulo down centered color white/cyan.

form produ.procod
     produ.pronom format "x(30)"
     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
     w-movim.movpc  format ">,>>9.9999" column-label "V.Unit."
     w-movim.movalicms column-label "ICMS"
     w-movim.movalipi  column-label "IPI"
     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 6 no-box width 81.

form
    estab.etbcod          label "Filial"         colon 16
    estab.etbnom       no-label
    vchave-acesso-danfe   label "Cod Barras NFE" colon 16 format "x(44)"
    vforcod               label "Fornecedor"     colon 16
    forne.fornom       no-label
    vnumero                                      colon 16
    vserie                label "Série"
    vopccod               label "Op. Fiscal" format "9999" colon 16
    opcom.opcnom       no-label
    vpladat                                      colon 16
    vrecdat                                      colon 41
    vdesc label "% Desc."          
    vdesval label "Valor Desconto"               colon 16
    vfrecod label "Transp."                      colon 16
    frete.frenom no-label
    vfrete label "Frete"
      with frame f1 side-label width 80 row 4 color white/cyan.

form
    vbicms   
    vicms
    vipi
    voutras 
    vfre
    vacr  label "Acrescimo"
    vplatot
      with frame f2 side-label row 12 width 80 overlay color white/cyan.

do:

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
    prompt-for estab.etbcod with frame f1.
    find estab using estab.etbcod no-lock.
    display estab.etbcod
            estab.etbnom with frame f1.
    vetbcod = estab.etbcod.
    if vetbcod = 990
    then do:
        message "Operacao Invalida para Matriz". pause.
        undo, leave.
    end.
    
    update vchave-acesso-danfe with frame f1.
    
    vserie = "1".
    
    if length(vchave-acesso-danfe) = 44
    then do:

        assign vcnpj-aux = substring(vchave-acesso-danfe,7,14)
               vserie    = string(int(substring(vchave-acesso-danfe,23,3)))
               vnumero   = int(substring(vchave-acesso-danfe,26,9)).
       
        
        find first forne where forne.forcgc = vcnpj-aux
                      no-lock  no-error.
                      
        if not avail forne
        then do:
            bell.
            message "Fornecedor nao Cadastrado !!".
            /*
            undo, retry.
            */
        end.
        
        assign vforcod = forne.forcod.
        
        display vforcod with frame f1.
        
        display forne.fornom when avail forne with frame f1.
        if forne.forcgc = ""
        then do:
            bell.
            message "CGC NAO CADASTRADO".
            /*
            undo, retry.
            */
        end. 
        if forne.ativo = no
        then do:
            message "Fornecedor Desativado".
            pause.
            undo, retry.
        end.        

        display vnumero
                vserie  with frame f1.
    
    end.

    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-error.
    if not avail forne
    then do:
        bell.
        message "Fornecedor nao Cadastrado !!".
        undo, retry.
    end.
    display forne.fornom when avail forne with frame f1.
    if forne.forcgc = ""
    then do:
        bell.
        message "CGC NAO CADASTRADO".
        pause.
        undo, retry.
    end. 
    if forne.ativo = no
    then do:
        message "Fornecedor Desativado".
        pause.
        undo, retry.
    end.        
    
    find last cpforne where cpforne.forcod = forne.forcod no-lock no-error.

    if avail cpforne
        and date(cpforne.date-1) <> ?
        and date(cpforne.date-1) <= today
        and length(vchave-acesso-danfe) <> 44
    then do:
    
        message "Fornecedor NFE desde " string(cpforne.date-1,"99/99/9999") skip
                " Informe a chave de acesso do DANFE! " view-as alert-box. 
        undo,retry.
    end.

    display vserie with frame f1.
    update vnumero
           vserie  with frame f1.
    
    do on error undo, retry:       
           
        update vopccod with frame f1.
        
        find first opcom where opcom.opccod = string(vopccod)
                            no-lock no-error.
        if not avail opcom                    
            or length(string(vopccod)) <> 4
        then do:
        
            message "CFOP Inválido, Pressione F7 e escolha novamente."
                            view-as alert-box.
        
            undo,retry.
        
        end.
        else display opcom.opcnom with frame f1.

    end.

    
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

    do on error undo, retry:
        find tipmov where tipmov.movtdc = 4 no-lock.
        vdesc = 0.
        
        update vpladat
               vrecdat with frame f1.
        if vpladat > today or vpladat < today - 30 or vpladat = ?
        then do:
            message "Data Invalida".
            undo, retry.
        end.
        update vdesc
               vdesval
               vfrecod
                with frame f1.
        find frete where frete.frecod = vfrecod no-lock.
        display frete.frenom no-label with frame f1.
        update vfrete with frame f1.
        vvencod = frete.forcod.
        
    end.
    do on error undo, retry:
    assign vbicms  = 0
           vicms   = 0
           vprotot1 = 0
           vipi    = 0
           vdescpro = 0
           vacfprod = 0
           vplatot  = 0
           vtotal = 0
           voutras = 0
           vfre    = 0
           vacr    = 0.
    
    do on error undo:
        hide frame f-obs no-pause.
        update vbicms label "Base Icms"
               vicms  label "Valor Icms" with frame f2.

        
        if vbicms = 0 or
           vicms  = 0
        then do:
            
            vobs[1] = "ICMS DESTACADO".
            vobs[2] = "M.E.".
            vobs[3] = "GAS".
            vobs[4] = "NEW FREE".
            display "1§ " TO 05 vobs[1] no-label 
                    "2§ " TO 05 vobs[2] no-label 
                    "3§ " TO 05 vobs[3] no-label 
                    "4§ " to 05 vobs[4] no-label
                        with frame f-icms side-label row 5
                                 overlay columns 50.
           
            update vtipo label "Escolha" format "99" 
                           with frame f-icms2 side-label columns 58
                                           row 04 no-box. 
            
            if vtipo <> 1 and
               vtipo <> 2 and
               vtipo <> 3 and
               vtipo <> 4
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
        else do:
            if (vbicms * 0.25) < vicms
            then do:
                message "Valor do icms nao confere com Base de Calculo".
                undo, retry.
            end.
        end.
        


 
        hide frame f-obs no-pause.

    end.
    update
           vipi    label "IPI"
           voutras
           vfre    label "Frete"
           vacr    label "Acrescimo" with frame f2.

    do on error undo:
       update  vplatot with frame f2.
       if vbicms > vplatot
       then do:
           vtipo = 1.
           vobs[1] = "".
           update vobs[1] label "Obs" format "x(21)"
                        with frame f-obs side-label
                                                centered color message.
           if substring(vobs[1],04,1) = "" 
           then do:
               message "Informar Observacao".
               undo, retry.
           end.
       end.
    end.
    hide frame f-obs no-pause.

    clear frame f-produ1 no-pause.
    bl-princ:
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4
                            F10 E e C c) with frame f-produ.

        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = yes.
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
                     produ.pronom format "x(30)"
                     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                     w-movim.movalicms column-label "ICMS"
                     w-movim.movalipi  column-label "IPI"
                     /*
                     w-movim.subtotal
                            format ">>,>>9.99" column-label "Total" */
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
                        w-movim.movalicms
                        w-movim.movalipi
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
            then do transaction:
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
                            find last cprodu where cprodu.procod >= 400000 and
                                                   cprodu.procod <= 449999
                                exclusive-lock no-error.
                            if available cprodu
                            then assign vprocod = cprodu.procod + 1.
                            else assign vprocod = 400000.
                        end.
                        if frame-index = 2
                        then do:
                            find last cprodu where cprodu.procod >= 450000 and
                                                   cprodu.procod <= 900000
                                exclusive-lock no-error.
                            if available cprodu
                            then assign vprocod = cprodu.procod + 1.
                            else assign vprocod = 450000.
                        end.
                    end.

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
                           produ.proipiper colon 15 label "Aliq.Icms"
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

                        for each estab no-lock:

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



        else do:
            if produ.proseq = 99
            then do:
                message color red/with
                "Entrada bloqueada para produto INATIVO."
                view-as alert-box.
                undo.
            end.

            vant = yes.
        end.
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
        w-movim.movalicms = 12.
        update  w-movim.movalicms
                w-movim.movalipi
                    with frame f-produ1.
        vcusto = w-movim.movpc.
        if vbicms <> 0
        then do:
            vcusto = vcusto +
                (w-movim.movpc * ((vbicms / (vbicms - vacr)) - 1)).
        end.
        for each xestoq where xestoq.procod = produ.procod.
            xestoq.estcusto = ((vcusto *
                                  (w-movim.movalipi / 100)) +
                                  vcusto).
        end.

        vprotot = 0.
        w-movim.subtotal = w-movim.movqtm * (((w-movim.movpc * w-movim.movalipi)
                                              / 100) + w-movim.movpc).
        /*update  w-movim.subtotal validate(w-movim.subtotal > 0,
                         "Total dos Produtos Invalido")  with frame f-produ1.*/
        clear frame f-produ1 all no-pause.


        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.movpc
                    w-movim.movalicms
                    w-movim.movalipi
                            with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
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
                     /*
    if vbicms > vprotot
    then do:
        message "Base do icms maior que total da nota".
        undo, retry.
    end.               */

    do on error undo:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.notobs[3] = if vtipo = 0
                                 then ""
                                 else vobs[vtipo]
               plani.cxacod   = frete.forcod
               plani.placod   = vplacod
               plani.protot   = vprotot
               plani.emite    = vforcod
               plani.bicms    = vbicms
               plani.icms     = vicms
               plani.frete    = vfrete
               plani.descpro  = vprotot * (vdesc / 100)
               plani.acfprod  = vacfprod
               plani.seguro   = vseguro
               plani.desacess = vdesacess
               plani.ipi      = vipi
               plani.platot   = /* vprotot - (vprotot * (vdesc / 100)) +
                                voutras + vfre + vacr */ vplatot
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = tipmov.movtdc
               plani.desti    = estab.etbcod
               plani.modcod   = tipmov.modcod
               plani.opccod   = 4
               plani.vencod   = frete.frecod
               plani.notfat   = vforcod
               plani.horincl  = time
               plani.hiccod   = vopccod
               plani.dtinclu  = vrecdat
               plani.pladat   = vpladat
               PLANI.DATEXP   = today
               plani.notsit   = no
               plani.outras = voutras
              plani.isenta = plani.platot - plani.outras - plani.bicms.
              
              assign plani.ufdes  = vchave-acesso-danfe.
              
              if plani.descprod = 0
              then plani.descprod = vdesval.
        for each w-movim:            
            vmovseq = vmovseq + 1.
            find produ where recid(produ) = w-movim.wrec no-lock.
            find plani where plani.etbcod = estab.etbcod and
                             plani.placod = vplacod no-lock.
            create wetique.
            assign wetique.wrec = recid(produ)
                   wetique.wqtd = w-movim.movqtm.

            create movim.
            ASSIGN movim.movtdc = plani.movtdc
                   movim.PlaCod = plani.placod
                   movim.etbcod = plani.etbcod
                   movim.movseq = vmovseq
                   movim.procod = produ.procod
                   movim.movqtm = w-movim.movqtm
                   movim.movpc  = w-movim.movpc
                   movim.MovAlICMS = (plani.icms * 100) / plani.bicms
                   movim.MovAlIPI  = (plani.icms * 100) / plani.ipi
                   movim.movdat    = plani.pladat
                   movim.MovHr     = int(time)
                   MOVIM.DATEXP    = plani.datexp
                   movim.desti     = plani.desti
                   movim.emite     = plani.emite.
            /*
            run atuest.p(input recid(movim),
                         input "I",
                         input 0).
            */
            delete w-movim.
        end.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock.

            run atuest.p(input recid(movim),
                         input "I",
                         input 0).
        end.
    end.
    vezes = 0.
    prazo = 0.
    find plani where plani.etbcod = estab.etbcod and
                     plani.placod = vplacod no-lock.
    update vezes label "Vezes"
                with frame f-tit width 80 side-label centered color white/red.



    vtotpag = plani.platot.

    do on error undo:

        update vtotpag with frame f-tit.
    

        if vtotpag < (plani.protot + plani.ipi - vdesval - plani.descprod)
        then do:
            message "Verifique os valores da nota".
            undo, retry.
        end.
    end.


    do transaction:
    do i = 1 to vezes:

        create titulo.
        assign titulo.etbcod = plani.etbcod
               titulo.titnat = yes
               titulo.modcod = "DUP"
               titulo.clifor = forne.forcod
               titulo.titsit = "lib"
               titulo.empcod = wempre.empcod
               titulo.titdtemi = vpladat
               titulo.titnum = string(plani.numero)
               titulo.titpar = i.

        if prazo <> 0
        then assign titulo.titvlcob = vtotpag
                    titulo.titdtven = titdtemi + prazo.
        else assign titulo.titvlcob = vtotpag / vezes
                    titulo.titdtven = titulo.titdtemi + ( 30 * i).

    end.

    vsaldo = vtotpag.
    for each titulo where titulo.empcod = wempre.empcod and
                          titulo.titnat = yes and
                          titulo.modcod = "DUP" and
                          titulo.etbcod = estab.etbcod and
                          titulo.clifor = forne.forcod and
                          titulo.titnum = string(plani.numero).
        display titulo.titpar
                titulo.titnum
                    with frame ftitulo down centered
                            color white/cyan.

        prazo = 0.

        update prazo with frame ftitulo.

        titulo.titdtven = vpladat + prazo.

        titulo.titvlcob = vsaldo.

        update titulo.titdtven
               titulo.titvlcob with frame ftitulo no-validate.

        vsaldo = vsaldo - titulo.titvlcob.

        find titctb where titctb.forcod = titulo.clifor and
                          titctb.titnum = titulo.titnum and
                          titctb.titpar = titulo.titpar no-error.
        if not avail titctb
        then do:
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
    if plani.frete > 0
    then do:
        create btitulo.
        assign btitulo.etbcod = plani.etbcod
               btitulo.titnat = yes
               btitulo.modcod = "FRE"
               btitulo.clifor = frete.forcod
               btitulo.cxacod = forne.forcod
               btitulo.titsit = "lib"
               btitulo.empcod = wempre.empcod
               btitulo.titdtemi = vpladat
               btitulo.titnum   = string(plani.numero)
               btitulo.titnumger = string(plani.numero)
               btitulo.titpar = 1
               btitulo.titvlcob = plani.frete.

        update btitulo.titdtven label "Venc.Frete"
               btitulo.titnum   label "Controle"
                    with frame f-frete centered color white/cyan
                                    side-label row 15 no-validate.
    end.
    end.
    message "Nota Fiscal Incluida". pause.

    for each w-movim:
        delete w-movim.
    end.

    if plani.desti = 996
    then do:
        run peddis.p (input recid(plani)).

        find first wetique no-error.
        if not avail wetique
        then leave.
        message "Confirma emissao de Etiquetas" update sresp.
        if sresp
        then do:
            for each wetique:
                run eti_barl.p (input wetique.wrec,
                                input wetique.wqtd).
            end.
        end.
        for each wetique:
            delete wetique.
        end.
    end.
end.
