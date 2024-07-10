/**    Esqueletao de Programacao                          titulo.p */

{admcab.i}

find first func where func.funcod = sfuncod and
                      func.etbcod = setbcod no-lock no-error.
def var vdtven like titulo.titdtven.
def var vano as int.
def var vmes as int.
def var vlog   as log.
def var vok as log.
def var reccont         as  int.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(14)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta",""].
def var esqcom2         as char format "x(22)" extent 3
            initial ["Pagamento/Cancelamento", "Bloqueio/Liberacao",
                        "Data Exportacao"].
def buffer btitulo      for titulo.
def buffer ctitulo      for titulo.
def buffer b-titu       for titulo.
def var vetbcod         like titulo.etbcod.
def var vmodcod         like titulo.modcod format "x(3)".
def var vtitnat         like titulo.titnat.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def var vclifor         like titulo.clifor.
def var wperdes         as dec format ">9.99 %" label "Perc. Desc.".
def var wperjur         as dec format ">9.99 %" label "Perc. Juros".
def var vtitvlpag       like titulo.titvlpag.
def var vtitvlcob       like titulo.titvlcob.
def var vdtpag          like titulo.titdtpag.
def var vdate           as   date.
def var vetbcobra       like titulo.etbcobra initial 0.
def var vcontrola       as   log initial no.
def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.
def var i as int.

form esqcom1
    with frame f-com1 row 5 no-box no-labels side-labels column 1.
form esqcom2
    with frame f-com2
        row screen-lines - 2 title " OPERACOES " no-labels column 1 centered.
{titfrm.i}
repeat:
    clear frame ff1 all.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    vlog = no.
    update vetbcod validate(can-find(estab where estab.etbcod = vetbcod),
                            "Estabelecimento Invalido") colon 25
           with frame ff1 side-labels row 3 width 80 color white/cyan.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame ff1.
    update vmodcod validate(can-find(modal where modal.modcod = vmodcod),
                            "Modalidade Invalida") colon 25
           with frame ff1.
    find modal where modal.modcod = vmodcod no-lock.
    display modal.modnom no-label with frame ff1.
    update vtitnat colon 25
           with frame ff1.
    hide frame ff1 no-pause.
    vcliforlab = if vtitnat
                 then "Fornecedor:"
                 else "   Cliente:".
    lclifor = if vtitnat
              then no
              else yes .

    display vcliforlab no-labels to 26 with frame ff1.
    prompt-for titulo.clifor validate(input titulo.clifor > 0, "")
         no-label colon 25 with frame ff1.
    if vtitnat
    then find forne where forne.forcod = input titulo.clifor no-lock.
    else find clien where clien.clicod = input titulo.clifor no-lock no-error.
    vclifor = input frame ff1 titulo.clifor .
    if avail clien
    then vclifornom = if vtitnat
                 then forne.fornom
                 else clien.clinom.
    disp vclifornom no-label with frame ff1.

    update v-consulta-parcelas-LP label " Considera apenas LP"
     help "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"
       colon 25
    with frame ff1  side-label .
    pause 0.    

    hide frame ff1 no-pause.
    
    display vetbcod vmodcod vtitnat
            v-consulta-parcelas-LP
            with frame ff no-box row 4 side-labels color white/red width 81.
    pause 0.

    assign
        esqregua = yes
        esqpos1  = 1
        esqpos2  = 1
        recatu1  = ?.

