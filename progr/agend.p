/*----------------------------------------------------------------------------*/
/* agend.p                TITULOS EM ABERTO                                   */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var recatu2 as recid.
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat.
def var wclifor like titulo.clifor initial 0.
def var wclicod like clien.clicod  initial 0.
def var wdti    like titulo.titdtven label "Periodo" initial today.
def var wdtf    like titulo.titdtven.
def var vtitvlcob like titulo.titvlcob.
def var wtot      as dec format ">>>,>>>,>>9.99" label "Total".
def var wtotcon   as dec format ">>9" label "Total Consultados".
def var wseq as i extent 2.
def var i as i.
def var wopcao as char.
def var wforcli as i format "999999" label "For/Cli".
def var vapenom like clien.clinom.
def var wempcod like empre.empcod.
define  temp-table wktit
        field seq as    i label "Nr" format ">>99"
        field modcod    like titulo.modcod
        field clfcod    like clien.clicod
        field clfnom    like clien.clinom

        field titvlpag  like titulo.titvlpag
        field titvljur  like titulo.titvljur
        field titvldes  like titulo.titvldes

        field titnum    like titulo.titnum
        field titpar    like titulo.titpar
        field cobcod    like titulo.cobcod
        field titdtven  like titulo.titdtven
        field titvlcob  like titulo.titvlcob
        field etbcod     like titulo.etbcod
        field rec       as   recid.
