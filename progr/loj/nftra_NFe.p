{admcab.i}

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimimp like movimimp.

def var vmotivo as char format "x(60)".
def var vsenha like func.senha.
def var vfuncod like func.funcod.
def var vok as log.
def var v-ok as log.
def var vmovqtm   like  movim.movqtm.
def var vsubtotal like  movim.movqtm.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    like  plani.serie.
def var vhiccod   like  plani.hiccod label "Op.Fiscal" format "9999".
def var vprocod   as char /* like  produ.procod*/.
def var vcodigo   as int.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vtotal      like plani.platot.
def buffer bestab for estab.

def workfile w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc format ">>,>>9.99"
               field movpc     as decimal format ">>,>>9.99".

def buffer bw-movim for w-movim.

def var vconta-produtos as integer.

form produ.procod
     produ.pronom format "x(29)"
     w-movim.movqtm format ">>>>9" column-label "Qtd"
     w-movim.movpc  format ">>,>>9.99" column-label "V.Unit."
     w-movim.subtotal format ">>>,>>9.99" column-label "Total"
     with frame f-produ1 row 10 12 down overlay
                centered width 80.

form vprocod      label "Codigo" format "x(14)"
     produ.pronom  no-label format "x(25)"
     vprotot
     with frame f-produ centered  side-label
                        row 9 no-box width 81.

form
    estab.etbcod  label "Emitente" colon 15
    estab.etbnom  no-label
    vetbcod       label "Destinatario" colon 15
    bestab.etbnom no-label
    vhiccod       format "9999" colon 15
    with frame f1 side-label width 80 row 4.
      
repeat:    
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

    find estab where estab.etbcod = setbcod no-lock.
    disp 
        estab.etbcod
        estab.etbnom
        with frame f1.
   
    update vetbcod  with frame f1.
    find bestab where bestab.etbcod = vetbcod no-lock no-error.
    if not avail bestab
    then do:
        message "Estabelecimento nao cadastrado".
        undo, retry.
    end.
    display bestab.etbnom with frame f1.

    if vetbcod = setbcod
    then do:
        message "Estabelecimentos iguais".
        undo, retry.
    end.

    if vetbcod = 997 or
       /*vetbcod = 999 or comentado pelo Leote em 12/2016 p/o chamado 721808*/
       vetbcod =  22 or
       vetbcod = 990 or
       vetbcod = 991 or
       vetbcod = 994 or
       vetbcod = 998 or
       vetbcod = 980 or
       vetbcod = 996 or
       vetbcod = 993 or
       vetbcod = 900
    then do:
        message "Emissao de nota devera ser realizada para o Deposito 901." view-as alert-box.
        undo, retry.
    end.

    if vetbcod = 889 /*or vetbcod = 65 */
    then do:
        message "Filial nao liberada para transferencia".
        undo, retry.
    end.
    run not_notgvlclf.p ("Estab", recid(bestab), output sresp).
    if not sresp
    then return.

