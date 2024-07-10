/**    Esqueletao de Programacao                          titexporta.p */
{admcab.i}
def var vv as log initial no. 
def var vok as log.
def var vinicio         as  log initial no.
def var reccont         as  int.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(14)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(22)" extent 3
            initial ["Pagamento/Cancelamento", "Bloqueio/Liberacao",
                        "Data Exportacao"].
def buffer btitexporta      for titexporta.
def buffer ctitexporta      for titexporta.
def buffer b-titu       for titexporta.
def var vempcod         like titexporta.empcod.
def var vetbcod         like titexporta.etbcod.
def var vmodcod         like titexporta.modcod.
def var vtitnat         like titexporta.titnat.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def var vclifor         like titexporta.clifor.
def var wperdes         as dec format ">9.99 %" label "Perc. Desc.".
def var wperjur         as dec format ">9.99 %" label "Perc. Juros".
def var vtitvlpag       like titexporta.titvlpag.
def var vtitvlcob       like titexporta.titvlcob.
def var vdtpag          like titexporta.titdtpag.
def var vdate           as   date.
def var vetbcobra       like titexporta.etbcobra initial 0.
def var vcontrola       as   log initial no.
form esqcom1
    with frame f-com1
    row 5 no-box no-labels side-labels column 1.
form esqcom2
    with frame f-com2
        row screen-lines - 2 title " OPERACOES " no-labels side-labels column 1
        centered.
{expfrm.i}
repeat:
    clear frame ff1 all.
    assign
        esqregua = yes
        esqpos1  = 1
        esqpos2  = 1
        recatu1  = ?.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    update vetbcod validate(can-find(estab where estab.etbcod = vetbcod),
                            "Estabelecimento Invalido") colon 18
           with frame ff1 side-labels row 5 width 80 color white/cyan.
    find estab where estab.etbcod = vetbcod .
    display estab.etbnom no-label with frame ff1.
    vmodcod = "CRE".
    vtitnat = no.
    hide frame ff1 no-pause.
    display vetbcod vmodcod vtitnat
            with frame ff no-box row 4 side-labels color white/red width 81.
    vcliforlab = if vtitnat
                 then "Fornecedor:"
                 else "   Cliente:".
    lclifor = if vtitnat
              then no
              else yes .

