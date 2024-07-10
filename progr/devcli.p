/*----------------------------------------------------------------------------*/
/* /usr/admfin/atrasli.p                                  Atrasos - Listagem  */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var valor   like titulo.titvlcob.
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat.
def var wclifor like titulo.clifor.
def var wtitvljur like titulo.titvljur format ">>,>>>,>>9.99" label "Juros".
def var wdti    like titulo.titdtven label "Data Inicial" initial today.
def var wdtf    like titulo.titdtven label "Data Final" initial today.
def var wtitdat as date format "99/99/99" column-label "Cob/Pag".
def var wvltot like titulo.titvlcob.
def var wtotjur      as dec format ">>>,>>9.99".
def var wtotcob      as dec format ">,>>>,>>>,>>9.99".
def var wtotvlr      as dec format ">>>,>>>,>>9.99".
def var wgerjur      as dec format ">>>,>>9.99".
def var wgercob      as dec format ">,>>>,>>>,>>9.99".
def var wgervlr      as dec format ">>>,>>>,>>9.99".
def var wnrdias as i format ">>9" label "DD".
def var i as i.
def var wnome as char format "x(30)" label "Nome".
def var wforcli as i format "999999" label "For/Cli".
def var wcab    as c format "x(14)".
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:

    form wdti colon 20
             with frame fdat width 80 side-label
             row  4 title color normal " Clientes em Atraso "  .

    update wdti
            with frame fdat.
    update "     Valores Acima de"
                valor
                with frame fvalor
                         no-label centered row 7 width 80.

    {confir.i 1 "Listagem de Atrasos"}

    form wforcli
         wnome
         titulo.titdtven format "99/99/99" column-label "Dt.Vecto"
         titulo.titnum
         titulo.titpar
         titulo.modcod
         titulo.etbcod
         estab.etbnom
         wnrdias
         titulo.titvlcob format ">>,>>>,>>9.99"
         with frame fdet width 140 no-box down.

    form "Total" at 85
             wtotcob space(4)
             wtotjur
             wtotvlr
             skip (1) with frame ftot no-label width 140 no-box.

    form "Total Geral" at 79
             wgercob space(4)
             wgerjur
             wgervlr  with frame fger no-label width 140 no-box.


    assign wtotjur = 0
           wtotcob = 0
           wtotvlr = 0.

    output to relat page-size 64.
    {ini17cpp.i}

    for each titulo use-index titdtven
                    where titulo.empcod    =  wempre.empcod and
                          titnat           =  no            and
                          titulo.modcod    =  "CRE"         and
                          titdtven        <   wdti          and
                         (titulo.titsit    =  "LIB"          or
                          titulo.titsit    =  "IMP")        and
                          titulo.titvlcob >=  valor
                                    break by titulo.clifor.

    form header wempre.emprazsoc
         space(6) "DEVCLI"  at 107
         "Pag.: " at 118 page-number format ">>9" skip
         "CLIENTES DEVEDORES EM  " string(wdti)  " COM VALOR MAIOR QUE "
         string(valor)
         today format "99/99/9999" at 107
         string(time,"hh:mm:ss") at 120
         skip fill("-",127) format "x(127)" skip
         with frame fcab no-label page-top no-box width 127.
    view frame fcab.

            assign wnrdias   = wdti      - titulo.titdtven
                   wtitvljur = titvljur  * wnrdias
                   wvltot    = wtitvljur + titvlcob
                   wtotjur   = wtotjur   + wtitvljur
                   wtotcob   = wtotcob   + titvlcob
                   wtotvlr   = wtotvlr   + wvltot.

        if wtitnat
        then do:
            find forne where forne.forcod =  titulo.clifor.
                       assign wforcli = forne.forcod
                              wnome   = forne.fornom.
        end.
        else do:
            find clien where clien.clicod = titulo.clifor.
                       assign wforcli = clien.clicod
                              wnome   = clien.clinom.
        end.

        find estab where estab.etbcod = titulo.etbcod no-lock.

        display wforcli
                wnome
                titulo.titdtven
                titulo.titnum
                titulo.titpar
                titulo.modcod
                titulo.etbcod
                estab.etbnom
                wnrdias
                titulo.titvlcob
                with frame fdet.
        down with frame fdet.

        if last-of(clifor)
        then do:
                       put skip
                           space(85)
                           fill("-",52) format "x(52)".
                       display wtotcob
                               wtotjur
                               wtotvlr with frame ftot no-box.
                       put skip
                           space(85)
                           fill("-",52) format "x(52)".
                       assign wgercob = wgercob + wtotcob
                              wgerjur = wgerjur + wtotjur
                              wgervlr = wgervlr + wtotvlr
                              wtotcob = 0
                              wtotjur = 0
                              wtotvlr = 0.
        end.
        if last(clifor)
        then do:
            put skip
                space(79)
                fill("-",58) format "x(58)".
            display wgercob
                    wgerjur
                    wgervlr with frame fger no-box.
            put skip
                space(79)
                fill("-",58) format "x(58)".
            assign wgercob = 0
                   wgerjur = 0
                   wgervlr = 0.
        end.
    end.
    {fin17cpp.i}
    output close.
end.
