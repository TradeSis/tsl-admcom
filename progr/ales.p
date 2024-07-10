/*----------------------------------------------------------------------------*/
/* /usr/admfin/bloqe.p                                         Bloqueados     */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 08/12/92 Oscar   Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat.
def var wclifor like titulo.clifor.
def var wdti    like titulo.titdtven label "Periodo" initial today.
def var wdtf    like titulo.titdtven.
def var wtitvlcob like titulo.titvlcob.
def var wtot      as dec format ">,>>>,>>>,>>9.99" label "Total".
def var wseq as i extent 2.
def var i as i.
def var wopcao as char.
def var wforcli as i format "999999" label "For/Cli".
define  temp-table wktit
        field seq as   i label "Nr" format "99"
        field empcod   like titulo.empcod
        field modcod   like titulo.modcod
        field clifor   like titulo.clifor
        field titnum   like titulo.titnum
        field titpar   like titulo.titpar
        field cobcod   like titulo.cobcod
        field titdtven like titulo.titdtven
        field titvlcob like titulo.titvlcob
        field etbcod   like titulo.etbcod.
wdtf = wdti + 30.
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:

    update wmodcod validate(wmodcod = "" or
                            can-find(modal where modal.modcod = wmodcod),
                            "Modalidade nao cadastrada")
                            label "Modal/Natur" colon 12.

    display " - ".
    if wmodcod = "CRE"
       then wtitnat = no.
    update wtitnat no-label.
    repeat:
        if wtitnat
           then do with column 1 side-labels 1 down width 48 row 4 frame ff:
             wclifor = 0.
             update wclifor validate(wclifor = 0 or
                                   can-find(forne where forne.forcod = wclifor),
                                    "Fornecedor nao cadastrado")
                                    colon 12.
             if wclifor <> 0
                then do:
                        find forne where forne.forcod = wclifor.
                        display fornom format "x(32)" no-label at 14.
                end.
           end.
           else do with column 1 side-labels 1 down width 48 row 4 frame fc:
             wclifor = 0.
             update wclifor validate(wclifor = 0 or
                                   can-find(clien where clien.clicod = wclifor),
                                    "Cliente nao Cadastrado")
                                    colon 12.
             if wclifor <> 0
                then do:
                        find clien where clien.clicod = wclifor.
                        display clinom format "x(32)" no-label at 14.
                end.
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
    for each titulo where titulo.empcod = wempre.empcod and
                          titdtven >=  wdti        and
                          titdtven <=  wdtf        and
                          titnat   =   wtitnat     and
                          titsit   =   "BLO"       and
                        ( if wclifor = 0
                             then true
                             else titulo.clifor = wclifor ) and
                        ( if wetbcod = 0
                             then true
                             else titulo.etbcod = wetbcod )            and
                        ( if wmodcod = ""
                             then true
                             else titulo.modcod = wmodcod )
                              break by titulo.titdtven
                                    by titulo.clifor
                                    by titulo.modcod
                                    by titulo.titnum
                                    by titulo.titpar:
            create wktit.
            i = i + 1.
            assign seq = i
                   wktit.empcod   = titulo.empcod
                   wktit.modcod   = titulo.modcod
                   wktit.clifor   = titulo.clifor
                   wktit.titnum   = titulo.titnum
                   wktit.titpar   = titulo.titpar
                   wktit.cobcod   = titulo.cobcod
                   wktit.titdtven = titulo.titdtven
                   wktit.titvlcob = titulo.titvlcob
                   wktit.etbcod   = titulo.etbcod
                   wtot           = wtot + titulo.titvlcob.
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
             form titulo.titdtemi colon 15
                  titulo.titdtven colon 15
                  titulo.titvljur colon 57
                  titulo.titvlcob colon 15
                  titulo.titdtdes colon 57
                  titulo.cobcod colon 15
                  cobra.cobnom no-label at 20
                  titulo.titvldes colon 57
                  with side-labels 1 down width 80 frame f5 overlay.
              form titulo.bancod colon 15
                           bandesc no-label at 26
                   titulo.agecod colon 15
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
                         find titulo where titulo.empcod = wktit.empcod and
                                           titulo.modcod = wktit.modcod and
                                           titulo.clifor = wktit.clifor and
                                           titulo.titnum = wktit.titnum and
                                           titulo.titpar = wktit.titpar.

                         if titulo.titnat
                            then do:
                                    find forne where forne.forcod =
                                                        titulo.clifor .
                                    display titulo.clifor colon 15
                                            forne.fornom  no-label colon 30
                                            titulo.titnum colon 15
                                            titulo.titpar colon 57
                                            with side-labels 1 down width 80
                                                 frame f4f overlay row 8.
                             end.
                             else do:
                                     find clien where clien.clicod =
                                                        titulo.clifor .
                                     display titulo.clifor colon 15
                                             clien.clinom  no-label colon 30
                                             titulo.titnum colon 15
                                             titulo.titpar colon 57
                                             with side-labels 1 down width 80
                                                  frame f4c overlay row 8.
                             end.
                         find cobra of titulo.
                         display titulo.titdtemi
                                 titulo.titdtven
                                 titulo.titvlcob
                                 titulo.cobcod
                                 cobra.cobnom
                                 titulo.titvljur
                                 titulo.titdtdes
                                 titulo.titvldes with frame f5.
                         if  titulo.cobcod = 1
                             then do with side-labels 1 down
                                          width 80 frame f6c overlay:
                                 display titulo.bancod.
                                 find banco where banco.bancod = titulo.bancod.
                                 display bandesc no-label.
                                 display titulo.agecod.
                                 find agenc of banco where
                                               agenc.agecod = titulo.agecod.
                                 display agedesc no-label.
                             end.
                         display titulo.titobs with no-labels
                                width 80 title " Observacoes " frame f7 overlay.
                         pause.
                end.
            end.
        end.
    end.
end.
