{admcab.i}
def var vcx as int.
def var totglo like globa.gloval.
def var vlpres      like plani.platot.
def var vcta01      as char format "99999".
def var vcta02      as char format "99999".
def var vdata       like titulo.titdtemi.
def var vpago       like titulo.titvlpag.
def var vdesc       like titulo.titdesc.
def var vjuro       like titulo.titjuro.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vcxacod     like titulo.cxacod.
def var vmodcod     like titulo.modcod.
def var vlvist      like plani.platot.
def var vlpraz      like plani.platot.
def var vlentr      like plani.platot.
def var vljuro      like plani.platot.
def var vldesc      like plani.platot.
def var vlpred      like plani.platot.
def var vldev       like plani.platot.
def var vldevvis    like plani.platot.
def var vljurpre    like plani.platot.
def var vlsubtot    like plani.platot.
def var vtot        like plani.platot.
def var vnumtra     like plani.platot.
def var ct-vist     as   int.
def var ct-praz     as   int.
def var ct-entr     as   int.
def var ct-pres     as   int.
def var ct-juro     as   int.
def var ct-desc     as   int.
def var ct-dev      as   int.
def var ct-devvis   as   int.
def var vdtexp      as   date.
def var vdtimp      as   date.
def stream tela.

def temp-table wf-atu
             field imp      as date
             field exporta  as date.

def buffer bimporta for importa.
def buffer bexporta for exporta.

output stream tela to terminal.

form wf-atu.imp label "Falta Importar do CPD"
     wf-atu.exporta label "Falta Exportar para CPD"
     with frame fatu centered no-box down.

