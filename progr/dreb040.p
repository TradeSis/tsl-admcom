{admcab.i}
def temp-table wetb
    field etbcod like estab.etbcod
    field wval   like titulo.titvlcob.
def var totglo like globa.gloval.
def var vvenda like estoq.estvenda.
def var    vqtdcon    as i label "QTD".
def var    vvalcon    as dec label "VALOR".
def var    vqtdconesp as i label "QTD".
def var    vvalconesp as dec label "VALOR".
def buffer btitulo for titulo.
def buffer bcontrato for contrato.
def buffer bmovim for movim.
def var wpla like contrato.crecod.
def var vlpres      like plani.platot.
def var vdata       like titulo.titdtemi.
def var vpago       like titulo.titvlpag.
def var vdesc       like titulo.titdesc.
def var vjuro       like titulo.titjuro.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vcxacod     like titulo.cxacod.
def var vmodcod     like titulo.modcod.
def var conta1      as integer.
def var conta2      as integer.
def var conta4      as integer.

def stream tela.

output stream tela to terminal.

form
    skip(1)
    "Pagamentos     :" conta2 skip
    "Titulos        :" conta4 skip
    "Saldo          :" conta1
    skip(1)
    with centered color blue/cyan no-label row 10 title " CALCULANDO "
    frame fcal.

do with 1 down side-label width 80 row 4 color blue/white:
    prompt-for estab.etbcod colon 20.
    find estab using etbcod .
    display estab.etbnom no-label.
    update vdata colon 20.
    update vcxacod colon 20.
    /*
    find caixa where caixa.etbcod = estab.etbcod and
                     caixa.cxacod = vcxacod no-lock.
    */
    assign
        vpago = 0
        vdesc = 0
        vjuro = 0.

    vlpres = 0.
    for each wetb.
        delete wetb.
    end.

    for each titulo where titulo.datexp = vdata.
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
        assign
            vpago  = vpago + titulo.titvlcob
            vjuro  = vjuro + titulo.titjuro
            vdesc  = vdesc + titulo.titdesc
            conta2 = conta2 + 1.
        display stream tela conta2 with frame fcal.
    end.

    do:
        find first btitulo where btitulo.datexp = vdata no-lock no-error.
        if not avail btitulo
        then next.
        {mdadmcab.i &Saida     = "printer"
                    &Page-Size = "64"
                    &Cond-Var  = "160"
                    &Page-Line = "66"
                    &Nom-Rel   = ""DREB040""
                    &Nom-Sis   = """SISTEMA CREDIARIO"""
                    &Tit-Rel   = """LISTAGEM DE DIGITACAO DE PAGAMENTOS "" +
                                  "" LOJA "" + string(estab.etbcod) + "" - "" +
                                               estab.etbnom + ""  -  CAIXA "" +
                                               string(vcxacod) "
                    &Width     = "160"
                    &Form      = "frame f-cabcab1"}

        for each titulo where titulo.datexp = vdata by titulo.moecod
                                                    by titulo.titnum
                                                    by titulo.titpar.
            if titulo.datexp <> titulo.cxmdat
            then next.
            if titulo.titdtpag = ?
            then next.
            if titulo.titpar   = 0
            then next.
            if titulo.clifor   = 1
            then next.
            if titulo.etbcobra <> estab.etbcod
            then next.
            find first wetb where wetb.etbcod = titulo.etbcod no-error.
            if not avail wetb
            then do:
                create wetb.
                assign wetb.etbcod = titulo.etbcod.
            end.
            assign wetb.wval = wetb.wval + titulo.titvlcob.


            if titulo.cxacod <> vcxacod then next.
            find clien where clien.clicod = titulo.clifor.
            vlpres = vlpres + titulo.titvlcob.

            display titulo.etbcod   column-label "Fil."
                    titulo.etbcobra column-label "Cob."
                    titulo.titnum   column-label "Contr."
                    titulo.titpar   column-label "Pr."
                    titulo.clifor   column-label "Cliente"
                    clien.clinom    column-label "Nome" format "x(35)"
                    titulo.titdtven
                    titulo.titdtpag
                    titulo.moecod   column-label "Moeda"
                    if titulo.titdtpag <> vdata
                    then "*"
                    else "" no-label format "x"
                    titulo.titvlcob column-label
                                    "Valor Pago" format ">>>,>>9.99" (TOTAL)
                    titulo.titjuro format ">>>,>>9.99"  (TOTAL)
                    titulo.titdesc format "->>,>>9.99"  (TOTAL)
                    with no-box width 150.
            conta4 = conta4 + 1.
            display stream tela conta4 with frame fcal.

        end.
      end.
      output close.
end.

      /************** PAGAMENTO DE CONSORCIO   ********************/
        find first globa where globa.glodat = vdata no-lock no-error.
        if avail globa
        then do:
            {mdadmcab.i &Saida     = "printer"
                        &Page-Size = "64"
                        &Cond-Var  = "160"
                        &Page-Line = "66"
                        &Nom-Rel   = ""DREB040""
                        &Nom-Sis   = """SISTEMA CREDIARIO"""
                        &Tit-Rel   = """LISTAGEM DE PAGAMENTOS DE CONSORCIO"" +
                                  "" LOJA "" + string(estab.etbcod) + "" - "" +
                                               estab.etbnom + ""  -  CAIXA "" +
                                               string(vcxacod) "
                        &Width     = "160"
                        &Form      = "frame f-cabcab9"}
            for each globa where globa.glodat = vdata no-lock:
                display globa.glopar
                        globa.gloval(total)
                        globa.glogru
                        globa.glocot with frame ff-glo down width 137.
            end.
            output close.
        end.



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
def var ct-vist     as   int.
def var ct-praz     as   int.
def var ct-entr     as   int.
def var ct-pres     as   int.
def var ct-juro     as   int.
def var ct-desc     as   int.
def var ct-dev      as   int.
def var ct-devvis   as   int.

