/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var vt-clifor like titluc.clifor.
def var vt-titdtven  like titluc.titdtven.
def var vt-titvlcob  like titluc.titvlcob.
def var vt-titobs like titluc.titobs.

def var vobs like titluc.titobs.
def var vlpag like titluc.titvlpag.
def var vldes like titluc.titvldes.
def var vljur like titluc.titvljur.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
      initial ["Inclusao","Alteracao","Exclusao","Consulta","Fornecedor",""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def buffer btitluc for titluc.
def var vclifor    like titluc.clifor.
def var vtitnum    like titluc.titnum.
def var vtitdtven  like titluc.titdtven.
def var vtitdtpag  like titluc.titdtpag.
def var vtitvlcob  like titluc.titvlpag.
def var vfordes    as int format ">>>>>9".
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

def var vdt-in as date init 01/01/08.
def var v-nat as log init yes.

if setbcod <> 999
then assign esqcom1[1] = "".


bl-princ:
repeat:
    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first titluc where titluc.titsit <> "PAG" and
                titluc.titdtven >= vdt-in 
                and titluc.etbcod = setbcod 
                and titluc.titnat = v-nat no-lock no-error.
    else find titluc where recid(titluc) = recatu1 no-lock no-error.

    if not available titluc
    then do:
        message "Cadastro de Despesas Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1 overlay row 6 centered side-label.
            assign vfordes = 0
                   vtitnum = ""
                   vtitdtven = today
                   vtitvlcob = 0.
            update vfordes label "Fornecedor" at 10.
            find foraut where foraut.forcod = vfordes no-lock no-error.
            if not avail foraut
            then do:
                message "Fornecedor nao Cadastrado".
                undo, retry.
            end.
            display foraut.fornom no-label.
            if foraut.autlp = no
            then do:
                find lanaut where lanaut.etbcod = setbcod and
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
            
            vobs[1] = "" . 
            vobs[2] = "" .
            
            update vobs[1] no-label
                   vobs[2] no-label with frame f-obs side-label
                                centered title "Observacoes".
                                
            message "Confirma inclusao da Despesa" update sresp.
            if sresp = no
            then undo, retry.
    
            do transaction:
                create titluc.
                assign titluc.empcod = 19
                       titluc.modcod = foraut.modcod
                       titluc.clifor = foraut.forcod
                       titluc.titpar = 1
                       titluc.etbcod = setbcod
                       titluc.titnat = yes
                       titluc.titsit = "BLO"
                       titluc.titdtemi = today
                       titluc.titdtven = vtitdtven
                       titluc.titvlcob = vtitvlcob
                       titluc.cxacod   = scxacod
                       titluc.cobcod   = 1
                       titluc.evecod   = 4
                       titluc.datexp   = today
                       titluc.titobs[1] = vobs[1]
                       titluc.titobs[2] = vobs[2].
                
                find last numaut where numaut.etbcod = setbcod no-error. 
                if avail numaut   
                then numaut.titnum = numaut.titnum + 1.   
                else do:
                    create numaut.
                    assign numaut.titnum = 1000000.
                end.
                
                find current numaut no-lock no-error.
                     
                titluc.titnum = string(numaut.titnum).
                
            end.

            find current titluc no-lock no-error.
            /**
            message "Criando despesa na matriz.....".

            connect fin -H erp.lebes.com.br -S sdrebfin -N tcp -ld 
                    finmatriz no-error.
   
            run cria-titluc.p (recid(titluc)).
                
            disconnect finmatriz.
                    
            hide message no-pause.
            */
        end.
    end.

    clear frame frame-a all no-pause.
    
    find foraut where foraut.forcod = titluc.clifor no-lock no-error.
    
    display titluc.clifor   column-label "Fornec" format ">>>>>>>9"
            foraut.fornom   format "x(20)" when avail foraut
            titluc.titnum   format "x(07)"
            titluc.titvlcob column-label "Valor" format ">>>,>>9.99"
            titluc.titdtven
            titluc.titdtpag
            titluc.vencod   column-label "Ven" format ">>9"
            titluc.titsit
                with frame frame-a 13 down centered.

    recatu1 = recid(titluc).
    
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat:
    
        find next titluc where titluc.titsit <> "PAG" and
                titluc.titdtven >= vdt-in 
                and titluc.etbcod = setbcod 
                and titluc.titnat = v-nat
                no-lock no-error.
        
        if not available titluc
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        down with frame frame-a.
        
        find foraut where foraut.forcod = titluc.clifor no-lock no-error.
        
        display titluc.clifor 
                foraut.fornom when avail foraut
                titluc.titnum
                titluc.titvlcob 
                titluc.titdtven 
                titluc.titdtpag 
                titluc.vencod
                titluc.titsit with frame frame-a.

    end.
    
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find titluc where recid(titluc) = recatu1 no-lock no-error.

        choose field titluc.clifor go-on(cursor-down cursor-up 
                                         cursor-left cursor-right 
                                         tab PF4 F4 ESC return).

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
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
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
        
            find next titluc where titluc.titsit <> "PAG" and
                        titluc.titdtven >= vdt-in 
                        and titluc.etbcod = setbcod 
                        and titluc.titnat = v-nat
                        no-lock no-error.
            if not avail titluc
            then next.
            
            color display normal titluc.clifor.
            
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.

        end.

        if keyfunction(lastkey) = "cursor-up"
        then do:
        
            find prev titluc where titluc.titsit <> "PAG" and
                            titluc.titdtven >= vdt-in 
                            and titluc.etbcod = setbcod
                            and titluc.titnat = v-nat 
                            no-lock no-error.
            if not avail titluc
            then next.
            
            color display normal titluc.clifor.
            
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
                       
                update vfordes label "Fornecedor" at 10.
                
                find foraut where foraut.forcod = vfordes no-lock no-error.
                if not avail foraut
                then do:
                    message "Fornecedor nao Cadastrado".
                    undo, retry.
                end.

                display foraut.fornom no-label.
                
                if foraut.autlp = no
                then do:
                    find lanaut where lanaut.etbcod = setbcod 
                                  and lanaut.forcod = foraut.forcod
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
                       
                vobs[1] = "" .  
                vobs[2] = "" .
                
                update vobs[1] no-label
                       vobs[2] no-label with frame f-obs side-label
                                    centered title "Observacoes".
                
                message "Confirma inclusao da Despesa" update sresp.
                if sresp = no
                then undo, retry.
            
                do transaction:
                    create titluc.
                    assign titluc.empcod = 19
                           titluc.modcod = foraut.modcod
                           titluc.clifor = foraut.forcod
                           titluc.titpar = 1
                           titluc.etbcod = setbcod
                           titluc.titnat = yes
                           titluc.titsit = "BLO"
                           titluc.titdtemi = today
                           titluc.titdtven = vtitdtven
                           titluc.titvlcob = vtitvlcob
                           titluc.cxacod   = scxacod
                           titluc.cobcod   = 1
                           titluc.evecod   = 4
                           titluc.datexp   = today
                           titluc.titobs[1] = vobs[1]
                           titluc.titobs[2] = vobs[2].
                
                    find last numaut where numaut.etbcod = setbcod no-error. 
                    if avail numaut   
                    then numaut.titnum = numaut.titnum + 1.   
                    else do:
                        create numaut.
                        assign numaut.titnum = 1000000.
                    end.    

                    find current numaut no-lock no-error.
                    
                    titluc.titnum = string(numaut.titnum).
                    
                    find current titluc no-lock no-error.
                    
                end.    
                /**
                message "Criando despesa na matriz.....". 
                connect fin -H erp.lebes.com.br -S sdrebfin -N tcp -ld 
                        finmatriz no-error.  
                
                run cria-titluc.p (recid(titluc)).   
                
                disconnect finmatriz.  
                
                hide message no-pause.       
                **/ 
                recatu1 = recid(titluc).
                leave.
            end.
            
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.

                if titluc.titsit = "BLO"
                then do:
                    assign vt-clifor    = titluc.clifor
                           vt-titdtven  = titluc.titdtven
                           vt-titvlcob  = titluc.titvlcob
                           vt-titobs[1] = titluc.titobs[1]
                           vt-titobs[2] = titluc.titobs[2].
                           
                    update vt-clifor
                           vt-titdtven
                           /*vt-titvlcob*/ with frame f-altera no-validate.
                    
                    update vt-titobs[1] no-label
                           vt-titobs[2] no-label with frame f-obs side-label
                                    centered title "Observacoes".
                                    
                    do transaction:    
                        find current titluc no-error.    
                        assign titluc.datexp    = today
                               titluc.clifor    = vt-clifor
                               titluc.titdtven  = vt-titdtven
                               titluc.titvlcob  = vt-titvlcob
                               titluc.titobs[1] = vt-titobs[1]
                               titluc.titobs[2] = vt-titobs[2].

                        find current titluc no-lock no-error.
                    end.
                    /**                                       
                    message "Alterando despesa na matriz.....".
                    connect fin -H erp.lebes.com.br -S sdrebfin -N tcp -ld 
                                        finmatriz no-error.
   
                    run alt-titluc.p (recid(titluc)).
                
                    disconnect finmatriz.
                    
                    hide message no-pause.                   
                    **/
                end.
            end.

            if esqcom1[esqpos1] = "Fornecedor"
            then do: 
                /**
                message "Conectando Matriz....".
                connect ger -H erp.lebes.com.br -S sdrebger -N tcp -ld germatriz no-error.
   
                run foraut_l.p.
                
                disconnect germatriz.
                    
                hide message no-pause.       
                **/
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp titluc.clifor
                     titluc.titnum
                     titluc.titdtemi
                     titluc.titdtven
                     titluc.titdtpag
                     titluc.titvlcob
                     titluc.cxacod
                     titluc.titsit with frame f-consulta no-validate.
                
                display titluc.titobs[1] no-label
                        titluc.titobs[2] no-label with frame f-obs1 side-label
                                    centered title "Observacoes".
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                
                if titluc.titsit <> "Pag"
                then do:
                    message "Confirma Exclusao de" titluc.titnum update sresp.
                    if not sresp
                    then undo.
                
                    find next titluc where 
                              titluc.titsit <> "PAG" and
                              titluc.titdtven >= vdt-in 
                              and titluc.etbcod = setbcod 
                              and titluc.titnat = v-nat
                              no-lock no-error.
                    if not available titluc
                    then do:
                        find titluc where recid(titluc) = recatu1 no-lock.
                        find prev titluc where  titluc.titsit <> "PAG" 
                                            and titluc.titdtven >= vdt-in
                                    and titluc.etbcod = setbcod
                                     and titluc.titnat = v-nat
                                  no-lock no-error.
                    end.

                    recatu2 = if available titluc
                              then recid(titluc)
                              else ?.
                    /**          
                    message "Excluindo despesa na matriz.....". 
                    connect fin -H erp.lebes.com.br -S sdrebfin -N tcp -ld
                            finmatriz no-error.  
                    
                    run exc-titluc.p (recatu1).  
                    
                    disconnect finmatriz.  
                    
                    hide message no-pause.       
                    **/
                    do transaction:
                        find titluc where recid(titluc) = recatu1.
                        
                        delete titluc.
                        
                        recatu1 = recatu2.
                    end.
                    
                    leave.
                end.
                else do:
                    message "Despesa ja paga, exclusao negada".
                    pause.
                    leave.
                end.
            end.

            if esqcom1[esqpos1] = "Pagamento"
            then do:
                if titluc.titsit = "lib"
                then do on error undo, retry:
                
                    assign vldes = 0 vljur = 0.
                    
                    update vldes label "Valor Desconto" at 1
                           vljur label "Valor Juros   " at 1
                           with frame f-pag side-label centered.
                        
                    vlpag = titluc.titvlcob - vldes + vljur.
                         
                    update vlpag label "Valor Pago    " at 1
                           with frame f-pag.

                    if vlpag < titluc.titvlcob
                    then vldes = titluc.titvlcob - vlpag.
                    else vljur = vlpag - titluc.titvlcob. 
                    
                    message "Confirma Pagamento da despesa" update sresp.
                    if sresp
                    then do:
                        
                        do transaction:
                            find current titluc no-error.
                            assign titluc.titdtpag = today
                                   titluc.titvlpag = vlpag
                                   titluc.titvljur = vljur
                                   titluc.titvldes = vldes
                                   titluc.etbcobra = setbcod
                                   titluc.datexp   = today
                                   titluc.cxacod   = scxacod
                                   titluc.titsit   = "pag".
                            find current titluc no-lock no-error.
                        end.
                        /**
                        message "Pagando despesa na matriz.....".
                        
                        find foraut where 
                             foraut.forcod = fin.titluc.clifor no-lock.
        
                        connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld                                         banfin no-error.
                        
                        connect fin -H erp.lebes.com.br -S sdrebfin -N tcp -ld 
                                        finmatriz no-error.
   
                        
                        run paga-titluc.p (recid(titluc)).
                
                
                        disconnect finmatriz.

                        if foraut.autlp = yes
                        then disconnect banfin.
                        
                        hide message no-pause.       
                       **/
                    
                    end.
                    
                end.
                else do:
                    message "Despesa nao autorizada".
                    pause.
                    undo, retry.
                end.
                leave.
            end.  
        end. 
        else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
        end.
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        find foraut where foraut.forcod = titluc.clifor 
                        no-lock no-error.
        display titluc.clifor 
                foraut.fornom when avail foraut
                titluc.titnum
                titluc.titvlcob
                titluc.titdtven
                titluc.titdtpag
                titluc.vencod
                titluc.titsit with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(titluc).
   end.
end.

