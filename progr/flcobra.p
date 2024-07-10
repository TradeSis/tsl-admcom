{admcab.i new}
def var vetbcod like estab.etbcod.
def var varquivo as char.
def var vdt  like plani.pladat.
def var i as int.
def var vdtini      like titulo.titdtemi    label "Data Inicial".
def var vdtfin      like titulo.titdtemi    label "Data Final".
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vjuro       like titulo.titjuro.
def var vdesc       like titulo.titdesc.

def temp-table tt-resumo
    field clicod like clien.clicod  column-label "Cliente"
    field clinom like clien.clinom  column-label "Nome"
    field flpag  like estab.etbcod  column-label "Fl.Pago"
    field flori  like estab.etbcod  column-label "Fl.Orig"
    field vlpag  like titulo.titvlcob    column-label "Tot. Pago"
                                                  format ">,>>>,>>9.99"
          index clinom clinom.

repeat:
    update vetbcod with frame fxx side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame fxx side-label.
    update vdtini colon 16
           vdtfin colon 16 with frame fxx.
    for each tt-resumo.
        delete tt-resumo.
    end.
    do vdt = vdtini to vdtfin:
        for each titulo where titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = "CRE" and
                              titulo.titdtpag = vdt and
                              titulo.etbcod = estab.etbcod no-lock:
            
            if titulo.etbcobra = titulo.etbcod 
            then next.
            if titulo.clifor = 1
            then next.
            if titulo.modcod <> "CRE"
            then next.
            if titulo.titpar = 0
            then next.

            find first tt-resumo where tt-resumo.clicod = titulo.clifor and
                                       tt-resumo.flpag  = titulo.etbcobra
                                            no-error.                        
            if not avail tt-resumo 
            then do:
                find clien where clien.clicod = titulo.clifor no-lock no-error.
                create tt-resumo.
                assign tt-resumo.clicod = titulo.clifor
                       tt-resumo.clinom = clien.clinom
                       tt-resumo.flori  = titulo.etbcod
                       tt-resumo.flpag  = titulo.etbcobra.
            end.
            tt-resumo.vlpag = tt-resumo.vlpag + titulo.titvlcob.
        end.
    end.
             
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/cxa".
    else varquivo = "i:\admcom\relat\cxa".
    
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = """flcobra"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """RESUMO MENSAL DE CAIXA  -  PERIODO DE "" +
                            string(vdtini)  + "" A "" + string(vdtfin) "
        &Width     = "120"
        &Form      = "frame f-cab"}

    for each tt-resumo use-index clinom:
        display tt-resumo.clicod column-label "Codigo"
                tt-resumo.clinom column-label "Nome"  
                tt-resumo.flori  column-label "Fl.Orig"
                tt-resumo.flpag  column-label "Fl.Pago"
                tt-resumo.vlpag(total) column-label "Valor Pago"
                    with frame flin width 160 down no-box.
    end.
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:             
        dos silent value("type " + varquivo + " > prn" ) .
    end.    
end.
