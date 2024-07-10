{admcab.i}
def var vdt1 like plani.pladat.
def var vdt2 like plani.pladat.
def var varquivo as char format "x(20)".
def var fila as char.
repeat:
    vdt1 = today - 30.
    vdt2 = today.
    update vdt1 label "Data Inicial"
           vdt2 label "Data Final" with frame f1 side-label width 80.
           
               
    if opsys = "unix"
    then do:
        find first impress where impress.codimp = setbcod no-lock no-error.
        if avail impress
        then assign fila = string(impress.dfimp) 
                    varquivo = "/admcom/relat/frete" + string(time).
    end.                    
    else assign fila = "" 
                varquivo = "l:\relat\frete" + string(time).

 
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = ""listafre""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""
        &Tit-Rel   = """LISTAGEM DE FRETES POR FORNECEDOR "" +
                    ""  - Data: "" + string(vdt1) + "" A "" +
                        string(vdt2)"
        &Width     = "120"
        &Form      = "frame f-cabcab"}

 
  

    for each estab no-lock,
        each plani where plani.movtdc = 04           and
                             plani.etbcod = estab.etbcod and
                             plani.pladat >= vdt1        and
                             plani.pladat <= vdt2        and
                             plani.cxacod <> 0 no-lock.
                             
            find frete where frete.forcod = plani.cxacod no-lock no-error.
            if not avail frete
            then next.
            
            find forne where forne.forcod = plani.emite no-lock no-error.
            
            find first titulo where titulo.etbcod   = plani.etbcod  and
                              titulo.titnat   = yes           and
                              titulo.modcod   = "NEC"         and
                              titulo.clifor   = frete.forcod  and
                              titulo.empcod   = 19            and
                              titulo.titnumger   = string(plani.numero) and
                              titulo.titpar   = 1            and
                              titulo.titdtemi = plani.pladat 
                              no-lock no-error.
            
            if not avail titulo
            then next.
            
            display plani.etbcod column-label "Dep."
                    plani.numero column-label "NF"
                    plani.pladat column-label "Emissao" 
                    frete.frenom no-label format "x(25)" 
                    forne.forfant column-label "Fornecedor" format "x(20)"
                    plani.platot(total)
                    titulo.titvlcob(total) 
                    ((titulo.titvlcob / plani.platot) * 100)
                        when avail titulo format "->>9.99%" 
                        with frame f2 down width 200.
    end.
    
    output close.
    message "Deseja imprimir relatorio" update sresp.
    if sresp
    then do:
            
        if opsys = "unix"
        then os-command silent lpr value(fila + " " + varquivo).
        else os-command silent type value(varquivo) > prn.
    
    end.

     
end.
