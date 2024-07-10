/*----------------------------------------------------------------------------*/
/* /usr/admfin/bloqe.p                                         Bloqueados     */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 08/12/92 Oscar   Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wetbcod like fin.titulo.etbcod initial 0.
def var wmodcod like fin.titulo.modcod initial "".
def var wtitnat like fin.titulo.titnat.
def var wclifor like fin.titulo.clifor.
def var wdti    like fin.titulo.titdtven label "Periodo" initial today.
def var wdtf    like fin.titulo.titdtven.
def var wtitvlcob like fin.titulo.titvlcob.
def var wtot      as dec format ">,>>>,>>>,>>9.99" label "Total".
def var wseq as i extent 2.
def var i as i.
def var wopcao as char.
def var wforcli as i format "999999" label "For/Cli".
define  temp-table wktit
        field seq as   i label "Nr" format "99"
        field empcod   like fin.titulo.empcod
        field modcod   like fin.titulo.modcod
        field clifor   like fin.titulo.clifor
        field titnum   like fin.titulo.titnum
        field titpar   like fin.titulo.titpar
        field cobcod   like fin.titulo.cobcod
        field titdtven like fin.titulo.titdtven
        field titvlcob like fin.titulo.titvlcob
        field etbcod   like fin.titulo.etbcod.
