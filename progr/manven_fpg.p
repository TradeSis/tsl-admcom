{admcab.i}
{def.i}

def temp-table tttit 
    field titnum like titulo.titnum
    field rec as recid.
def temp-table tt-marca like titulo.
def var vmarca as char format "x".

def var v-lancactb as log.
def var v-confeve as logical format "Sim/Nao".
def var vdtveni  like titulo.titdtven.
def var vdtvenf  like titulo.titdtven.
def var vdata    like titulo.titdtven.
def var vfrecod  like frete.frecod.
def var vv as int.
def var vlfrete like plani.platot.
def var vfre as int format "9" initial 1.
def buffer ftitulo for titulo.
def buffer ztitulo for titulo.
def var vdt like plani.pladat.
def var vcompl like lancxa.comhis format "x(50)".
def var vlanhis like lancxa.lanhis.
def var vnumlan as int.
def buffer blancxa for lancxa.
def var vlancod like lancxa.lancod.
def var vl-juro as dec.
def var vl-desc as dec.
def var jur-titag as dec.
def var des-titag as dec.
def var qtd-titag as dec.
def var val-titag as dec.

esqcom1[1] = "Marca/Desmarca".
esqcom1[2] = "Marca/Des tudo".
esqcom1[3] = "Alteracao".
esqcom1[5] = "Altera Evento".
/*
esqcom2[4] = "Exclusao".
*/
esqpos1  = 1. esqpos2  = 1.


def var vad-modcod like modal.modcod.
def var vad-modnom like modal.modnom format "x(30)".
def buffer sel-modal for modal.
repeat:
    for each wtit:
        delete wtit.
    end.
    for each tttit.
        delete tttit.
    end.
    clear frame ff1 all.
    assign recatu1  = ?.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    update vdtveni colon 18 
           vdtvenf
        with frame ff1 width 80 side-label.
    
    vad-modnom = "".
    vad-modcod = "".
    update vad-modcod at 8 label "Modalidade" with frame ff1.
    if vad-modcod <> ""
    then do:
        find sel-modal where sel-modal.modcod = vad-modcod no-lock .
        vad-modnom = sel-modal.modnom.
        disp vad-modnom no-label with frame ff1.
        pause 0.
    end. 
    else do:
        vad-modnom = "TODAS AS MODALIDADES".
        disp vad-modnom with frame ff1.
        pause 0.
    end.       

    vtitnat = yes.
    
    for each estab no-lock:
        for each modal where (if vad-modcod <> ""
                              then modal.modcod = vad-modcod
                              else (modal.modcod <> "DEV"
                         and modal.modcod <> "BON"
                         and modal.modcod <> "CHP")) no-lock:
            do vdata = vdtveni to vdtvenf:
                for each titulo where titulo.empcod = wempre.empcod and
                                      titulo.titnat = vtitnat and
                                      titulo.modcod = modal.modcod and
                                      titulo.etbcod = estab.etbcod and
                                      titulo.titdtven = vdata no-lock.
                    if titulo.titsit = "PAG"
                    then next.
                                  
                    create tttit.
                    assign tttit.titnum = titulo.titnum 
                           tttit.rec    = recid(titulo).
                end.                          
            end.
        end.
    end.
    
def buffer btttit for tttit.

def var qt-marca as int.
def var vl-marca as dec.
disp "Vencimento: " no-label
     vdtveni no-label
     " A " no-label
     vdtvenf no-label
     "         Marcados: " qt-marca format ">>>9" 
     "  " vl-marca  format ">>,>>>,>>9.99"  skip
     "Modalidade: " at 1 no-label
     vad-modcod no-label
     vad-modnom no-label
"_______________________________________________________________________________
_" at 1
     with frame f-dispc 1 down no-box row 3 color message width 80
     no-label 
     .
pause 0.
for each tt-marca.
    delete tt-marca.