/*
    if estab.ufecod <> bestab.ufecod
    then
        if vetbcod <> 900
        then do.
            message "Transferencia de MOVEIS liberada apenas para o CELL." 
                    view-as alert-box.
            undo, retry.
        end.
*/
    vhiccod = 5152.
    display vhiccod with frame f1.

    find tipmov where tipmov.movtdc = 6 no-lock.
    pause 0.
    do on error undo, retry:
        assign
               vprotot1 = 0
               vplatot  = 0
               vtotal = 0.
        vtotal = vprotot.
        clear frame f-produ1 no-pause.

        repeat with 1 down:
            hide frame f-produ2 no-pause.
            for each w-movim:
                if w-movim.movqtm = 0 or
                   w-movim.movpc  = 0 or
                   w-movim.subtotal = 0
                then delete w-movim.
            end.
            vprotot = 0. 
            clear frame f-produ1 all no-pause. 
            for each w-movim with frame f-produ1:
                find produ where recid(produ) = wrec no-lock.
                display produ.procod
                        produ.pronom 
                        w-movim.movqtm 
                        w-movim.movpc 
                        w-movim.subtotal with frame f-produ1.
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
                hide frame f-senh no-pause.
                sresp = yes.
                find first w-movim no-error.
                if not avail w-movim
                then do:
                    vprocod = "".
                    hide frame f-produ1 no-pause.
                    hide frame f-produ no-pause.
                    v-ok = yes.
                    undo, leave.
                end.

                sresp = no.
                message "Confirma Geracao de Nota Fiscal?" update sresp.
                if not sresp
                then do:
                    for each w-movim:
                        delete w-movim.
                    end.
               
                    vprocod = "".
                    hide frame f-produ1 no-pause.
                    hide frame f-produ no-pause.
                    v-ok = yes.
                    undo, leave.
                end.
                else leave.
            end.
            
            assign vconta-produtos = 0.
            for each bw-movim no-lock.
                assign vconta-produtos = vconta-produtos + 1. 
            end.

            if vconta-produtos > 299
            then do:
                message "Esta nota já possui 300 itens, "
                    "Para continuar será preciso finalizar esta nota e criar "
                    "uma nova."
                    view-as alert-box.
                undo.
            end.
            
            if lastkey = keycode("c") or lastkey = keycode("C")
            then do with frame f-produ2:
                clear frame f-produ2 all no-pause.
                hide frame f-senh   no-pause.
                hide frame f-motivo no-pause.
                
                for each w-movim:
                    find produ where recid(produ) = w-movim.wrec no-lock.
                    disp produ.procod
                         produ.pronom format "x(29)"
                         w-movim.movqtm format ">,>>9.99" column-label "Qtd"
                         w-movim.subtotal
                                format ">>>,>>9.99" column-label "Total"
                         w-movim.movpc  format ">>,>>9.99" column-label "Custo"
                            with frame f-produ2 row 5 9 down  overlay
                              centered width 80.
                    down with frame f-produ2.
                    pause 0.
                end.
                pause.
                undo.
            end.
            if lastkey = keycode("e") or lastkey = keycode("E")
            then do:
               update v-procod
                           with frame f-exclusao row 6 overlay 
                                side-label centered width 80 no-box.
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
                display produ.pronom format "x(35)" no-label 
                                    with frame f-exclusao.
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
                                with frame f-produ1.
                    down with frame f-produ1.
                    pause 0.
                    vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
                    display vprotot with frame f-produ.
                end.
                next.
            end.
            /*** 40673 ***/
            vcodigo = int(input vprocod) no-error.
            if vcodigo > 0 and  vcodigo < 9999999
            then find produ where produ.procod = vcodigo no-lock no-error.
            else find produ where produ.proindice = input vprocod
                            no-lock no-error.
            if not avail produ
            then do:
                message "Produto nao Cadastrado".
                undo.
            end.
            display produ.pronom with frame f-produ.

            if produ.proseq = 98 and
               produ.proseq = 99
            then do:
                message "Produto INATIVO" view-as alert-box.
                undo.
            end.

          if  produ.catcod = 31 and vetbcod <> 900
                                and vetbcod <> 901 
                                and vetbcod <> 995  
                           /*     and vetbcod <>  65  */
			

   
                THEN DO:
                message
                    "Transferencia de MOVEIS bloqueada para este estabelecimento."
                    view-as alert-box.
                undo.
            END. 

            /*if produ.catcod = 31 and vetbcod <> 65 and vetbcod <> 993
                and vetbcod <> 900
            THEN DO:
                message
                    "Transferencia de MOVEIS liberada apenas para a Filial 65." 
                    view-as alert-box.
                undo.
            END.*/

            
            /* BLOQUEIO INVENTARIO CD JULHO 2018 */
            if vetbcod = 900 and today >= 07/16/2018 and today <= 07/22/2018 and produ.catcod = 41 then do:
                message "CD EM INVENTARIO ATE 22/07. IMPOSSIVEL EMITIR NF DE MODA!" view-as alert-box.
                undo.
            end.

 /* BLOCO QUE BLOQUEIA TRANSF INVENTARIO CD */
          if vetbcod = 900 and (today >= 08/20/2018 and today <= 08/25/2018) and
produ.catcod = 31
    then do:
        message "CELL em inventario ate o dia 25/08. Impossivel emitir NFe contra o mesmo." view-as alert-box.
         undo, retry.
             end.

 /* BLOCO QUE BLOQUEIA TRANSF INVENTARIO CD 901 - ISIS 19/07/2019 */
          if vetbcod = 901 and (today >= 07/20/2019 and today <= 07/24/2019) and produ.catcod = 41
    then do:
        message "Deposito em inventario ate o dia 24/07. Impossivel emitir NFe contra o mesmo." view-as alert-box.
         undo, retry.
             end.
              