assign  vlpraz  = 0 vlvist  = 0 vlentr  = 0 vljuro  = 0 vldev = 0
        vldesc  = 0 vldevvis = 0
        ct-pres = 0 ct-juro = 0 ct-desc = 0 ct-vist = 0
        ct-praz = 0 ct-dev = 0 ct-devvis = 0.

for each plani use-index pladat where plani.movtdc = 5       and
                                      plani.etbcod = estab.etbcod and
                                      plani.pladat = vdata no-lock.
    if plani.cxacod = Vcxacod
    then do:
         find titulo where titulo.empcod = wempre.empcod and
                           titulo.titnat = no            and
                           titulo.modcod = "CRE"         and
                           titulo.etbcod = setbcod       and
                           titulo.clifor = 1             and
                           titulo.titnum = string(plani.numero) no-lock
                             no-error.
         /*
         if avail titulo
         then do:
              if plani.crecod = 1 and
                 titulo.titdtpag <> plani.pladat
              then assign vnumtra = vnumtra + plani.platot /* + plani.frete */
                                            + plani.acfprod.
         end.
         */
         if plani.crecod = 1
         then assign ct-vist = ct-vist + 1
                     vlvist = vlvist + (plani.protot /* + plani.frete */
                                     + plani.acfprod - plani.descprod).
         if plani.crecod = 2
         then assign ct-praz = ct-praz + 1
                     vlpraz = vlpraz + (plani.protot - plani.frete
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

for each titulo where titulo.datexp = vdata.
    if titulo.cxacod = vcxacod      and
       titulo.etbcod = estab.etbcod and
       titulo.titpar = 0
       then do:
            assign ct-entr = ct-entr + 1
                   vlentr  = vlentr  + titulo.titvlcob.
       end.
end.

for each titulo where titulo.datexp = vdata.
    vmodcod = titulo.modcod.
    if titulo.datexp <> titulo.cxmdat
    then next.

    if titulo.titdtpag = ?
    then vmodcod = "VDP".
    if titulo.cxacod   <> vcxacod
    then next.
    if titulo.titpar    = 0 or
       titulo.clifor    = 1
    then do:
        if titulo.clifor = 1
        then vmodcod = "VDV".
        else vmodcod = "ENT".
    end.

    if vmodcod <> "CRE"
    then next.

    if titulo.moecod = "PRE"
    then
        assign  vlpred = vlpred + titulo.titvlcob
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
    conta1 = conta1 + 1.
    display stream tela conta1 with frame fcal.
end.
totglo = 0.
for each globa where globa.glodat = vdata no-lock:
    totglo = totglo + globa.gloval.
end.

{mdadmcab.i &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "80"
            &Page-Line = "66"
            &Nom-Rel   = ""DREB040""
            &Nom-Sis   = """SISTEMA CREDIARIO"""
            &Tit-Rel   = """CONFERENCIA DE DOCUMENTOS EM "" +
                            string(vdata) "
            &Width     = "80"
            &Form      = "frame f-cabc1"}

display if not sresp then "******** FECHAMENTO PARCIAL ********"
                     else "" format "x(45)"
        skip(1)
        "CAIXA No. " vcxacod NO-LABEL
        "Valor" at 25 space(3)
        "Qdt" skip(1)
        vlpraz label "1.Venda a Prazo       "  space(5) ct-praz   no-label  skip
        vlvist label "2.Venda a Vista       "  space(5) ct-vist   no-label  skip
        vlentr label "3.Entrada             "  space(5) ct-entr   no-label  skip
        vlpres label "4.Prestacoes          "  space(5) ct-pres   no-label  skip
        vljuro label "5.Juros               "  space(5) ct-juro   no-label  skip
        vldesc label "6.Descontos           "  space(5) ct-desc   no-label  skip
        vldev  label "7.Devolucoes Prazo    "  space(5) ct-dev  no-label skip
        vldevvis label "7.Devolucoes Vista    "  space(5) ct-devvis  no-label
        skip(1)
        vlvist + vlentr + vlpres + vljuro - vldesc format "z,zzz,zz9.99"
                 label "TOTAL CAIXA           "               skip(2)
        vlpred   label "Pre-datados           " skip(2)
        vljurpre label "Juros Pre             " skip(2)
        vlvist + vlentr + vlpres + vljuro - vldesc - vldevvis -
        vlpred - vljurpre
               @ vlsubtot label "Sub-total             " skip(2)
        "_______________" label "Pagamentos            " skip(2)
        totglo            label "Total Global          " skip(2)
        "_______________" @ vtot     label "TOTAL                 " skip(3)
        "_______________" label "Deposito              "            SKIP(1)
        "_______________" label "Sobra                 "            SKIP(1)
        "_______________" label "Falta                 "            SKIP(3)

        with side-label frame f3 column 25.
        put skip
        fill("-",80) format "x(80)" skip.
        put "R E S U M O   D O S   P A G A M E N T O S" AT 40 .
        for each wetb:
            find estab where estab.etbcod = wetb.etbcod no-lock.
            display estab.etbnom
                    wetb.wval column-label "Valor Pago"
                        with frame f-wetb down width 80.
        end.
        put skip
        fill("-",80) format "x(80)" skip.


PUT
        "__________________________"  AT 7 space(10)
        "__________________________"   skip
        "   Encarregado Caixa      "  AT 7 space(10)
        "        Caixa             "  skip(3)
        "__________________________"  AT 10 skip
        "       GERENTE            " AT 10.
output close.


do:
    find first bmovim where bmovim.movdat = vdata no-lock no-error.
    if not avail bmovim
    then leave.
    {mdadmcab.i &Saida     = "printer"
                &Page-Size = "64"
                &Cond-Var  = "160"
                &Page-Line = "66"
                &Nom-Rel   = ""DREB040""
                &Nom-Sis   = """SISTEMA ESTOQUE"""
                &Tit-Rel   = """LISTAGEM DE DIVERGENCIAS DE PRECOS "" +
                              "" LOJA "" + string(estab.etbcod) + "" - "" +
                                               estab.etbnom "
                &Width     = "160"
                &Form      = "frame f-cabcab2"}

    for each movim where movim.movdat = vdata no-lock break by movim.etbcod:

        wpla = 0.
        IF MOVIM.MOVTDC <> 5
        THEN NEXT.

        find first estoq where estoq.procod = movim.procod no-lock no-error.
        if not avail estoq
        then next.

        vvenda = ESTOQ.ESTVENDA.
        if estprodat <> ?
        then if estprodat >= today
             then vvenda = estoq.estproper.
             else vvenda = estoq.estvenda.


        if vvenda = movim.movpc
        then next.

        find produ of movim no-lock.

        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc no-lock no-error.
        if not avail plani
        then next.

        find first contnf where contnf.etbcod = plani.etbcod and
                                contnf.placod = plani.placod no-lock no-error.

        if avail contnf
        then do:
            find contrato of contnf no-lock no-error.
            wpla = contrato.crecod.
        end.



        display plani.etbcod   column-label "Fil."
                plani.numero   column-label "Numero"
                plani.serie    column-label "Ser"
                movim.procod
                produ.pronom   format "x(30)"
                movim.movpc    column-label "Pc.Nota"
                vvenda         column-label "Pc.Venda"
                (movim.movpc - vvenda) column-label "Vl.Difer."
                ((movim.movpc / vvenda) - 1) * 100 format "->>9.99 %"
                               column-label " % Difer."
                wpla column-label "Plano"
                plani.protot column-label "Tot.Nota"
                plani.platot column-label "Tot.Finan"
                ((plani.protot / plani.platot) - 1) * 100 format "->>9.99 %"
                               column-label " % Finan."
                    with no-box width 150.

        if last-of(movim.etbcod)
        then page.

    end.
    output close.
end.



if day(vdata) >= 20 and
   day(vdata) <= 30
then do:


    find first bcontrato where bcontrato.dtinicial = vdata no-lock no-error.
    if not avail bcontrato
    then leave.

    {mdadmcab.i &Saida     = "printer"
                &Page-Size = "64"
                &Cond-Var  = "160"
                &Page-Line = "66"
                &Nom-Rel   = ""DREB040""
                &Nom-Sis   = """SISTEMA ESTOQUE"""
                &Tit-Rel   = """LISTAGEM DE DIVERGENCIAS DE DIAS "" +
                              "" LOJA "" + string(estab.etbcod) + "" - "" +
                                               estab.etbnom "
                &Width     = "160"
                &Form      = "frame f-cabcab3"}

    vqtdcon = 0.
    vvalcon = 0.
    vqtdconesp = 0.
    vvalconesp = 0.
    for each contrato where contrato.dtinicial = vdata:

        vqtdcon = vqtdcon + 1.
        vvalcon = vvalcon + contrato.vltotal.

        find clien where clien.clicod = contrato.clicod no-lock.

        find first titulo use-index titnum
                          where titulo.empcod = wempre.empcod and
                                titulo.titnat = no and
                                titulo.modcod = "CRE" and
                                titulo.etbcod = contrato.etbcod and
                                titulo.clifor = contrato.clicod and
                                titulo.titnum = string(contrato.contnum)
                                no-lock no-error.
        if not avail titulo
        then next.

        find finan where finan.fincod = contrato.crecod no-lock.

        if finent = yes
        then do:

            if contrato.dtinicial = titulo.titdtven
            then next.

        end.
        else do:

            if day(contrato.dtinicial) = day(titulo.titdtven) and
               month(contrato.dtinicial) = month(titulo.titdtven) + 1
            then next.

        end.

        if (titulo.titdtven - contrato.dtinicial) <= 31
        then next.

        vqtdconesp = vqtdconesp + 1.
        vvalconesp = vvalconesp + contrato.vltotal.

        disp contrato.contnum
             clien.clinom
             contrato.dtinicial
             finan.finent
             titulo.titdtven
             (titulo.titdtven - contrato.dtinicial) column-label "Dias"
             contrato.crecod
             contrato.vltotal column-label "Vl.Contrato"
             titulo.titvlcob column-label "Vl.Prestacao"
                    with no-box width 150 down.

    end.

    disp "TOTAL VENDA DO DIA ( ESPECIAL )" at 20 vvalconesp
                                                 vqtdconesp skip(1)
         "TOTAL VENDA DO DIA             " at 20 vvalcon
                                                 vqtdcon with frame ffff
                                                 side-labels.

    output close.
end.