bl-princ:
repeat :
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if  recatu1 = ? then
        find first titexporta where
            titexporta.empcod   = wempre.empcod and
            titexporta.titnat   = vtitnat       and
            titexporta.modcod   = vmodcod       and
            titexporta.etbcod   = vetbcod  no-error.
    else
        find titexporta where recid(titexporta) = recatu1.
    vinicio = no.
    if  not available titexporta then do:
        message "Cadastro de titexportas Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp then undo.
        do with frame ftitexporta:
                create titexporta.
                assign
                    titexporta.empcod = wempre.empcod
                    titexporta.titnat = vtitnat
                    titexporta.modcod = vmodcod
                    titexporta.etbcod = vetbcod
                    titexporta.datexp = today.
                assign
                    titexporta.clifor = vclifor.
                update titexporta.titnum
                       titexporta.titpar
                       titexporta.titdtemi
                       titexporta.titdtven format "99/99/9999"
                       titexporta.titvlcob
                       titexporta.cobcod.
                find cobra where cobra.cobcod = titexporta.cobcod.
                display cobra.cobnom  no-label.
                if  cobra.cobban then do with frame fbanco.
                    update titexporta.bancod colon 15.
                    find banco where banco.bancod = titexporta.bancod.
                    display banco.bandesc .
                    update titexporta.agecod.
                    find agenc of banco where agenc.agecod = titexporta.agecod.
                    display agedesc.
                end.
                wperjur = 0 .
                update wperjur with frame fjurdes.
                titexporta.titvljur = titexporta.titvlcob * (wperjur / 100).
                update titexporta.titvljur with frame fjurdes .
                wperdes = 0.
                update titexporta.titdtdes
                       wperdes
                       with frame fjurdes.
                titexporta.titvldes = titexporta.titvlcob * (wperdes / 100).
                update titexporta.titvldes
                       with frame fjurdes.
                update text(titobs)
                       with frame fobs .
                pause 0.
                vinicio = yes.
        end.
    end.
    clear frame frame-a all no-pause.
    
    display
        titexporta.etbcobra column-label "EC" format ">9"
        titexporta.titnum
        titexporta.titpar   format ">>9"
        titexporta.clifor  column-label "Conta"
        titexporta.titvlcob format ">>,>>9.99" column-label "Vl.Cobrado"
        titexporta.titdtven format "99/99/9999"   column-label "Dt.Vecto"
        titexporta.titdtpag format "99/99/9999"   column-label "Dt.Pagto"
        titexporta.titvlpag when titexporta.titvlpag > 0 format ">>>,>>9.99"
                                            column-label "Valor Pago"
        titexporta.titsit
            with frame frame-a 10 down centered color white/red
            title " " + vcliforlab + " " + vclifornom + " "
                    + " Cod.: " + string(vclifor) + " " width 80.

    recatu1 = recid(titexporta).
    if  esqregua then do:
        display esqcom1[esqpos1] with frame f-com1.
        color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
        find next titexporta where
            titexporta.empcod   = wempre.empcod and
            titexporta.titnat   = vtitnat       and
            titexporta.modcod   = vmodcod       and
            titexporta.etbcod   = vetbcod       no-error.
        if not available titexporta
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if not vinicio
        then down with frame frame-a.
        display
            titexporta.etbcobra column-label "EC"
            titexporta.titnum
            titexporta.titpar
            titexporta.clifor
            titexporta.titvlcob
            titexporta.titdtven
            titexporta.titdtpag
            titexporta.titvlpag when titexporta.titvlpag > 0
            titexporta.titsit
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
        find titexporta where recid(titexporta) = recatu1.
        color display messages titexporta.titpar.
        on f7 recall.
        choose field titexporta.titnum
            go-on(cursor-down cursor-up cursor-left cursor-right F7 PF7
                  page-up       page-down
                  tab PF4 F4 ESC return).
        {pagtit.i}
        if  keyfunction(lastkey) = "RECALL"
        then do with frame fproc centered row 5 overlay color message
                            side-label:
            prompt-for titexporta.titnum label "Titulo" colon 10.
            find first titexporta where
                        titexporta.empcod   = wempre.empcod and
                        titexporta.titnat   = vtitnat       and
                        titexporta.modcod   = vmodcod       and
                        titexporta.etbcod   = vetbcod       and
                        titexporta.titnum  >= input titexporta.titnum
                        no-error.
            recatu1 = if avail titexporta
                      then recid(titexporta) else ?. leave.
        end.
        on f7 help.
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
            find next titexporta where
            titexporta.empcod   = wempre.empcod and
            titexporta.titnat   = vtitnat       and
            titexporta.modcod   = vmodcod       and
            titexporta.etbcod   = vetbcod   no-error.
            if  not avail titexporta then
                next.
            color display white/red
                titexporta.titnum titexporta.titpar.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if  keyfunction(lastkey) = "cursor-up" then do:
            find prev titexporta where
            titexporta.empcod   = wempre.empcod and
            titexporta.titnat   = vtitnat       and
            titexporta.modcod   = vmodcod       and
            titexporta.etbcod   = vetbcod       no-error.
            if not avail titexporta
            then next.
            color display white/red
                titexporta.titnum titexporta.titpar.
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
          then
            hide frame frame-a no-pause.
          display vcliforlab at 6 vclifornom
                with frame frame-b 1 down centered color blue/gray
                width 81 no-box no-label row 5 overlay.
          if  esqregua then do:
            if  esqcom1[esqpos1] = "Inclusao" then do with frame ftitexporta:
                create titexporta.
                assign
                    titexporta.empcod = wempre.empcod
                    titexporta.titnat = vtitnat
                    titexporta.modcod = vmodcod
                    titexporta.etbcod = vetbcod
                    titexporta.datexp = today.
                assign
                    titexporta.clifor = vclifor.
                update titexporta.titnum
                       titexporta.titpar
                       titexporta.titdtemi
                       titexporta.titdtven format "99/99/9999"
                       titexporta.titvlcob
                       titexporta.cobcod.
                find cobra where cobra.cobcod = titexporta.cobcod.
                display cobra.cobnom .
                if  cobra.cobban then do with frame fbanco:
                    update titexporta.bancod.
                    find banco where banco.bancod = titexporta.bancod.
                    display banco.bandesc .
                    update titexporta.agecod.
                    find agenc of banco where agenc.agecod = titexporta.agecod.
                    display agedesc.
                end.
                wperjur = 0 .
                update wperjur
                       with frame fjurdes.
                titexporta.titvljur = titexporta.titvlcob * (wperjur / 100).
                update titexporta.titvljur with frame fjurdes .
                wperdes = 0.
                update titexporta.titdtdes
                       wperdes
                       with frame fjurdes.
                titexporta.titvldes = titexporta.titvlcob * (wperdes / 100).
                update titexporta.titvldes
                        with frame fjurdes.
                update text(titobs)
                       with frame fobs .
                pause 0.
                recatu1 = recid(titexporta).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame ftitexporta:
                {segur.i 1}
                vtitvlcob = titexporta.titvlcob .
                titexporta.datexp = today.
                update titexporta.titnum
                       titexporta.titpar
                       titexporta.titdtemi
                       titexporta.titdtven format "99/99/9999"
                       titexporta.titvlcob
                       titexporta.cobcod
                       titexporta.etbcod
                       titexporta.etbcobra with no-validate.
                find cobra where cobra.cobcod = titexporta.cobcod.
                display cobra.cobnom .
                if cobra.cobban
                then do with frame fbanco:
                    update titexporta.bancod.
                    find banco where banco.bancod = titexporta.bancod.
                    display banco.bandesc .
                    update titexporta.agecod.
                    find agenc of banco where agenc.agecod = titexporta.agecod.
                    display agedesc.
                end.
                update titexporta.titvljur with frame fjurdes .
                update titexporta.titdtdes
                       with frame fjurdes.
                update titexporta.titvldes
                        with frame fjurdes.
                update text(titobs)
                       with frame fobs.
                if  titexporta.titvlcob <> vtitvlcob then do:
                   if  titexporta.titvlcob < vtitvlcob then do:
                    assign sresp = yes.
                    display "  Confirma GERACAO DE NOVO titexporta ?"
                                with frame fGERT color messages
                                width 60 overlay row 10 centered.
                    update sresp no-label with frame fGERT.
                    if  sresp then do:
                        find last btitexporta where
                            btitexporta.empcod   = wempre.empcod and
                            btitexporta.titnat   = vtitnat       and
                            btitexporta.modcod   = vmodcod       and
                            btitexporta.etbcod   = vetbcod       and
                            btitexporta.clifor   = vclifor       and
                            btitexporta.titnum   = titexporta.titnum.
                            create ctitexporta.
                            assign
                                ctitexporta.empcod = btitexporta.empcod
                                ctitexporta.modcod = btitexporta.modcod
                                ctitexporta.clifor = btitexporta.clifor
                                ctitexporta.titnat = btitexporta.titnat
                                ctitexporta.etbcod = btitexporta.etbcod
                                ctitexporta.titnum = btitexporta.titnum
                                ctitexporta.cobcod = titexporta.cobcod
                                ctitexporta.titpar   = btitexporta.titpar + 1
                                ctitexporta.titdtemi = today
                                ctitexporta.titdtven = titexporta.titdtven
                                ctitexporta.titnumger = titexporta.titnum
                                ctitexporta.titparger = titexporta.titpar
                                ctitexporta.datexp    = today.
                            display
                                    ctitexporta.titnum
                                    ctitexporta.titpar
                                    ctitexporta.titdtemi
                                    ctitexporta.titdtven
                                    ctitexporta.titvlcob
                                    with frame fmos width 40 1 column
                                              title " Titulo Gerado " overlay
                                              centered row 10.
                            recatu1 = recid(ctitexporta).
                            leave.
                        end.
                     end.
                     else do:
                        display "  Confirma AUMENTO NO VALOR DO titexporta?"
                                with frame faum color messages
                                width 60 overlay row 10 centered.
                        update sresp no-label with frame faum.
                        if not sresp
                        then undo, leave.
                    end.
                end.
            end.
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao"
            then do:
                find modal of titexporta no-lock no-error.
                disp titexporta.modcod
                     modal.modnom when available modal
                     titexporta.titnum
                     titexporta.titpar
                     titexporta.titdtemi
                     titexporta.titdtven format "99/99/9999"
                     titexporta.titvlcob
                     titexporta.cobcod
                     titexporta.titparger
                     titexporta.titnumger with frame ftitexporta.

                disp titexporta.titvljur
                     titexporta.titjuro
                     titexporta.titdtpag
                     titexporta.titvlpag
                     titexporta.etbcob
                     titexporta.etbcobra
                     titexporta.datexp format "99/99/9999"
                     titexporta.cxmdat
                     titexporta.cxacod with frame fjurdes.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                if not vv
                then do:
                    {segur.i 2}
                end.
                vv = yes.
                message "Confirma Exclusao de titexporta"
                            titexporta.titnum ",Parcela" titexporta.titpar
                    update sresp.
                if not sresp
                then leave.
                find next titexporta where
            titexporta.empcod   = wempre.empcod and
            titexporta.titnat   = vtitnat       and
            titexporta.modcod   = vmodcod       and
            titexporta.etbcod   = vetbcod       no-error.
                if not available titexporta
                then do:
                    find titexporta where recid(titexporta) = recatu1.
                    find prev titexporta where
            titexporta.empcod   = wempre.empcod and
            titexporta.titnat   = vtitnat       and
            titexporta.modcod   = vmodcod       and
            titexporta.etbcod   = vetbcod no-error.
                end.
                recatu2 = if available titexporta
                          then recid(titexporta)
                          else ?.
                find titexporta where recid(titexporta) = recatu1.
                delete titexporta.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao" update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                {mdadmcab.i
                   &Saida     = "printer"
                   &Page-Size = "64"
                   &Cond-Var  = "130"
                   &Page-Line = "66"
                   &Nom-Rel   = ""titexp""
                   &Nom-Sis   = """SISTEMA DE CREDIARIO"""
                   &Tit-Rel   = """LISTAGEM DE PENDENCIAS  "" + 
                                 ""ESTABELECIMENTO:  "" + string(vetbcod)"
                   &Width     = "130"
                   &Form      = "frame f-cabcab"}

                for each btitexporta where 
                            btitexporta.empcod   = wempre.empcod and
                            btitexporta.titnat   = vtitnat       and
                            btitexporta.modcod   = vmodcod       and
                            btitexporta.etbcod   = vetbcod no-lock:
                    
                    
                    display
                        btitexporta.etbcobra column-label "EC" format ">9"
                        btitexporta.titnum
                        btitexporta.titpar   format ">>9"
                        btitexporta.clifor  column-label "Conta"
                        btitexporta.titvlcob 
                               format ">>,>>9.99" column-label "Vl.Cobrado"
                        btitexporta.titdtven 
                               format "99/99/9999"   column-label "Dt.Vecto"
                        btitexporta.titdtpag 
                               format "99/99/9999"   column-label "Dt.Pagto"
                        btitexporta.titvlpag when titexporta.titvlpag > 0 
                               format ">>>,>>9.99" column-label "Valor Pago"
                        btitexporta.titsit 
                            with frame ff-lista down width 200.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            hide frame f-com2 no-pause.
            if  esqcom2[esqpos2] = "Pagamento/Cancelamento"
            then
              if  titexporta.titsit = "LIB" or titexporta.titsit = "IMP"
              then do with frame f-Paga overlay row 6 1 column centered.
                 display titexporta.titnum    colon 13
                        titexporta.titpar    colon 33 label "Pr"
                        titexporta.titdtemi  colon 13
                        titexporta.titdtven  colon 13 format "99/99/9999"
                        titexporta.titvlcob  colon 13 label "Vl.Cobr."
                        with frame fdadpg side-label
                        overlay row 6 color white/cyan width 40
                        title " titexporta ".
               titexporta.datexp = today.

               if  titexporta.modcod = "CRE" then do:
               /*    {titpagb4.i}  */
               end.
               else do:
                assign titexporta.titdtpag = today.
                display titexporta.titdtdes colon 13 label "Dt.Desc"
                            titexporta.titvldes colon 13 label "Desc Diario"
                            titexporta.titvljur colon 13
                            with frame fdadpg.
                update titexporta.titdtpag
                           with frame fpag1.
                if  titexporta.titdtpag > titexporta.titdtven then do:
                        assign titexporta.titvlpag = titexporta.titvlcob
                               + (titexporta.titvljur *
                                    (titexporta.titdtpag - titulo.titdtven)).
                end.
                else
                    if titexporta.titdtpag <= titexporta.titdtdes
                    then do:
                            titexporta.titvlpag = titexporta.titvlcob -
                                          (titexporta.titvldes *
                                     ((titulo.titdtdes - titulo.titdtpag) + 1)).
                    end.
                    else
                            titexporta.titvlpag = titexporta.titvlcob .
                assign vtitvlpag = titexporta.titvlpag.
                do on error undo, retry:
                    update titexporta.titvlpag with frame fpag1.
                    if titexporta.titvlpag > titexporta.titvlcob
                    then do:
                        bell.
                        message "Valor Invalido !!".
                        undo.
                    end.
                end.

                update titexporta.cobcod with frame fpag1.

                if titexporta.titvlpag >= titexporta.titvlcob
                then titexporta.titjuro = titexporta.titvlpag - titulo.titvlcob.
                else do:
                        assign sresp = no.
                        display "  Confirma PAGAMENTO PARCIAL ?"
                                with frame fpag color messages
                                width 40 overlay row 10 centered.
                    update sresp no-label with frame fpag.
                    if  sresp then do:
                        find last btitexporta where
                            btitexporta.empcod   = wempre.empcod and
                            btitexporta.titnat   = vtitnat       and
                            btitexporta.modcod   = vmodcod       and
                            btitexporta.etbcod   = vetbcod       and
                            btitexporta.clifor   = vclifor       and
                            btitexporta.titnum   = titexporta.titnum.
                            create ctitexporta.
                            assign
                                ctitexporta.empcod = btitexporta.empcod
                                ctitexporta.modcod = btitexporta.modcod
                                ctitexporta.clifor = btitexporta.clifor
                                ctitexporta.titnat = btitexporta.titnat
                                ctitexporta.etbcod = btitexporta.etbcod
                                ctitexporta.titnum = btitexporta.titnum
                                ctitexporta.cobcod = titexporta.cobcod
                                ctitexporta.titpar   = btitexporta.titpar + 1
                                ctitexporta.titdtemi = titexporta.titdtemi

                                ctitexporta.titdtven = if titexporta.titdtpag <
                                                      titexporta.titdtven
                                                   then titexporta.titdtven
                                                   else titexporta.titdtpag


                                ctitexporta.titnumger = titexporta.titnum
                                ctitexporta.titparger = titexporta.titpar
                                ctitexporta.datexp    = today
                                titexporta.titnumger = ctitexporta.titnum
                                titexporta.titparger = ctitexporta.titpar.
                            display
                                    ctitexporta.titnum
                                    ctitexporta.titpar
                                    ctitexporta.titdtemi
                                    ctitexporta.titdtven format "99/99/9999"
                                    ctitexporta.titvlcob
                                    with frame fmos width 40 1 column
                                              title " Titulo Gerado " overlay
                                              centered row 10.
                        end.
                        else
                            titulo.titdesc = titulo.titvlcob - titulo.titvlpag.
                end.
                find cobra of titexporta.
                if cobra.cobban
                then do with frame fbancpg :
                        update titexporta.titbanpag .
                        find banco where banco.bancod = titexporta.titbanpag.
                        display bandesc .
                        update titexporta.titagepag .
                        find agenc of banco
                            where agenc.agecod = titexporta.titagepag.
                        display agedesc no-label.
                        update titexporta.titchepag.
                end.
                update titexporta.titvljur label "Juros"
                       titexporta.titvldes label "Desconto" with frame fpag1.
                assign titexporta.titsit = "PAG".

               end.
               recatu1 = recid(titexporta).
               leave.
              end.
              else
                if  titexporta.titsit = "PAG" then do:
                    {segur.i 3}
                    display titexporta.titnum
                            titexporta.titpar
                            titexporta.titdtemi
                            titexporta.titdtven format "99/99/9999"
                            titexporta.titvlcob
                            titexporta.cobcod
                            with frame ftitexporta.
                    titexporta.datexp = today.
                    titexporta.cxmdat = ?.
                    titexporta.cxacod = 0.
                    display titexporta.titdtpag titulo.titvlpag titulo.cobcod
                            with frame fpag1.
                    message "Confirma o Cancelamento do Pagamento ?"
                            update sresp.
                    if  sresp then do:
                        message "Parcela deve ser Impressa ?"
                                update sresp.
                        assign titexporta.titsit    = if  sresp then
                                                      "IMP"
                                                  else
                                                      "LIB"
                               titexporta.titdtpag  = ?
                               titexporta.titvlpag  = 0
                               titexporta.titbanpag = 0
                               titexporta.titagepag = ""
                               titexporta.titchepag = ""
                               titexporta.datexp    = today.
                        find first b-titu where
                                   b-titu.empcod    =  titexporta.empcod and
                                   b-titu.titnat    =  titexporta.titnat and
                                   b-titu.modcod    =  titexporta.modcod and
                                   b-titu.etbcod    =  titexporta.etbcod and
                                   b-titu.clifor    =  titexporta.clifor and
                                   b-titu.titnum    =  titexporta.titnum and
                                   b-titu.titpar    <> titexporta.titpar and
                                   b-titu.titparger =  titexporta.titpar
                                   no-lock no-error.
                        if  avail b-titu then do:
                        display "Verifique Titulo Gerado do Pagamento Parcial"
                                with frame fver color messages
                                width 50 overlay row 10 centered.
                            pause.
                        end.
                   end.
                   recatu1 = recid(titexporta).
                   next bl-princ.
                end.

            if esqcom2[esqpos2]  = "Data Exportacao"
            then do:
                display titexporta.datexp format "99/99/9999"
                        with side-label centered row 10 color white/cyan
                             frame fexpo. 
                bell.
                message "Deseja marcar para exportar ?" update sresp.
                if sresp
                then do:
                    find titexporta where recid(titexporta) = recatu1.
                    titexporta.datexp = today.
                end.
            end.
            if esqcom2[esqpos2]  = "Bloqueio/Liberacao" and
               titexporta.titsit    <> "PAG"
            then do:
                if titexporta.titsit <> "BLO"
                then do:
                    message "Confirma o Bloqueio do titexporta ?" update sresp.
                    if  sresp then do:
                        titexporta.titsit = "BLO".
                        titexporta.datexp = today.
                    end.
                end.
                else
                    if titexporta.titsit = "BLO"
                    then do:
                        message "Confirma a Liberacao do Titulo ?" update sresp.
                        if  sresp then do:
                            titexporta.titsit = "IMP".
                            titexporta.datexp = today.
                        end.
                     end.
            end.
          end.
          view frame frame-a.
          view frame f-com2 .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        display
            titexporta.etbcobra
            titexporta.titnum
            titexporta.titpar
            titexporta.clifor
            titexporta.titvlcob
            titexporta.titdtven format "99/99/9999"
            titexporta.titdtpag
            titexporta.titvlpag when titexporta.titvlpag > 0
            titexporta.titsit
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(titexporta).
   end.
end.
end.
