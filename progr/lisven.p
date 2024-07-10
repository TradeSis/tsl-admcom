{admcab.i}
def var vclacod like clase.clacod.
def var vetbcod like estab.etbcod.
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.

repeat:
    update vetbcod label "Filial" with frame f1 
                side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdti label "Data Inicial" at 1
           vdtf label "Data Final" with frame f1.
    update vclacod label "Classe" at 1 with frame f1.
    find clase where clase.clacod = vclacod no-lock.
    display clase.clanom no-label with frame f1.
    
    {mdadmcab.i 
        &Saida     = "printer"
        &Page-Size = "64" 
        &Cond-Var  = "150" 
        &Page-Line = "66" 
        &Nom-Rel   = ""lisven"" 
        &Nom-Sis   = """SISTEMA DE VENDAS""" 
        &Tit-Rel   = """VENDAS DE "" + clase.clanom + 
                      "" DA FILIAL "" + string(vetbcod,"">>9"") + 
                      "" PERIODO DE "" +   
                      string(vdti,""99/99/9999"") + "" A "" +                       string(vdtf,""99/99/9999"") "
        &Width     = "150" 
        &Form      = "frame f-cabcab"}

 
    for each produ where clacod = clase.clacod no-lock,
        each movim where movim.etbcod = estab.etbcod  and
                         movim.movtdc = 05            and
                         movim.procod = produ.procod  and
                         movim.movdat >= vdti         and
                         movim.movdat <= vdtf         no-lock 
                                    break by produ.procod:
        
        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc no-lock no-error.
        if avail plani 
        then do:        
            disp produ.procod 
                 produ.pronom format "x(30)"  
                 plani.numero  
                 plani.vencod column-label "VEN"  
                 movim.datexp format "99/99/9999"  
                 movqtm(total by produ.procod) 
                     column-label "QTD" format ">>>>9".
        end.  
    end.
    output close.
end.