{admcab.i}
def buffer btitulo for titulo.

{setbrw.i}

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def NEW SHARED temp-table tt-modalidade-selec /* #1 */
    field modcod as char.

def var vval-carteira as dec.
def var wvlpri      like titulo.titvlpag.
def var wvlpag      like titulo.titvlpag.
def var vdata       like titulo.titdtemi.
DEF VAR vpago       like titulo.titvlpag.
def var vdesc       like titulo.titvldes.
def var vjuro       like titulo.titjuro.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var vetbcod like estab.etbcod.
def buffer bestab for estab.
def var varquivo as char.
def var vparcial as dec.
def var par-origem as char.

repeat with 1 down side-label width 80 row 3:
    
    for each tt-modalidade-selec: delete tt-modalidade-selec. end.
    
    update vetbcod colon 25.
    find bestab where bestab.etbcod = vetbcod no-lock.
    display bestab.etbnom no-label.
    update vdata colon 25.
    
    assign sresp = false.
           
    update sresp label "Seleciona Modalidades?" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label
           width 80.

    if sresp
    then run selec-modal.p ("REC"). /* #1 */

    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
    end.
      
    display vmod-sel format "x(40)" no-label.

    assign
        vpago = 0
        vdesc = 0
        vjuro = 0
        vparcial = 0.
    if bestab.etbcod <> 999
    then do:
        for each tt-modalidade-selec,
            each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = no and
                              titulo.modcod = tt-modalidade-selec.modcod and
                              titulo.titdtpag = vdata and
                              titulo.etbcobra = vetbcod
                                            no-lock use-index etbcod:
            if titulo.titpar = 0
            then next.
            if titulo.etbcobra <> vetbcod or
               titulo.clifor = 1
            then next.
            assign
                vjuro = vjuro + if titulo.titjuro = titulo.titdesc
                                then 0
                                else titulo.titjuro
                vdesc = vdesc + if titulo.titjuro = titulo.titdesc
                                then 0
                                else titulo.titdesc .
            if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
            then vparcial = vparcial + titulo.titvlpag
                            - titulo.titjuro + titulo.titdesc.
            else vpago = vpago + titulo.titvlpag
                                 - titulo.titjuro + titulo.titdesc.
        end.
    end.
    if vpago = 0 and
       vdesc = 0 and
       vjuro = 0 and
       bestab.etbcod <> 999
    then do:
        message "Nenhum Pagamento  efetuado".
        undo.
    end.
    if bestab.etbcod <> 999
    then
        display vpago label "Valor Pago"    colon 20
                vjuro label "Valor Juro"     colon 20
                vdesc label "Valor Desconto"    colon 20
                vparcial label "Valor Pago Parcial" colon 20
                with frame ff side-label width 80.

    message "Imprimir Resumo ou Geral ?" update sresumo.
    if sresumo and
       bestab.etbcod <> 999
    then do:
       /* output to printer page-size 64. */
        form header
            wempre.emprazsoc
                    space(6) "PAGRE"   at 60
                    "Pag.: " at 71 page-number format ">>9" skip
                    "RESUMO DE DIGITACAO DE PAGAMENTOS "   at 1
                    today format "99/99/9999" at 60
                    string(time,"hh:mm:ss") at 73
                    skip fill("-",80) format "x(80)" skip
                    with frame fcab no-label page-top no-box width 137.
        view frame fcab.
        display bestab.etbcod
                bestab.etbnom
                vdata column-label "Data"
                vpago column-label "Valor Pago"
                vjuro column-label "Valor Juro"
                vdesc column-label "Valor Desconto"
                with frame flin.
        output close.
    end.
    else do:
        if bestab.etbcod = 999
        then do:
            run pagmag.p ( input bestab.etbcod,
                           input 1,
                           input 3,
                           input vdata,
                           input sresumo).
        end.
        else do:
            
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/ppre" + string(time).
    else varquivo = "..\relat\ppre" + string(time).
            

            {mdad.i
                &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "140"
                &Page-Line = "66"
                &Nom-Rel   = """PAGREB4"""
                &Nom-Sis   = """SISTEMA CREDIARIO"""
                &Tit-Rel   = """LISTAGEM DE DIGITACAO DE PAGAMENTOS ESTAB.: ""
                            + string(bestab.etbcod) + "" - "" + bestab.etbnom "
                &Width     = "160"
                &Form      = "frame f-cab"}
        for each tt-modalidade-selec,
            each titulo where titulo.etbcobra = vetbcod and
                              titulo.modcod = tt-modalidade-selec.modcod and
                              titulo.titdtpag = vdata and
                              titulo.clifor <> 1 and
                              titulo.titpar > 0 use-index etbcod
                                    no-lock by titulo.titnum.
            
            find clien where clien.clicod = titulo.clifor NO-LOCK no-error.
            
            /*
            if titulo.etbcobra <> bestab.etbcod or
               titulo.clifor = 1
            then next.
            */
            
            if acha("PARCIAL",titulo.titobs[1]) <> ?
            then par-origem = string(titulo.titparger).
            else par-origem = "". 
            vjuro = if titulo.titjuro = titulo.titdesc
                    then 0
                    else titulo.titjuro.
            vdesc = if titulo.titjuro = titulo.titdesc
                    then 0
                    else titulo.titvldes.
            display titulo.etbcod   column-label "Fil."
                    titulo.etbcobra column-label "Cob."
                    titulo.titnum   column-label "Contr."
                    titulo.titpar   column-label "Pr."
                    par-origem      column-label "Ori"  format "xx"
                    titulo.clifor   column-label "Cliente"
                    clien.clinom    column-label "Nome" format "x(35)"
                                        when avail clien
                    titulo.titdtven
                    titulo.titdtpag
                    titulo.titvlcob 
                    titulo.titvlpag - titulo.titjuro + titulo.titvldes
                         column-label "Valor Pago" format ">>>,>>9.99" (TOTAL)
                    vjuro                       format ">>>,>>9.99"  (TOTAL)
                    vdesc                       format "->>,>>9.99"  (TOTAL)
                    with no-box width 160 frame flin2 down.
            down with frame flin2.

        end.
        end.
        put unformatted chr(30) "0".
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

