{admcab.i}
def var i as i.
def var vetbcod like estab.etbcod.
def var totavi like titulo.titvlcob.
def var totapr like titulo.titvlcob.
def var totent like titulo.titvlcob.
def var totjur like titulo.titjuro.
def var totpre like titulo.titvlcob.

def var x as i.
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
def var vdt1        as   date.
def var vdt2        as   date.
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
    update vetbcod colon 20.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label.
    x = 0.
    totavi = 0.
    totapr = 0.
    totjur = 0.
    totpre = 0.
    totent = 0.

    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final" colon 20.

output to printer page-size 66.

put unformatted chr(27) + "P" + chr(18).
do vdata = vdt1 to vdt2:


    assign vcta01 = string(estab.prazo,"99999")
           vcta02 = string(estab.vista,"99999").

    assign  vlpraz  = 0 vlvist  = 0 vlentr  = 0 vljuro  = 0 vldev = 0
            vldesc  = 0 vldevvis = 0 vlpres = 0
            ct-pres = 0 ct-juro = 0 ct-desc = 0 ct-vist = 0
            ct-praz = 0 vlpred  = 0 vljurpre = 0 vnumtra = 0 ct-dev = 0
            ct-devvis = 0.

        for each plani use-index pladat where plani.movtdc = 5       and
                                              plani.etbcod = estab.etbcod and
                                              plani.pladat = vdata no-lock.

                if plani.crecod = 1
                then assign ct-vist = ct-vist + 1
                            vlvist = vlvist +  if plani.outras > 0
                                               then plani.outras
                                               else plani.platot.
                if plani.crecod = 2
                then assign ct-praz = ct-praz + 1
                            vlpraz = vlpraz + if plani.outras > 0
                                              then plani.outras
                                              else plani.platot.

                if plani.crecod = 1 and
                   plani.vlserv > 0
                then assign ct-devvis = ct-devvis + 1
                            vldevvis = vldevvis + plani.vlserv.

                if plani.crecod = 2 and
                   plani.vlserv > 0
                then assign ct-dev = ct-dev + 1
                            vldev = vldev + plani.vlserv.
        end.
        for each caixa where caixa.etbcod = estab.etbcod no-lock:
        for each titulo where titulo.cxacod = caixa.cxacod and
                              titulo.etbcod = estab.etbcod and
                              titulo.cxmdat = vdata        no-lock.
            if titulo.titnat = yes
            then next.
            if titulo.modcod <> "CRE"
            then next.
            if titulo.etbcod = estab.etbcod and
               titulo.titpar = 0
            then do:
                assign ct-entr = ct-entr + 1
                       vlentr  = vlentr  + titulo.titvlcob.
            end.


            if titulo.titdtpag = ?
            then next.
            if titulo.titpar   = 0
            then next.
            if titulo.clifor   = 1
            then next.
            if titulo.etbcobra <> estab.etbcod
            then next.
        end.
        end.
        i = 0.
        do i = 1 to 33:
        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = no and
                              titulo.modcod = "CRE" and
                              titulo.titdtpag = vdata and
                              titulo.etbcod = i
                                            no-lock use-index titdtpag:
            if titulo.titpar = 0
            then next.
            if titulo.etbcobra <> vetbcod or titulo.clifor = 1
            then next.
            assign
                vlpres = vlpres + titulo.titvlpag
                              - titulo.titjuro + titulo.titdesc
                vljuro = vljuro + if titulo.titjuro = titulo.titdesc
                                then 0
                                else titulo.titjuro
                ct-pres = ct-pres + if titulo.titvlcob > 0
                                    then 1
                                    else 0
                ct-juro = ct-juro + if titulo.titjuro > 0
                                    then 1
                                    else 0.
        end.
        end.
    do on error undo, retry:

    if vlpraz = 0 and
       vlvist = 0 and
       vljuro = 0 and
       vlpres = 0 and
       vlentr = 0
    then next.

    put "RESUMO GERAL DOS CAIXAS DA LOJA DIA "  vdata "  "
    estab.etbnom format "x(20)" skip
    fill("-",80) format "x(80)" skip.


    totavi = totavi + vlvist.
    totapr = totapr + vlpraz.
    totjur = totjur + vljuro.
    totpre = totpre + vlpres.
    totent = totent + vlentr.


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

        vlpraz + vlvist + vlentr + vlpres + vljuro
                            label "Valor         "
        "Numero do Lote: ________________"
        skip(2) with side-label no-box frame f3 column 05.
    end.
end.

display totapr label "Total a Prazo"
        totavi            label "Total a Vista"
        (totapr + totavi) label "Total Venda  " format ">,>>>,>>>,>>9.99"
        totent            label "Total Entrada"
        totpre            label "Total Prestac"
        totjur label "Total Juros  "
        (totapr + totavi + totent + totpre + totjur) label "Total Geral  "
            with frame ftot side-label width 80 centered.


output close.
end.
