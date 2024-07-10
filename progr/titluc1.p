/* titluc1.p                */ 
/* demanda Autorização de Despesas   08/2014                         */
{admcab.i}

def var v-lancactb as log.
def var vobs like  fin.titluc.titobs.
def var vlpag like fin.titluc.titvlpag.
def var vldes like fin.titluc.titvldes.
def var vljur like fin.titluc.titvljur.

def var vip as char.
def var varquivo        as   char.

def var vdti            like plani.pladat.
def var vdtf            like plani.pladat.
def var vtitsit         like titluc.titsit.

def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6 
    initial ["Autorizacao","Consulta","Listagem","Observacao","Inclusao","Exclusao"].
def var esqcom2         as char format "x(13)" extent 6
            initial ["Rateio Premio","","","",""].

def temp-table tt-titluc
    field wrec as recid.

{seltpmo.i "DESPESA" "PREMIO"}

def buffer btitluc       for titluc.
def var vetbcod         like titluc.etbcod.
def var vsetcod         like setaut.setcod.
def var vforcod       like titluc.clifor.

def var vclifor    like titluc.clifor.
def var vtitnum    like titluc.titnum.
def var vtitdtven  like titluc.titdtven.
def var vtitdtpag  like titluc.titdtpag.
def var vtitvlcob  like titluc.titvlpag.
def var vfordes    as int format ">>>>>9".
def var vint-titnum as integer.

    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.

    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    
    update vsetcod label "Setor" with frame ff1 side-label width 80.
    
    find setaut where setaut.setcod = vsetcod no-lock no-error.
    if not avail setaut
    then do:
        message "Setor nao cadastrado".
        undo, retry.
    
    end.
    display setaut.setnom no-label with frame ff1.
    /*  May 23 16:16 estava comentado.
        em 10/07 descomentado pela pre-corretiv 165507 */
    if today > 11/30/07 and
       func.aplicod <> string(setaut.setcod)
    then do:
        bell.
        message color red/with
        "Funcionario nao autorizado"
         view-as alert-box.
        undo. 
    end.
    for each tt-titluc:
        delete tt-titluc.
    end.
    vetbcod = 0.    
    update vetbcod at 1 label "Filial"
        with frame ff1.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom no-label with frame ff1.
    end.   
         
    assign vforcod = 0.     

    update vforcod at 1 label "Fornecedor"
            with frame ff1.

    if vforcod <> 0  
    then do:
     
        find first forne where forne.forcod = vforcod no-lock.
        display forne.fornom no-label with frame ff1.
        

     end.

    for each foraut where foraut.setcod = setaut.setcod and
            (if vforcod <> 0 then foraut.forcod = vforcod else true) 
            no-lock,
        each titluc where titluc.clifor = foraut.forcod no-lock
        :
         if titluc.cobcod = 5
           then next.
         if vetbcod > 0
            and titluc.etbcod <> vetbcod
           then next.
           
         if vforcod > 0 and vforcod <> titluc.clifor
           then next.
           
            if  /*titluc.titsit = "NEG" or */
               titluc.titsit = "BLO" or
               titluc.titsit = "AUT"
            then do:
                create tt-titluc.
                assign tt-titluc.wrec = recid(titluc).
            end.
    end.
    
    
    hide frame ff1 no-pause.    
    
def buffer bmodgru for modgru.
form with frame frame-a.

