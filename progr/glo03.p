{admcab.i}
def var totetb like plani.platot.
def var vtotal like plani.platot.
def var varquivo as char format "x(20)".
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def var vtot    like plani.platot.
def var vetbcod like estab.etbcod.
repeat:
    update vdti label "Data Inicial"
           vdtf label "Data Final"
            with frame f-dat centered color blue/cyan row 8
                                    title " Periodo " side-label.


    varquivo = "..\relat\glpre" + string(day(today)).

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "64" 
        &Cond-Var  = "130" 
        &Page-Line = "66" 
        &Nom-Rel   = ""glo03""
        &Nom-Sis   = """SISTEMA DE CONSORCIO""" 
        &Tit-Rel   = """LISTAGEM DE VENDAS "" + 
        string(vdti,""99/99/9999"") + "" A "" + 
        string(vdtf,""99/99/9999"")"
        &Width     = "130"
        &Form      = "frame f-cabcab"}
    
    for each estab no-lock:
        for each glopre where glopre.dtemi >= vdti     and
                          glopre.dtemi <= vdtf         and
                          glopre.etbcod = estab.etbcod and
                          glopre.parcela = 1 no-lock break by glopre.etbcod
                                                           by glopre.vencod
                                                           by glopre.dtemi:

            vtot = 0.
            find glofin where glofin.gfcod = glopre.gfcod no-lock no-error.
            if avail glofin
            then assign vtot = (glofin.gfcre * 0.04)
                        vtotal = vtotal + (glofin.gfcre * 0.04)
                        totetb = totetb + (glofin.gfcre * 0.04). 
        
            find func where func.etbcod = estab.etbcod and
                            func.funcod = glopre.vencod no-lock no-error.
        
            display glopre.etbcod
                    glopre.vencod column-label "Vend."
                    func.funnom when avail func
                    glopre.dtemi 
                    glopre.numero
                    glofin.gfdes when avail glofin 
                    vtot column-label "Comissao"
                        with frame f-glo down width 200.
            if last-of(glopre.vencod)
            then do:
                display vtotal label "TOTAL" at 96 
                        with frame ftot side-label width 200.
                vtotal = 0.
            end.
            if last-of(glopre.etbcod)
            then do:
                
                find func where func.etbcod = estab.etbcod and
                                func.funcod = 99 no-lock no-error.
                
                display "GERENTE: "  to 75
                        func.funnom no-label format "x(15)"
                        "TOTAL: "    at 96
                        (totetb * 0.10) format "->>>,>>9.99" 
                                with frame f-etb width 200.
                totetb = 0.
            end.
        
        end.
    end.
    output close.   
    dos silent value("type " + varquivo + "  > prn").  
   
   
end.
