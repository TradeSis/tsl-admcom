{admcab.i}
def var varquivo as char.
def stream stela.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.

def temp-table tt-pro
    field procod like produ.procod
    field placod like plani.placod
    field etbcod like plani.etbcod
    field movdat like movim.movdat.

def var vprocod like produ.procod.
def var vplacod like plani.placod.
def var vetbcod like plani.etbcod.
def var vmovdat like movim.movdat.

repeat:

    update vdti label "Data Inicial"
           vdtf label "Data Final" with frame f1 side-label width 80.

    for each tt-pro:
        delete tt-pro.
    end.
    
    input from l:\progr\erropro.log.
    repeat:
        import vprocod
               vetbcod
               vplacod 
               vmovdat
               ^.
    
        create tt-pro.
        assign tt-pro.procod = vprocod
               tt-pro.etbcod = vetbcod
               tt-pro.placod = vplacod
               tt-pro.movdat = vmovdat.
    end.    
    input close.
 
    varquivo = "c:\temp\lix" + string(day(today)).

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""erropro""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """PRODUTOS NAO CADASTRADOS - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

 
    output stream stela to terminal.
    for each tt-pro where tt-pro.movdat >= vdti and
                          tt-pro.movdat <= vdtf,
        each movim where movim.etbcod = tt-pro.etbcod and
                         movim.placod = tt-pro.placod and
                         movim.procod = tt-pro.procod no-lock
                                                by tt-pro.movdat
                                                by tt-pro.etbcod:
                                                
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod 
                                        no-lock no-error.
            if not avail plani
            then next.
                               
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then do:
                find tipmov where tipmov.movtdc = plani.movtdc 
                                                    no-lock no-error.
                if not avail tipmov
                then next.
                
                display stream stela
                        tt-pro.etbcod
                        movim.procod  
                        tipmov.movtnom format "x(15)" when avail tipmov 
                        plani.desti  format ">>>>>>>999"
                        plani.numero
                        plani.datexp format "99/99/9999" column-label "Data"
                        movim.movqtm column-label "Qtd" format ">>>9"
                        (movim.movqtm * movim.movpc)(total) 
                                column-label "Total"
                                        with frame ff down width 80.
                down with frame ff.
                
                display 
                        tt-pro.etbcod
                        movim.procod  
                        tipmov.movtnom format "x(15)" when avail tipmov 
                        plani.desti  format ">>>>>>>999"
                        plani.numero
                        plani.datexp format "99/99/9999" column-label "Data"
                        movim.movqtm column-label "Qtd" format ">>>9"
                        (movim.movqtm * movim.movpc)(total) 
                                column-label "Total"
                                        with frame ff-2 down width 80.
                down with frame ff-2.

            end.                
            down with frame ff.
    end.
    output stream stela close.
    output close.
    
    message "Deseja Imprimir" update sresp.
    if sresp
    then dos silent value("type " + varquivo + " > prn").
    
        
        
end.
