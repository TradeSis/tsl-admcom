{admcab.i}

def input parameter p-recid as recid.

def var varquivo as char.


find tpimport where recid(tpimport) = p-recid no-lock no-error.
if not avail tpimport then return.

    varquivo = "/admcom/relat/" + tpimport.numeropi + "." + string(time).
        
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "130"  
        &Page-Line = "66"
        &Nom-Rel   = ""importacao_r01""  
        &Nom-Sis   = """SISTEMA FINANCEIRO """
        &Tit-Rel   = """ PROCESSO DE IMPORTACAO "" + tpimport.numeropi "
        &Width     = "130"
        &Form      = "frame f-cabcab"}


for each fatudesp where fatudesp.numeroDI = tpimport.numeropi no-lock.
    for each titulo where
             titulo.clifor = fatudesp.clicod and
             titulo.titnum begins string(fatudesp.fatnum)
             no-lock:
        find forne where forne.forcod = titulo.clifor no-lock.
        find cobra where cobra.cobcod = titulo.cobcod no-lock.
        display 
                        titulo.clifor 
                        column-label "Forne" format "999999" 
                        forne.fornom         column-label "Ag.Comercial"
                                      format "x(30)"
                        titulo.modcod column-label "Mod"
                        titulo.titnum 
                        titulo.titpar
                        cobra.cobnom  when avail cobra
                            column-label "Cobranca" format "x(08)"
                        titulo.etbcod column-label "Fl." format ">99" 
                        titulo.titvlcob(total) 
                                column-label "Valor!Total" 
                                        format ">>,>>>,>>9.99"
                        titulo.titvljur format ">>>,>>9.99" 
                                column-label "Vl.Juros"
                        titulo.titvldes format ">>>,>>9.99" 
                                column-label "Vl.Desc"
                        (titulo.titvlcob + titulo.titvljur - 
                         titulo.titvldes)(total) 
                         format ">,>>>,>>9.99"  column-label "Valor!Cobrado"
                        titulo.evecod column-label "Ev." format ">9"
                        titulo.titsit with frame f2 width 150 down.
 
            down with frame f2.
    end.
end.
output close.
run visurel.p(varquivo,"").
