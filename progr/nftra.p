{admcab.i}

{/admcom/progr/loja-com-ecf-def.i} 

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimimp like movimimp.

def var v-ok as log.
def var vmovqtm   like  movim.movqtm.
def var vemite    like  estab.etbcod.
def var vsubtotal like  movim.movqtm.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(3)".
def var vhiccod   like  plani.hiccod label "Op.Fiscal".
def var vprocod   like  produ.procod.
def var vdown as i.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotal      like plani.platot.
def var vsenha988   as log.
def buffer bestab for estab.
def buffer bplani for plani.
def buffer xestab for estab.

def stream str-log.

def  temp-table w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc
               field movpc     as decimal format ">>,>>9.99"
               field ocnum like movim.ocnum.

form produ.procod
     produ.pronom format "x(30)"
     w-movim.movqtm format ">>>>9" column-label "Qtd"
     w-movim.movpc  format ">>,>>9.99" column-label "V.Unit."
     w-movim.subtotal format ">>>,>>9.99" column-label "Total"
     w-movim.ocnum[1]
     with frame f-produ1 row 6 12 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 5 no-box width 81.

form
    estab.etbcod  label "Emitente" colon 15
    estab.etbnom  no-label
    vetbcod       label "Destinatario" colon 15
    bestab.etbnom no-label format "x(20)"
    vserie  colon 15 label "Serie"
    vnumero
    vhiccod       format "9999" colon 15
    with frame f1 side-label color white/cyan width 80 row 4.

def var vctotransf as dec.

repeat:
    vmovseq = 0.
    for each w-movim:
        delete w-movim.
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

    disp vemite @ estab.etbcod with frame f1.
    prompt-for estab.etbcod with frame f1.
    vemite = input frame f1 estab.etbcod.
    {valetbnf.i estab vemite ""Emitente""} 
    vemite = input estab.etbcod.
    display estab.etbnom no-label with frame f1.

    if vemite = 998 or setbcod = 998
    then do:
        message "Realize a operacao no novo modulo de SSC" view-as alert-box.
        undo, retry.
    end.

    {/admcom/progr/loja-com-ecf.i vemite} 
     
    if (vemite >= 993 and
        vemite <= 999) or
        vemite = 22 or
        vemite = 988 or
        p-loja-com-ecf or
        vemite = 900 
    then.
    else
        if vemite <> 997 and vemite <> 980
        then do:
            message "Emitente invalido" view-as alert-box.
            undo, retry.
        end.

    update vetbcod  with frame f1.

        /*if vemite <> 988 and vetbcod = 995
        then do:
                        message "Estabelecimento bloqueado para transferencia. Entre em contato com o setor de Controladoria." view-as alert-box.
                        undo, retry.
        end.*/
                /* LIBERADO EM 14/07 POR MARCIO TAVARES */

    if vetbcod = 500 or vetbcod = 991 or vetbcod = 980 or vetbcod = 996
    then do:
        message "Estabelecimento bloqueado para transferencia. Entre em contato com o setor de Controladoria." 
                view-as alert-box.
        undo, retry.
    end.
    
    find bestab where bestab.etbcod = vetbcod no-lock no-error.
    if not avail bestab
    then do:
        message "Destinatario nao cadastrado" view-as alert-box.
        undo, retry.
    end.    
    display bestab.etbnom no-label with frame f1.
    if bestab.ufecod = "RS"
    then vhiccod = 5152.
    else vhiccod = 6152. 
    run not_notgvlclf.p ("Estab", recid(bestab), output sresp).
    if not sresp
    then undo.

    if (bestab.etbcod = 995 and estab.etbcod  = 998) or
       (bestab.etbcod = 998 and estab.etbcod  = 995)
    then do:
        message "Operacao Bloqueada" view-as alert-box.
        undo, retry.
    end.       

    if estab.etbcgc = bestab.etbcgc
    then do.
        message "Estabelecimentos tem o mesmo CNPJ" view-as alert-box.
        undo.
    end.

/***
    if bestab.etbcod = 422 /* or bestab.etbcod = 89 */
    then do:
        message "Filial desativada". pause.
        undo, retry.
    end.
