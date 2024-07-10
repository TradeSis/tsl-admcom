{admcab.i}
   
def var vimp as char format "x(20)" 
            extent 2 initial ["Consulta","Relatorio"]. 


def var vv as int.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vmovtdc like tipmov.movtdc format "99".
def var vetbcod like plani.etbcod.

repeat:
    update vetbcod label "Filial" colon 16 
        with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    update vmovtdc label "Tipo de Nota" colon 16
        with frame f1 side-label.
    if vmovtdc = 0
    then display "GERAL" @ tipmov.movtnom with frame f1.
    else do:
        find tipmov where tipmov.movtdc = vmovtdc no-lock.
        disp tipmov.movtnom no-label with frame f1.
    end.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final"
                with frame f1 side-label.
     
    display vimp no-label with frame fimp.
    choose field vimp with frame fimp  centered.
    if frame-index = 1
    then vv = 1.
    else vv = 2.
    


    {mdadmcab.i
            &Saida     = "i:\admcom\relat\connf.txt"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""connf""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """MOVIMENTO FILIAL - "" + 
                            string(estab.etbcod) + ""  "" + 
                          string(vdti,""99/99/9999"") + "" ATE "" + 
                          string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}
                    
    for each tipmov where if vmovtdc = 0 
                          then true 
                          else tipmov.movtdc = vmovtdc no-lock:           
        
        for each plani where plani.etbcod = estab.etbcod and
                             plani.emite  = estab.etbcod and
                             plani.movtdc = tipmov.movtdc and
                             plani.datexp >= vdti and
                             plani.datexp <= vdtf no-lock:
                             
            disp plani.movtdc format "99" column-label "TP"
                 tipmov.movtnom format "x(20)"
                 plani.numero
                 plani.emite
                 plani.desti format ">>>>>>>99"
                 plani.datexp format "99/99/9999" column-label "Data Mov."
                 plani.platot(total) with frame f2 down width 200.
        end.
        
        for each plani where plani.desti  = estab.etbcod and
                             plani.movtdc = tipmov.movtdc and
                             plani.datexp >= vdti and
                             plani.datexp <= vdtf no-lock:
            disp plani.movtdc format "99" column-label "TP"
                 tipmov.movtnom format "x(20)"
                 plani.numero
                 plani.emite
                 plani.desti format ">>>>>>>99"
                 plani.datexp format "99/99/9999" column-label "Data Mov."
                 plani.platot(total) with frame f3 down width 200.
            
            if plani.movtdc = 4
            then do:
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc no-lock:
                    find produ where produ.procod = movim.procod no-lock.
                    display movim.procod
                            produ.pronom
                            movim.movqtm
                            movim.movpc
                                with frame f5 down width 200.
                end.                 
            end.
        end.
    end.
    
    output close.
    if vv = 1
    then dos silent ved i:\admcom\relat\connf.txt.
    else dos silent type i:\admcom\relat\connf.txt > prn. 

 
 
end.
