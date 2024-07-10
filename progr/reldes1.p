{admcab.i}

def var wvlpri      like titluc.titvlpag.
def var wvlpag      like titluc.titvlpag.

def var vdata       like titluc.titdtemi.
def var vetbcod like estab.etbcod.
def var vdt1 like plani.pladat.
def var vdt2 like plani.pladat.
def var varquivo as char.
repeat:
    update vetbcod label "Filial" colon 15
        with frame f-date.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label
                with frame f-date.
    else do:            
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f-date.
    end.    
    update vdt1 label "Data Incial" colon 15
           vdt2 label "Data Final"  colon 15
               with frame f-date side-label width 80.
    
    varquivo = "l:\relat\desp." + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "147"
        &Page-Line = "0"
        &Nom-Rel   = ""reldes01""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """FILIAL "" + string(vetbcod,"">>9"") +
                        "" PERIODO DE "" +
                         string(vdt1,""99/99/9999"") + "" A "" +
                         string(vdt2,""99/99/9999"") "
       &Width     = "147"
       &Form      = "frame f-cabcab"}
    

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each titluc where titluc.etbcobra = estab.etbcod and
                          titluc.titdtpag >= vdt1   and
                          titluc.titdtpag <= vdt2 no-lock 
                                    break by titluc.etbcod:

        find foraut where foraut.forcod = titluc.clifor no-lock no-error.
        find setaut where setaut.setcod = foraut.setcod no-lock no-error.
        
        display titluc.etbcod column-label "Filial"
                titluc.titnum 
                setaut.setnom format "x(15)"
                titluc.clifor column-label "Codigo"  
                foraut.fornom format "x(30)"
                titluc.titdtpag
                titluc.titvlpag(total by titluc.etbcod)
                    with frame f-tit down width 140.
    end.
    output close.
    {mrod.i} 
end.
