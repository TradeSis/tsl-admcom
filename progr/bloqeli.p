/*----------------------------------------------------------------------------*/
/* /usr/admfin/bloqeli.p                                Bloqueados - Listagem */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 08/12/92 Oscar   Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var varquivo as char format "x(20)".
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat.
def var wclifor like titulo.clifor.
def var wtitvlcob like titulo.titvlcob.
def var wtot      as dec format ">,>>>,>>>,>>9.99" label "Total".
def var wtotcob      as dec format ">,>>>,>>>,>>9.99".
def var wgercob      as dec format ">,>>>,>>>,>>9.99".
def var wnrdias as i format ">>9" label "DD".
def var i as i.
def var wnome as char format "x(15)" label "Nome".
def var wforcli as i format "999999" label "For/Cli".
def var wcab    as c format "x(14)".
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
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
        clear frame ff all.
        clear frame fc all.
        if wtitnat
           then do with column 1 side-labels 1 down width 48 row 4 frame ff:
             disp "" @ wclifor.
             wcab    = "A Pagar".
             prompt-for wclifor label "Fornecedor".

             if input wclifor <> ""
                then do:
                        find forne where forne.forcod = input wclifor.
                        display fornom format "x(32)" no-label at 10.
                end.
                else disp "RELATORIO DE TODOS OS FORNECEDORES" @ fornom.
           end.
           else do with column 1 side-labels 1 down width 48 row 4 frame fc:
             disp "" @ wclifor.
             wcab    = "A Receber".
             prompt-for wclifor label "Clientes".
             if input wclifor <> ""
                then do:
                        find clien where clien.clicod = input wclifor.
                        display clinom format "x(32)" no-label at 10.
                end.
                else disp "RELATORIO DE TODOS OS CLIENTES" @ clinom.
           end.

        {confir.i 1 "impressao de Titulos Bloqueados"}
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/res" + string(time).
    else varquivo = "..\relat\res" + string(time).
        
{mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "147"
        &Page-Line = "66"
        &Nom-Rel   = ""bloqeli""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """TITULOS BLOQUEADOS"""
        &Width     = "147"
        &Form      = "frame f-cabcab"}

        
        
        
     /*   output to printer page-size 60.*/
        {ini17cpp.i}

        form titulo.titdtven format "99/99/9999"
             titulo.modcod
             wforcli
             space(2)
             wnome
             titulo.titnum
             titulo.titpar
             titulo.etbcod
             titulo.cobcod
             titulo.bancod
             space(0) "/" space(0)
             titulo.agecod
             titulo.titvlcob
             titulo.titobs[1]
             titulo.titobs[2] colon 60
                             with frame fdet width 200 no-label no-box.

        form "Total" at 69
             wtotcob
             skip (1) with frame ftot no-label width 140 no-box.

        form "Total Geral" at 63
             wgercob
             with frame fger no-label width 140 no-box.

        form header wempre.emprazsoc no-label
                    "Administrativo Financeiro" at 89 today at 133
                    skip "Titulos Bloqueados" at 79 wcab no-label
                    "Pag." at 133 page-number - 1 format ">>9"
                    skip fill("-",140) format "x(140)" skip
"Dt.Vcto. MT  For/Cli Nome            Titulo       PC Est." at  1
" Cb Bco/Agencia     Valor Cobrado"                                        at 58
"Observacoes"                                                              at 92
"-------- --- ------- --------------- ------------ -- ----" at  1
" -- ------------ ----------------"                                        at 58
"--------------------------------------------------" at 92
                    with frame fcab page-top no-box width 160.
                    view frame fcab.

        wtotcob = 0.
        
        for each titulo where titulo.empcod = wempre.empcod and
                              titnat   =   wtitnat     and
                              titsit   =   "BLO"       and
                            ( if wclifor = 0 or wclifor = ?
                                 then true
                                 else titulo.clifor = wclifor ) and
                            ( if wmodcod = ""
                              then true
                              else titulo.modcod = wmodcod ) and
                            ( if wetbcod = 0
                                 then true
                                 else titulo.etbcod = wetbcod ) no-lock
                                  break by titulo.titdtven
                                        by titulo.clifor
                                        by titulo.modcod
                                        by titulo.titnum
                                        by titulo.titpar:

             if wtitnat
                then do:
                       find forne where forne.forcod =  titulo.clifor.
                        assign wforcli = forne.forcod
                               wnome   = forne.forfan.
                end.
                else do:
                       find clien where clien.clicod = titulo.clifor.
                        assign wforcli = clien.clicod
                               wnome   = clien.clinom.
                end.

             display titulo.titdtven
                     titulo.modcod
                     wforcli
                     wnome
                     titulo.titnum
                     titulo.titpar
                     titulo.etbcod
                     titulo.cobcod
                     titulo.bancod  when titulo.bancod <> 0
                     titulo.agecod  when titulo.bancod <> 0
                     titulo.titvlcob
                     titulo.titobs[1]
                     titulo.titobs[2] with frame fdet.
             down with frame fdet.

             wtotcob = wtotcob + titvlcob.

             if last-of(titdtven)
                then do:
                        put skip
                            space(68)
                            fill("-",54) format "x(54)".
                        display wtotcob with frame ftot no-box.
                        put skip
                            space(68)
                            fill("-",54) format "x(54)".
                        assign wgercob = wgercob + wtotcob
                        wtotcob = 0.
                end.
       end.
       put skip
           space(62)
           fill("-",60) format "x(60)".
       display wgercob with frame fger no-box.
       put skip
           space(62)
           fill("-",60) format "x(60)".
       wgercob = 0.
       {fin17cpp.i}
       output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.

    end.
end.
