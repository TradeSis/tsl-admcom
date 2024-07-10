{admcab.i }
{def.i}

def temp-table tttit 
    field titnum like titulo.titnum
    field rec as recid.

def var vdtven like titulo.titdtven.
def var vfrecod like frete.frecod.
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
esqpos1  = 1. esqpos2  = 1.
repeat:
    for each wtit:
        delete wtit.
    end.
    clear frame ff1 all.
    assign recatu1  = ?.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    update vdtven colon 18 with frame ff1.
    do on error undo:
        update vmodcod validate(can-find(modal where modal.modcod = vmodcod),
                                "Modalidade Invalida") colon 18 with frame ff1.
        find modal where modal.modcod = vmodcod.
        display modal.modnom no-label with frame ff1.
        if modcod = "CRE"
        then do:
            message "modalidade invalida".
            undo, retry.
        end.
    end.
    do on error undo:
        vtitnat = yes.
        update vtitnat colon 18
               with frame ff1 side-labels width 80 color white/cyan.
    end.

    hide frame ff1 no-pause.
    display vdtven vmodcod vtitnat
            with frame ff no-box row 4 side-labels color white/red width 81.
    
    vcliforlab = "Fornecedor:".
    lclifor = if vtitnat
              then no
              else yes .
    display vcliforlab no-labels to 19 with frame ff1.
    hide frame ff1 no-pause.
    
    for each estab no-lock:
        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = vtitnat and
                              titulo.modcod = vmodcod and
                              titulo.etbcod = estab.etbcod and
                              titulo.titdtven = vdtven no-lock.
            create tttit.
            assign tttit.titnum = titulo.titnum 
                   tttit.rec    = recid(titulo).
        end.                          
    end.
    