/* BLOCO QUE BLOQUEIA TRANSF INVENTARIO CD 995 - GABRIELA 08/11/19 */ 
if vetbcod = 995 and (today >= 11/14/2019 and today <= 11/25/2019)
    then do:
        message "Deposito em inventario ate o dia 25/11. Impossivel emitir NFe contra o mesmo." view-as alert-box.
         undo, retry.
             end.             
          
/* BLOCO QUE BLOQUEIA TRANSF INVENTARIO CD 901 - GABRIELA 03/01/2020 */
          if vetbcod = 901 and (today >= 01/06/2020 and today <= 01/09/2020) and produ.catcod = 41
    then do:
        message "Deposito em inventario ate o dia 09/01. Impossivel emitir NFe contra o mesmo." view-as alert-box.
         undo, retry.
             end.

/* BLOCO QUE BLOQUEIA TRANSF CD 901 IMPLANTACAO SAP - GABRIELA 18/06/20 */ 
if vetbcod = 901 and (today >= 06/20/2020 and today <= 01/01/2099)
    then do:
        message "Deposito em inventario. Implantacao SAP. Impossivel emitir NFe contra o mesmo." view-as alert-box.
         undo, retry.
             end.
 
/* BLOCO QUE BLOQUEIA TRANSF CD 995 IMPLANTACAO SAP - GABRIELA 23/06/20 */
if vetbcod = 995 and (today >= 06/24/2020 and today <= 01/01/2099)
    then do:
        message "Deposito em inventario. Implantacao SAP. Impossivel emitir NFe contra o mesmo." view-as alert-box.
         undo, retry.
             end.

                                
        /* BLOQUEIO DE MOVEIS PRO SSC SEM OS */
        if vetbcod = 988 and produ.catcod = 31
        then do:
            message "IMPOSSIVEL TRANSFERIR MOVEIS PARA O SSC SEM OS!" view-as alert-box.
            undo.
        end.
 

            if bestab.etbcod = 988 /* SSC */
            then do.
                find clase of produ no-lock.
                if produ.catcod <> 41 or
                   clase.clasup = 234080200 or
                   clase.clasup = 234080300 or
                   clase.clasup = 234080400 or
                   clase.clasup = 234080600 or
                   clase.clasup = 234080700
                then do.
                    message "Para o SSC somente CONFECOES" view-as alert-box.
                    undo.
                end.
            end.
                if today < 03/10/20 or
                   today > 03/20/20
                then do:   
                if vetbcod = 995
                        then do.
                        find clase of produ no-lock.
                        if clase.clasup = 234080200 or
                                clase.clasup = 234080300 or
                                clase.clasup = 234080400 or
                                clase.clasup = 234080600 or
                                clase.clasup = 234080700
                        then do.
                message "Nao e permitido transferir relogio para esse estabelecimento." view-as alert-box.
                        undo.
                        end.
                end.
                end.

            if (bestab.etbcod = 993 or
                bestab.etbcod = 997 or
                bestab.etbcod = 999) and setbcod <> 13 
            then do:
                if produ.catcod = 41 
                then do:
                    message "Produto de Confeccao".
                    pause.
                    undo, retry.
                end.
            end.

            if bestab.etbcod = 996 or
               /*bestab.etbcod = 995 or*/
               bestab.etbcod = 994
            then do:
                if (produ.catcod = 31 or
                    produ.catcod = 35) and
                   produ.procod <> 414435 and
                   produ.procod <> 415200 and
                   produ.procod <> 415354 and
                   produ.procod <> 415201 and
                   produ.procod <> 418788 
                then do:
                    message "Produto de Moveis".
                    undo, retry.
                end.
            end.

            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not available estoq
            then do:
                message "Produto Sem Registro de Armazenagem".
                pause.
                undo.
            end.

            display produ.procod produ.pronom with frame f-produ1.
            vmovqtm = 0.
            vsubtotal = 0.
            find first w-movim where w-movim.wrec = recid(produ) 
                                no-lock no-error.
            if not avail w-movim
            then do:
                create w-movim.
                assign w-movim.wrec = recid(produ)
                       w-movim.movpc = estoq.estcusto.
            end.
            vmovqtm = w-movim.movqtm.
            do on error undo , retry:
                update w-movim.movqtm validate(w-movim.movqtm > 0,
                                 "Quantidade Invalida") with frame f-produ1.
                w-movim.movqtm = w-movim.movqtm + vmovqtm.
                if w-movim.movqtm > 1000
                then do:
                    sresp = no.
                    message "Confirma esta quantidade?" update sresp.
                    if not sresp
                    then undo, retry.
                end.
            
                if produ.catcod = 31
                then do:
                    run loj/ver_est.p (input produ.procod,
                                       input w-movim.movqtm,
                                       output vok).

                    hide frame f-senh no-pause.
                    hide frame f-motivo no-pause.
                
                    if vok = no
                    then do on error undo, leave on endkey undo, retry:
                        message "Deseja incluir este codigo?" update sresp.
                        if sresp
                        then do on endkey undo, retry:
                            vsenha = "".
                            vfuncod = 0.
                            update vfuncod label "Matricula"
                                   vsenha blank 
                                        with frame f-senh side-label 
                                                centered row 10 overlay.
                            find first func where func.funcod = vfuncod and
                                                  func.etbcod = setbcod and
                                                  func.senha  = vsenha 
                                            no-lock no-error.
                            if not avail func
                            then do:
                                message "Funcionario Invalido.".
                                pause.
                                delete w-movim.
                            end.
                            else do on endkey undo, retry:
                                hide frame f-senh no-pause.
                                vmotivo = "".
                                update vmotivo no-label
                                        with frame f-motivo centered
                                           width 80 side-label row 15 overlay 
                                                title "MOTIVO DE LIBERACAO".
                                hide frame f-motivo no-pause.
                                if vmotivo = ""
                                then do:
                                    message "Motivo invalido".
                                    undo, retry.
                                end.
                                else do:
                                    output to 
                                        value ("/usr/admcom/work/motivo" + 
                                                  string(estab.etbcod,"99")) 
                                                             append.
                                        put produ.procod   " "
                                            w-movim.movqtm " "
                                            func.funcod    " "
                                            func.funnom    " "
                                            vmotivo        " "
                                            today format "99/99/9999" skip. 
                                    output close.
                                end.
                            end.
                        end.
                        else do:
                            delete w-movim.
                            leave.
                        end.    
                    end.    
                end.
            
                find first w-movim where w-movim.wrec = recid(produ) no-error.
                if not avail w-movim
                then next.
                if w-movim.movqtm = 0
                then do:
                    delete w-movim.
                    next.
                end.
            end.
        
            display w-movim.movpc with frame f-produ1.
            
            vprotot = 0.
            w-movim.subtotal = vsubtotal + (w-movim.movpc * w-movim.movqtm).

            clear frame f-produ1 all no-pause.

            for each w-movim:
                find produ where recid(produ) = wrec no-lock.
                display produ.procod
                        produ.pronom
                        w-movim.movqtm
                        w-movim.subtotal
                        w-movim.movpc
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
    
    find first w-movim no-error.
    if not avail w-movim
    then undo, retry.
    
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    for each tt-movimimp. delete tt-movimimp. end.

    do transaction:
        find tipmov where tipmov.movtdc = 6 no-lock.        
        run le_tabini.p (estab.etbcod, 0, "NFE - SERIE", OUTPUT vserie).
        vnumero = ?.
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = ?
               tt-plani.emite    = estab.etbcod
               tt-plani.plaufemi = estab.ufecod
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = bestab.etbcod
               tt-plani.plaufdes = bestab.ufecod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = vhiccod
               tt-plani.notfat   = bestab.etbcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.hiccod   = vhiccod
               tt-plani.notobs[3] = "D" 
               tt-plani.outras = tt-plani.frete +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi.
              tt-plani.isenta = tt-plani.platot - tt-plani.outras.
    end.

    do transaction:
        vmovseq = 0.    
        for each w-movim:
            vmovseq = vmovseq + 1.
            find produ where recid(produ) = w-movim.wrec no-lock no-error.
            if not avail produ
            then next.
            tt-plani.protot = tt-plani.protot + 
                    (w-movim.movqtm * w-movim.movpc).
            tt-plani.platot = tt-plani.platot + 
                    (w-movim.movqtm * w-movim.movpc).

            create tt-movim.
            assign tt-movim.movtdc = tt-plani.movtdc
                   tt-movim.PlaCod = tt-plani.placod
                   tt-movim.etbcod = tt-plani.etbcod
                   tt-movim.desti  = tt-plani.desti
                   tt-movim.emite  = tt-plani.emite
                   tt-movim.movseq = vmovseq
                   tt-movim.procod = produ.procod
                   tt-movim.movqtm = w-movim.movqtm
                   tt-movim.movpc  = w-movim.movpc
                   tt-movim.movdat = tt-plani.pladat
                   tt-movim.MovHr  = time.    
            delete w-movim.
        end.
    end.
    run manager_nfe.p (input "5152", input ?, output v-ok).
end.
