{admcab.i}
def var vetbcod like estab.etbcod.
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.
def temp-table  tt-produ
    field procod like produ.procod
    field etbcod like estab.etbcod.
def var vfil as char format "x(2)".    
def var varquivo as char.
repeat:

    for each tt-produ:
        delete tt-produ.
    end.
    
    update vetbcod label "Filial" colon 15
            with frame f1 width 80 side-label.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
    
    
    update vdti label "Data Inicial" colon 15
           vdtf label "Data Final"  with frame f1 side-label width 80.
    for each movim where movim.movdat >= vdti and
                         movim.movdat <= vdtf no-lock.

        if vetbcod = 0
        then.
        else if vetbcod = movim.etbcod
             then.
             else next.
        display movim.procod with 1 down. pause 0.
        
        
        if movim.movdes > 0
        then do: 
            find first tt-produ where tt-produ.procod = movim.procod and
                                      tt-produ.etbcod = movim.etbcod no-error.
            if not avail tt-produ 
            then do:
                
                create tt-produ. 
                assign tt-produ.procod = movim.procod 
                       tt-produ.etbcod = movim.etbcod. 
                
            end.
        end.
    end.    
    varquivo = "..\relat\proalt" + string(time).
    {mdad.i &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "110"
            &Page-Line = "66"
            &Nom-Rel   = ""proalt""
            &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""
            &Tit-Rel   = """PRECOS ALTERADOS NA VENDA "" +
                        ""  - Data: "" + string(vdti) + "" A "" +
                            string(vdtf)"
            &Width     = "110"
            &Form      = "frame f-cabcab1"}
    
    for each tt-produ break by tt-produ.procod
                            by tt-produ.etbcod:
        if first-of(tt-produ.procod)
        then vfil = "".
        vfil = vfil + string(tt-produ.etbcod) + " ".
        
        if last-of(tt-produ.procod)
        then display tt-produ.procod 
                     vfil format "x(100)" label "Filiais" 
                            with frame f2 down width 110.
        
        
    end.                
    output close.
    {mrod.i}
end.