bl-princ:
repeat :
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if  recatu1 = ? then
        find first titulo use-index titdtven
                    where titulo.empcod   = wempre.empcod and
            titulo.titnat   = vtitnat       and
            titulo.modcod   = vmodcod       and 
            (titulo.etbcod = 995 or titulo.etbcod = 996 or 
             titulo.etbcod = 22 or titulo.etbcod = 999 or
             titulo.etbcod = 997 or titulo.etbcod = 98)  and 
            titulo.titdtven = vdtven no-error.
    else find titulo where recid(titulo) = recatu1.
    vinicio = no.
    if  not available titulo 
    then do:
        message "Cadastro de Titulos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp 
        then undo.
    end.
    clear frame frame-a all no-pause.
    view frame ff.
    display titulo.etbcod format ">>9" column-label "Fl"
            titulo.titnum format "x(7)"
            titulo.titpar   format ">9"
        titulo.titvlcob format ">>>,>>9.99" column-label "Vl.Cobrado"
        titulo.titdtven format "99/99/9999"   column-label "Dt.Vecto"
        titulo.titdtpag format "99/99/9999"   column-label "Dt.Pagto"
        titulo.titvlpag when titulo.titvlpag > 0 format ">>>,>>9.99"
                                            column-label "Valor Pago"
        titulo.titvljur column-label "Juros" format ">>,>>9.9"
        titulo.titvldes column-label "Desc"  format ">>,>>9.9"
        titulo.titsit column-label "S" format "X"
            with frame frame-a 10 down centered color white/red width 80.
            
    recatu1 = recid(titulo).
    if  esqregua then do:
        display esqcom1[esqpos1] with frame f-com1.
        color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
        find next titulo use-index titdtven
                    where titulo.empcod   = wempre.empcod and
                               titulo.titnat   = vtitnat       and
                               titulo.modcod   = vmodcod       and
            (titulo.etbcod = 995 or titulo.etbcod = 996 or 
             titulo.etbcod = 22 or titulo.etbcod = 999 or
             titulo.etbcod = 997 or titulo.etbcod = 98)  and 
                               titulo.titdtven = vdtven   no-error.
        if not available titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if not vinicio
        then down with frame frame-a.
        view frame ff.
        display titulo.etbcod
                titulo.titnum
                titulo.titpar
                titulo.titvlcob
                titulo.titdtven
                titulo.titdtpag
                titulo.titvlpag when titulo.titvlpag > 0
                titulo.titvljur
                titulo.titvldes
                titulo.titsit with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
        find titulo where recid(titulo) = recatu1.
        color display messages titulo.titnum titulo.titpar.
        on f7 recall.
        choose field titulo.titnum titulo.titpar
            go-on(cursor-down cursor-up cursor-left cursor-right F7 PF7
                  page-up page-down tab PF4 F4 ESC return v V ).
        {pagtit.i}
       if  keyfunction(lastkey) = "RECALL"
       then do with frame fproc centered row 5 overlay color message side-label:
            update vtitnum colon 10.
            find first tttit where tttit.titnum = vtitnum no-error.
            if not avail tttit
            then do:
                message "Titulo nao existe com este numero".
                next.
            end.
            else do:   
                find first titulo where recid(titulo) = tttit.rec.
                recatu1 = if avail titulo
                      then recid(titulo) else ?. leave.
            end.
       end. on f7 help.
       if  keyfunction(lastkey) = "V" or
           keyfunction(lastkey) = "v"
       then do with frame fdt centered row 5 overlay color message side-label:
            vdt = today.
            update vdt label "Vencimento".
            find first titulo where titulo.empcod   = wempre.empcod and
                                    titulo.titnat   = vtitnat       and
                                    titulo.modcod   = vmodcod       and
                        (titulo.etbcod = 995 or titulo.etbcod = 996 or 
                         titulo.etbcod = 22 or titulo.etbcod = 999 or
                         titulo.etbcod = 997 or titulo.etbcod = 98)  and 
                                    titulo.titdtven >= vdt no-error.
            if avail titulo
            then recatu1 = recid(titulo). 
            else do:
                find next titulo use-index titdtven where 
                                 titulo.empcod = wempre.empcod   and
                                 titulo.titnat   = vtitnat       and
                                 titulo.modcod   = vmodcod       and
                               (titulo.etbcod = 995 or titulo.etbcod = 996 or 
                             titulo.etbcod = 22 or titulo.etbcod = 999 or
                             titulo.etbcod = 997 or titulo.etbcod = 98)  and 
                                 titulo.titdtven >= vdt no-error.
                             
                if avail titulo
                then recatu1 = recid(titulo).
                else do:
                     find prev titulo use-index titdtven where 
                                 titulo.empcod = wempre.empcod   and
                                 titulo.titnat   = vtitnat       and
                                 titulo.modcod   = vmodcod       and
                               (titulo.etbcod = 995 or titulo.etbcod = 996 or 
                                 titulo.etbcod = 22 or titulo.etbcod = 999 or
                             titulo.etbcod = 997 or titulo.etbcod = 98)  and 
                                 titulo.titdtven <= vdt no-error.
                 
                    if avail titulo
                    then recatu1 = recid(titulo).
                    else recatu1 = ?.
                end.    
                      
            end.   
            leave.
        end. 
        
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
            find next titulo use-index titdtven
                             where titulo.empcod   = wempre.empcod and
                                   titulo.titnat   = vtitnat       and
                                   titulo.modcod   = vmodcod       and
                                 (titulo.etbcod = 995 or titulo.etbcod = 996 or 
                                 titulo.etbcod = 22 or titulo.etbcod = 999 or
                                 titulo.etbcod = 997 or titulo.etbcod = 98)  and 
                                   titulo.titdtven = vdtven no-error.
            if  not avail titulo
            then do:
                message "". pause 0.
                next.
            end.    
            color display white/red titulo.titnum titulo.titpar.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if  keyfunction(lastkey) = "cursor-up" then do:
            find prev titulo use-index titdtven
                             where titulo.empcod   = wempre.empcod and
                                   titulo.titnat   = vtitnat       and
                                   titulo.modcod   = vmodcod       and
                               (titulo.etbcod = 995 or titulo.etbcod = 996 or 
                                titulo.etbcod = 22 or titulo.etbcod = 999 or
                                titulo.etbcod = 997 or titulo.etbcod = 98)  and 
                                    titulo.titdtven = vdtven no-error.
            if not avail titulo
            then next.
            color display white/red titulo.titnum titulo.titpar.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
          if esqcom2[esqpos2] <> "Pagamento/Cancelamento" or
             esqcom2[esqpos2] <> "Bloqueio/Liberacao"
          then hide frame frame-a no-pause.
          display vcliforlab at 6 vclifornom
                with frame frame-b 1 down centered color blue/gray
                width 81 no-box no-label row 5 overlay.
          if  esqregua then do:
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame ftitulo:
                vtitvlcob = titulo.titvlcob .
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
                find cobra where cobra.cobcod = titulo.cobcod.
                display cobra.cobnom.
                if cobra.cobban
                then do with frame fbanco:
                    update titulo.bancod.
                    find banco where banco.bancod = titulo.bancod.
                    display banco.bandesc .
                    update titulo.agecod.
                    find agenc of banco where agenc.agecod = titulo.agecod.
                    display agedesc.
                end.
                update titulo.modcod colon 15.
                find modal where modal.modcod = titulo.modcod no-lock.
                display modal.modnom no-label.
                update titulo.evecod colon 15.
                find event where event.evecod = titulo.evecod no-lock.
                display event.evenom no-label.
                update titulo.titvljur with frame fjurdes .
                update titulo.titdtdes with frame fjurdes.
                update titulo.titvldes format ">>,>>9.99"
                        with frame fjurdes.
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
            if esqcom1[esqpos1] = "Consulta" or esqcom1[esqpos1] = "Exclusao"
            then do:
                find modal of titulo no-lock no-error.
                disp titulo.modcod
                     modal.modnom when available modal no-label
                     titulo.titnum
                     titulo.titpar
                     titulo.titdtemi
                     titulo.titdtven
                     titulo.titvlcob
                     titulo.cobcod with frame ftitulo.
                disp titulo.titvljur
                     titulo.titjuro
                     titulo.titdtdes
                     titulo.titvldes
                     titulo.titdtpag
                     titulo.titvlpag with frame fjurdes.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
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
                find next titulo use-index titdtven
                                 where titulo.empcod   = wempre.empcod and
                                       titulo.titnat   = vtitnat       and
                                       titulo.modcod   = vmodcod       and
                          (titulo.etbcod = 995 or titulo.etbcod = 996 or 
                                 titulo.etbcod = 22 or titulo.etbcod = 999 or
                                titulo.etbcod = 997 or titulo.etbcod = 98)  and 
                                       titulo.titdtven = vdtven no-error.
                if not available titulo
                then do:
                    find titulo where recid(titulo) = recatu1.
                    find prev titulo use-index titdtven
                                     where titulo.empcod   = wempre.empcod and
                                           titulo.titnat   = vtitnat       and
                                           titulo.modcod   = vmodcod       and
                               (titulo.etbcod = 995 or titulo.etbcod = 996 or 
                                 titulo.etbcod = 22 or titulo.etbcod = 999 or
                                 titulo.etbcod = 997 or titulo.etbcod = 98)  and 
                                           titulo.titdtven = vdtven no-error.
                end.
                recatu2 = if available titulo
                          then recid(titulo)
                          else ?.
                find titulo where recid(titulo) = recatu1.
                {ctb02.i}
                delete titulo.
                recatu1 = recatu2.
                leave.
            end.
          end.
          else do:
            hide frame f-com2 no-pause.
            if  esqcom2[esqpos2] = "Pagamento/Cancelamento"
            then if  titulo.titsit = "LIB" or titulo.titsit = "IMP" or
                     titulo.titsit = "CON"
              then do with frame f-Paga overlay row 6 1 column centered.
                 display titulo.titnum    colon 13
                        titulo.titpar    colon 33 label "Pr"
                        titulo.titdtemi  colon 13
                        titulo.titdtven  colon 13
                        titulo.titvlcob  colon 13 label "Vl.Cobr."
                        titulo.titvljur  colon 13 label "Vl.Juro"
                        titulo.titvldes  format ">>,>>9.99"
                                colon 13 label "Vl.Desc"
                        with frame fdadpg side-label
                        overlay row 6 color white/cyan width 40
                        title " Titulo ".
                 titulo.datexp = today.
               if  titulo.modcod = "CRE" then do:
                   {titpagb4.i}
                   update titulo.titvljur  colon 13 label "Vl.Juro"
                          titulo.titvldes  colon 13 label "Vl.Desc"
                                format ">>,>>9.99"
                                            with frame fdadpg side-label
                                    overlay row 6 color white/cyan width 40
                                                            title " Titulo ".
               end.
               else do:
                   hide frame lanca no-pause.
                   assign titulo.titdtpag = today.
                   display titulo.titdtdes colon 13 label "Dt.Desc"
                           titulo.titvldes colon 13 label "Vl.Desc"
                                           format ">>,>>9.99"
                           titulo.titvljur colon 13 label "Vl.Juro"
                                      with frame fdadpg.
                   update titulo.titdtpag with frame fpag1.
                   titulo.titvlpag = titulo.titvlcob.
                   
                titulo.titvlpag = titulo.titvlcob + titulo.titvljur
                                     - titulo.titvldes.
                assign vtitvlpag = titulo.titvlpag.
                update titulo.titvlpag with frame fpag1.
                update titulo.cobcod with frame fpag1.
                update titulo.titvljur column-label "Juros"
                       titulo.titvldes format ">>,>>9.99"
                            with frame fpag1.
                
                
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

                    vlancod = titulo.vencod.
                    vlanhis = titulo.titparger.
                    vcompl  = titulo.titnumger.

                    if vclifor = 533
                    then vlanhis = 6.
                    
                    if vclifor = 100071
                    then vlanhis = 6.

                    if vclifor = 100072
                    then vlanhis = 3.

                    
                    find forne where forne.forcod = titulo.clifor no-lock.
                    if titulo.modcod = "DUP"
                    then assign vlancod = 100
                                vlanhis = 1
                                vcompl  = titulo.titnum 
                                        + "-" + string(titulo.titpar)
                                        + " " + forne.fornom.
                    else
                    update vlancod label "Lancamento"
                           vlanhis label "Historico" format ">99"
                           vcompl  label "Complemento"
                       
                            with frame lanca centered side-label
                                row 15 overlay.
                    
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
                        
                        find last blancxa no-lock no-error.
                        if not avail blancxa
                        then vnumlan = 1.
                        else vnumlan = blancxa.numlan + 1.
                        create lancxa.
                        ASSIGN lancxa.cxacod = 13
                               lancxa.datlan = titulo.titdtpag
                               lancxa.lancod = vlancod
                               lancxa.numlan = vnumlan
                               lancxa.vallan = titulo.titvlcob
                               lancxa.comhis = vcompl
                               lancxa.lantip = "C"
                               lancxa.forcod = titulo.clifor
                               lancxa.titnum = titulo.titnum
                               lancxa.lanhis = vlanhis.
                        


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
                                   blancxa.lanhis = tablan.lanhis.
                        end.    

                    end.
                    else do:
                        message "Lancamento nao cadastrado".
                        undo, retry.
                    end.
                end.
                hide frame lanca no-pause.
  
                if titulo.titvlpag >= titulo.titvlcob
                then. 
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
                            btitulo.etbcod   = titulo.etbcod and
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
               recatu1 = recid(titulo).
               leave.
              end.
              else
                if  titulo.titsit = "PAG" then do:
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
                    message "Confirma o Cancelamento do Pagamento ?"
                            update sresp.
                    if  sresp then do:
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
                   recatu1 = recid(titulo).
                   next bl-princ.
                end.
            if esqcom2[esqpos2]  = "Bloqueio/Liberacao" and
               titulo.titsit    <> "PAG"
            then do:
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
          end.
          view frame frame-a.
          view frame f-com2 .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        display titulo.etbcod
                titulo.titnum
                titulo.titpar
                titulo.titvlcob
                titulo.titdtven
                titulo.titdtpag
                titulo.titvlpag when titulo.titvlpag > 0
                titulo.titvljur
                titulo.titvldes
                titulo.titsit with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(titulo).
   end.
end.
end.