def var vfuncod like func.funcod.
def var setbcod-ant like estab.etbcod.    
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then find first tt-titluc where true no-error.
    else find tt-titluc where recid(tt-titluc) = recatu1.
    
    vinicio = yes.
    
    if not available tt-titluc
    then do with frame f-inclui2 overlay row 6 centered side-label:
    
        message "Nenhuma despesa cadastrada" update sresp.
        
        if sresp = no
        then return. 
        
        assign vfordes = 0 
               vtitnum = "" 
               vtitdtven = today 
               vtitvlcob = 0.
        
        update vetbcod label "Filial" at 10.
        
        find estab where estab.etbcod = vetbcod no-lock no-error. 
        if not avail estab 
        then do: 
            message "Filial nao cadastrada". 
            undo, retry.
        end. 
        
        display estab.etbnom no-label. 
        vip = "filial" + string(estab.etbcod,"999").
                       
        update vfordes label "Fornecedor" at 10.
        find foraut where foraut.forcod = vfordes no-lock no-error.
        if not avail foraut 
        then do: 
            message "Fornecedor nao Cadastrado". 
            undo, retry.
        end. 
        
        if foraut.setcod <> setaut.setcod  
        then do: 
            message "Fornecedor nao pertence a este setor". 
            undo, retry.
        end. 
        
        display foraut.fornom no-label. 
        
        if foraut.autlp = no 
        then do: 
            find lanaut where lanaut.etbcod = vetbcod and
                              lanaut.forcod = foraut.forcod 
                                                no-lock no-error.
            if not avail lanaut 
            then do:
                message "Fornecedor nao possui codigo contabil".
                pause. 
                undo, retry.
            end.
                                                
        end.
                
        update vtitvlcob label "Valor     "  at 10
               vtitdtven label "Vencimento"  at 10.
  

        vfuncod = 0.       
        setbcod-ant = setbcod.   
        v-tipodes = "".
        
        run d-tipo-sel.

        if v-tipodes <> "DESPESA"
        THEN DO:
            find first bmodgru where
                       bmodgru.modcod = foraut.modcod and
                       bmodgru.mogsup <> 0
                       no-lock no-error.
            if not avail bmodgru
            then do:
                bell.
                message color red/with
                "Modalidade nao pertence a nenhum grupo de modalidades."
                "Favor associar a modalidade " foraut.modcod
                " a um grupo."
                view-as alert-box.
                undo.
            end.
            find first modgru where modgru.mogcod = bmodgru.mogsup and
                              modgru.modcod = "PEM"
                       no-lock no-error.
            if not avail modgru
            then do:
                bell.
                message color red/with
                "Modalidade " foraut.modcod 
                " nao pertence a grupo de PREMIOS."
                view-as alert-box.
                undo.

            end.
                       
        END.
        
        if v-tipodes = "CREDIARISTA"
        THEN vfuncod = 150.

        if v-tipodes = "GERENTE"
        THEN vfuncod = 99.

        if  v-tipodes = "VENDEDOR" 
        then do on error undo, retry :
            setbcod = vetbcod.
            update vfuncod label "Consultor" at 10.
             find func where func.etbcod = estab.etbcod and
                            func.funcod = vfuncod no-lock.
            disp func.funnom +  " - " + func.funfunc no-label
            format "x(50)".
        end.               
        setbcod = setbcod-ant.
                       
        vobs[1] = "" .   
        vobs[2] = "" .
                
        if vfuncod > 0 and avail func
        then vobs[1] = func.funnom.
         
        update vobs[1] no-label
               vobs[2] no-label with frame f-obs side-label
                   centered title "Observacoes".
        
        sresp = no.        
        run valida-complpmo.p(input vtitdtven,
                              input vetbcod,
                              input foraut.forcod,
                              input setaut.setcod,
                              input vfuncod,
                              input foraut.modcod,
                              output sresp).

        if not sresp
        then do:
            bell.
            message color red/with
            "Bloqueio para inclir ou liberar fora de competencia."
            view-as alert-box. 
            undo.
        end.
        
        message "Confirma inclusao da Despesa" update sresp. 
        if sresp = no 
        then undo, retry.
         
        do transaction: 
        
            create titluc. 
            assign titluc.empcod = 19 
                   titluc.modcod = foraut.modcod 
                   titluc.clifor = foraut.forcod 
                   titluc.titpar = 1 
                   titluc.etbcod = estab.etbcod 
                   titluc.vencod = vfuncod
                   titluc.titnat = yes 
                   titluc.titsit = "AUT" 
                   titluc.titdtemi = today 
                   titluc.titdtven = vtitdtven 
                   titluc.titvlcob = vtitvlcob 
                   titluc.cxacod   = 1 
                   titluc.cobcod   = 1 
                   titluc.evecod   = 4 
                   titluc.datexp   = today 
                   titluc.titobs[1] = vobs[1] 
                   titluc.titobs[2] = vobs[2]
                   .
            
            if  v-tipodes <> "DESPESA"
            THEN titluc.titobs[2] = titluc.titobs[2] +
                "|PREMIO=" + v-tipodes.
            
            run p-gera-numaut (output vint-titnum).
            titluc.titnum = string(vint-titnum).
                
            if v-tipodes <> "DESPESA" 
            then assign
                     titluc.titsit = "BLO"
                     titluc.cxacod = 0
                     titluc.cobcod = 2
                     titluc.evecod = 5 .
           else do:
                
                if estab.etbcod < 900 and
                    {conv_difer.i estab.etbcod} and 
                    estab.etbcod <> 22 
                then do: 
                    /** Proc. 334
                    
                    message "Criando despesa na loja.....".
                        connect fin -H value(vip) -S sdrebfin -N tcp -ld 
                                        finloja no-error.
                    if not connected ("finloja")  
                    then do:  
                        message "Filial nao conectada".  
                        pause.  
                        undo, retry. 
                    end.
                    run cria-titluc.p (recid(titluc)). 
                        disconnect finloja.
                    ***/
                end. 
                else assign titluc.titsit = "LIB" 
                        titluc.evecod = 1.
            
                        
            end.                    
            hide message no-pause.        
            create tt-titluc. 
            assign tt-titluc.wrec = recid(titluc).
        
        end.           
                      
        recatu1 = ?.
        next bl-princ.
        
    
    end.
    clear frame frame-a all no-pause.
    
    find titluc where recid(titluc) = tt-titluc.wrec no-lock.
    find foraut where foraut.forcod = titluc.clifor no-lock no-error.
    

    display titluc.etbcod    column-label "Fl" format ">>9"
            titluc.titnum    column-label "Despesa" format "x(07)"
            titluc.clifor    column-label "Codigo"
            foraut.fornom    column-label "Fornecedor" format "x(19)"
            titluc.titdtven  column-label "Dt.Venc"
            titluc.titvlcob  column-label "Valor" format ">>,>>9.99"
            titluc.titsit 
            foraut.autlp     
                with frame frame-a 12 down width 80.

    recatu1 = recid(tt-titluc).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-titluc where true.
        if not available tt-titluc
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.

        find titluc where recid(titluc) = tt-titluc.wrec no-lock.


        find foraut where foraut.forcod = titluc.clifor no-lock no-error.

        display titluc.etbcod 
                titluc.titnum     
                titluc.clifor     
                foraut.fornom     
                titluc.titdtven   
                titluc.titvlcob   
                titluc.titsit 
                foraut.autlp 
                 with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a 12 down:

        find tt-titluc where recid(tt-titluc) = recatu1.
        find titluc where recid(titluc) = tt-titluc.wrec no-lock.


        run color-message.
        choose field titluc.etbcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        run color-normal.
        
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 6
                          then 6
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-titluc where true no-error.
                if not avail tt-titluc
                then leave.
                recatu1 = recid(tt-titluc).
                find titluc where recid(titluc) = tt-titluc.wrec no-lock.

            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-titluc where true no-error.
                if not avail tt-titluc
                then leave.
                recatu1 = recid(tt-titluc).
                find titluc where recid(titluc) = tt-titluc.wrec no-lock.

            end.
            leave.
        end.


        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-titluc where true no-error.
            if not avail tt-titluc
            then next.
            find titluc where recid(titluc) = tt-titluc.wrec no-lock.
            color display normal
                titluc.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-titluc where true no-error.
            if not avail tt-titluc
            then next.
            find titluc where recid(titluc) = tt-titluc.wrec no-lock.
            color display normal
                titluc.etbcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 centered side-label.
            
                assign vfordes = 0
                       vtitnum = ""
                       vtitdtven = today
                       vtitvlcob = 0.
                
                update vetbcod label "Filial" at 10.
                find estab where estab.etbcod = vetbcod no-lock no-error.
                if not avail estab
                then do:
                    message "Filial nao cadastrada".
                    undo, retry.
                end.
                
                display estab.etbnom no-label.
                vip = "filial" + string(estab.etbcod,"999").
                       
                update vfordes label "Fornecedor" at 10.
                find foraut where foraut.forcod = vfordes no-lock no-error.
                if not avail foraut
                then do:
                    message "Fornecedor nao Cadastrado".
                    undo, retry.
                end.
                if foraut.setcod <> setaut.setcod 
                then do:
                    message "Fornecedor nao pertence a este setor".
                    undo, retry.
                end.
                display foraut.fornom no-label.
                if foraut.autlp = no
                then do:
                    find lanaut where lanaut.etbcod = vetbcod and
                                      lanaut.forcod = foraut.forcod 
                                                no-lock no-error.
                    if not avail lanaut
                    then do:
                        message "Fornecedor nao possui codigo contabil".
                        pause.
                        undo, retry.
                    end.
                                                
                end.
                
                
                update vtitvlcob label "Valor     "  at 10
                       vtitdtven label "Vencimento"  at 10.
                       
                       
                vfuncod = 0.       
                setbcod-ant = setbcod.        
               
                v-tipodes = "".
                
                run d-tipo-sel.

                if  v-tipodes = "CREDIARISTA"
                then vfuncod = 150.
                if  v-tipodes = "GERENTE"
                then vfuncod = 99.
                                
                if  v-tipodes = "VENDEDOR"
                then do on error undo, retry :
                    setbcod = vetbcod.
                    update vfuncod label "Consultor" at 10.
                    find func where func.etbcod = estab.etbcod and
                            func.funcod = vfuncod no-lock.
                    end.
                setbcod = setbcod-ant.
                                        
                vobs[1] = "" .  
                vobs[2] = "" .
            
                
                if vfuncod > 0 and avail func
                then vobs[1] = func.funnom.
                
                update vobs[1] no-label
                       vobs[2] no-label with frame f-obs side-label
                                    centered title "Observacoes".
                
                sresp = no.        
        run valida-complpmo.p(input vtitdtven,
                              input vetbcod,
                              input foraut.forcod,
                              input setaut.setcod,
                              input vfuncod,
                              input foraut.modcod,
                              output sresp).

        if not sresp
        then do:
            bell.
            message color red/with
            "Bloqueio para inclir ou liberar fora de competencia."
            view-as alert-box. 
            undo.
        end.
                    
                message "Confirma inclusao da Despesa/Premio" update sresp.
                if sresp = no
                then undo, retry.
                do transaction:
                    create titluc.
                    assign titluc.empcod = 19
                           titluc.modcod = foraut.modcod
                           titluc.clifor = foraut.forcod
                           titluc.titpar = 1
                           titluc.etbcod = estab.etbcod
                           titluc.titnat = yes
                           titluc.titsit = "AUT"
                           titluc.titdtemi = today
                           titluc.titdtven = vtitdtven
                           titluc.titvlcob = vtitvlcob
                           titluc.cxacod   = 1
                           titluc.cobcod   = 1
                           titluc.evecod   = 4
                           titluc.datexp   = today
                           titluc.titobs[1] = vobs[1]
                           titluc.titobs[2] = vobs[2]
                           titluc.vencod = vfuncod.
                    
                    if  v-tipodes <> "DESPESA"
                    THEN titluc.titobs[2] = titluc.titobs[2] +
                        "|PREMIO=" + v-tipodes.
                    
                    run p-gera-numaut (output vint-titnum). 

                    assign titluc.titnum = string(vint-titnum).

                    if  v-tipodes <> "DESPESA" 
                    then assign
                         titluc.titsit = "BLO"
                         titluc.cxacod = 0
                         titluc.cobcod = 2
                         titluc.evecod = 5 .
                    else do:
                        
                        if estab.etbcod < 900 and {conv_difer.i estab.etbcod}
                            and estab.etbcod <> 22
                        then do:
                            /** Proc 334
                            message "Criando despesa na loja.....".
                            connect fin -H value(vip) -S sdrebfin -N tcp -ld 
                                        finloja no-error.
                            if not connected ("finloja") 
                            then do: 
                                message "Filial nao conectada". 
                                pause. 
                                undo, retry. 
                            end.
                            run cria-titluc.p (recid(titluc)).
                            disconnect finloja.
                            **/
                        end.
                        else assign titluc.titsit = "LIB"
                                titluc.evecod = 1.

                    end.    
                     
                    hide message no-pause.        
                    create tt-titluc. 
                    assign tt-titluc.wrec = recid(titluc).
                    recatu1 = recid(tt-titluc).
                    next bl-princ.
                end.        
                      
                recatu1 = recid(tt-titluc).
                leave.
            end.

            if esqcom1[esqpos1] = "Observacao"
            then do transaction:
                if titluc.titsit = "Pag"
                then do:
                    message "Despesa Paga". 
                    pause. 
                    undo, retry.
                end.

                find titluc where recid(titluc) = tt-titluc.wrec.

                update titluc.titobs[1] no-label 
                       titluc.titobs[2] no-label 
                            with frame f-obs centered
                                title "Observacoes".
            
                titluc.datexp = today.
            end.

            if esqcom1[esqpos1] = "Autorizacao"
            then do transaction with frame f-altera overlay row 6 1 
                    column centered.
                
                find first titluc where recid(titluc) = tt-titluc.wrec.
                if titluc.titsit = "PAG"
                then do:
                    message "Despesa ja paga".
                    pause.
                    undo, retry.
                end.     
                find foraut where foraut.forcod = titluc.clifor 
                        no-lock no-error.
                if avail foraut and
                         foraut.autlp
                then.
                else run ver-lancactb.
                
                vtitsit = titluc.titsit.
                update vtitsit 
                help "[NEG - Negado] - [AUT - Autorizado] - [BLO - Bloqueado]"  
                with frame f-altera no-validate.
                    
                if vtitsit <> "NEG" and
                   vtitsit <> "AUT" and
                   vtitsit <> "BLO"
                then do:
                    if vtitsit = "LIB" /*and
                       (titluc.clifor = 104712 or
                        titluc.clifor = 103294)
                        validacao eliminada em 29/08/2014 por Felipe Trojack
                                    */
                    then.
                    else do:    
                        message color red/with
                            "Situacao Invalida para fornecedores diferentes de"
                            104712 103294
                            view-as alert-box.
                        next bl-princ.
                    end.
                end.

                /* demanda Autorização de Despesas  */
                /*  08/2014                         */
                if vtitsit = "LIB"
                then do.
                    def buffer modgru74 for modgru.
                    find first modgru74 where modgru74.mogcod = 74 no-lock.
                    find first 
                            modgru where modgru.modcod = titluc.modcod no-lock.
                    if modgru.mogsup = 74
                    then do.
                        if setaut.setcod = 11 or
                           setaut.setcod = 32
                        then . /* Permite Alteracao */
                        else do on endkey undo. 
                            message "Setor" setaut.setcod setaut.setnom 
                                        "sem permissao para Liberar "
                                    "Grupo "    modgru74.mogcod modgru74.mognom
                                    view-as alert-box.
                            next bl-princ.
                        end.
                    end.
                end.
                
                
                
                titluc.titsit = vtitsit.
                titluc.datexp = today.
                
                if titluc.titsit = "NEG"
                then do:
                    delete tt-titluc.
                    recatu1 = ? .
                    next bl-princ.
                end.
                leave.
                
            end.

            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 centered side-label.

               find titluc where recid(titluc) = tt-titluc.wrec no-lock.

                disp titluc.etbcod   label "Filial    "  at 1 
                     titluc.titnum   label "Despesa   "  at 1
                     titluc.clifor   label "Fornecedor"  at 1.
                        
                find foraut where foraut.forcod = titluc.clifor no-lock.
                display foraut.fornom no-label.        
                
     
                display        
                     titluc.modcod   label "Modalidade"  at 1
                     titluc.titdtemi label "Emissao   "  at 1
                     titluc.titdtven label "Vencimento"  at 1
                     titluc.titvlcob label "Valor     "  at 1
                     titluc.titdtpag label "Pagamento "  at 1
                     titluc.cxacod   label "Caixa     "  at 1
                     titluc.datexp   label "Exportado "  at 1
                        format "99/99/9999" 
                        with frame f-consulta no-validate.
                 
                display titluc.titobs[1] no-label 
                        titluc.titobs[2] no-label 
                            with frame f-obs centered
                                title "Observacoes".

            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do transaction with frame f-exclui 
                            overlay row 6 1 column centered.
                            
                message "Confirma Exclusao de" titluc.titnum update sresp.
                if not sresp
                then leave.
                find next tt-titluc where true no-error.
                if not available tt-titluc
                then do:
                    find tt-titluc where recid(tt-titluc) = recatu1.
                    find prev tt-titluc where true no-error.
                end.

                recatu2 = if available tt-titluc
                          then recid(tt-titluc)
                          else ?.
                find tt-titluc where recid(tt-titluc) = recatu1.

                find titluc where recid(titluc) = tt-titluc.wrec. 
                vip = "filial" + string(titluc.etbcod,"999").

                
                if titluc.etbcod < 900 and {conv_difer.i titluc.etbcod}
                    and titluc.etbcod <> 22
                then do: 
                    
                    message "Deletando despesa na loja.....". 
                    connect fin -H value(vip) -S sdrebfin -N tcp -ld finloja no-error.
                    if not connected ("finloja")  
                    then do:  
                        message "Filial nao conectada".  
                        pause.  
                        undo, retry. 
                    end. 
                    
                
                    run deleta_titluc.p (recid(titluc)). 
                    disconnect finloja.  
                    hide message no-pause.
                    delete tt-titluc.
                end.
                else do:
                    delete titluc.
                    delete tt-titluc.
                end.
                recatu1 = recatu2.
                leave.
            end.

            if esqcom1[esqpos1] = "Listagem"
            then do:

                vtitsit = "PAG".
                update vdti label "Periodo"
                       vdtf no-label
                       vtitsit label "Situacao"
                            with frame f-lista width 80 side-label.
                            
                recatu2 = recatu1.

                sresp = no.
                message "Listar Observacoes ? " update sresp.
                
                if opsys = "UNIX"
                then varquivo = "/admcom/relat/titlucl" + STRING(day(today))
                + string(time).
                else varquivo = "l:~\relat~\titluc" + STRING(day(today))
                + string(time).

                {mdad.i
                    &Saida     = "value(varquivo)"  
                    &Page-Size = "64" 
                    &Cond-Var  = "130" 
                    &Page-Line = "66" 
                    &Nom-Rel   = ""titluc1""
                    &Nom-Sis   = """SISTEMA FINANCEIRO"""
                    &Tit-Rel   = """DESPESAS DAS FILIAIS PAGAS EM "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
                    &Width     = "130"
                    &Form      = "frame f-cabcab"}


                

                if vtitsit = "PAG"
                then do:
                    for each titluc where titluc.titsit = vtitsit and
                                          titluc.titdtpag >= vdti and
                                          titluc.titdtpag <= vdtf no-lock:
                   
                        find foraut where foraut.forcod = titluc.clifor 
                            no-lock no-error.
                        if not avail foraut   
                        then next.
                        
                        if vetbcod > 0
                          and titluc.etbcod <> vetbcod 
                        then next.  
                        if foraut.setcod <> vsetcod 
                        then next.
                        
                        if vforcod > 0
                            and titluc.clifor <> vforcod
                        then next.    
                        
                        display titluc.etbcod    
                                titluc.titnum     
                                titluc.clifor     
                                (if avail foraut
                                 then foraut.fornom
                                 else "NAO CADASTRADO") format "x(30)"     
                                titluc.titdtven   
                                titluc.titvlcob(total)   
                                titluc.titvlpag(total)
                                titluc.titdtpag
                                titluc.titsit  
                                foraut.autlp  when avail foraut
                                    with frame f-lista2 width 130 down.
                        down with frame f-lista2.
                        if sresp
                        then do:
                            if titluc.titobs[1] <> ""
                            then do:
                                put skip "         Obs: " titluc.titobs[1] skip.
                                if titluc.titobs[2] <> ""
                                then put "              " titluc.titobs[2] skip.
                            end.
                        end.

                    end.
                end.
                else do:

                     for each titluc where titluc.titsit = vtitsit and
                                           titluc.titdtven >= vdti and
                                           titluc.titdtven <= vdtf no-lock:
                   
                        find foraut where foraut.forcod = titluc.clifor 
                            no-lock no-error.
                        if not avail foraut   
                        then next.
                        if vetbcod > 0 and
                            titluc.etbcod <> vetbcod
                        then next.    
                        if foraut.setcod <> vsetcod 
                        then next.
                        
                        if vforcod > 0
                            and titluc.clifor <> vforcod
                        then next.
                        
                        display titluc.etbcod    
                                titluc.titnum     
                                titluc.clifor     
                                (if avail foraut
                                 then foraut.fornom
                                 else "NAO CADASTRADO") format "x(30)"     
                                titluc.titdtven   
                                titluc.titvlcob(total)   
                                titluc.titvlpag(total)
                                titluc.titdtpag
                                titluc.titsit  
                                foraut.autlp  when avail foraut
                                    with frame f-lista3 width 130 down.
                        down with frame f-lista3.
                        if sresp
                        then do:
                            if titluc.titobs[1] <> ""
                            then do:
                                put skip "         Obs: " titluc.titobs[1] skip.
                                if titluc.titobs[2] <> ""
                                then put "              " titluc.titobs[2] skip.
                            end.
                        end.
                    end.
                
                end.                             

                
                output close.
                                   
                if opsys = "UNIX"  
                then do:
                    run visurel.p (input varquivo, input "").
                end.
                else do:
                    {mrod.i}.       
                end.
                
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            if esqcom2[esqpos2] = "Rateio Premio"
            then do:
                run rateio-titluc.p(vsetcod, vetbcod, vforcod).
                next bl-princ.
            end.
            /*     
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
            */
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.

        find titluc where recid(titluc) = tt-titluc.wrec no-lock.

        find foraut where foraut.forcod = titluc.clifor no-lock no-error.

        display titluc.etbcod    
                titluc.titnum    
                titluc.clifor    
                foraut.fornom    
                titluc.titdtven  
                titluc.titvlcob  
                titluc.titsit 
                foraut.autlp
                    with frame frame-a down.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-titluc).
   end.
end.

procedure ver-lancactb:
    v-lancactb = yes.
    
    find first fatudesp where 
               fatudesp.clicod = titluc.clifor and
               fatudesp.fatnum = int(titluc.titnum)
               no-lock no-error.
    if not avail fatudesp
    then do:           
        find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = titluc.etbcod and
                lancactb.forcod = titluc.clifor and
                lancactb.modcod = titluc.modcod
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = titluc.clifor and
                lancactb.modcod = titluc.modcod
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = titluc.modcod
                no-lock no-error.
    
        if not avail lancactb
        then do:
            bell.
            message color red/with
            "CONTA CONTABIL para modalidade " titluc.modcod
             " nao esta cadastrada." skip
            "Favor resolver com o SETOR DE CONTABILIDADE."
             view-as alert-box.

            v-lancactb = no.
        end.
    end.
    else do:
        find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = fatudesp.etbcod and
                lancactb.forcod = fatudesp.clicod and
                lancactb.modcod = fatudesp.modctb
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = fatudesp.clicod and
                lancactb.modcod = fatudesp.modctb
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = fatudesp.modctb
                no-lock no-error.

        if not avail lancactb
        then do:
            bell.
            message color red/with
            "CONTA CONTABIL para modalidade " fatudesp.modctb
             " nao esta cadastrada." skip
            "Favor resolver com o SETOR DE CONTABILIDADE."
             view-as alert-box.
            v-lancactb = no.
        end.
    end.
end procedure.

procedure color-message.
color display message
        titluc.etbcod
        titluc.titnum
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        titluc.etbcod
        titluc.titnum
        with frame frame-a.
end procedure.



procedure p-gera-numaut.                    

   def buffer bf-numaut for numaut.

   def output parameter opint-titnum  as integer.

       
   find last bf-numaut where bf-numaut.etbcod = 999 exclusive-lock.
       
   if not avail bf-numaut
   then create bf-numaut.
               bf-numaut.titnum = bf-numaut.titnum + 1.
                                
   opint-titnum = bf-numaut.titnum.
       
   release bf-numaut.
       
end procedure.
