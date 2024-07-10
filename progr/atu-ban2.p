/*----------------------------------------------------------------------------*/
/* finan/agendli.p                                          Agenda - Listagem */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{admcab.i}
def temp-table tt-estab like estab.
def temp-table wtitulo like titulo.
def var vlog as log.
def var vdt as date.
def var vmodcod like modal.modcod.
def workfile wmodal like modal.
def var wtotger like titulo.titvlcob.
def var vnome like clien.clinom.
def var recatu2 as recid.
def var vtitrel     as char format "x(50)".
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat.
def var wclifor like titulo.clifor initial 0.
def var wclicod like clien.clicod initial 0.
def var wdti    like titulo.titdtven label "Periodo" initial today.
def var wdtf    like titulo.titdtven.
def var wtitvlcob like titulo.titvlcob.
def var wtot      as dec format ">,>>>,>>>,>>9.99" label "Total".
def var wseq as i extent 2.
def var i as i.
def var wbar as c label "/" initial "/" format "x".
def var wclfnom as char format "x(30)" label "clfnom".
def var wforcli as i format "999999" label "For/Cli".
wdtf = wdti + 30.
wtotger = 0.
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
    wtotger = 0.
    disp "" @ wetbcod colon 12.
    for each wtitulo.
        delete wtitulo.
    end.
    for each tt-estab:
        delete tt-estab.
    end.
    update wetbcod label "Estabelec." .
    if  wetbcod <> 0
       then do:
               find estab where
                          estab.etbcod =  wetbcod.
               display etbnom no-label format "x(10)".
       end.
       else disp "TODOS" @ etbnom.

    if wetbcod = 0
    then do:
        for each estab no-lock:
            create tt-estab.
            assign tt-estab.etbcod = estab.etbcod.
        end.
    end.
    else do:
        create tt-estab.
        assign tt-estab.etbcod = wetbcod.
    end.
    update wmodcod validate(wmodcod = "" or
                            can-find(modal where modal.modcod = wmodcod),
                            "Modalidade nao cadastrada")
                            label "Modal/Natur" colon 12.
    display " - ".
    if wmodcod = "CRE"
       then wtitnat = no.
    wtitnat = yes.
    update wtitnat no-label.
    repeat:
        clear frame ff.
        clear frame fc.
        if wtitnat
        then do with column 1 side-labels 1 down width 48 row 4 frame ff:
             disp "" @ wclifor.
             update wclifor label "Fornecedor"
                help "Informe o codigo do Fornecedor ou <ENTER> para todos".
             if input wclifor <> "" and wclifor <> 0
                then do:
                        find forne where forne.forcod = input wclifor.
                        display fornom format "x(32)" no-label at 10.
                end.
                else disp "RELATORIO DE TODOS OS FORNECEDORES" @ fornom.
        end.
        else do with column 1 side-labels 1 down width 48 row 4 frame fc:
             disp "" @ wclicod.
             prompt-for wclicod label "Cliente"
                help "Informe o codigo do Cliente ou <ENTER> para todos".
             if input wclicod <> ""
                then do:
                        find clien where clien.clicod = input wclicod.
                        display clinom format "x(32)" no-label at 10.
                end.
                else disp "RELATORIO DE TODOS OS CLIENTES" @ clinom.
        end.
        if not wtitnat
        then wclifor = wclicod.
        else wclifor = wclifor.

        form wdti colon 12
             " A"
             wdtf colon 29 no-label with frame fdat width 80 side-label.

        update wdti
               wdtf with frame fdat.
        for each wmodal:
            delete wmodal.
        end.
        if wmodcod = ""
        then do:
            for each modal no-lock:
                create wmodal.
                assign wmodal.modcod = modal.modcod
                       wmodal.modnom = modal.modnom.
            end.
            repeat:
                vlog = no.
                update vmodcod with frame f-modal centered side-label.
                find first wmodal where wmodal.modcod = vmodcod
                                                            no-lock no-error.
                if not avail wmodal
                then do:
                    message "Modalidade Invalida".
                    undo, retry.
                end.
                display wmodal.modnom no-label with frame f-modal.
                delete wmodal.
                vlog = yes.
            end.
        end.
        else do:
            create wmodal.
            assign wmodal.modcod = wmodcod.
        end.
        wtot = 0.

        vtitrel = if wtitnat
                  then "PAGAR"
                  else "RECEBER" .
        hide frame fdat no-pause.
        hide frame f-modal no-pause.
        hide frame fc no-pause.
        hide frame f1 no-pause.
        hide frame ff no-pause.

        if vlog = no
        then display "TODAS MODALIDADES" with frame f-mod no-box.
        else do:
            put skip.
            for each wmodal:
                display wmodal.modcod with frame f-mod no-box
                        side-label width 80 row 4.
            end.
        end.

        form vnome   format "x(17)"     column-label "Ag.Comercial"
             titulo.titnum format "x(8)"
             titulo.titpar
             titulo.cobcod format "9" column-label "C"
             titulo.bancod
             titulo.titvldes column-label "Desconto" format ">>>,>>9.99"
             titulo.titvljur column-label "Juros" format ">>>,>>9.99"
             titulo.titvlcob      column-label "Cobrado" format ">>>>,>>9.99"
                   with frame f2 width 80 10 down row 6.

        do vdt = wdti to wdtf:

        for each wmodal,
            each tt-estab,
            each titulo where titulo.empcod = wempre.empcod and
                              titnat   =   wtitnat          and
                              titulo.modcod = wmodal.modcod and
                              titdtven =  vdt               and
                              titulo.etbcod = tt-estab.etbcod  and
                            ( if wclifor = 0
                              then true
                              else titulo.clifor = wclifor ) and
                            ( titsit   = "LIB" or
                              titsit   = "CON")
                                 break by titulo.titdtven:
            if wtitnat
            then do:
                find forne where forne.forcod = titulo.clifor no-lock no-error.
                if avail forne
                then vnome = forne.fornom.
                else vnome = "".
            end.
            else do:
                find clien where clien.clicod = titulo.clifor no-lock.
                vnome = clien.clinom.
            end.
            create wtitulo.
            ASSIGN wtitulo.empcod    = titulo.empcod
                   wtitulo.modcod    = titulo.modcod
                   wtitulo.titnat    = titulo.titnat
                   wtitulo.clifor    = titulo.clifor
                   wtitulo.titnumger = vnome
                   wtitulo.titnum    = titulo.titnum
                   wtitulo.titpar    = titulo.titpar
                   wtitulo.etbcod    = titulo.etbcod
                   wtitulo.titdtemi  = titulo.titdtemi
                   wtitulo.titdtven  = titulo.titdtven
                   wtitulo.titvlcob  = titulo.titvlcob
                   wtitulo.titdtdes  = titulo.titdtdes
                   wtitulo.titvldes  = titulo.titvldes
                   wtitulo.cobcod    = titulo.cobcod
                   wtitulo.bancod    = titulo.bancod
                   wtitulo.agecod    = titulo.agecod
                   wtitulo.titdtpag  = titulo.titdtpag
                   wtitulo.titvlpag  = titulo.titvlpag
                   wtitulo.cxacod    = titulo.cxacod
                   wtitulo.evecod    = titulo.evecod.
        end.
        end.
        for each wtitulo break by wtitulo.titdtven
                               by wtitulo.titnumger.

            find titulo where titulo.empcod = wtitulo.empcod  and
                              titulo.modcod = wtitulo.modcod  and
                              titulo.titnat = wtitulo.titnat  and
                              titulo.etbcod = wtitulo.etbcod  and
                              titulo.clifor = wtitulo.clifor  and
                              titulo.titnum = wtitulo.titnum  and
                              titulo.titpar = wtitulo.titpar.
            wtot = wtot + titulo.titvlcob.
            display titulo.titdtven wtitulo.titdtven
                with frame ff2 row 5 side-label no-box.
            find cobra of titulo no-lock.
            vnome = wtitulo.titnumger.
            display vnome
                    titulo.titnum
                    titulo.titpar
                    titulo.titvlcob with frame f2.
            update titulo.cobcod 
                   titulo.bancod 
                   titulo.titvldes
                   titulo.titvljur with frame f2 with no-validate.

            if wtitnat and
               titulo.cobcod = 3 /* Bancario */
            then do.
                run fatu-codbar.p (recid(titulo)).
            end.
            down with frame f2.
            if last-of(wtitulo.titdtven)
            then do:
                display "-------------" @ titulo.titvlcob
                        with frame f2.
                down with frame f2.
                display wtot            @ titulo.titvlcob
                        with frame f2.
                wtotger = wtotger + wtot.
                wtot = 0.
                put skip(1).
            end.
        end.
        display wtotger label "Total Geral" with frame f3 side-label.
    end.
end.