end.    
bl-princ:
repeat :
    disp esqcom1 with frame f-com1 centered row 6.
    disp esqcom2 with frame f-com2.
    pause 0.
    if  recatu1 = ?
    then find first tttit where true no-error.
    else find first tttit where recid(tttit) = recatu1.
    vinicio = no.
    if  not available tttit 
    then do:
        message "Nenhum titulo para pagar nesta data".
        leave bl-princ.
    end.
    clear frame frame-a all no-pause.
    view frame ff.
    find titulo where recid(titulo) =  tttit.rec NO-LOCK.
    find tt-marca of titulo no-lock no-error.
    if avail tt-marca
    then vmarca = "*". else vmarca = "".
    run desconto-antecipacao.
    if titulo.titsit = "PAG"
    then assign 
            vtitvljur = titulo.titvljur 
            vtitvldes = titulo.titvldes .
    else assign 
            vtitvljur = titulo.titvljur + vl-juro
            vtitvldes = titulo.titvldes + vl-desc .
    display vmarca no-label format "x"
            titulo.etbcod format ">>9" column-label "Fl"
            tttit.titnum format "x(7)"
            titulo.titpar   format ">9"
        titulo.titvlcob format ">>>,>>9.99" column-label "Vl.Cobrado"
        titulo.titdtven format "99/99/99"   column-label "Dt.Vecto"
        titulo.titdtpag format "99/99/99"   column-label "Dt.Pagto"
        titulo.titvlpag when titulo.titvlpag > 0 format ">>>,>>9.99"
                                            column-label "Valor Pago"
        vtitvljur  column-label "Juros" format ">>>,>>9.9"
        vtitvldes  column-label "Desc"  format ">>>,>>9.9"
        titulo.titsit column-label "S" format "X"
            with frame frame-a 9 down centered color white/red width 80.
            
    recatu1 = recid(tttit).
    if  esqregua then do:
        display esqcom1[esqpos1] with frame f-com1.
        color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
        find next tttit where true no-error.
        if not available tttit
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if not vinicio
        then down with frame frame-a.
        view frame ff.
        find titulo where recid(titulo) = tttit.rec NO-LOCK.
        find tt-marca of titulo no-lock no-error.
        if avail tt-marca
        then vmarca = "*" . else vmarca = "".
        run desconto-antecipacao.
        if titulo.titsit = "PAG"
        then assign 
            vtitvljur = titulo.titvljur 
            vtitvldes = titulo.titvldes .
        else assign 
            vtitvljur = titulo.titvljur + vl-juro
            vtitvldes = titulo.titvldes + vl-desc .
        display vmarca
                titulo.etbcod
                tttit.titnum
                titulo.titpar
                titulo.titvlcob
                titulo.titdtven
                titulo.titdtpag
                titulo.titvlpag when titulo.titvlpag > 0
                vtitvljur 
                vtitvldes 
                titulo.titsit with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
        
        find first tttit where recid(tttit) = recatu1 no-error.
        find titulo where recid(titulo) = tttit.rec NO-LOCK no-error.
        /*
        color display messages tttit.titnum.
        */
        
        on f7 recall.
        choose field tttit.titnum 
            go-on(cursor-down cursor-up cursor-left cursor-right F7 PF7
                  page-up page-down tab PF4 F4 ESC return v V ).
        if  keyfunction(lastkey) = "RECALL"
        then do with frame fproc centered row 5  
                                overlay color message side-label:
            update vtitnum colon 10.
            find first tttit where tttit.titnum = vtitnum no-error.
            if not avail tttit
            then do:
                message "Titulo nao existe com este numero".
                next.
            end.
            else do:   
                find first titulo where recid(titulo) = tttit.rec NO-LOCK.
                recatu1 = recid(tttit). leave.
            end.
        end. on f7 help.
        
        if  keyfunction(lastkey) = "TAB" then do:
            if  esqregua then do:
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
        if keyfunction(lastkey) = "cursor-right" then do:
            if  esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 3
                          then 3
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left" then do:
            if esqregua then do:
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
        
        if keyfunction(lastkey) = "cursor-down" then do:
            find next tttit where true no-error.
            find titulo where recid(titulo) = tttit.rec no-lock no-error.
            if not avail titulo
            then next.
            color display white/red tttit.titnum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.   
        if  keyfunction(lastkey) = "cursor-up" then do:
            find prev tttit where true.
            find titulo where recid(titulo) = tttit.rec no-lock no-error.
            if not avail titulo
            then next.
            color display white/red tttit.titnum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            find first tt-marca no-error.
            if avail tt-marca
            then do:
                sresp = no.
                message "Exitem titulos marcados. Deseja realmete sair ?"
                update sresp.
                if not sresp
                then do:
                    recatu1 = ?.
                    next bl-princ.
                end.
            end.
            leave bl-princ.
        end.
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
          if esqcom2[esqpos2] <> "Pagamento/Cancelamento" or
             esqcom2[esqpos2] <> "Bloqueio/Liberacao"
          then hide frame frame-a no-pause.
         /*
          display vcliforlab at 6 vclifornom
                with frame frame-b 1 down centered color blue/gray
                width 81 no-box no-label row 5 overlay.
         */
          if  esqregua 
          then do:
            if esqcom1[esqpos1] = "Marca/Desmarca"
            then do :
                if titulo.titsit <> "LIB" and 
                   titulo.titsit <> "IMP" and
                   titulo.titsit <> "CON"
                then do:
                    message color red/with
                     "Situacao " titulo.titsit " nao permite pagamento."
                     view-as alert-box.
                    next bl-princ. 
                end.   
                
                if today >= 09/01/13
                then do:
                    run ver-lancactb.
                    if v-lancactb = no
                    then next bl-princ.
                end.
                find first tt-marca of titulo no-error.
                if not avail tt-marca
                then do:
                    create tt-marca.
                    buffer-copy titulo to tt-marca.
                    vmarca = "*".
                    qt-marca = qt-marca + 1.
                    vl-marca = vl-marca + 
                       ((titulo.titvlcob + titulo.titvljur) - titulo.titvldes).
                end.
                else do:
                    delete tt-marca.
                    vmarca = "".
                    qt-marca = qt-marca - 1.
                    vl-marca = vl-marca - 
                       ((titulo.titvlcob + titulo.titvljur) - titulo.titvldes).
                    .
                end.
                disp qt-marca  vl-marca with frame f-dispc.
                leave.
            end.
            if esqcom1[esqpos1] = "Marca/Des tudo"
            then do :
                find first tt-marca no-error.
                if avail tt-marca
                then do:
                    for each tt-marca:
                        delete tt-marca.
                    end.    
                    vmarca = "*".
                    qt-marca = 0.
                    vl-marca = 0.
                end.
                else
                for each btttit no-lock,
                    first titulo where recid(titulo) =  btttit.rec NO-LOCK.
                    if  titulo.titsit <> "LIB" and 
                        titulo.titsit <> "IMP" and
                        titulo.titsit <> "CON"
                    then next.

                    if today >= 09/01/13
                    then do:
                        run ver-lancactb.
                        if v-lancactb = no
                        then next bl-princ.
                    end.
                    find first tt-marca of titulo no-error.
                    if not avail tt-marca
                    then do:
                        create tt-marca.
                        buffer-copy titulo to tt-marca.
                        vmarca = "*".
                        qt-marca = qt-marca + 1.
                        vl-marca = vl-marca + ((titulo.titvlcob + 
                                    titulo.titvljur) - titulo.titvldes).

                    end.
                end.
                disp qt-marca  vl-marca with frame f-dispc.
                leave.
            end.

            if esqcom1[esqpos1] = "Alteracao"
            then do ON ERROR UNDO with frame ftitulo:
                find titulo where recid(titulo) = tttit.rec.
                vtitvlcob = titulo.titvlcob.
                titulo.datexp = today.
                hide frame f-senha no-pause.
                hide frame f-fre2 no-pause.
                update titulo.clifor column-label "Fornecedor"
                       titulo.titnum
                       titulo.titpar
                       titulo.titdtemi
                       titulo.titdtven
                       titulo.titvlcob
                       titulo.cobcod with no-validate.
                find cobra where cobra.cobcod = titulo.cobcod NO-LOCK.
                display cobra.cobnom.
                if cobra.cobban
                then do with frame fbanco:
                    update titulo.bancod.
                    find banco where banco.bancod = titulo.bancod NO-LOCK.
                    display banco.bandesc .
                    update titulo.agecod.
                    find agenc of banco where agenc.agecod = titulo.agecod
                               NO-LOCK.
                    display agedesc.
                end.
                update titulo.modcod colon 15.
                find modal where modal.modcod = titulo.modcod no-lock.
                display modal.modnom no-label.
                update titulo.evecod colon 15.
                find event where event.evecod = titulo.evecod no-lock.
                display event.evenom no-label.
                run desconto-antecipacao.
                if titulo.titsit = "PAG"
                then assign 
                        vtitvljur = titulo.titvljur 
                        vtitvldes = titulo.titvldes .
                else assign 
                        vtitvljur = titulo.titvljur + vl-juro
                        vtitvldes = titulo.titvldes + vl-desc .
                update vtitvljur with frame fjurdes .
                /*update titulo.titdtdes with frame fjurdes.*/
                update vtitvldes format ">>>,>>9.99"
                        with frame fjurdes.
                assign
                    titulo.titvljur = vtitvljur
                    titulo.titvldes = vtitvldes.    

                update text(titulo.titobs) with frame fobs.
                if  titulo.titvlcob <> vtitvlcob then do:
                   if  titulo.titvlcob < vtitvlcob then do:
                    assign sresp = yes.
                    display "  Confirma GERACAO DE NOVO TITULO ?"
                                with frame fGERT color messages
                                width 60 overlay row 10 centered.
                    update sresp no-label with frame fGERT.
                    if  sresp then do:
                        find last btitulo where
                            btitulo.empcod   = wempre.empcod and
                            btitulo.titnat   = vtitnat       and
                            btitulo.modcod   = vmodcod       and
                            btitulo.etbcod   = titulo.etbcod       and
                            btitulo.clifor   = titulo.clifor       and
                            btitulo.titnum   = titulo.titnum.
                            create ctitulo.
                            assign ctitulo.empcod = btitulo.empcod
                                   ctitulo.modcod = btitulo.modcod
                                   ctitulo.clifor = btitulo.clifor
                                   ctitulo.titnat = btitulo.titnat
                                   ctitulo.etbcod = btitulo.etbcod
                                   ctitulo.titnum = btitulo.titnum
                                   ctitulo.cobcod = titulo.cobcod
                                   ctitulo.titpar   = btitulo.titpar + 1
                                   ctitulo.titdtemi = today
                                   ctitulo.titdtven = titulo.titdtven
                                  ctitulo.titvlcob = vtitvlcob - titulo.titvlcob
                                   ctitulo.titnumger = titulo.titnum
                                   ctitulo.titparger = titulo.titpar
                                   ctitulo.datexp    = today.
                            display ctitulo.titnum
                                    ctitulo.titpar
                                    ctitulo.titdtemi
                                    ctitulo.titdtven
                                    ctitulo.titvlcob
                                    with frame fmos width 40 1 column
                                              title " Titulo Gerado " overlay
                                              centered row 10.
                            recatu1 = recid(ctitulo).
                            leave.
                        end.
                     end.
                     else do:
                        display "  Confirma AUMENTO NO VALOR DO TITULO?"
                                with frame faum color messages
                                width 60 overlay row 10 centered.
                        update sresp no-label with frame faum.
                        if not sresp then undo, leave.
                    end.
                end.
                message "Confirma Titulo" update sresp.
                if sresp
                then do on error undo:
                    for each ztitulo use-index iclicod where
                                            ztitulo.clifor = titulo.clifor and
                                            ztitulo.titnat = yes no-lock:
                        if ztitulo.titnum begins "A"
                        then do:
                            display ztitulo.etbcod
                                    ztitulo.titnum
                                    ztitulo.titpar
                                    ztitulo.titdtven
                                    ztitulo.titdtpag
                                    ztitulo.titvlpag  
                                        with frame f-alerta down
                                                centered overlay row 10
                                                    color black/yellow.
                            pause.
                        end.
                    end.                       
                    hide frame f-alerta no-pause.
                    vv = 0.
                    update vfre label "Frete" with frame f-fre2
                            centered side-label row 8.
                    if vfre = 2
                    then do:
                        vv = 0.            
                        for each ftitulo use-index cxmdat where 
                                        ftitulo.etbcod = titulo.etbcod and
                                        ftitulo.cxacod = titulo.clifor and
                                        ftitulo.titnumger = 
                                                        string(titulo.titnum) 
                                          no-lock.
                            find first frete where frete.forcod = 
                                                        ftitulo.clifor
                                                                    no-lock.
                            display ftitulo.etbcod
                                    ftitulo.titdtven
                                    ftitulo.titnum column-label "Conhec."
                                                 format "x(10)"
                                    ftitulo.titnumger column-label "NF.Fiscal"
                                                 format "x(07)"
                                    frete.frenom format "x(20)"
                                    ftitulo.titvlcob column-label "Vl.Cobrado" 
                                           with frame ffrete2 1 down row 15
                                            width 80 centered color white/cyan.
                            vv = vv + 1.
                            pause.
                        end.    
                        if vv = 0
                        then do:
                            update  vfrecod with frame f-frete22.
                            find frete where frete.frecod = vfrecod no-lock.
                            display frete.frenom no-label with frame f-frete22.
                            vlfrete = 0.
                            update vlfrete label "Valor Frete"
                                        with frame f-frete22.

                            create btitulo.
                            assign btitulo.etbcod   = titulo.etbcod
                                   btitulo.titnat   = yes
                                   btitulo.modcod   = "FRE"
                                   btitulo.clifor   = frete.forcod
                                   btitulo.cxacod   = titulo.clifor
                                   btitulo.titsit   = "lib"
                                   btitulo.empcod   = titulo.empcod
                                   btitulo.titdtemi = titulo.titdtemi
                                   btitulo.titnum   = titulo.titnum
                                   btitulo.titpar   = 1
                                   btitulo.titnumger = titulo.titnum
                                   btitulo.titvlcob = vlfrete.
                                   
                            update btitulo.titdtven label "Venc.Frete"
                                   btitulo.titnum   label "Controle"
                                with frame f-frete22 centered color white/cyan
                                                side-label row 15 no-validate.

                        end.    
                            
                    end. 
                    hide frame ffrete2 no-pause.
                    
                    vsenha = "".
                    update vfunc
                           vsenha blank
                           with frame f-senha side-label overlay centered.
                    if vfunc <> 29 and
                       vfunc <> 30
                    then do:
                        message "Funcionario nao autorizado".
                        undo, retry.
                    end.
                    find func where func.etbcod = 999 and
                                    func.funcod = vfunc and
                                    func.senha  = vsenha no-lock no-error.
                    if not avail func
                    then do:
                        message "Senha Invalida".
                        undo, retry.
                    end.
                    if titulo.titsit = "CON"
                    then titulo.titsit = "LIB".
                    else titulo.titsit = "CON".
                    
                    message "Confirma Frete" update sresp.
                    if sresp
                    then do:
                        for each btitulo use-index cxmdat where 
                                   btitulo.etbcod    = titulo.etbcod and
                                   btitulo.cxacod    = titulo.clifor and
                                   btitulo.titnumger = string(titulo.titnum): 
                        
                            if btitulo.titsit = "CON"
                            then btitulo.titsit = "LIB".
                            else btitulo.titsit = "CON".

                        end.
                    end.
                end.
            end.
            if esqcom1[esqpos1] = "Consulta" or esqcom2[esqpos2] = "Exclusao"
            then do:
                find titulo where recid(titulo) = tttit.rec NO-LOCK.
                find modal of titulo no-lock no-error.
                disp titulo.modcod
                     modal.modnom when available modal no-label
                     titulo.titnum
                     titulo.titpar
                     titulo.titdtemi
                     titulo.titdtven
                     titulo.titvlcob
                     titulo.cobcod with frame ftitulo.
                run desconto-antecipacao.
                if titulo.titsit = "PAG"
                then assign 
                        vtitvljur = titulo.titvljur 
                        vtitvldes = titulo.titvldes .
                else assign 
                        vtitvljur = titulo.titvljur + vl-juro
                        vtitvldes = titulo.titvldes + vl-desc .
                disp vtitvljur 
                     /*titulo.titjuro
                     titulo.titdtdes*/
                     vtitvldes 
                     titulo.titdtpag
                     titulo.titvlpag with frame fjurdes.
            end.
            if esqcom2[esqpos2] = "Exclusao"
            then do ON ERROR UNDO
                    with frame f-exclui overlay row 6 1 column centered.
                find titulo where recid(titulo) = tttit.rec NO-LOCK.
                if titulo.titsit = "CON"
                then do:
                    message "Titulo nao pode ser excluido". pause.
                    undo, retry.
                end.
                message "Confirma Exclusao de Titulo"
                            titulo.titnum ",Parcela" titulo.titpar
                update sresp.
                if not sresp
                then leave.
                find next tttit where true.
                if not available tttit
                then do:
                    find tttit where recid(tttit) = recatu1.
                    find prev tttit where true.
                end.
                recatu2 = if available tttit
                          then recid(tttit)
                          else ?. 
                find tttit where recid(tttit) = recatu1.
                find titulo where recid(titulo) = tttit.rec.
                delete tttit.
                delete titulo.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Altera Evento"
            then do:
                update vevecod label "Cod.Evento" 
                    with frame fpedeve centered row 19 side-labels overlay.
                find first event where event.evecod = vevecod no-lock no-error.
                if not avail event 
                then do:
                    message "Evento Invalido" view-as alert-box.
                    undo, retry.
                end.
                display event.evenom no-label with frame fpedeve.
                pause 0.
                message "Confirma Alteracao em Marcados e Liberados ?"
                        update v-confeve .
                hide frame fpedeve.
                pause 0.
                if v-confeve = yes
                then run Altera-Evento-marcados.
                leave.
            end.
          end.
          else do:
            hide frame f-com2 no-pause.
            /********************************/
            
            if  esqcom2[esqpos2] = "Pagamento/Cancelamento"
            then do ON ERROR UNDO: 
                find first tt-marca no-error.
                if not avail tt-marca
                then do:
                    bell.
                    message color red/with
                    "Favor marcar o(s) titulo(s) para pagamento."
                    view-as alert-box.
                    undo, leave.
                end.

                message "Confirma Pagamento/Cancelamento ?" update sresp.
                if not sresp
                then undo, leave.
                find titulo where recid(titulo) = tttit.rec.
                
              find first tt-marca no-error.
              if avail tt-marca
              then do:
                run paga-marcados. 
                recatu1 = ?.  
                next bl-princ.
              end.
              
              if titulo.titsit = "LIB" or
                 titulo.titsit = "IMP" or
                 titulo.titsit = "CON"
              then do with frame f-Paga overlay row 6 1 column centered.
                 run desconto-antecipacao.
                 if titulo.titsit = "PAG"
                 then assign 
                        vtitvljur = titulo.titvljur 
                        vtitvldes = titulo.titvldes .
                else assign 
                        vtitvljur = titulo.titvljur + vl-juro
                        vtitvldes = titulo.titvldes + vl-desc .
                 display titulo.titnum    colon 13
                        titulo.titpar    colon 33 label "Pr"
                        titulo.titdtemi  colon 13
                        titulo.titdtven  colon 13
                        titulo.titvlcob  colon 13 label "Vl.Cobr."
                        vtitvljur colon 13 label "Vl.Juro"
                        vtitvldes format ">>>,>>9.99"
                                colon 13 label "Vl.Desc"
                        with frame fdadpg side-label
                        overlay row 6 color white/cyan width 40
                        title " Titulo ".
                 titulo.datexp = today.
               if titulo.modcod = "CRE"
               then do:
                   {titpagb4.i}
                   update titulo.titvljur  colon 13 label "Vl.Juro"
                          titulo.titvldes  colon 13 label "Vl.Desc"
                                format ">>>,>>9.99"
                                            with frame fdadpg side-label
                                    overlay row 6 color white/cyan width 40
                                          title " Titulo " no-validate.
               end.
               else do:
                   hide frame lanca no-pause.
                   run desconto-antecipacao.
                   if titulo.titsit = "PAG"
                   then assign 
                            vtitvljur = titulo.titvljur 
                            vtitvldes = titulo.titvldes .
                    else assign 
                            vtitvljur = titulo.titvljur + vl-juro
                            vtitvldes = titulo.titvldes + vl-desc .
                   assign titulo.titdtpag = today.
                   display titulo.titdtdes colon 13 label "Dt.Desc"
                           vtitvldes  colon 13 label "Vl.Desc"
                                           format ">>>,>>9.99"
                           vtitvljur  colon 13 label "Vl.Juro"
                                      with frame fdadpg.
                update titulo.titdtpag validate(titulo.titdtpag >= today - 30,
                            "Data de Pagamento Invalida.") 
                            with frame fpag1.
                assign   
                    titulo.titvlpag = titulo.titvlcob + vtitvljur - vtitvldes
                    vtitvlpag = titulo.titvlpag.
                update titulo.titvlpag with frame fpag1.
                update titulo.cobcod with frame fpag1.
                update vtitvljur column-label "Juros"
                       vtitvldes format ">>>,>>9.99"
                            with frame fpag1 no-validate.
                assign
                    titulo.titvljur = vtitvljur
                    titulo.titvldes = vtitvldes.
                
                titulo.titvlpag = titulo.titvlcob + titulo.titvljur -
                                  titulo.titvldes.
                
                vlancod = 0.
                if vtitnat = yes
                then do on error undo, retry:
                    hide frame ff no-pause.
                    hide frame ff1 no-pause.
                    hide frame fdadpg no-pause.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame ftitulo no-pause.
                    hide frame ftit    no-pause.
                    hide frame ftit2   no-pause.
                    hide frame fbancpg no-pause.
                    hide frame fbanco  no-pause.
                    hide frame fbanco2 no-pause.
                    hide frame fjurdes no-pause.
                    hide frame fjurdes2 no-pause.
                    hide frame fobs2  no-pause.
                    hide frame fobs   no-pause.
                    hide frame fpag1  no-pause.

                    find forne where forne.forcod = titulo.clifor 
                                        no-lock no-error.
                    vlancod = titulo.vencod.
                    vlanhis = titulo.titparger.
                    vcompl  = titulo.titnumger.

                    if titulo.modcod = "DUP"
                    then assign vlancod = 100
                                vlanhis = 1
                                vcompl  = titulo.titnum 
                                        + "-" + string(titulo.titpar)
                                        + " " + forne.fornom.
                    else do:
                        find last blancxa where blancxa.forcod = forne.forcod
                                            and  blancxa.etbcod = titulo.etbcod
                                            and  blancxa.lantip = "C"
                                            no-lock no-error.
                        if avail blancxa
                        then assign vlancod = blancxa.lancod
                                    vlanhis = blancxa.lanhis
                                    vcompl  = blancxa.comhis.
   
                        if vclifor = 533 
                        then vlanhis = 5.
                    
                        if vclifor = 100071 
                        then vlanhis = 4.

                        if vclifor = 100072 
                        then vlanhis = 3.

                        find lanaut where lanaut.etbcod = titulo.etbcod and
                                          lanaut.forcod = titulo.clifor
                                                    no-lock no-error.
                        if avail lanaut 
                        then
                            assign vlanhis = lanaut.lanhis
                                   vcompl  = lanaut.comhis
                                   vlancod = lanaut.lancod.

                        if vcompl  = "" or
                           vlancod = 0  or
                           vlanhis = 0
                        then

                        update vlancod label "Lancamento"
                               vlanhis label "Historico" format ">99"
                               vcompl  label "Complemento"
                                    with frame lanca centered side-label
                                            row 15 overlay.
                    end.
                    
                    if vclifor = 533
                    then vlanhis = 5.
                    
                    if vclifor = 100071
                    then vlanhis = 4.

                    if vclifor = 100072
                    then vlanhis = 3.

                    find lanaut where lanaut.etbcod = titulo.etbcod and
                                      lanaut.forcod = titulo.clifor
                                                no-lock no-error.
                    if avail lanaut 
                    then
                        assign vlanhis = lanaut.lanhis
                               vcompl  = lanaut.comhis
                               vlancod = lanaut.lancod.
     
                    if vlanhis = 6
                    then vcompl = "".
                    
                    if vlancod <> 0 and vtitnat = yes
                    then do:
                        find tablan where tablan.lancod = vlancod 
                                                    no-lock no-error.
                        if not avail tablan
                        then do:
                            message "Lancamento nao cadastrado".
                            undo, retry.
                        end.
                        display tablan.landes no-label with frame lanca.
                        
                        vlancod = tablan.codred.
                        
                        find last blancxa no-lock no-error.
                        if not avail blancxa
                        then vnumlan = 1.
                        else vnumlan = blancxa.numlan + 1.
                        create lancxa.
                        assign lancxa.cxacod = 13
                               lancxa.datlan = titulo.titdtpag
                               lancxa.lancod = vlancod
                               lancxa.numlan = vnumlan
                               lancxa.vallan = titulo.titvlcob
                               lancxa.comhis = vcompl
                               lancxa.lantip = "C"
                               lancxa.forcod = titulo.clifor
                               lancxa.titnum = titulo.titnum
                               lancxa.etbcod = titulo.etbcod
                               lancxa.modcod = titulo.modcod
                               lancxa.lanhis = vlanhis.
                        
                        find forne where forne.forcod = titulo.clifor 
                                        no-lock no-error.
                            
                        if lancxa.lanhis = 1
                        then lancxa.comhis = titulo.titnum + " " + forne.fornom.
                        
                        find lanaut where lanaut.etbcod = titulo.etbcod and
                                          lanaut.forcod = titulo.clifor
                                                no-lock no-error.
                        if avail lanaut
                        then do:
                            assign lancxa.lanhis = lanaut.lanhis
                                   lancxa.comhis = lanaut.comhis 
                                   lancxa.lancod = lanaut.lancod.
                        end.
                                
                        if titulo.titvljur > 0 and vtitnat = yes
                        then do:
                            find last lancxa no-lock no-error.
                            if not avail lancxa
                            then vnumlan = 1.
                            else vnumlan = lancxa.numlan + 1.
                            create blancxa.
                            ASSIGN blancxa.cxacod = 13
                                   blancxa.datlan = titulo.titdtpag
                                   blancxa.lancod = 110
                                   blancxa.numlan = vnumlan
                                   blancxa.vallan = titulo.titvljur
                                   blancxa.comhis = vcompl
                                   blancxa.lantip = "C"
                                   blancxa.forcod = titulo.clifor
                                   blancxa.titnum = titulo.titnum
                                   blancxa.etbcod = titulo.etbcod
                                   blancxa.modcod = titulo.modcod
                                   blancxa.lanhis = 13.
                        end.    
                        
                        if titulo.titvldes > 0 and vtitnat = yes
                        then do:
                            find last lancxa no-lock no-error.
                            if not avail lancxa
                            then vnumlan = 1.
                            else vnumlan = lancxa.numlan + 1.
                            create blancxa.
                            if titulo.clifor = 100090
                            then find tablan where tablan.lancod = 111 no-lock.
                            else find tablan where tablan.lancod = 439 no-lock.
                            ASSIGN blancxa.cxacod = 13
                                   blancxa.datlan = titulo.titdtpag
                                   blancxa.lancod = tablan.lancod
                                   blancxa.numlan = vnumlan
                                   blancxa.vallan = titulo.titvldes
                                   blancxa.comhis = vcompl
                                   blancxa.lantip = "D"
                                   blancxa.forcod = titulo.clifor
                                   blancxa.titnum = titulo.titnum
                                   blancxa.etbcod = titulo.etbcod
                                   blancxa.modcod = titulo.modcod
                                   blancxa.lanhis = tablan.lanhis.
                            
                            if tablan.lanhis = 12
                            then blancxa.comhis = 
                                 titulo.titnum + " " + forne.fornom.
                        end.    
                    end.
                    else do:
                        message "Lancamento nao cadastrado".
                        undo, retry.
                    end.
                end.
                hide frame lanca no-pause.
  
                if titulo.titvlpag >= titulo.titvlcob
                then. /* titulo.titjuro = titulo.titvlpag - titulo.titvlcob. */
                else do:
                   assign sresp = no.
                   display "  Confirma PAGAMENTO PARCIAL ?"
                     with frame fpag color messages
                                width 40 overlay row 10 centered.
                    update sresp no-label with frame fpag.
                    if  sresp then do:
                        find last btitulo where
                            btitulo.empcod   = wempre.empcod and
                            btitulo.titnat   = vtitnat       and
                            btitulo.modcod   = vmodcod       and
                            btitulo.etbcod   = vetbcod       and
                            btitulo.clifor   = vclifor       and
                            btitulo.titnum   = titulo.titnum.
                            create ctitulo.
                            assign 
                                ctitulo.exportado = yes
                                ctitulo.empcod = btitulo.empcod
                                ctitulo.modcod = btitulo.modcod
                                ctitulo.clifor = btitulo.clifor
                                ctitulo.titnat = btitulo.titnat
                                ctitulo.etbcod = btitulo.etbcod
                                ctitulo.titnum = btitulo.titnum
                                ctitulo.cobcod = titulo.cobcod
                                ctitulo.titpar   = btitulo.titpar + 1
                                ctitulo.titdtemi = titulo.titdtemi
                                ctitulo.titdtven = if titulo.titdtpag <
                                                      titulo.titdtven
                                                   then titulo.titdtven
                                                   else titulo.titdtpag
                                ctitulo.titvlcob = vtitvlpag - titulo.titvlpag
                                ctitulo.titnumger = titulo.titnum
                                ctitulo.titparger = titulo.titpar
                                ctitulo.datexp    = today
                                 titulo.titnumger = ctitulo.titnum
                                 titulo.titparger = ctitulo.titpar.
                            display ctitulo.titnum
                                    ctitulo.titpar
                                    ctitulo.titdtemi
                                    ctitulo.titdtven
                                    ctitulo.titvlcob
                                    with frame fmos width 40 1 column
                                              title " Titulo Gerado " overlay
                                              centered row 10.
                        end.
                        else titulo.titdesc = titulo.titvlcob - titulo.titvlpag.
                end.
                assign titulo.titsit = "PAG".
                {ctb01.i}
               end.
               recatu1 = recid(tttit).
               leave.
              end.
              else
                if titulo.titsit = "PAG"
                then do:
                display titulo.titnum
                        titulo.titpar
                        titulo.titdtemi
                        titulo.titdtven
                        titulo.titvlcob
                        titulo.cobcod with frame ftitulo.
                    titulo.datexp = today.
                    titulo.cxmdat = ?.
                    titulo.cxacod = 0.
                    display titulo.titdtpag titulo.titvlpag titulo.cobcod
                            with frame fpag1.
                    message "Pagemento ja efetuado ". pause.
                    undo, retry.
                    /*******
                    message "Confirma o Cancelamento do Pagamento ?"
                            update sresp.
                    if sresp then do:
                        for each lancxa where lancxa.datlan = titulo.titdtpag
                                        and   lancxa.forcod = titulo.clifor 
                                        and   lancxa.titnum = titulo.titnum
                                        and   lancxa.lancod = titulo.vencod:
                            delete lancxa.
                        end.
                        assign titulo.titsit  = "LIB"
                               titulo.titdtpag  = ?
                               titulo.titvlpag  = 0
                               titulo.titbanpag = 0
                               titulo.titagepag = ""
                               titulo.titchepag = ""
                               titulo.titvljur  = 0
                               titulo.datexp    = today.
                        find first b-titu where
                                   b-titu.empcod    =  titulo.empcod and
                                   b-titu.titnat    =  titulo.titnat and
                                   b-titu.modcod    =  titulo.modcod and
                                   b-titu.etbcod    =  titulo.etbcod and
                                   b-titu.clifor    =  titulo.clifor and
                                   b-titu.titnum    =  titulo.titnum and
                                   b-titu.titpar    <> titulo.titpar and
                                   b-titu.titparger =  titulo.titpar
                                   no-lock no-error.
                        if  avail b-titu then do:
                        display "Verifique Titulo Gerado do Pagamento Parcial"
                                with frame fver color messages
                                width 50 overlay row 10 centered.
                            pause.
                        end.
                   
                    end.
                    recatu1 = recid(tttit).
                    next bl-princ.
                    ****/
                end.
            end.

            /********************************/
            /*
            if esqcom2[esqpos2]  = "Bloqueio/Liberacao" and
               titulo.titsit    <> "PAG"
            then do ON ERROR UNDO:
                find current titulo.
                if titulo.titsit <> "BLO"
                then do:
                    message "Confirma o Bloqueio do Titulo ?" update sresp.
                    if  sresp then do:
                        titulo.titsit = "BLO".
                        titulo.datexp = today.
                    end.
                end.
                else
                    if titulo.titsit = "BLO"
                    then do:
                        message "Confirma a Liberacao do Titulo ?" update sresp.
                        if  sresp then do:
                            titulo.titsit = "LIB".
                            titulo.datexp = today.
                        end.
                     end.
            end.
            */
          end.
          view frame frame-a.
          view frame f-com2 .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        find titulo where recid(titulo) = tttit.rec NO-LOCK.
        find tt-marca of titulo no-lock no-error.
        if avail tt-marca
        then vmarca = "*" . else vmarca = "".
        run desconto-antecipacao.
        if titulo.titsit = "PAG"
        then assign vtitvljur = titulo.titvljur
               vtitvldes = titulo.titvldes .
        else assign vtitvljur = titulo.titvljur + vl-juro
               vtitvldes = titulo.titvldes + vl-desc .
        display vmarca
                titulo.etbcod
                tttit.titnum
                titulo.titpar
                titulo.titvlcob
                titulo.titdtven
                titulo.titdtpag
                titulo.titvlpag when titulo.titvlpag > 0
                vtitvljur
                vtitvldes
                titulo.titsit with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tttit).
   end.
