{admcab.i}
def var vcon as char.
def var vrel as char.
def var vv as int.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vmovtdc like tipmov.movtdc format "99".
def var vetbcod like plani.etbcod.
def var varquivo as char.
def var varquivo1 as char.

repeat:
    vrel = "".
    vcon = "".
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
     
    varquivo = "l:\relat\venda." + string(time).
                

    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""confmov""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """MOVIMENTO FILIAL - "" + 
                            string(estab.etbcod) + ""  "" + 
                          string(vdti,""99/99/9999"") + "" ATE "" + 
                          string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab1"}
                    
    for each tipmov where if vmovtdc = 0 
                          then true 
                          else tipmov.movtdc = vmovtdc no-lock:           
        
        for each plani where plani.etbcod = estab.etbcod and
                             plani.emite  = estab.etbcod and
                             plani.movtdc = tipmov.movtdc and
                             plani.datexp >= vdti and
                             plani.datexp <= vdtf and
                             plani.platot = 0.01,
            each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock by plani.numero:
                             
            find produ where produ.procod = movim.procod no-lock no-error.
            disp tipmov.movtnom format "x(20)"
                 plani.numero format ">>>>>>>>>9"
                 plani.emite
                 plani.desti format ">>>>>>>99"
                 plani.datexp format "99/99/9999" column-label "Data Mov."
                 plani.platot(total)
                 produ.procod
                 produ.pronom format "x(30)"
                  with frame f2 down width 200.
        end.
        
    end.
    
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo,
                       input "").
    end.
    else do:
        {mrod.i}
    end.
end.
