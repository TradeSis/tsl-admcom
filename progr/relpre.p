{admcab.i}
def var totmov  like plani.platot.
def var vetbcod like estab.etbcod.
def var vdti    like plani.pladat initial today.
def var vdtf    like plani.pladat initial today.
def var varquivo as char.

repeat:
    
    
    totmov = 0.
    update vetbcod label "Filial"
            with frame f1 width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f1.
            
    update vdti label "Periodo"
           vdtf no-label 
               with frame f1 side-label.
    
    varquivo = "l:\relat\pre" + STRING(day(vdti)) +
                                STRING(month(vdti)) +
                                string(estab.etbcod,">>9").

 
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"  
        &Cond-Var  = "147"
        &Page-Line = "64" 
        &Nom-Rel   = """relpre"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """LISTAGEM DE NOTAS FISCAIS"" + estab.etbnom + ""  "" +
                        "" Periodo: "" + string(vdti,""99/99/9999"") +
                        "" Ate "" + string(vdtf,""99/99/9999"")"
        &Width     = "147"
        &Form      = "frame f-cab"}

     
    
    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 05           and
                         plani.pladat >= vdti        and
                         plani.pladat <= vdtf no-lock:



        totmov = 0.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
                           
            totmov = totmov + (movim.movpc * movim.movqtm).
    
        end.

        if totmov = 0 and 
           plani.platot > 1 and
           plani.serie = "V"
       
        then display plani.etbcod
                     plani.numero format "9999999"  
                     plani.serie   
                     plani.pladat 
                     plani.platot(total)
                        with frame f2 width 100 down.

    end.

    output close.
    {mrod.i}
    
end.
    