end.
end.

procedure Altera-Evento-Marcados:

    for each tt-marca:
        message 
            "Alterando Evento de Marcados e Liberados....>>> " tt-marca.titnum.
        pause 0.
        find titulo where 
             titulo.empcod = tt-marca.empcod and
             titulo.titnat = tt-marca.titnat and
             titulo.modcod = tt-marca.modcod and
             titulo.etbcod = tt-marca.etbcod and
             titulo.clifor = tt-marca.clifor and
             titulo.titnum = tt-marca.titnum and
             titulo.titpar = tt-marca.titpar
             no-lock no-error.
        
        if titulo.titsit <> "L"
        then do:
            message "Titulo" titulo.titnum "com Situacao diferente de 'L' !!"
            view-as alert-box.
            next. 
        end.
        if avail titulo and titulo.titsit = "L"
        then assign tt-marca.evecod = vevecod
                    titulo.evecod   = vevecod.
    end.
end procedure.


procedure paga-marcados:
    def var vtitdtpag like titulo.titdtpag.
    def var vtitvlpag like titulo.titvlpag.
    def var vtotalpag like titulo.titvlpag.
    def var vformpaga as int.
    vtitdtpag = today.
    do on error undo:
    update vtitdtpag label "Data de Pagamento" 
                            validate(vtitdtpag >= (today - 30 /*7*/),
                                     "Data de Pagamento Invalida.").
    if vtitdtpag = ?
    then undo.
    for each formpag where formpag.tipo = "" no-lock:
        disp string(formpag.codigo,">>>>>>>>9") + " - " + formpag.descricao 
                format "x(30)"
            with frame f-formpag down
            column 35 no-label width 35
            title " FORMAS DE PAGAMENTO ".
    end.
    update vformpaga label "Pagamento"
    help "Informe o codigo fa FORMA DE PAGAMENTO".        
    find first formpag where
               formpag.tipo = "" and
               formpag.codigo = vformpaga
               no-lock no-error.
    if not avail formpag
    then do:
        message color red/with
               "Forma de pagamento nao cadastrada."
               view-as alert-box
               .
        undo.
    end.           
    if avail formpag and
       vtitdtpag <> ?
    then do:   
    vtotalpag = 0.
    for each tt-marca:
        message "Totalizando pagamentos....>>> " tt-marca.titnum .
        pause 0.
        find titulo where 
             titulo.empcod = tt-marca.empcod and
             titulo.titnat = tt-marca.titnat and
             titulo.modcod = tt-marca.modcod and
             titulo.etbcod = tt-marca.etbcod and
             titulo.clifor = tt-marca.clifor and
             titulo.titnum = tt-marca.titnum and
             titulo.titpar = tt-marca.titpar
             no-lock no-error.
        if avail titulo
        then do:
            run desconto-antecipacao.
            assign 
                vtitvljur = titulo.titvljur + vl-juro
                vtitvldes = titulo.titvldes + vl-desc .

            vtotalpag = vtotalpag +
                  (titulo.titvlcob + vtitvljur - vtitvldes)
              .          
        end.
    end. 
    /*
    update vtitvlpag validate(vtitvlpag = vtotalpag,
                            "Valor infromado difere do total selecionado.")
            label "Valor total pago"
            with frame f-pagm 1 down 
            centered overlay row 10 side-label.
    update vtitdtpag validate(vtitdtpag >= today - 30 and
                              vtitdtpag <= today,
                              "Data invalida para pagamento.") 
                               with frame f-pagm.
     */
     for each tt-marca:
        message "Efetuando pagamentos....>>> " tt-marca.titnum .
        pause 0.
        find titulo where 
             titulo.empcod = tt-marca.empcod and
             titulo.titnat = tt-marca.titnat and
             titulo.modcod = tt-marca.modcod and
             titulo.etbcod = tt-marca.etbcod and
             titulo.clifor = tt-marca.clifor and
             titulo.titnum = tt-marca.titnum and
             titulo.titpar = tt-marca.titpar
             no-error.
        if avail titulo
        then do:
            run desconto-antecipacao.
            assign 
                vtitvljur = titulo.titvljur + vl-juro
                vtitvldes = titulo.titvldes + vl-desc
                titulo.titdtpag = vtitdtpag
                titulo.titvljur = vtitvljur
                titulo.titvldes = vtitvldes
                titulo.titvlpag = titulo.titvlcob + titulo.titvljur
                                    - titulo.titvldes
            /*    titulo.cobcod = 1 */
                .
            
            vlancod = 0.
            if vtitnat = yes
            then do:
                find forne where forne.forcod = titulo.clifor
                        no-lock no-error.
                find first fatudesp where
                               /*fatudesp.etbcod = titulo.etbcod and*/
                               fatudesp.clicod = titulo.clifor and
                               fatudesp.fatnum = int(titulo.titnum) and
                               fatudesp.inclusao = titulo.titdtemi
                               no-lock no-error.
                if avail fatudesp
                then do:
                    vcompl  = titulo.titnum + "-" + string(titulo.titpar)
                                            + " " + forne.fornom.
                    run pag-tit-desp.
                end.
                else do:
                        
                    if today >= 09/01/13
                    then do:
                        vcompl  = titulo.titnum + "-" + string(titulo.titpar)
                                                + " " + forne.fornom.
                        run pag-titulo.
                    end.           
                    else do:
                    
                        vlancod = titulo.vencod.
                        vlanhis = titulo.titparger.
                        vcompl  = titulo.titnumger.
                    
                    

                    if titulo.modcod = "DUP"
                    then assign vlancod = 100
                                vlanhis = 1
                                vcompl  = titulo.titnum 
                                        + "-" + string(titulo.titpar)
                                        + " " + forne.fornom.
                    else do:

                        find last blancxa where blancxa.forcod = forne.forcod
                                            and  blancxa.etbcod = titulo.etbcod
                                            and  blancxa.lantip = "C"
                                            no-lock no-error.
                        if avail blancxa
                        then assign vlancod = blancxa.lancod
                                    vlanhis = blancxa.lanhis
                                    vcompl  = blancxa.comhis.
                    end.
                    
                    if vclifor = 533
                    then vlanhis = 5.
                    
                    if vclifor = 100071
                    then vlanhis = 4.

                    if vclifor = 100072
                    then vlanhis = 3.

                    find lanaut where lanaut.etbcod = titulo.etbcod and
                                      lanaut.forcod = titulo.clifor
                                                no-lock no-error.
                    if avail lanaut 
                    then do: 
                        assign vlanhis = lanaut.lanhis
                               vcompl  = lanaut.comhis
                               vlancod = lanaut.lancod.
                    end.
                    
                    if vlanhis = 6
                    then vcompl = "".
                    
                    if vlancod <> 0 and vtitnat = yes
                    then do:
                        find tablan where tablan.lancod = vlancod
                                                        no-lock no-error.
                        if avail tablan
                        then vlancod = tablan.codred.
                                                        
                        find last blancxa no-lock no-error.
                        if not avail blancxa
                        then vnumlan = 1.
                        else vnumlan = blancxa.numlan + 1.
                        create lancxa.
                        assign lancxa.cxacod = formpag.contacre /*13*/
                               lancxa.datlan = titulo.titdtpag
                               lancxa.lancod = vlancod
                               lancxa.numlan = vnumlan
                               lancxa.vallan = titulo.titvlcob
                               lancxa.comhis = vcompl
                               lancxa.lantip = "C"
                               lancxa.forcod = titulo.clifor
                               lancxa.titnum = titulo.titnum
                               lancxa.etbcod = titulo.etbcod
                               lancxa.modcod = titulo.modcod
                               lancxa.lanhis = vlanhis.
                        
                        if lancxa.lanhis = 1
                        then lancxa.comhis = titulo.titnum + " " + forne.fornom.
                        
                        assign lancxa.lanhis = vlanhis
                               lancxa.comhis = vcompl 
                               lancxa.lancod = vlancod.

                        if titulo.titvljur > 0 and vtitnat = yes
                        then do:
                            find last lancxa no-lock no-error.
                            if not avail lancxa
                            then vnumlan = 1.
                            else vnumlan = lancxa.numlan + 1.
                            create blancxa.
                            ASSIGN blancxa.cxacod = formpag.contacre /*13*/
                                   blancxa.datlan = titulo.titdtpag
                                   blancxa.lancod = 110
                                   blancxa.numlan = vnumlan
                                   blancxa.vallan = titulo.titvljur
                                   blancxa.comhis = vcompl
                                   blancxa.lantip = "C"
                                   blancxa.forcod = titulo.clifor
                                   blancxa.titnum = titulo.titnum
                                   blancxa.etbcod = titulo.etbcod
                                   blancxa.modcod = titulo.modcod
                                   blancxa.lanhis = 13.
                                   
                        end.    
                        
                        if titulo.titvldes > 0 and vtitnat = yes
                        then do:
                            find last lancxa no-lock no-error.
                            if not avail lancxa
                            then vnumlan = 1.
                            else vnumlan = lancxa.numlan + 1.
                            create blancxa.
                            if titulo.clifor = 100090
                            then find tablan where tablan.lancod = 111 no-lock.
                            else find tablan where tablan.lancod = 439 no-lock.
                            ASSIGN blancxa.cxacod = formpag.contacre /*13*/
                                   blancxa.datlan = titulo.titdtpag
                                   blancxa.lancod = tablan.lancod
                                   blancxa.numlan = vnumlan
                                   blancxa.vallan = titulo.titvldes
                                   blancxa.comhis = vcompl
                                   blancxa.lantip = "D"
                                   blancxa.forcod = titulo.clifor
                                   blancxa.titnum = titulo.titnum
                                   blancxa.etbcod = titulo.etbcod
                                   blancxa.modcod = titulo.modcod
                                   blancxa.lanhis = tablan.lanhis.
                            
                            if tablan.lanhis = 12
                            then blancxa.comhis = 
                                 titulo.titnum + " " + forne.fornom.

                        end.    

                    end.
                    else do:
                        message color red/with
                         "Conta para Lancamento Contabil nao cadastrada" skip
                         "Fornecedor: " string(forne.forcod) forne.fornom skip
                         "Favor comunicar o Setor Contabil"
                         view-as alert-box.
                    end.
                    end.
                end.
            
            end.
            titulo.titsit = "PAG".

            if avail fatudesp
            then do:
                run paga-titudesp.
            end.
            
            delete tt-marca.
        end.
    end. 
    end.
    end.
    qt-marca = 0.
    vl-marca = 0.
