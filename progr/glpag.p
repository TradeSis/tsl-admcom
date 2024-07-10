{admcab.i}
def var totetb like plani.platot.
def var vtotal like plani.platot.
def var varquivo as char format "x(20)".
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def var vtot    like plani.platot.
def var vetbcod like estab.etbcod.
repeat:

    update vetbcod label "Filial"
                with frame f-dat.
    update vdti label "Data Inicial"
           vdtf label "Data Final"
            with frame f-dat centered color blue/cyan row 8
                                    title " Periodo " side-label.


    
    varquivo = "..\relat\glpag" + string(day(today)).

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "64" 
        &Cond-Var  = "130" 
        &Page-Line = "66" 
        &Nom-Rel   = ""glpag""
        &Nom-Sis   = """SISTEMA DE CONSORCIO""" 
        &Tit-Rel   = """LISTAGEM DE PAGTO "" + 
                        string(vdti,""99/99/9999"") + "" A "" + 
                        string(vdtf,""99/99/9999"") + "" Filial "" + 
                        string(vetbcod,"">>9"")"
        &Width     = "130"
        &Form      = "frame f-cabcab"}
    
    for each glopre where glopre.dtpag >= vdti         and
                          glopre.dtpag <= vdtf         and
                          glopre.etbcod = vetbcod no-lock by glopre.dtpag:

        find func where func.etbcod = estab.etbcod and
                        func.funcod = glopre.vencod no-lock no-error.
        
        find clien where clien.clicod = glopre.clicod no-lock no-error.
            
            
        display glopre.dtpag 
                glopre.clicod column-label "Cliente"
                clien.clinom when avail clien
                glopre.numero
                glopre.parcela
                glopre.grupo
                glopre.cota
                glopre.valpar(total)
                    with frame f-glo down width 200.
        
    end.
    output close.   
    dos silent value("type " + varquivo + "  > prn").  
   
   
end.