***/

    vserie = "1".
    /*
    def var serie-nfe as char.
    run le_tabini.p (vemite, 0, "NFE - SERIE", OUTPUT serie-nfe).
    vserie = serie-nfe.
    */
    display
        vserie
        vnumero
        vhiccod with frame f1. 
    
    find tipmov where tipmov.movtdc = 6  no-lock.
    do on error undo, retry:
    assign
        vprotot1 = 0
        vplatot  = 0
        vtotal   = 0.
    vtotal = vprotot.
    clear frame f-produ1 no-pause.
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        hide frame f-aviso no-pause.
        
        vprotot1 = 0. 
        for each w-movim where w-movim.movqtm = 0 or
                               w-movim.movpc  = 0 or
                               w-movim.subtotal = 0:
            delete w-movim.
        end.
        clear frame f-produ1 all no-pause.
            
        vprotot = 0.
        for each w-movim with frame f-produ1:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.movpc
                    w-movim.subtotal
                    w-movim.ocnum[1]
                       with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
            display vprotot with frame f-produ.
        end.

        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4
                            F10 E e C c) with frame f-produ.
        v-ok = no.
        if keyfunction(lastkey) = "end-error"
        then do:
            find first w-movim no-lock no-error.
            if not avail w-movim
            then leave.

            sresp = no.
            message "Confirma Geracao de Nota Fiscal?" update sresp.
            if not sresp
            then do:
                for each w-movim:
                    delete w-movim.
                end.
                vprocod = 0.
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
                v-ok = yes.
                undo, leave.
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
                     w-movim.movqtm format ">,>>9.99" column-label "Qtd"
                     w-movim.subtotal
                            format ">>>,>>9.99" column-label "Total"
                     w-movim.movpc  format ">>,>>9.99" column-label "Custo"
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
                     w-movim.subtotal = w-movim.movqtm * w-movim.movpc.
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
                        w-movim.subtotal
                        w-movim.ocnum[1]
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
        if produ.proseq = 98 or
           produ.proseq = 99
        then do:
            message "Transferencia bloqueada para produto INATIVO"
                view-as alert-box.
            undo.
        end.

        display produ.pronom with frame f-produ.
        vctotransf = 0.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not available estoq
        then do:
            message "Produto Sem Registro de Armazenagem".
            pause.
            undo.
        end.
        vctotransf = estoq.estcusto.
        if vctotransf = 0
        then vctotransf = 1.
        
        find last mvcusto where mvcusto.procod = produ.procod
                no-lock no-error.
        if avail mvcusto and
                 mvcusto.valctotransf > 0
        then vctotransf = mvcusto.valctotransf.         

        if estab.etbcod = 988 /* SSC */
        then do.
            find clase of produ no-lock.
            if produ.catcod <> 41 or
               clase.clasup = 234080200 or
               clase.clasup = 234080300 or
               clase.clasup = 234080400 or
               clase.clasup = 234080600 or
               clase.clasup = 234080700
            then do.
                message "SSC somente transfere CONFECOES" view-as alert-box.
                if not vsenha988
                then
                    run versenha.p ("ManutSSC", "", 
                                    "Senha para TRANSFERIR produtos no SSC",
                                    output vsenha988).
                if not vsenha988
                then undo.
            end.
        end.

        display produ.pronom with frame f-produ.
        display produ.pronom with frame f-produ1.
        vmovqtm = 0.
        vsubtotal = 0.
        find first w-movim where w-movim.wrec = recid(produ) no-lock no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ)
                   w-movim.movpc = vctotransf /*estoq.estcusto*/.
        end.
        vmovqtm = w-movim.movqtm.
        do on error undo, retry:
            update w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        
            w-movim.movqtm = w-movim.movqtm + vmovqtm.
            /*
            if w-movim.movqtm > 100000
            then undo, retry.
            */
            
            if w-movim.movqtm > 1000
            then do:
                sresp = no.
                message "Confirma esta quantidade?" update sresp.
                if not sresp
                then undo, retry.
            end.
            /*if w-movim.movpc = 0
            then*/ do:
                update w-movim.movpc with frame f-produ1.
                if w-movim.movpc > 10000
                then do:
                    sresp = no.
                    message "Confirma este valor?" update sresp.
                    if not sresp
                    then undo, retry.
                end.
            end.
        end.        
        if estab.etbcod <> 22 
        then do:
            if ((estoq.estatual - estoq.estpedcom) >= 0 and 
               ((estoq.estatual - estoq.estpedcom) - w-movim.movqtm) < 0) or
                (estoq.estatual - estoq.estpedcom) < 0 
            then do:
                display  
                        "Qtd Estoque :" at 5 (estoq.estatual - estoq.estpedcom)                                                                     no-label format "->>,>>9.99"
                        "Qtd Desejada:" at 5 w-movim.movqtm 
                                            no-label format "->>,>>9.99"
                            with frame f-aviso overlay row 10
                                side-label centered 
                                    title "Estoque nao possui esta Quantidade".
                pause.
                delete w-movim. 
                undo, retry.
            end.
        end.
        
        display w-movim.movpc with frame f-produ1.
        
        vprotot = 0.
        w-movim.subtotal = vsubtotal + (w-movim.movpc * w-movim.movqtm).
        
        if estab.etbcod = 22 and bestab.etbcod = 995
        then do on error undo:
            update w-movim.ocnum[1] column-label "Pedido"
                with frame f-produ1.
            if w-movim.ocnum[1] > 0
            then do:
            find pedid where
                 pedid.etbcod = 996 and
                 pedid.pednum = w-movim.ocnum[1] and
                 pedid.pedtdc = 1 no-lock no-error.
            if not avail pedid
            then do:
                message "Pedido nao encontrado." .
                pause.
                undo.
            end.    
            end.
        end.
        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.subtotal
                    w-movim.movpc
                    w-movim.ocnum[1]
                            with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot = vprotot + (w-movim.movpc * w-movim.movqtm).
            display vprotot with frame f-produ.
        end.
    end.
    if not sresp
    then undo, retry.
    end.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    if v-ok = yes
    then undo, retry.
    find first w-movim where w-movim.movqtm > 0 and
                             w-movim.movpc > 0 no-error.
                             
    if not avail w-movim 
    then undo, leave.

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
 
    find first w-movim where w-movim.movqtm > 0 and
                             w-movim.movpc > 0 no-error.
    if not avail w-movim 
    then undo, leave.

    {/admcom/progr/loja-com-ecf.i vemite} 
    
    if vemite <> 995 and
       vemite <> 998 and
       vemite <> 993 and
       vemite <> 996 and
       vemite <> 999 and
       vemite <> 980 and
       vemite <> 988 and
       vemite <> 900 and
       p-loja-com-ecf <> yes
    then do:
        message "Impossível emitir nota modelo 1, contate o setor de TI!"
                view-as alert-box.
        pause.
        return.
    end.
    else
        run emissao-NFe.