end procedure.

procedure desconto-antecipacao:
    assign
        vl-juro = 0
        vl-desc = 0
        jur-titag = 0
        des-titag = 0
        qtd-titag = 0
        val-titag = 0.
    if acha("AGENDAR",titulo.titobs[2]) <> ? and
           titulo.titdtven <> date(acha("AGENDAR",titulo.titobs[2])) 
    then do:
        if acha("VALJURO",titulo.titobs[2]) <> "?"
        then vl-juro   = dec(acha("VALJURO",titulo.titobs[2])).
        else vl-juro   = 0.
        if acha("VALDESC",titulo.titobs[2]) <> "?"
        then vl-desc   = dec(acha("VALDESC",titulo.titobs[2])).
        else vl-desc = 0.
        if vl-juro = ? then vl-juro = 0.
        if vl-desc = ? then vl-desc = 0.
        if vl-juro <> ?
        then jur-titag = jur-titag + vl-juro + titulo.titvljur.
        if vl-desc <> ?
        then des-titag = des-titag + vl-desc + titulo.titvldes.
        qtd-titag = qtd-titag + 1.
        val-titag = val-titag + titulo.titvlcob.
    end.
end procedure.

procedure pag-tit-desp:
    
    run gera-titpag.
    
    find first tituctb where
             tituctb.clifor = titulo.clifor and
             tituctb.titnum = titulo.titnum and
             tituctb.titpar = titulo.titpar and
             tituctb.titdtemi = titulo.titdtemi and
             tituctb.etbcod = titulo.etbcod
             no-lock no-error.
    if avail tituctb
    then for each tituctb where
             tituctb.clifor = titulo.clifor and
             tituctb.titnum = titulo.titnum and
             tituctb.titpar = titulo.titpar and
             tituctb.titdtemi = titulo.titdtemi and
             tituctb.etbcod = titulo.etbcod
             no-lock:
                
        find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = tituctb.clifor and
                lancactb.modcod = tituctb.modcod
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = tituctb.modcod
                no-lock no-error.
        if avail lancactb
        then do:
            run lan-contabil("CAIXA",
                            lancactb.contadeb,
                            formpag.contacre,
                            tituctb.modcod,
                            titulo.titdtpag,
                            (tituctb.titvlcob + 
                             tituctb.titvljur - tituctb.titvldes),
                            tituctb.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int2,
                            vcompl,
                            "C").
        end. 
    end. 
    else do:
        find first  lancactb where
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
        if avail lancactb
        then do:
            run lan-contabil("CAIXA",
                            lancactb.contadeb,
                            formpag.contacre,
                            fatudesp.modctb,
                            titulo.titdtpag,
                            (titulo.titvlcob + 
                             titulo.titvljur - titulo.titvldes),
                            fatudesp.clicod,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int2,
                            vcompl,
                            "C").
        end. 
    end.