wdtf = wdti + 30.
repeat with column 51 side-labels 1 down width 30 row 4 frame f1
                    color black/cyan:
    wempcod = 0.
    clear frame f1 all.
    disp "" @ wetbcod colon 12.
    update wetbcod label "Estab" .

    if wetbcod <> 0
       then do:
               find estab where
                         estab.etbcod = wetbcod no-lock.
               display etbnom no-label format "x(10)".
               wetbcod = estab.etbcod.
               wempcod = wempre.empcod.
       end.
       else disp "TODOS" @ etbnom.

    update wmodcod validate(wmodcod = "" or
                            can-find(modal where modal.modcod = wmodcod),
                            "Modalidade nao cadastrada")
                            label "Modal/Natur" colon 12.

    display " - ".
    if wmodcod = "CRE"
       then wtitnat = no.
    update wtitnat no-label.
    repeat:
        wtotcon = 0.
        clear frame ff all.
        clear frame fc all.
        if wtitnat
           then do with column 1 side-labels 1 down width 48 row 4 frame ff:
             disp "" @ wclifor.
             update wclifor label "Fornecedor"
                help "Informe o codigo do Fornecedor ou <ENTER> para todos".
             if input wclifor <> ""
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
        form wdti colon 12
             " A"
             wdtf colon 29 no-label with frame fdat width 80 side-label.

        form wtot colon 12 skip
             wtotcon  with frame ftot width 30
                        row 8 column 51 side-label color black/cyan .

        update wdti
               wdtf with frame fdat.

        if wdti > wdtf
        then do:
            bell.
            message "Data Final deve ser maior que Data Inicial".
            pause.
            undo.
        end.

        for each wktit:
            delete wktit.
        end.
        assign wseq[1] = 0
               i = 0
               wtot = 0.
    for each titulo where titulo.empcod = wempre.empcod and
                          titulo.titnat =   wtitnat     and
                          ( if wmodcod = ""
                            then true
                            else titulo.modcod = wmodcod ) and
                          titulo.titdtven >= wdti and
                          titulo.titdtven <= wdtf and
                          ( if wetbcod = 0
                            then true
                            else titulo.etbcod = wetbcod ) and
                          ( if wclifor = 0
                            then true
                            else titulo.clifor = wclifor ) and
                          titsit   =   "LIB"
                             NO-LOCK:
                       /*       break by titulo.titdtven
                                    by titulo.clifor
                                    by titulo.modcod
                                    by titulo.titnum
                                    by titulo.titpar: */

            if wtitnat
            then find forne where forne.forcod = titulo.clifor NO-LOCK.
            else find clien where clien.clicod = titulo.clifor no-lock.
            create wktit.
            i = i + 1.
            assign seq = i
                   wktit.rec      = recid(titulo)
                   wktit.etbcod   = titulo.etbcod
                   wktit.modcod   = titulo.modcod
                   wktit.clfcod   = titulo.clifor
                   wktit.clfnom   = (if wtitnat
                                     then forne.fornom
                                     else clien.clinom)
                   wktit.titvlpag = titulo.titvlpag
                   wktit.titvljur = titulo.titvljur
                   wktit.titvldes = titulo.titvldes

                   wktit.titnum   = titulo.titnum
                   wktit.titpar   = titulo.titpar
                   wktit.cobcod   = titulo.cobcod
                   wktit.titdtven = titulo.titdtven
                   wktit.titvlcob = titulo.titvlcob
                   wktit.etbcod   = titulo.etbcod
                   wtotcon        = wtotcon + 1.
            /*
            {titvlatu.ini vtitvlcob}
            */
            wtot = wtot + vtitvlcob.


        end.
        disp wtot wtotcon with frame ftot.
        l1:
        repeat with frame f2 6 down width 80:

            form    wktit.seq
                    wktit.titdtven format "99/99/99" column-label "Dt.Vecto"
                 /*wktit.titvlpag column-label "VL.Titulo" format ">>,>>9.99"*/
                    wktit.titvlcob  format ">,>>,>>9.99"
                                    column-label "Vl.Titulo"
                  vtitvlcob column-label "DESC/ENC." format "->,>>9.99"
                    /*wktit.clfnom  format "x(23)"*/
                    vapenom format "x(20)" column-label "Nome - Apelido"
                    wktit.titnum
                    wktit.titpar
                    wktit.modcod
                 /* wktit.clfcod */
                    with frame f2 6 down width 80 row 12 color black/cyan .


            for each wktit where seq >= wseq[1]
                                 i = 1 to 6:
            vtitvlcob = 0.
            /*
            {titvlatu.ini vtitvlcob}
            */
            vtitvlcob = vtitvlcob - wktit.titvlcob.
            vapenom = wktit.clfnom.

                display wktit.seq
                        /*wktit.clfnom*/
                        vtitvlcob
                        vapenom
                        wktit.titnum
                        wktit.titpar
                        wktit.titdtven
                        wktit.titvlcob
                        wktit.modcod with frame f2.
                down with frame f2.
                if i = 1
                   then wseq[1] = seq.
                wseq[2] = seq.
            end.
            if wtot = 0
               then do:
                    find first wktit no-error.
                    if not avail wktit
                    then do:
                       message "Nenhum Titulo p/ este Periodo".
                       undo.
                    end.
               end.
            up frame-line (f2) - 1 with frame f2.
            repeat on endkey undo,leave l1:
               hide frame f4f.
               hide frame f4c.
               hide frame f5.
               hide frame f6c.
               hide frame f7.
               choose row wktit.seq
                help "[C] para Consulta,[A] para Ag.Comercial, PG-DOWN e PG-UP"
                             go-on(PAGE-DOWN PAGE-UP C c A a)
                             with frame f2.
               wopcao = keyfunction(lastkey).
             if wopcao = "PAGE-UP"
                then do:
                        hide message no-pause.
                        find last wktit where seq < wseq[1] no-error.

                        if not available wktit
                           then do:
                                   message "Nao ha mais registros".
                                   pause.
                                   undo.
                           end.

                          for each wktit where seq < wseq[1]
                                             by seq descending
                                             i = 1 to frame-down (f2):

                             if i = 1
                                 then wseq[2] = seq.
                              if i = frame-down (f2)
                                 then wseq[1] = seq.
                          end.
                          clear frame f2 all.
                          leave.
                end.
             if wopcao = "PAGE-DOWN"
                then do:
                        hide message no-pause.
                        find first wktit where seq > wseq[2] no-error.

                        if not available wktit
                           then do:
                                   message "Nao ha mais registros".
                                   pause.
                                   undo.
                           end.

                        wseq[1] = seq.
                        clear frame f2 all.
                        leave.
                end.
             form titulo.titdtemi colon 15
                  titulo.titvljur colon 57
                  titulo.titdtven colon 15
                  titulo.titvlcob colon 15
                  titulo.titvldes colon 57 label "Desc.Variavel"
                  titulo.cobcod colon 15
                  cobra.cobnom no-label at 20
                  with side-labels 1 down width 80 frame f5 overlay
                                        color black/cyan.
            if wopcao = "C"  or
                wopcao = "c"
                then do:
                if input wktit.seq = 0
                    then do:
                    message "Escolha uma das linhas preenchidas".
                    undo.
                end.
                find first wktit where wktit.seq = input wktit.seq.
                find titulo where recid(titulo) = wktit.rec NO-LOCK.

                if titulo.titnat
                    then do:
                    find forne where forne.forcod = titulo.clifor no-lock.
                    display titulo.clifor colon 15
                            forne.fornom  no-label colon 30
                            titulo.titnum colon 15
                            titulo.titpar colon 57
                            with side-labels 1 down width 80
                                 frame f4f overlay row 8
                                 color black/cyan.
                end.
                else do:
                    find clien where clien.clicod = titulo.clifor no-lock.
                    display titulo.clifor colon 15
                            clien.clinom no-label colon 30
                            titulo.titnum colon 15
                            titulo.titpar colon 57
                            with side-labels 1 down width 80
                                 frame f4c overlay row 8
                                 color black/cyan.

                end.

                find cobra of titulo no-lock.
                display titulo.titdtemi
                                 titulo.titdtven
                                 titulo.titvlcob
                                 titulo.cobcod
                                 cobra.cobnom
                                 titulo.titvljur
                                 /*titulo.titdtdes*/
                                 titulo.titvldes with frame f5.
                if  cobra.cobban
                    then do with side-labels 1 down
                           width 80 frame f6c overlay
                                                color black/cyan:
                    display titulo.bancod.
                    find banco where banco.bancod = titulo.bancod no-lock.
                    display titulo.agecod.
                end.
                display titulo.titobs with no-labels
                        width 80 title " Observacoes " frame f7 overlay
                        color black/cyan.
                pause.
            end.

            form
                clien.clicod                          at 5    skip
                clien.clinom      label "Nome"        at  6   skip
                clien.ciccgc         label "CGC/CPF"     at  3
                clien.ciinsc                                skip(01)
                clien.endereco                      at  2
                clien.numero                        to 78
                clien.compl                         at  4
                clien.bairro                                skip
                clien.cep                           at 36
                clien.cidade
                clien.ufecod
                clien.fone                          at  6
                clien.contato skip
                clien.fax
                with frame f-cli side-label color black/cyan centered
                                  title " Informa‡äes Gerais " overlay.

            if wopcao = "A"  or
                wopcao = "a"
                then do:
                if input wktit.seq = 0
                    then do:
                    message "Escolha uma das linhas preenchidas".
                    undo.
                end.
                /*
                find first wktit where wktit.seq = input wktit.seq.
                find titulo where recid(titulo) = wktit.rec NO-LOCK.
                find clifor of titulo no-lock.
                find tclifor of clifor no-lock.
                disp
                clifor.clfcod                          at 5    skip
                clifor.clfnom      label "Nome"        at  6   skip
                clifor.nomfan    label "Fantasia"    at  2   skip
                clifor.tippes                       at  4
                clifor.indctr                        to 72   skip
                clifor.tclcod
                tclifor.tclnom no-label
                clifor.cgccpf         label "CGC/CPF"     at  3
                clifor.ciinsc                                skip(01)
                clifor.endereco                      at  2
                clifor.numero                        to 78
                clifor.compl                         at  4
                clifor.bairro                                skip
                clifor.paissig                       at 6
                clifor.cep                           at 36
                clifor.cidade
                clifor.ufecod
                clifor.fone                          at  6
                clifor.ramal
                clifor.contato skip
                clifor.clffone     at 6
                clifor.clframal
                clifor.fax
                clifor.telex
                clifor.cxpos     label "CP"                  skip(01)
                clifor.dtcad     label "Cadastro Desde"    at  2
                clifor.sitcad    label "Situa‡Æo"    at 42   skip
                clifor.dturen    label "Renovado"    at  2
                clifor.situacao                        at 42   skip
                clifor.motivo                        at  4
                with frame f-cli.
                */
                pause.
            end.
            end.
        end.
    end.
end.
