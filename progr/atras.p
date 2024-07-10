/*----------------------------------------------------------------------------*/
/* /usr/admfin/atras.p                                           Atrasos      */
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
def var wtitvljur like titulo.titvljur format ">>,>>>,>>9.99" label "Juros".
def var wdti      like titulo.titdtven label "Data Refer. " initial today.
def var wtitdat as date format "99/99/99" column-label "Cob/Pag".
def var wtitvlcob like titulo.titvlcob.
def var wtotjur      as dec format ">>,>>>,>>9.99".
def var wtotcob      as dec format ">,>>>,>>>,>>9.99".
def var wnrdias as i format ">>9" label "DD".
def var i as i.
def var wopcao as char.
def var wforcli as i format "999999" label "For/Cli".
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
    clear frame f1 all.
    disp "" @ wetbcod colon 12.
    prompt-for wetbcod label "Estabelec." .
    if input wetbcod <> ""
       then do:
               find estab where estab.etbcod = input wetbcod.
               display etbnom no-label format "x(10)".
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
        hide frame f2.
        hide frame f3.
        hide frame ftot.
        hide frame frod.
        clear frame ff all.
        clear frame fc all.
        if wtitnat
           then do with column 1 side-labels 1 down width 48 row 4 frame ff:
             disp "" @ wclifor.
             prompt-for wclifor label "Fornecedor"
                help "Informe o codigo do Fornecedor ou <ENTER> para todos".
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
        form wdti colon 20 with frame fdat width 80 side-label.

        update wdti with frame fdat.
        hide frame fdat.

        form wforcli
             titulo.titnum
             titulo.titpar
             titulo.etbcod
             titulo.modcod
                         with frame f2 7 down width 34 row 8.

        form titulo.titdtven format "99/99/99" label "Dt.Vcto."
             wnrdias
             titulo.titvlcob
             wtitvljur
                         with frame f3 7 down width 46 row 8 column 35.

        display wdti colon 12
                     with frame frod no-label row 19 width 34.
        clear frame f2 all.
        clear frame f3 all.
        wtotjur = 0.
        wtotcob = 0.
        for each titulo where titulo.empcod = wempre.empcod and
                              titdtven <   wdti        and
                              titnat   =   wtitnat     and
                             (titsit   =   "LIB"        or
                              titsit   =   "BLO")      and
                            ( if wclifor = 0
                                 then true
                                 else titulo.clifor = wclifor ) and
                             ( if wetbcod = 0
                                  then true
                                  else titulo.etbcod = wetbcod )         and
                             ( if wmodcod = ""
                                  then true
                                  else titulo.modcod = wmodcod )
                              break by titulo.titdtven
                                    by titulo.clifor
                                    by titulo.modcod
                                    by titulo.titnum
                                    by titulo.titpar:

                wnrdias = wdti - titulo.titdtven.
                wtitvljur = titvljur * wnrdias.
                wtotjur = wtotjur + wtitvljur.
                wtotcob = wtotcob + titvlcob.

             if wtitnat
                then display titulo.clifor @ wforcli with frame f2.
                else display titulo.clifor @ wforcli with frame f2.

             display titulo.titnum
                     titulo.titpar
                     titulo.etbcod
                     titulo.modcod with frame f2.

             display titulo.titdtven
                     wnrdias
                     titulo.titvlcob
                     wtitvljur with frame f3.
             display "Totais :    "
                     wtotcob
                     wtotjur
                     with frame ftot row 19 column 35 no-label width 46.

              if frame-line (f3) = frame-down (f3)
                 then pause.
                 else pause 0.

             down with frame f2.
             down with frame f3.
        end.
        pause.
    end.
end.