bl-princ:
repeat :
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find titulo where recid(titulo) = recatu1 no-lock.

    if not available titulo
    then do transaction:
        message "Cadastro de Titulos Vazio".
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.    
    recatu1 = recid(titulo).
    if esqregua
    then do:
        display esqcom1[esqpos1] with frame f-com1.
        color display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.

    repeat:
        run leitura (input "seg").
        if not available titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
        find titulo where recid(titulo) = recatu1 no-lock.
        on f7 recall.
        choose field titulo.titnum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  F7 PF7
                  page-up       page-down
                  tab PF4 F4 ESC return).

        if keyfunction(lastkey) = "RECALL"
        then do with frame fproc centered row 5 overlay color message
                            side-label:
            prompt-for titulo.titnum colon 10.
            find first titulo where
                        titulo.empcod   = wempre.empcod and
                        titulo.titnat   = vtitnat       and
                        titulo.modcod   = vmodcod       and
                        titulo.etbcod   = vetbcod       and
                        titulo.clifor   = vclifor       and
                        titulo.titnum  >= input titulo.titnum
                     no-lock    no-error.
            recatu1 = if avail titulo
                      then recid(titulo) else ?.
            leave.
        end.

        on f7 help.

        if keyfunction(lastkey) = "TAB"
        then do:
            if  esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                color display message esqcom2[esqpos2] with frame f-com2.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                color display message esqcom1[esqpos1] with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 3 then 3 else esqpos2 + 1.
                color display messages esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                color display messages esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                run leitura (input "down").
                if not avail titulo
                then leave.
                recatu1 = recid(titulo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                run leitura (input "up").
                if not avail titulo
                then leave.
                recatu1 = recid(titulo).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "cursor-down"
        then do:
            run leitura (input "down").
            if not avail titulo
            then next.
            color display white/red titulo.titnum with frame frame-a.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            run leitura (input "up").    
            if not avail titulo
            then next.
            color display white/red titulo.titnum with frame frame-a.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:

          if esqcom2[esqpos2] <> "Pagamento/Cancelamento" or
             esqcom2[esqpos2] <> "Bloqueio/Liberacao"
          then hide frame frame-a no-pause.
          display vcliforlab at 6 vclifornom
                with frame frame-b 1 down centered color blue/gray
                width 81 no-box no-label row 5 overlay.
          if esqregua
          then do:
          if esqcom1[esqpos1] = "Inclusao"
          then do:
            hide frame frame-a no-pause.
            hide frame frame-b no-pause.
            hide frame f-com1 no-pause.
            hide frame f-com2 no-pause.
            run fin/criacontrato.p (input vclifor, input vetbcod , input vmodcod,
                    output recatu1).
            leave.
          end.
          /*
            if esqcom1[esqpos1] = "Inclusao"
            then do with frame ftitulo transaction:
                create titulo.
                assign
                    titulo.empcod = wempre.empcod
                    titulo.titnat = vtitnat
                    titulo.modcod = vmodcod
                    titulo.etbcod = vetbcod
                    titulo.datexp = today
                    titulo.exportado = no
                    titulo.titsit = "LIB"
                    titulo.clifor = vclifor.

                update titulo.titnum
                       titulo.titpar
                       titulo.titdtemi
                       titulo.titdtven format "99/99/9999"
                       titulo.titvlcob
                       titulo.cobcod.
                find cobra where cobra.cobcod = titulo.cobcod no-lock.
                display cobra.cobnom .
                if cobra.cobban
                then do with frame fbanco:
                    update titulo.bancod.
                    find banco where banco.bancod = titulo.bancod no-lock.
                    display banco.bandesc .
                    update titulo.agecod.
                    find agenc of banco where agenc.agecod = titulo.agecod
                     no-lock.
                    display agedesc.
                end.
                wperjur = 0.
                update wperjur
                       with frame fjurdes.
                titulo.titvljur = titulo.titvlcob * (wperjur / 100).
                update titulo.titvljur with frame fjurdes .
                wperdes = 0.
                update titulo.titdtdes
                       wperdes
                       with frame fjurdes.
                titulo.titvldes = titulo.titvlcob * (wperdes / 100).
                update titulo.titvldes
                       with frame fjurdes.
                update text(titobs)
                       with frame fobs.
                pause 0.
                recatu1 = recid(titulo).
                leave.
            end.
          */
          
            if esqcom1[esqpos1] = "Alteracao" 
                    /*and titulo.modcod <> "CRE" */
                    
            then do with frame ftitulo TRANSACTION:
                /*{segur.i 1}*/
                FIND CURRENT TITULO EXCLUSIVE.
                
                vtitvlcob = titulo.titvlcob.
                titulo.datexp = today.
                titulo.exportado = no.
                vdtven = titulo.titdtven.
                disp titulo.titnum
                     titulo.titpar
                     titulo.titdtemi.
                     
                update titulo.titnum   when titulo.titnat
                       titulo.titpar   when titulo.titnat
                       titulo.titdtemi when titulo.titnat
                       titulo.titdtven format "99/99/9999"
                       .
                if titulo.titdtven <> vdtven
                then do:
                    sresp = yes.
                    message "Deseja alterar outros vencimentos?" update sresp.
                    if sresp
                    then do:
                        vmes = month(titulo.titdtven).
                        vano = year(titulo.titdtven).
                        if vmes = 12
                        then assign vmes = 1 
                                    vano = vano + 1.
                        else vmes = vmes + 1.            
                        for each btitulo where 
                                 btitulo.empcod   = titulo.empcod and
                                 btitulo.titnat   = titulo.titnat and
                                 btitulo.modcod   = titulo.modcod and
                                 btitulo.etbcod   = titulo.etbcod and
                                 btitulo.clifor   = titulo.clifor and
                                 btitulo.titnum   = titulo.titnum and
                                 btitulo.titpar   > titulo.titpar:

                            btitulo.titdtven = date(vmes,
                                                    day(titulo.titdtven),
                                                    vano).
                            
                            if month(btitulo.titdtven) = 12
                            then assign vmes = 1
                                        vano = vano + 1.
                            else vmes = vmes + 1.

                            btitulo.datexp = today.
                            btitulo.exportado = no.
                        end.            
                    end.
                end.        
                update titulo.titvlcob 
                       titulo.cobcod
                       titulo.etbcod   when titulo.titnat
                       titulo.etbcobra
                       with no-validate.
                       
                find cobra where cobra.cobcod = titulo.cobcod no-lock.
                display cobra.cobnom.
                if cobra.cobban
                then do with frame fbanco:
                    update titulo.bancod.
                    find banco where banco.bancod = titulo.bancod no-lock.
                    display banco.bandesc .
                    update titulo.agecod.
                    find agenc of banco where agenc.agecod = titulo.agecod
                               no-lock.
                    display agedesc.
                end.
                update titulo.titvljur with frame fjurdes .
                update titulo.titdtdes with frame fjurdes.
                update titulo.titvldes with frame fjurdes.
                update text(titobs)
                       with frame fobs.
                
                if titulo.titvlcob <> vtitvlcob
                then do:
                    sresp = yes.
                    message "Deseja alterar outros valores" update sresp.
                    if sresp
                    then do:
                        for each btitulo where 
                                 btitulo.empcod   = titulo.empcod and
                                 btitulo.titnat   = titulo.titnat and
                                 btitulo.modcod   = titulo.modcod and
                                 btitulo.etbcod   = titulo.etbcod and
                                 btitulo.clifor   = titulo.clifor and
                                 btitulo.titnum   = titulo.titnum and
                                 btitulo.titpar   > titulo.titpar:

                            btitulo.titvlcob = titulo.titvlcob.
                            btitulo.datexp = today.
                            btitulo.exportado = no.
                        end.            
                    end.
                end.  
                if  titulo.titvlcob <> vtitvlcob and sresp = no
                then do:
                   if  titulo.titvlcob < vtitvlcob then do:
                    assign sresp = yes.
                    display "  Confirma GERACAO DE NOVO TITULO ?"
                                with frame fGERT color messages
                                width 60 overlay row 10 centered.
                    update sresp no-label with frame fGERT.
                    if sresp
                    then do:
                        find last btitulo where
                            btitulo.empcod   = wempre.empcod and
                            btitulo.titnat   = vtitnat       and
                            btitulo.modcod   = vmodcod       and
                            btitulo.etbcod   = vetbcod       and
                            btitulo.clifor   = vclifor       and
                            btitulo.titnum   = titulo.titnum.
                            create ctitulo.
                            assign
                                ctitulo.empcod = btitulo.empcod
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
                                ctitulo.datexp    = today
                                ctitulo.exportado = no.
                            display
                                    ctitulo.titnum
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
                        if not sresp
                        then undo, leave.
                    end.
                end.
                
                FIND CURRENT TITULO NO-LOCK.
                
            end.
            if (esqcom1[esqpos1] = "Consulta" or
                esqcom1[esqpos1] = "Exclusao") and vlog = no
            then do:
                find modal of titulo no-lock no-error.
                disp titulo.modcod
                     modal.modnom when available modal
                     titulo.titnum
                     titulo.titpar
                     titulo.titdtemi
                     titulo.titdtven format "99/99/9999"
                     titulo.titvlcob
                     titulo.cobcod
                     titulo.titparger
                     titulo.titnumger with frame ftitulo.

                disp titulo.titvljur
                     titulo.titjuro
                     titulo.titdtpag
                     titulo.titvlpag
                     titulo.etbcob
                     titulo.etbcobra
                     titulo.datexp format "99/99/9999"
                     titulo.cxmdat
                     titulo.cxacod with frame fjurdes.
            end.
            if esqcom1[esqpos1] = "Exclusao"  and
               (titulo.clifor = 1 or
                titulo.clifor = 10 or
                titulo.clifor = 20) 
            then do with frame f-exclui overlay row 6 1 column centered
                TRANSACTION.
                
            if vlog = no
            then do:
                {segur.i 2}
            end. 
                message "Confirma Exclusao de Titulo"
                            titulo.titnum ",Parcela" titulo.titpar
                    update sresp.
                if not sresp
                then leave.
                find next titulo where
            titulo.empcod   = wempre.empcod and
            titulo.titnat   = vtitnat       and
            titulo.modcod   = vmodcod       and
            titulo.etbcod   = vetbcod       and
            titulo.clifor   = vclifor 
            NO-LOCK no-error.
                if not available titulo
                then do:
                    find titulo where recid(titulo) = recatu1 NO-LOCK.
                    find prev titulo where
            titulo.empcod   = wempre.empcod and
            titulo.titnat   = vtitnat       and
            titulo.modcod   = vmodcod       and
            titulo.etbcod   = vetbcod       and
            titulo.clifor   = vclifor NO-LOCK no-error.
                end.
                recatu2 = if available titulo
                          then recid(titulo)
                          else ?.
                find titulo where recid(titulo) = recatu1 EXCLUSIVE.
                delete titulo.
                recatu1 = recatu2.
                vlog = yes.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de Titulos" update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each titulo NO-LOCK :
                    display titulo.
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
              if titulo.titsit = "LIB" or titulo.titsit = "IMP"
              then do with frame f-Paga overlay row 6 1 column centered
                TRANSACTION.
                FIND CURRENT TITULO EXCLUSIVE.
                 display titulo.titnum    colon 13
                        titulo.titpar    colon 33 label "Pr"
                        titulo.titdtemi  colon 13
                        titulo.titdtven  colon 13 format "99/99/9999"
                        titulo.titvlcob  colon 13 label "Vl.Cobr."
                        with frame fdadpg side-label
                        overlay row 6 color white/cyan width 40
                        title " Titulo ".
               titulo.datexp = today.
               titulo.exportado = no.
               if  titulo.modcod = "CRE" 
               then do:
                   {titpagb4.i}
               end.
               else do:
               
                assign titulo.titdtpag = today.
                display titulo.titdtdes colon 13 label "Dt.Desc"
                            titulo.titvldes colon 13 label "Desc Diario"
                            titulo.titvljur colon 13
                            with frame fdadpg.
                update titulo.titdtpag
                           with frame fpag1.
                if  titulo.titdtpag > titulo.titdtven then do:
                        assign titulo.titvlpag = titulo.titvlcob
                               + (titulo.titvljur *
                                    (titulo.titdtpag - titulo.titdtven)).
                end.
                else if titulo.titdtpag <= titulo.titdtdes
                     then do:
                        titulo.titvlpag = titulo.titvlcob -
                                          (titulo.titvldes *
                                     ((titulo.titdtdes - titulo.titdtpag) + 1)).
                     end.
                     else titulo.titvlpag = titulo.titvlcob .
                assign vtitvlpag = titulo.titvlpag.
                do on error undo, retry:
                    update titulo.titvlpag with frame fpag1.
                    if titulo.titvlpag > titulo.titvlcob
                    then do:
                        bell.
                        message "Valor Invalido !!".
                        undo.
                    end.
                end.

                update titulo.cobcod with frame fpag1.

                if titulo.titvlpag >= titulo.titvlcob
                then titulo.titjuro = titulo.titvlpag - titulo.titvlcob.
                else do:
                    assign sresp = no.
                    display "  Confirma PAGAMENTO PARCIAL ?"
                                with frame fpag color messages
                                width 40 overlay row 10 centered.
                    update sresp no-label with frame fpag.
                    if sresp 
                    then do:
                        find last btitulo where
                            btitulo.empcod   = wempre.empcod and
                            btitulo.titnat   = vtitnat       and
                            btitulo.modcod   = vmodcod       and
                            btitulo.etbcod   = vetbcod       and
                            btitulo.clifor   = vclifor       and
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
                                ctitulo.exportado = no
                                 titulo.titnumger = ctitulo.titnum
                                 titulo.titparger = ctitulo.titpar.
                        display ctitulo.titnum
                                ctitulo.titpar 
                                ctitulo.titdtemi 
                                ctitulo.titdtven format "99/99/9999"                                 ctitulo.titvlcob
                                    with frame fmos width 40 1 column
                                              title " Titulo Gerado " overlay
                                              centered row 10.
                    end.
                    else titulo.titdesc = titulo.titvlcob - titulo.titvlpag.
                end.
                find cobra of titulo no-lock.
                if cobra.cobban
                then do with frame fbancpg :
                        update titulo.titbanpag .
                        find banco where banco.bancod = titulo.titbanpag.
                        display bandesc .
                        update titulo.titagepag .
                        find agenc of banco
                            where agenc.agecod = titulo.titagepag.
                        display agedesc no-label.
                        update titulo.titchepag.
                end.
                update titulo.titvljur label "Juros"
                       titulo.titvldes label "Desconto" with frame fpag1.
                assign titulo.titsit = "PAG".

               end.
               recatu1 = recid(titulo).
               leave.
              end.
              else
                if  titulo.titsit = "PAG" then do
                    TRANSACTION:
                    FIND CURRENT TITULO EXCLUSIVE.
                    {segur.i 3}
                    display titulo.titnum
                            titulo.titpar
                            titulo.titdtemi
                            titulo.titdtven format "99/99/9999"
                            titulo.titvlcob
                            titulo.cobcod
                            with frame ftitulo.
                    titulo.datexp = today.
                    titulo.exportado = no.
                    titulo.cxmdat = ?.
                    titulo.cxacod = 0.
                    display titulo.titdtpag titulo.titvlpag titulo.cobcod
                            with frame fpag1.
                    message "Confirma o Cancelamento do Pagamento ?"
                            update sresp.
                    if  sresp then do:
                        assign titulo.titsit    = "LIB"
                               titulo.titdtpag  = ?
                               titulo.titvlpag  = 0
                               titulo.titbanpag = 0
                               titulo.titagepag = ""
                               titulo.titchepag = ""
                               titulo.datexp    = today
                               titulo.exportado = no.
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
                        /*Conecat filial*/
                        run con-filial.

                   end.
                   recatu1 = recid(titulo).
                   next bl-princ.
                end.

            if esqcom2[esqpos2]  = "Data Exportacao"
            then do TRANSACTION:
                display titulo.datexp format "99/99/9999"
                        with side-label centered row 10 color white/cyan
                             frame fexpo.
                bell.
                message "Deseja marcar para exportar ?" update sresp.
                if sresp
                then do:
                    find titulo where recid(titulo) = recatu1
                        EXCLUSIVE.
                    titulo.datexp = today.
                    titulo.exportado = no.
                end.
            end.
            /*
            if esqcom2[esqpos2]  = "Bloqueio/Liberacao" and
               titulo.titsit    <> "PAG"
            then do:
                if titulo.titsit <> "BLO"
                then do:
                    message "Confirma o Bloqueio do Titulo ?" update sresp.
                    if  sresp then do TRANSACTION:
                        FIND CURRENT TITULO EXCLUSIVE.
                        titulo.titsit = "BLO".
                        titulo.datexp = today.
                        titulo.exportado = no.
                    end.
                end.
                else
                    if titulo.titsit = "BLO"
                    then do:
                        message "Confirma a Liberacao do Titulo ?" update sresp.
                        if  sresp then do TRANSACTION:
                            
                            FIND CURRENT TITULO EXCLUSIVE.
                            
                            titulo.titsit = "IMP".
                            titulo.datexp = today.
                            titulo.exportado = no.
                        end.
                     end.
            end.  */

          end.
        end.

        run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(titulo).
   end.
end.

hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

end.

procedure con-filial:
    def var vfilial as int.
    def var vip as char.
    def var vstatus as char.
    
    message "Informe a Filial para conectar" update vfilial.
    
    if vfilial > 0
    then do:
    vip = "filial" + string(vfilial,"999").
    
    message "Conectando...>>>>>   " vip.
  
    connect fin -H value(vip) -S sdrebfin -N tcp -ld finloja.
    
    if not connected ("finloja")
    then do:
        vstatus = "FALHA NA CONEXAO COM A FILIAL".
    end.
    else do:        
    run atutifil.p ( recid(titulo), output vstatus ). 
    /*
    output to atutifil.log.
        put today "   "  vip format "x(15)" skip   
            vstatus format "x(60)" skip
            .
    output close.
    */             
    if connected ("finloja")
    then disconnect finloja.
    end.
    message color red/with
        vstatus view-as alert-box.
    end.
end procedure.



procedure frame-a.
    display
        titulo.titnum
        titulo.titpar   format ">>9"
        titulo.titdtemi format "99/99/9999" column-label "Dt.Emis"
        titulo.titvlcob format ">>>,>>9.99" column-label "Vl. Cobrado"
        titulo.titdtven format "99/99/9999" column-label "Dt.Vecto"
        titulo.titdtpag format "99/99/9999" column-label "Dt.Pagto"
        titulo.titvlpag when titulo.titvlpag > 0 format ">>>,>>9.99"
                                            column-label "Valor Pago"
        titulo.titsit
        titulo.tpcontrato
        with frame frame-a 9 down centered color white/red row 6
            title " " + vcliforlab + " " + vclifornom + " "
                    + " Cod.: " + string(vclifor) + " ".

end procedure.


procedure leitura.

def input parameter par-tipo as char.

def var recatu as recid.
        
if par-tipo = "pri" 
then do.
        find first titulo where
                           titulo.empcod   = 19 and
                           titulo.titnat   = vtitnat       and
                           titulo.modcod   = vmodcod       and
                           titulo.etbcod   = vetbcod and
                           titulo.clifor   = vclifor
                                no-lock no-error.
        if avail titulo
        then do:
            if (v-consulta-parcelas-LP = yes and titulo.tpcontrato <> "L") or
               (v-consulta-parcelas-LP = no  and titulo.tpcontrato = "L")
            then par-tipo = "seg".
            else recatu = recid(titulo).
        end.
end.

if par-tipo = "seg" or par-tipo = "down" 
then
    repeat:
        find next titulo where
                           titulo.empcod   = 19 and
                           titulo.titnat   = vtitnat       and
                           titulo.modcod   = vmodcod       and
                           titulo.etbcod   = vetbcod       and
                           titulo.clifor   = vclifor      
                                no-lock no-error.
        if avail titulo
        then
            if (v-consulta-parcelas-LP = yes and titulo.tpcontrato <> "L") or
               (v-consulta-parcelas-LP = no  and titulo.tpcontrato = "L")
            then next.
            else do.
                recatu = recid(titulo).
                leave.
            end.
        else leave.
    end.
             
if par-tipo = "up" 
then
    repeat:
        find prev titulo where
                           titulo.empcod   = 19 and
                           titulo.titnat   = vtitnat       and
                           titulo.modcod   = vmodcod       and
                           titulo.etbcod   = vetbcod       and
                           titulo.clifor   = vclifor      
                                no-lock no-error.
        if avail titulo
        then
            if (v-consulta-parcelas-LP = yes and titulo.tpcontrato <> "L") or
               (v-consulta-parcelas-LP = no  and titulo.tpcontrato = "L")
            then next.
            else do.
                recatu = recid(titulo).
                leave.
            end.
        else leave.
    end.

    if recatu <> ?
    then find titulo where recid(titulo) = recatu no-lock.

end procedure.
 