end procedure. 

procedure pag-titulo:
              
    find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = titulo.clifor and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
    if not avail lancactb
    then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
    
    if avail lancactb
    then do:
        if titulo.agecod <> "FRETE"
        then
        run lan-contabil("CAIXA",
                            lancactb.contadeb,
                            formpag.contacre,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvlpag,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int2,
                            vcompl,
                            "C").
        if titulo.agecod = "FRETE"
        then
        run lan-contabil("CAIXA",
                            "559",
                            formpag.contacre,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvlpag,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int2,
                            vcompl,
                            "C").

        if titulo.titvljur > 0 and vtitnat = yes
        then do:
            run lan-contabil("CAIXA",
                            228,
                            lancactb.contadeb,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvljur,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            13,
                            vcompl,
                            "C").
        end.    
                        
        if titulo.titvldes > 0 and vtitnat = yes
        then do:
            run lan-contabil("CAIXA",
                            lancactb.contadeb,
                            235,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvldes,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            12,
                            vcompl,
                            "C").
        end.
    end.    
    run gera-titpag.
end procedure. 


procedure lan-contabil:
    def input parameter l-tipo as char.
    def input parameter l-landeb like lancactb.contadeb.
    def input parameter l-lancre like lancactb.contacre.
    def input parameter l-modcod like lancxa.modcod.
    def input parameter l-datlan as date.
    def input parameter l-vallan as dec.
    def input parameter l-forcod like titulo.clifor.
    def input parameter l-titnum like titulo.titnum.
    def input parameter l-etbcod like estab.etbcod.
    def input parameter l-hiscod as char.
    def input parameter l-hiscomp as char.
    def input parameter l-lantipo as char.

    def buffer elancxa for lancxa.
    /*
    if l-landeb = 448 and
       l-landeb = 447 and
       l-landeb = 362
    then l-hiscod = "262".
    */
           
    if l-tipo = "CAIXA"
    THEN
    do on error undo:
            find first elancxa where 
                       elancxa.cxacod = lancactb.contadeb and
                       elancxa.modcod = l-modcod and
                       elancxa.forcod = l-forcod and
                       elancxa.titnum = l-titnum and
                       elancxa.lantip = "X"
                        no-error.
            if avail elancxa 
            then do on error undo:
                /*if month(titulo.titdtpag) = month(titulo.titdtemi) and
                   year(titulo.titdtpag) = year(titulo.titdtemi)
                then delete elancxa.
                else if lancactb.contadeb > 0
                then*/ l-landeb = elancxa.lancod.
            end.
            else. /*l-landeb = lancactb.contadeb.*/
             
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-lancre and
                       lancxa.lancod = l-landeb and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.lantip = l-lantipo and
                       lancxa.comhis = l-hiscomp and
                       lancxa.etbcod = l-etbcod
                        no-error.
            if not avail lancxa
            then do:            
            
            find last blancxa use-index ind-1
                where blancxa.numlan <> ? no-lock no-error.
            if not avail blancxa
            then vnumlan = 1.
            else vnumlan = blancxa.numlan + 1.
            
            create lancxa.
            assign lancxa.cxacod = l-lancre
                   lancxa.datlan = l-datlan
                   lancxa.lancod = l-landeb
                   lancxa.modcod = l-modcod
                   lancxa.numlan = vnumlan
                   lancxa.vallan = l-vallan
                   lancxa.comhis = l-hiscomp
                   lancxa.lantip = l-lantipo
                   lancxa.forcod = l-forcod
                   lancxa.titnum = l-titnum
                   lancxa.etbcod = l-etbcod
                   lancxa.lanhis = int(l-hiscod).
            end.                    
    end.
    else if l-tipo = "EXTRA-CAIXA"
    THEN DO ON ERROR UNDO:
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-lancre and
                       lancxa.lancod = l-landeb and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.lantip = "X"      and
                       lancxa.comhis = l-hiscomp and
                       lancxa.etbcod = l-etbcod
                        no-error.
            if not avail lancxa
            then do: 
            find last blancxa use-index ind-1
                where blancxa.numlan <> ? no-lock no-error.
            if not avail blancxa
            then vnumlan = 1.
            else vnumlan = blancxa.numlan + 1.
             
                create lancxa.
                assign
                    lancxa.numlan = blancxa.numlan + 1
                    lancxa.lansit = "F"
                    lancxa.datlan = l-datlan
                    lancxa.cxacod = l-lancre
                    lancxa.lancod = l-landeb
                    lancxa.modcod = l-modcod
                    lancxa.vallan = l-vallan
                    lancxa.lanhis = int(l-hiscod)
                    lancxa.forcod = l-forcod
                    lancxa.titnum = l-titnum
                    lancxa.etbcod = l-etbcod
                    lancxa.lantip = "X"
                    lancxa.livre1 = "" 
                    lancxa.comhis = l-hiscomp 
                    .
            end.
       end.
