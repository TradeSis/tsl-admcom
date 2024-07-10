/*----------------------------------------------------------------------------*/
/* /usr/admctp/antec.p                                         Antecipacoes   */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 18/12/92 Oscar   Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat.
def var wclifor like titulo.clifor.
def var wdti    like titdtven label "Periodo" initial today.
def var wdtf    like titdtven.
def var wtitvlcob like titulo.titvlcob.
def var wtot      as dec format ">,>>>,>>>,>>9.99" label "Total".
def var wseq as i extent 2.
def var i as i.
def var wopcao as char.
def var wforcli as i format "999999" label "For/Cli".
define  temp-table wktit
   field seq as   i label "Nr" format "99"
   field empcod   like titulo.empcod
   field titdtdes like titulo.titdtdes column-label "Dt.Desc."
                                       format "99/99/99"
   field clifor   like titulo.clifor
   field titnum   like titulo.titnum
   field titpar   like titulo.titpar
   field titvldes like titulo.titvldes  label "Vlr. Desc." format ">,>>>,>>9.99"
   field titdtven like titulo.titdtven  label "Dt.Venc."   format "99/99/99"
   field titvlcob like titulo.titvlcob  label "Vlr. Cobr." format ">,>>>,>>9.99"
   field percdes  as dec format ">9.99" label "Des. %"
   field modcod   like titulo.modcod.

form wetbcod colon 18
     estab.etbnom  no-label colon 30
     wdti          colon 18  " A"
     wdtf          colon 35  no-label
                   with side-labels width 80 frame f1.

wdtf = wdti + 30.

repeat with side-labels 1 down width 80 row 4 frame f1:
    hide frame f2 .
    clear frame f1 all.
    disp "" @ wetbcod .
    prompt-for wetbcod label "Estabelecimento" .
    if input wetbcod <> ""
       then do:
               find estab where estab.etbcod = input wetbcod.
               display etbnom .
       end.
       else disp "TODOS" @ etbnom.

    update wdti validate(input wdti <> ?,
                        "Data deve ser Informada").

    update wdtf validate(input wdtf > input wdti,
                         "Data Invalida").

    for each wktit:
        delete wktit.
    end.
    assign wseq[1] = 0
           i = 0
           wtot = 0.
    for each titulo where titulo.empcod = wempre.empcod and
                          titdtdes >=  wdti        and
                          titdtdes <=  wdtf        and
                         (titsit   =   "LIB"        or
                          titsit   =   "BLO")      and
                        ( if wetbcod = 0
                             then true
                             else titulo.etbcod = wetbcod )
                              break by titulo.titdtven
                                    by titulo.clifor
                                    by titulo.modcod
                                    by titulo.titnum
                                    by titulo.titpar:
        create wktit.
        i = i + 1.
        assign seq = i
               wktit.empcod   = titulo.empcod
               wktit.titdtdes = titulo.titdtdes
               wktit.clifor   = titulo.clifor
               wktit.titnum   = titulo.titnum
               wktit.titpar   = titulo.titpar
               wktit.titvldes = titulo.titvldes
               wktit.titdtven = titulo.titdtven
               wktit.titvlcob = titulo.titvlcob
               wktit.modcod   = titulo.modcod
               wktit.percdes  = (titulo.titvldes / titulo.titvlcob) * 100
               wtot           = wtot + titulo.titvldes.
    end.
    l1:
    repeat with frame f2:
        form            wktit.seq
             space(1)   wktit.titdtven
             space(1)   wforcli
             space(1)   wktit.titnum
             space(1)   wktit.titpar
             space(1)   wktit.titvlcob
             space(1)   wktit.titdtdes
             space(1)   wktit.titvldes
             space(1)   wktit.percdes with frame f2 10 down width 80 row 8.

        for each wktit where seq >= wseq[1]
                             i = 1 to 10:

            display wktit.seq with frame f2.
            if wtitnat
               then display wktit.clifor @ wforcli with frame f2.
               else display wktit.clifor @ wforcli with frame f2.

            display wktit.titnum
                    wktit.titpar
                    wktit.titvlcob
                    wktit.titdtven
                    wktit.titvlcob
                    wktit.titvldes
                    wktit.titdtdes
                    wktit.percdes with frame f2.

            down with frame f2.
        /*
            pause 0.
            display wtot with frame ftot column 50 row 19 side-label width 31.
        */
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