end.

procedure emissao-NFe:
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    for each tt-movimimp. delete tt-movimimp. end.
    
    do on error undo:
        vplacod = ?.
        vnumero = ?.
        
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = vplacod
               tt-plani.emite    = estab.etbcod
               tt-plani.plaufemi = estab.ufecod
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = 6
               tt-plani.desti    = bestab.etbcod
               tt-plani.plaufdes = bestab.ufecod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = 5152
               tt-plani.notfat   = bestab.etbcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.hiccod   = vhiccod
               tt-plani.notobs[3] = "D"
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi.
              tt-plani.isenta = tt-plani.platot - tt-plani.outras.
    end.
    
    if not can-find (first w-movim)
    then do:    
        output stream str-log
               to value("/admcom/wms/logsnfe/nota_sem_item.csv") append.
        put stream str-log
             "ETBCOD;PLACOD;MOVTDC;PLADAT;NFTRA" skip.
        output stream str-log close.
        
        message "Movimentacao sem itens, NFe nao sera gerada" view-as alert-box.
        undo, retry.       
    end.
    vmovseq = 0.
    for each w-movim,
        first produ where recid(produ) = w-movim.wrec 
            no-lock by produ.pronom:
        vmovseq = vmovseq + 1.
        /*
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        if not avail produ
        then next.
        */
        tt-plani.protot = tt-plani.protot + (w-movim.movqtm * w-movim.movpc).
        tt-plani.platot = tt-plani.platot + (w-movim.movqtm * w-movim.movpc).

        create tt-movim.
        ASSIGN tt-movim.movtdc = 6
               tt-movim.PlaCod = tt-plani.placod
               tt-movim.etbcod = tt-plani.etbcod
               tt-movim.movseq = vmovseq
               tt-movim.procod = produ.procod
               tt-movim.movqtm = w-movim.movqtm
               tt-movim.movpc  = w-movim.movpc
               tt-movim.movdat    = tt-plani.pladat
               tt-movim.MovHr     = int(time)
               tt-movim.emite     = tt-plani.emite
               tt-movim.desti     = tt-plani.desti
               tt-movim.ocnum[1]  = w-movim.ocnum[1] .    
        delete w-movim.
    end.

    def var p-ok as log init no.
    def var p-valor as char.
    def var nfe-emite like plani.emite.
    p-valor = "".
    if vemite = 998
    then nfe-emite = 993.
    else nfe-emite = vemite.
    run le_tabini.p (nfe-emite, 0, "NFE - TIPO DOCUMENTO", OUTPUT p-valor).
    if p-valor = "NFE"
    then run manager_nfe.p (input "5152", input ?, output p-ok).
    else message "Erro: Verifique os registros TAB_INI do emitente."    
            view-as alert-box.               

end procedure.