end procedure.
 
procedure gera-titpag:
    find first titpag where
               titpag.empcod = titulo.empcod and
               titpag.titnat = titulo.titnat and
               titpag.modcod = titulo.modcod and
               titpag.etbcod = titulo.etbcod and
               titpag.clifor = titulo.clifor and
               titpag.titnum = titulo.titnum and
               titpag.titpar = titulo.titpar and
               titpag.moecod = string(formpag.codigo)
               no-error.
    if not avail titpag
    then do:
        create titpag.
        assign
            titpag.empcod = titulo.empcod
            titpag.titnat = titulo.titnat
            titpag.modcod = titulo.modcod
            titpag.etbcod = titulo.etbcod
            titpag.clifor = titulo.clifor
            titpag.titnum = titulo.titnum
            titpag.titpar = titulo.titpar
            titpag.moecod = string(formpag.codigo)
            titpag.titvlpag = titulo.titvlpag 
            titpag.cxacod = scxacod
            titpag.cxmdata = today
            titpag.cxmhora = string(time)
            titpag.datexp  = today
            titpag.exportado = no.
    end.
    else do:
        assign
            titpag.titvlpag = titulo.titvlpag 
            titpag.moecod = string(formpag.codigo)
            titpag.cxacod = scxacod
            titpag.cxmdata = today
            titpag.cxmhora = string(time)
            titpag.datexp  = today
            titpag.exportado = no.
    end.
