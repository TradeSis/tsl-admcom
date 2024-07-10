/*----------------------------------------------------------------------------*/
/* finan/pag.p                                          Agenda - Listagem */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{ADMCAB.i}
def temp-table wpag
    field wcod like titulo.clifor
    field wnome like forne.fornom
    field wmodcod like titulo.modcod
    field wdes  like titulo.titvlcob
    field wjur  like titulo.titvlcob
    field wcob  like titulo.titvlcob
    field wpag  like titulo.titvlcob.
def var vcob like titulo.titvlpag.
def var vpag like titulo.titvlpag.
def var vdes like titulo.titvlpag.
def var vjur like titulo.titvlpag.
def var vacum like titulo.titvlpag.
def var vlog as log.
def var vdt as date.
def var vmodcod like modal.modcod.
def temp-table wmodal like modal.
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
    disp "" @ wetbcod colon 12.
    update wetbcod label "Estabelec." .
    if  wetbcod <> 0
       then do:
               find estab where
                          estab.etbcod =  wetbcod.
               display etbnom no-label format "x(10)".
       end.
       else disp "TODOS" @ etbnom.
    for each wpag:
        delete wpag.
    end.

    update wmodcod validate(wmodcod = "" or
                            can-find(modal where modal.modcod = wmodcod),
                            "Modalidade nao cadastrada")
                            label "Modal/Natur" colon 12.
    display " - ".
    if wmodcod = "CRE"
       then wtitnat = no.
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
            vlog = no.
            repeat:
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
            vlog = yes.
        end.
        wtot = 0.
        {confir.i 1 "impressao de Agenda Financeira"}

        vtitrel = if wtitnat
                  then "PAGAR"
                  else "RECEBER" .


        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "119"
            &Page-Line = "66"
            &Nom-Rel   = ""PAG""
            &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" + vtitrel "
            &Tit-Rel   = """PAGAMENTOS FINANCEIRA - PERIODO DE "" +
                                  string(wdti,""99/99/9999"") + "" A "" +
                                  string(wdtf,""99/99/9999"") "
            &Width     = "119"
            &Form      = "frame f-cabcab"}

        if vlog = no
        then put skip "TODAS MODALIDADES" skip.
        else do:
            put skip
                "MODALIDADES: ".

            for each wmodal:
                put wmodal.modcod ", ".
            end.
            put skip(1).
        end.
        vacum = 0.
        vcob  =  0.
        vjur  =  0.
        vdes  =  0.
        vpag  =  0.

        do vdt = wdti to wdtf:
        for each wmodal,
            each titulo where titulo.empcod = wempre.empcod and
                              titnat   =   wtitnat          and
                              titulo.modcod = wmodal.modcod and
                              titdtpag =  vdt        and
                            ( if wetbcod = 0
                                 then true
                                 else titulo.etbcod = wetbcod ) and
                            ( if wclifor = 0
                              then true
                              else titulo.clifor = wclifor ) and
                              titsit   =   "PAG" no-lock break by titulo.clifor:

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
            find first wpag where wpag.wcod = titulo.clifor and
                                  wpag.wmodcod = titulo.modcod no-error.
            if not avail wpag
            then do:
                create wpag.
                assign wpag.wcod = titulo.clifor
                       wpag.wnome = vnome
                       wpag.wmodcod = titulo.modcod.
            end.
            wpag.wcob  = wpag.wcob  + titulo.titvlcob.
            wpag.wjur  = wpag.wjur  + titulo.titvljur.
            wpag.wdes  = wpag.wdes  + titulo.titvldes.
            wpag.wpag  = wpag.wpag  + titulo.titvlpag.
        end.
        end.
        for each wpag break by wpag.wmodcod
                            by wpag.wnome:
            vacum = vacum + wpag.wpag.
            display wpag.wcod
                    wpag.wnome
                    wpag.wmodcod
                    wpag.wcob
                         column-label "Vl.Cobrado" format "->,>>>,>>9.99"
                    wpag.wjur column-label "Juros" format "->,>>>,>>9.99"
                    wpag.wdes column-label "Desconto"   format "->,>>>,>>9.99"
                    wpag.wpag format "->,>>>,>>9.99"
                            column-label "Vl.Pago"
                    vacum column-label "Acumulado" format "->,>>>,>>9.99"
                            with frame f-pag width 150 down.
            if last-of(wpag.wmodcod)
            then do:
                vacum = 0.
                put skip(1).
            end.

        end.
        output close.
    end.
end.
