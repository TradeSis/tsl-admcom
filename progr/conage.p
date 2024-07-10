/*----------------------------------------------------------------------------*/
/* finan/agendli.p                                          Agenda - Listagem */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{admcab.i}

def var vtitvlcob like titulo.titvlcob.
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
    wtotger = 0.
    disp "" @ wetbcod colon 12.
    update wetbcod label "Estabelec." .
    if  wetbcod <> 0
       then do:
               find estab where
                          estab.etbcod =  wetbcod NO-LOCK.
               display etbnom no-label format "x(10)".
       end.
       else disp "TODOS" @ etbnom.
    wmodcod = "".
    update wmodcod validate(wmodcod = "" or
                            can-find(modal where modal.modcod = wmodcod),
                            "Modalidade nao cadastrada")
                            label "Modal/Natur" colon 12.
    display " - ".
    if wmodcod = "CRE"
       then wtitnat = no.
       else wtitnat = yes.
    update wtitnat no-label.
    repeat:
        wtotger = 0.
        wtot = 0.
        vtitvlcob = 0.
        wtitvlcob = 0.
        clear frame ff.
        clear frame fc.
        if wtitnat
           then do with column 1 side-labels 1 down width 48 row 4 frame ff:
             disp "" @ wclifor.
             update wclifor label "Fornecedor"
                help "Informe o codigo do Fornecedor ou <ENTER> para todos".
             if input wclifor <> "" and wclifor <> 0
                then do:
                        find forne where forne.forcod = input wclifor NO-LOCK.
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
                        find clien where clien.clicod = input wclicod NO-LOCK.
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
            vlog = yes.
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
            
            for each wmodal:
                display wmodal.modcod with frame f-mod no-box
                        side-label width 80 row 4.
            end.
        end.


        for each wmodal,
            each estab NO-LOCK,
            each titulo where titulo.empcod = wempre.empcod and
                              titnat   =   wtitnat          and
                              titulo.modcod = wmodal.modcod and
                              titulo.titdtven >= wdti       and
                              titulo.titdtven <= wdtf       and
                              titulo.etbcod = estab.etbcod  and
                            ( if wclifor = 0
                              then true
                              else titulo.clifor = wclifor ) and
                              (titsit   =   "LIB" or
                               titsit   =   "CON") no-lock
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
            /* find cobra of titulo no-lock. */
            form
                titulo.titdtven format "99/99/9999"   COLUMN-LABEL "Dt.Vecto"
                titulo.clifor format "99999999"
                vnome   format "x(20)"     column-label "Ag.Comercial"
                titulo.modcod column-label "Mod"
                titulo.titnum format "x(8)"
                titulo.titpar
                /*
                cobra.cobnom format "x(8)"       column-label "Cobranca"
                */
                titulo.titvlcob      column-label "Cobrado" format ">>>>,>>9.99"
                    with frame f2 width 80 10 down row 6.

            wtot = wtot + titvlcob + titvljur - titulo.titvldes.

            if first-of(titulo.titdtven)
            then display titulo.titdtven with frame f2.

            vtitvlcob = titulo.titvlcob + titulo.titvljur - titulo.titvldes.
            display titulo.clifor
                    vnome
                    titulo.modcod
                    titulo.titnum
                    titulo.titpar
                    /* cobra.cobnom */
                    /* vtitvlcob */
                    (titulo.titvlcob + titulo.titvljur - titulo.titvldes)
                             @ titulo.titvlcob
                        with frame f2. down with frame f2.

            if last-of(titulo.titdtven)
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