end procedure. 

procedure paga-titudesp.
    for each titudesp where
             titudesp.clifor = titulo.clifor and
             titudesp.titnum = titulo.titnum and
             titudesp.titpar = titulo.titpar and
             titudesp.titdtemi = titulo.titdtemi
             .
        assign
            titudesp.titdtpag = titulo.titdtpag
            titudesp.titvlpag = titudesp.titvlcob
            titudesp.titsit   = titulo.titsit
            .         
    end.
    for each tituctb where
             tituctb.clifor = titulo.clifor and
             tituctb.titnum = titulo.titnum and
             tituctb.titpar = titulo.titpar and
             tituctb.titdtemi = titulo.titdtemi
             .
        assign
            tituctb.titdtpag = titulo.titdtpag
            tituctb.titvlpag = tituctb.titvlcob
            tituctb.titsit   = titulo.titsit
            .         
    end.

                                        
end.

procedure ver-lancactb:
    v-lancactb = yes.
    
    find first fatudesp where 
               fatudesp.clicod = titulo.clifor and
               fatudesp.fatnum = int(titulo.titnum)
               no-lock no-error.
    if not avail fatudesp
    then do:           
        find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = titulo.etbcod and
                lancactb.forcod = titulo.clifor and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = titulo.clifor and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
    
        if not avail lancactb
        then do:
            bell.
            message color red/with
            "CONTA CONTABIL para modalidade " titulo.modcod
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
