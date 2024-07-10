{admcab.i}
def var vper as dec.
def var varquivo as char.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.

repeat:

    update vetbcod colon 16 label "Filial" 
            with frame f1 side-label width 80.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        disp estab.etbnom no-label with frame f1.
    end.
    update vdti colon 16 label "Data Inicial"
           vdtf colon 16 label "Data Final"with frame f1.
 

    varquivo = "..\relat\devfor.txt".

    {mdad.i 
        &Saida     = "value(varquivo)"  
        &Page-Size = "64"  
        &Cond-Var  = "137"  
        &Page-Line = "66"  
        &Nom-Rel   = ""reldev""  
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE""" 
        &Tit-Rel   = """DEVOLUCAO DE COMPRA "" +
                        string(vetbcod,"">>9"") + "" PERIODO DE "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "137" 
        &Form      = "frame f-cabcab"}



    for each plani where plani.etbcod = estab.etbcod and 
                         plani.emite  = estab.etbcod and
                         plani.movtdc = 13 and
                         plani.datexp >= vdti and
                         plani.datexp <= vdtf:
                 
        find first opcom where opcom.opcant = string(plani.hiccod)
                                    no-lock no-error.
                    
        find forne where forne.forcod = plani.desti no-lock.
        if not avail forne
        then next.
    
        if forne.ufecod = "RS"
        then vper = 0.17.
        else vper = 0.12.
    
        if plani.bicms = 0
        then plani.bicms = plani.platot.
    
        plani.icms = plani.bicms * vper.
                                                    

        disp opcom.opccod when avail opcom 
             plani.numero 
             plani.desti format ">>>>>>>99" 
             forne.fornom format "x(30)"
             plani.datexp format "99/99/9999" 
                    column-label "Data Mov."          plani.platot(total)
             plani.bicms(total) 
             plani.icms(total)
                  with frame f2 down width 140.
    end.                  
    output close.
    {mrod.i}
end.
    
