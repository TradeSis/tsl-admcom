/*----------------------------------------------------------------------------*/
/* /usr/admctp/antecli.p                              Antecipacoes - Listagem */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 18/12/92 Oscar   Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var varquivo as char format "x(20)".
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat.
def var wclifor like titulo.clifor.
def var wdti    like titulo.titdtven label "Periodo" initial today.
def var wdtf    like titulo.titdtven.
def var wtitvlcob like titulo.titvlcob.
def var wtot      as dec format ">,>>>,>>>,>>9.99" label "Total".
def var wtotdes      as dec format ">>,>>>,>>9.99".
def var wtotcob      as dec format ">>>,>>>,>>9.99".
def var wgerdes      as dec format ">>,>>>,>>9.99".
def var wgercob      as dec format ">>>,>>>,>>9.99".
def var wperdes as dec format ">>>9.9999".
def var i as i.
def var wnome as char format "x(30)" label "Nome".
def var wforcli as i format "999999" label "For/Cli".
form wetbcod colon 18
     estab.etbnom  no-label colon 30
     wdti          colon 18  " A"
     wdtf          colon 35  no-label
                   with side-labels width 80 frame f1.

wdtf = wdti + 30.

repeat with side-labels 1 down width 80 row 4 frame f1:
    clear frame f1 all.
    disp "" @ wetbcod .
    prompt-for wetbcod label "Estabelec." .
    if input wetbcod <> ""
       then do:
               find estab where estab.etbcod = input wetbcod.
               display etbnom .
       end.
       else disp "TODOS" @ etbnom.
     repeat with frame f1:
        update wdti validate(input wdti <> ?,
                            "Data deve ser Informada").

        update wdtf validate(input wdtf > input wdti,
                             "Data Invalida").

        {confir.i 1 "impressao de Titulos Antecipados"}
        
     if opsys = "UNIX"
     then varquivo = "/admcom/relat/res" + string(time).
     else varquivo = "..~\relat~\res" + string(time).

     output to value(varquivo) page-size 60.
      /*
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "147"
        &Page-Line = "66"
        &Nom-Rel   = ""antecli""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """TITULOS C/DESCONTO ANTECIPACAO "" +
                      "" PERIODO DE "" +
                         string(vdti,""99/99/9999"") + "" A "" +
                         string(vdtf,""99/99/9999"") "
       &Width     = "147"
       &Form      = "frame f-cabcab"}
        */
        {ini17cpp.i}

        form titulo.titdtdes format "99/99/99"
             wforcli
             space(2)
             wnome
             titulo.titnum
             titulo.titpar
             titulo.modcod
             titulo.etbcod
             titulo.cobcod
             titulo.titvlcob
             space(1)
             titulo.titvldes
             wperdes
             with frame fdet width 140 no-box no-label.

        form "Total" at 73
             wtotcob space(4)
             wtotdes
             skip (1) with frame ftot no-label width 140 no-box.

        form "Total Geral" at 67
             wgercob space(4)
             wgerdes
                      with frame fger no-label width 140 no-box.

        form header wempre.emprazsoc no-label
                    "Administrativo Financeiro" at 56 today at 110
                    skip 
                    "Titulos c/ Desconto p/ Antecipacao" at 46
                    "Pag." at 110 page-number - 1 format ">>9"
                    "Periodo : " at 50 wdti no-label " a " wdtf no-label
                    skip fill("-",117) format "x(117)" skip
"Dt.Antc. For/Cli Nome                           Titulo       PC MT  Est." at 1
" Cb    Valor Cobrado      Valor Desc. Desc. %"     at 73
"-------- ------- ------------------------------ ------------ -- --- ----" at  1
" -- ---------------- ---------------- -------"     at 73
                    with frame fcab page-top no-box width 140.
                    view frame fcab.

        assign wtotdes = 0
               wtotcob = 0.
        for each titulo where titulo.empcod = wempre.empcod and
                              titdtdes >=  wdti        and
                              titdtdes <=  wdtf        and
                              titnat    =  yes         and
                            ( titsit   =   "LIB"        or
                              titsit   =   "BLO" )     and
                            ( if wetbcod = 0
                                 then true
                                 else titulo.etbcod = wetbcod )
                              no-lock
                              break by titulo.titdtdes
                                    by titulo.clifor
                                    by titulo.modcod
                                    by titulo.titnum
                                    by titulo.titpar:

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

             wperdes = titvldes / titvlcob * 100.
             display titulo.titdtdes
                     wforcli
                     space(2)
                     wnome
                     titulo.titnum
                     titulo.titpar
                     titulo.modcod
                     titulo.etbcod
                     titulo.cobcod
                     titulo.titvlcob
                     titvldes
                     wperdes
                     with frame fdet.
             down with frame fdet.

             assign wtotcob = wtotcob + titvlcob
                    wtotdes = wtotdes + titvldes.

             if last-of(titdtdes)
                then do:
                        put skip
                            space(72)
                            fill("-",45) format "x(45)".
                        display wtotcob
                                wtotdes
                                        with frame ftot no-box.
                        put skip
                            space(72)
                            fill("-",45) format "x(45)".
                        wgercob = wgercob + wtotcob.
                        wgerdes = wgerdes + wtotdes.
                        wtotcob = 0.
                        wtotdes = 0.
                end.
        end.
        put skip
            space(66)
            fill("-",51) format "x(51)".
        display wgercob
                wgerdes
                       with frame fger no-box.
        put skip
            space(66)
            fill("-",51) format "x(51)".
        assign wgercob = 0
               wgerdes = 0.
        {fin17cpp.i}
        output close.
    
        if opsys="UNIX"
        then do:
            run visurel.p(varquivo, "").
        end.
        else do:     
          {mrod.i}
        end.
    end.
end.