do with 1 down side-label width 80 row 4 color blue/white:
    prompt-for estab.etbcod colon 20.
    find estab using etbcod .
    display estab.etbnom no-label.
    update vdata colon 20.

    assign vcta01 = string(estab.prazo,"99999")
           vcta02 = string(estab.vista,"99999").

    assign  vlpraz  = 0 vlvist  = 0 vlentr  = 0 vljuro  = 0 vldev = 0
            vldesc  = 0 vldevvis = 0
            ct-pres = 0 ct-juro = 0 ct-desc = 0 ct-vist = 0
            ct-praz = 0 vlpred  = 0 vljurpre = 0 vnumtra = 0 ct-dev = 0
            ct-devvis = 0.

    do vcx = 1 to 10:
        for each titulo where titulo.etbcod = estab.etbcod and
                              titulo.cxacod = vcx          and
                              titulo.cxmdat = vdata no-lock.
            if titulo.datexp <> titulo.cxmdat
            then next.
            if titulo.titdtpag = ?
            then next.
            if titulo.titpar    = 0
            then next.
            if titulo.clifor = 1
            then next.
            if titulo.etbcobra <> estab.etbcod
            then next .
            if titulo.cxacod <> vcx then next.
            find clien where clien.clicod = titulo.clifor.
            vlpres = vlpres + titulo.titvlcob.
        end.

        for each plani use-index pladat where plani.movtdc = 5       and
                                              plani.etbcod = estab.etbcod and
                                              plani.pladat = vdata no-lock.
            if plani.cxacod = vcx
            then do:
                find titulo where titulo.empcod = wempre.empcod and
                                  titulo.titnat = no            and
                                  titulo.modcod = "CRE"         and
                                  titulo.etbcod = setbcod       and
                                  titulo.clifor = 1             and
                                  titulo.titnum = string(plani.numero) no-lock
                                  no-error.

                if avail titulo
                then do:
                    if plani.crecod = 1 and
                       titulo.titdtpag <> plani.pladat
                    then assign vnumtra = vnumtra +
                                                    (if plani.outras > 0
                                                     then plani.outras
                                                     else plani.protot)
                                                  /* + plani.frete */
                                                  + plani.acfprod.
                end.

                if plani.crecod = 1
                then assign ct-vist = ct-vist + 1
                            vlvist = vlvist + (
                                                    (if plani.outras > 0
                                                     then plani.outras
                                                     else plani.protot)

                            /* + plani.frete */
                                            + plani.acfprod - plani.descprod).
                if plani.crecod = 2
                then assign ct-praz = ct-praz + 1
                            vlpraz = vlpraz + (
                                                    (if plani.outras > 0
                                                     then plani.outras
                                                     else plani.protot)
                            /* - plani.frete */
                                                            - plani.descprod).

                if plani.crecod = 1 and
                   plani.vlserv > 0
                then assign ct-devvis = ct-devvis + 1
                            vldevvis = vldevvis + plani.vlserv.

                if plani.crecod = 2 and
                   plani.vlserv > 0
                then assign ct-dev = ct-dev + 1
                            vldev = vldev + plani.vlserv.

            end.
        end.
    end.

    for each caixa where caixa.etbcod = estab.etbcod no-lock:
        for each titulo where titulo.datexp = vdata.
            if titulo.cxacod = caixa.cxacod and
               titulo.etbcod = estab.etbcod and
               titulo.titpar = 0
            then do:
                assign ct-entr = ct-entr + 1
                       vlentr  = vlentr  + titulo.titvlcob.
            end.
        end.
    end.

    for each caixa where caixa.etbcod = estab.etbcod no-lock:
        for each titulo where titulo.datexp = vdata.
            vmodcod = titulo.modcod.
            if titulo.datexp <> titulo.cxmdat
            then next.

            if titulo.titdtpag = ?
            then vmodcod = "VDP".
            if titulo.cxacod <> caixa.cxacod
            then next.
            if titulo.titpar    = 0 or
            titulo.clifor       = 1
            then do:
                if titulo.clifor = 1
                then vmodcod = "VDV".
                else vmodcod = "ENT".
            end.

            if vmodcod <> "CRE"
            then next.

            if titulo.moecod = "PRE"
            then assign  vlpred = vlpred + titulo.titvlcob
                         vljurpre = vljurpre + titulo.titjuro.

            vljuro = vljuro + titulo.titjuro.
            vldesc = vldesc + titulo.titdesc.
            ct-pres = ct-pres + if titulo.titvlcob > 0
                                then 1
                                else 0.
            ct-juro = ct-juro + if titulo.titjuro > 0
                                then 1
                                else 0.
            ct-desc = ct-desc + if titulo.titdesc > 0
                                then 1
                                else 0.
        end.
    end.
    totglo = 0.
    for each globa where globa.glodat = vdata no-lock :
        totglo = totglo + globa.gloval.
    end.


    do on error undo, retry:

    {mdadmcab.i &Saida = "printer"
            &Page-Size = "64"
            &Cond-Var  = "80"
            &Page-Line = "66"
            &Nom-Rel   = ""DREB040""
            &Nom-Sis   = """SISTEMA CREDIARIO"""
            &Tit-Rel   = """ RESUMO GERAL DOS CAIXAS DA LOJA ""  +
                            string(estab.etbcod) + "" - "" +
                            string(estab.etbnom) + "" EM "" + string(vdata) "
            &Width     = "80"
            &Form      = "frame f-cabc1"}

    display "Cta DB" at 21 space(2) "Cta CR" space(6)
        "Valor" space(6) "Qtd" space(6) "Hist"
        skip(1)
        "1.Venda a Prazo"  space(3) "  169"
                           space(5) vcta01  no-label
                           space(3) vlpraz  no-label
                           space(5) ct-praz no-label format ">>>9"
                           space(3) "  109" skip

        "2.Venda a Vista"  space(3) "   13"
                           space(5) vcta02 no-label
                           space(3) vlvist  no-label
                           space(5) ct-vist no-label format ">>>9"
                           space(3) "    9" skip

        "3.Entrada      "  space(3) "   13"
                           space(5) "  169"
                           space(3) vlentr  no-label
                           space(5) ct-entr no-label format ">>>9"
                           space(3) "   39" skip

        "4.Prestacoes   "  space(3) "   13"
                           space(5) "  169"
                           space(3) vlpres  no-label
                           space(5) ct-pres no-label format ">>>9"
                           space(3) "   39" skip

        "5.Juros        "  space(3) "   13"
                           space(5) " 6839"
                           space(3) vljuro  no-label
                           space(5) ct-juro no-label format ">>>9"
                           space(3) "   39" skip

        "6.Descontos    "  space(3) " 6800"
                           space(5) "  169"
                           space(3) vldesc  no-label
                           space(5) ct-desc no-label format ">>>9"
                           space(3) "   85" skip

        "7.Devol. Prazo "  space(3) "     "
                           space(5) "     "
                           space(3) vldev  no-label
                           space(5) ct-dev no-label format ">>>9"
                           space(3) "     " skip

        "8.Devol. Vista "  space(3) "     "
                           space(5) "     "
                           space(3) vldevvis  no-label
                           space(5) ct-devvis no-label format ">>>9"
                           space(3) "     " skip(2)


        "Numero do Lote: ________________"                         skip
        vlpraz + vlvist + vlentr + vlpres + vljuro + vldesc
                            label "Valor         "
        skip(2)
        with side-label no-box frame f3 column 05.

        /*

        vlpred                label "Pre-datados           " skip
        vljurpre              label "Juros Pre             " skip(1)
        vlpred + vljurpre     label "TOTAL PRE             " format ">>>,>>9.99"
        skip(2)
        vnumtra               label "Numerarios em Transito" skip(1)
        vlvist + vlentr + vlpres + vljuro - vldesc - vldevvis -
        vlpred - vljurpre @ vlsubtot label "Sub-total             " skip(2)
        "_______________" label "Pagamentos            "            skip(2)
        totglo            label "Total Global          "            skip(2)
        "_______________" @ vtot     label "TOTAL                 " skip(2)
        "_______________" label "Deposito              "            SKIP(1)
        "_______________" label "Sobra                 "            SKIP(1)
        "_______________" label "Falta                 "            SKIP(2)
        with side-label no-box frame f3 column 05.

        PUT
        "__________________________"  AT 7 space(10)
        "__________________________"   skip
        "   Encarregado Caixa      "  AT 7 space(10)
        "        Caixa             "  skip(2).


        find last importa where importa.etbcod = 999 no-lock no-error.
        if avail importa
        then vdtimp = importa.importa - 1.
        else leave.

        if avail importa
        then repeat:
                vdtimp = vdtimp + 1.
                if vdtimp = today
                then leave.
                if weekday(vdtimp) = 1
                then next.
                find dtextra where dtextra.exdata  = vdtimp no-error.
                if avail dtextra
                then do:
                    find next importa where importa.etbcod = 999 no-lock
                                                                no-error.
                    next.
                end.
                find bimporta where bimporta.etbcod  = 999 and
                                    bimporta.importa = vdtimp no-lock no-error.
                if not avail bimporta
                then do:
                    create wf-atu.
                    assign wf-atu.imp = vdtimp.
                end.
                find next importa where importa.etbcod = 999 no-lock no-error.
        end.

        find last exporta where exporta.etbcod = setbcod no-lock no-error.
        if avail exporta
        then vdtexp = exporta.exporta - 1.
        else leave.

        if avail exporta
        then repeat:
                vdtexp = vdtexp + 1.
                if vdtexp = today
                then leave.
                if weekday(vdtexp) = 1
                then next.
                find dtextra where dtextra.exdata  = vdtexp no-error.
                if avail dtextra
                then do:
                    find next exporta where exporta.etbcod = setbcod no-lock
                                                                no-error.
                    next.
                end.

                find bexporta where bexporta.etbcod  = setbcod and
                                    bexporta.exporta = vdtexp no-lock no-error.
                if not avail bexporta
                then do:
                    find first wf-atu where wf-atu.exporta = ? no-error.
                    if not avail wf-atu
                    then create wf-atu.
                    assign wf-atu.exporta = vdtexp.
                end.
                find next exporta where exporta.etbcod = setbcod no-lock
                                                                no-error.
        end.

        for each wf-atu.
            display wf-atu with frame fatu attr-space.
            down with frame fatu.
        end.

        PUT
        skip(3)
        "_________________________________"  AT 10 skip
        " GERENTE: Ciente das Atualizacoes" AT 10.


        */

        output close.
    end.
end.

/*

do on error undo:
        {mdadmcab.i &Saida     = "printer"
                    &Page-Size = "64"
                    &Cond-Var  = "160"
                    &Page-Line = "66"
                    &Nom-Rel   = ""DREB040""
                    &Nom-Sis   = """SISTEMA CREDIARIO"""
                  &Tit-Rel   = """RELACAO DE VENDAS PARA CLIENTES EM ATRASO "" +
                                  "" LOJA "" + string(estab.etbcod) + "" - "" +
                                               estab.etbnom + """""
                    &Width     = "160"
                    &Form      = "frame f-cabcab2"}

        for each autoriz where autoriz.etbcod = estab.etbcod and
                               autoriz.data   = vdata        no-lock
                                                by autoriz.hora.

            if index(autoriz.motivo," Atraso") = 0
            then next.

            find clien where clien.clicod = autoriz.clicod no-lock no-error.
            if not avail clien or
               autoriz.motivo = ""
            then next.
            find func of autoriz no-lock.
            display func.funnom     column-label "Funcionario" form "x(15)"
                    string(autoriz.hora,"hh:mm") column-label "Hora"
                    clien.clicod    when avail clien
                    clien.clinom    when avail clien form "x(25)"
                    autoriz.valor1  column-label "Valor Atrasado"
"Motivo ______________________________________________________________________"
                    skip(1)
                    with frame fautoriz1 width 160 down.
        end.
      end.
      display skip(3)
              "_____________________________" at 90
              "     Assinatura Gerente      " at 90 with width 160 frame frod1.
      output close.

      do on error undo:
        {mdadmcab.i &Saida     = "printer"
                    &Page-Size = "64"
                    &Cond-Var  = "160"
                    &Page-Line = "66"
                    &Nom-Rel   = ""DREB040""
                    &Nom-Sis   = """SISTEMA CREDIARIO"""
         &Tit-Rel   = """RELATORIO VENDAS A CLIENTES COM LIMITE ULTRAPASSADO"" +
                                  "" LOJA "" + string(estab.etbcod) + "" - "" +
                                               estab.etbnom + """""
                    &Width     = "160"
                    &Form      = "frame f-cabcab3"}

        for each autoriz where autoriz.etbcod = estab.etbcod and
                               autoriz.data   = vdata        no-lock
                                                by autoriz.hora.

            if index(autoriz.motivo," Limite") = 0
            then next.

            find clien where clien.clicod = autoriz.clicod no-lock no-error.
            if not avail clien or
               autoriz.motivo = ""
            then next.
            find func of autoriz no-lock.
            display func.funnom     column-label "Funcionario" form "x(15)"
                    string(autoriz.hora,"hh:mm") column-label "Hora"
                    clien.clicod    when avail clien
                    clien.clinom    when avail clien form "x(25)"
                    autoriz.valor2  column-label "Devido + Compra"
                    autoriz.valor3  column-label "Limite"
                 "Motivo ______________________________________________________"
                    skip(1)
                    with frame fautoriz2 width 160 down.
        end.
      end.
      display skip(3)
              "_____________________________" at 90
              "     Assinatura Gerente      " at 90 with width 160 frame frod2.
      output close.

      do on error undo:
        {mdadmcab.i &Saida     = "printer"
                    &Page-Size = "64"
                    &Cond-Var  = "160"
                    &Page-Line = "66"
                    &Nom-Rel   = ""DREB040""
                    &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """RELATORIO VENDA PARA CLIENTES COM PARCELAS ATRASADAS"" +
                                  "" LOJA "" + string(estab.etbcod) + "" - "" +
                                               estab.etbnom + """""
                    &Width     = "160"
                    &Form      = "frame f-cabcab4"}

        for each autoriz where autoriz.etbcod = estab.etbcod and
                               autoriz.data   = vdata        no-lock
                                                by autoriz.hora.

            if index(autoriz.motivo," Parcelas") = 0
            then next.

            find clien where clien.clicod = autoriz.clicod no-lock no-error.
            if not avail clien or
               autoriz.motivo = ""
            then next.
            find func of autoriz no-lock.
            display func.funnom     column-label "Funcionario" form "x(15)"
                    string(autoriz.hora,"hh:mm") column-label "Hora"
                    clien.clicod    when avail clien
                    clien.clinom    when avail clien form "x(25)"
                    autoriz.valor1  column-label "Valor Atrasado"
                    autoriz.valor2  column-label "Devido + Compra"
                 "Motivo ______________________________________________________"
                    skip(1)
                    with frame fautoriz3 width 160 down.
        end.
      end.
      display skip(3)
              "_____________________________" at 90
              "     Assinatura Gerente      " at 90 with width 160 frame frod3.
      output close.

      do on error undo:
        {mdadmcab.i &Saida     = "printer"
                    &Page-Size = "64"
                    &Cond-Var  = "160"
                    &Page-Line = "66"
                    &Nom-Rel   = ""DREB040""
                    &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """RELATORIO DE VENDA A CLIENTE COM DISPENSA DE JUROS"" +
                                  "" LOJA "" + string(estab.etbcod) + "" - "" +
                                               estab.etbnom + """""
                    &Width     = "160"
                    &Form      = "frame f-cabcab5"}

        for each autoriz where autoriz.etbcod = estab.etbcod and
                               autoriz.data   = vdata        no-lock
                                                by autoriz.hora.

            if index(autoriz.motivo," Dispensa") = 0
            then next.

            find clien where clien.clicod = autoriz.clicod no-lock no-error.
            if not avail clien or
               autoriz.motivo = ""
            then next.
            find func of autoriz no-lock.
            display func.funnom     column-label "Funcionario" form "x(15)"
                    string(autoriz.hora,"hh:mm") column-label "Hora"
                    clien.clicod    when avail clien
                    clien.clinom    when avail clien form "x(25)"
                    autoriz.valor3  column-label "juros"
"Motivo ______________________________________________________________________"
                    skip(1)
                    with frame fautoriz4 width 160 down.
        end.
      end.
      display skip(3)
              "_____________________________" at 90
              "     Assinatura Gerente      " at 90 with width 160 frame frod4.
      put unformatted chr(30) "0".
      output close.
*/