wdtf = wdti + 30.
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
    clear frame f1.
    disp "" @ wetbcod colon 12.
    prompt-for wetbcod label "Estabelec." .
    if input wetbcod <> ""
       then do:
               find estab where estab.etbcod = input wetbcod.
               display etbnom no-label format "x(10)".
       end.
       else disp "TODOS" @ etbnom.

    update wmodcod validate(wmodcod = "" or
                            can-find(fin.modal where fin.modal.modcod = wmodcod),
                            "Modalidade nao cadastrada")
                            label "Modal/Natur" colon 12.

    display " - ".
    if wmodcod = "CRE"
       then wtitnat = no.
    update wtitnat no-label.
    repeat:
        hide frame f2.
        clear frame ff all.
        clear frame fc all.
        if wtitnat
           then do with column 1 side-labels 1 down width 48 row 4 frame ff:
             disp "" @ wclifor.
             prompt-for wclifor label "Fornecedor"
                help "Informe o codigo do fornecedor ou <ENTER> para todos".
             if input wclifor <> ""
                then do:
                        find forne where forne.forcod = input wclifor.
                        display fornom format "x(32)" no-label at 10.
                end.
                else disp "CONSULTA DE TODOS OS FORNECEDORES" @ fornom.
           end.
           else do with column 1 side-labels 1 down width 48 row 4 frame fc:
             disp "" @ wclifor.
             prompt-for wclifor label "Cliente"
                help "Informe o codigo do Cliente ou <ENTER> para todos".
             if input wclifor <> ""
                then do:
                        find clien where clien.clicod = input wclifor.
                        display clinom format "x(32)" no-label at 10.
                end.
                else disp "CONSULTA DE TODOS OS CLIENTES" @ clinom.
           end.
        form wdti colon 12
             " A"
             wdtf colon 29 no-label with frame fdat width 48 side-label.

        form wtot colon 12 with frame ftot width 31 row 8 column 50 side-label.

        update wdti
               wdtf with frame fdat.

        for each wktit:
            delete wktit.
        end.
        assign wseq[1] = 0
               i = 0
               wtot = 0.
    for each fin.titulo where fin.titulo.empcod = wempre.empcod and
                          titdtven >=  wdti        and
                          titdtven <=  wdtf        and
                          titnat   =   wtitnat     and
                          titsit   =   "BLO"       and
                        ( if wclifor = 0
                             then true
                             else fin.titulo.clifor = wclifor ) and
                        ( if wetbcod = 0
                             then true
                             else fin.titulo.etbcod = wetbcod )            and
                        ( if wmodcod = ""
                             then true
                             else fin.titulo.modcod = wmodcod )
                              break by fin.titulo.titdtven
                                    by fin.titulo.clifor
                                    by fin.titulo.modcod
                                    by fin.titulo.titnum
                                    by fin.titulo.titpar:
            create wktit.
            i = i + 1.
            assign seq = i
                   wktit.empcod   = fin.titulo.empcod
                   wktit.modcod   = fin.titulo.modcod
                   wktit.clifor   = fin.titulo.clifor
                   wktit.titnum   = fin.titulo.titnum
                   wktit.titpar   = fin.titulo.titpar
                   wktit.cobcod   = fin.titulo.cobcod
                   wktit.titdtven = fin.titulo.titdtven
                   wktit.titvlcob = fin.titulo.titvlcob
                   wktit.etbcod   = fin.titulo.etbcod
                   wtot           = wtot + fin.titulo.titvlcob.
        end.
        display wtot with frame ftot.
        l1:
        repeat with frame f2 7 down width 80:
            form            wktit.seq
                 space(2)   wktit.titdtven
                 space(2)   wforcli
                 space(2)   wktit.modcod
                 space(2)   wktit.titnum
                 space(2)   wktit.titpar
                 space(2)   wktit.etbcod
                 space(2)   wktit.cobcod
                 space(2)  wktit.titvlcob with frame f2 7 down width 80 row 11.

            for each wktit where seq >= wseq[1]
                                 i = 1 to 7:

                display wktit.seq with frame f2.
                if wtitnat
                   then display wktit.clifor @ wforcli with frame f2.
                   else display wktit.clifor @ wforcli with frame f2.

                display wktit.titnum
                        wktit.titpar
                        wktit.cobcod
                        wktit.titdtven
                        wktit.titvlcob
                        wktit.etbcod
                        wktit.modcod with frame f2.
                down with frame f2.
                if i = 1
                   then wseq[1] = seq.
                wseq[2] = seq.
            end.
            if wtot = 0
               then do:
                       message "Nenhum Titulo p/ este Periodo".
                       undo.
               end.
            up frame-line (f2) - 1 with frame f2.
            repeat on endkey undo,leave l1:
               hide frame f4f.
               hide frame f4c.
               hide frame f5.
               hide frame f6c.
               hide frame f7.
               choose row wktit.seq
                help "[C] para Consulta, PG-DOWN e PG-UP"
                             go-on(PAGE-DOWN PAGE-UP C c)
                             with frame f2.
               wopcao = keyfunction(lastkey).
             if wopcao = "PAGE-UP"
                then do:
                        hide message no-pause.
                        find last wktit where seq < wseq[1] no-error.

                        if not available wktit
                           then do:
                                   message "Nao ha mais registros".
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
                                   undo.
                           end.

                        wseq[1] = seq.
                        clear frame f2 all.
                        leave.
                end.
             form fin.titulo.titdtemi colon 15
                  fin.titulo.titdtven colon 15
                  fin.titulo.titvljur colon 57
                  fin.titulo.titvlcob colon 15
                  fin.titulo.titdtdes colon 57
                  fin.titulo.cobcod colon 15
                  fin.cobra.cobnom no-label at 20
                  fin.titulo.titvldes colon 57
                  with side-labels 1 down width 80 frame f5 overlay.
              form fin.titulo.bancod colon 15
                           bandesc no-label at 26
                   fin.titulo.agecod colon 15
                           agedesc no-label at 26
                           with side-labels 1 down width 80 frame f6c overlay.
              if wopcao = "C"  or
                 wopcao = "c"
                 then do:
                         if input wktit.seq = 0
                            then do:
                                   message "Escolha uma das linhas preenchidas".
                                   undo.
                            end.
                         find first wktit where wktit.seq = input wktit.seq.
                         find fin.titulo where fin.titulo.empcod = wktit.empcod and
                                           fin.titulo.modcod = wktit.modcod and
                                           fin.titulo.clifor = wktit.clifor and
                                           fin.titulo.titnum = wktit.titnum and
                                           fin.titulo.titpar = wktit.titpar.

                         if fin.titulo.titnat
                            then do:
                                    find forne where forne.forcod =
                                                        fin.titulo.clifor .
                                    display fin.titulo.clifor colon 15
                                            forne.fornom  no-label colon 30
                                            fin.titulo.titnum colon 15
                                            fin.titulo.titpar colon 57
                                            with side-labels 1 down width 80
                                                 frame f4f overlay row 8.
                             end.
                             else do:
                                     find clien where clien.clicod =
                                                        fin.titulo.clifor .
                                     display fin.titulo.clifor colon 15
                                             clien.clinom  no-label colon 30
                                             fin.titulo.titnum colon 15
                                             fin.titulo.titpar colon 57
                                             with side-labels 1 down width 80
                                                  frame f4c overlay row 8.
                             end.
                         find fin.cobra of fin.titulo.
                         display fin.titulo.titdtemi
                                 fin.titulo.titdtven
                                 fin.titulo.titvlcob
                                 fin.titulo.cobcod
                                 cobra.cobnom
                                 fin.titulo.titvljur
                                 fin.titulo.titdtdes
                                 fin.titulo.titvldes with frame f5.
                         if  fin.titulo.cobcod = 1
                             then do with side-labels 1 down
                                          width 80 frame f6c overlay:
                                 display fin.titulo.bancod.
                                 find banco where banco.bancod = fin.titulo.bancod.
                                 display bandesc no-label.
                                 display fin.titulo.agecod.
                                 find agenc of banco where
                                               agenc.agecod = fin.titulo.agecod.
                                 display agedesc no-label.
                             end.
                         display fin.titulo.titobs with no-labels
                                width 80 title " Observacoes " frame f7 overlay.
                         pause.
                end.
            end.
        end.
    end.
end.
