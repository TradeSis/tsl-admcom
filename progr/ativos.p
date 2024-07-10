{admcab.i}
def var varquivo as char.
def temp-table tt-cli
    field etbcod like estab.etbcod
    field qtd   as int.
    

repeat:

    for each tt-cli:
        delete tt-cli.
    end.

    message "Confirma Listagem de Clientes Ativos" update sresp.
    if not sresp
    then leave.
    
    for each clien where clien.clicod > 1 no-lock:
        display clien.clicod 
                 with frame f1 side-label 1 down centered. 
        pause 0.
    
        find first titulo where titulo.clifor = clien.clicod and
                                titulo.titnat = no           and
                                titulo.modcod = "CRE"        and
                                titulo.titsit = "LIB" no-lock no-error.
        
        if not avail titulo
        then next.
        
        find first tt-cli where tt-cli.etbcod = titulo.etbcod no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign tt-cli.etbcod = titulo.etbcod.
        end.
        tt-cli.qtd = tt-cli.qtd + 1.
    end.

    varquivo = "l:\relat\ati" + STRING(day(today)). 

    {mdadmcab.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""ativo""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """CLIENTES ATIVOS EM "" +
                                  string(today,""99/99/9999"") "
            &Width     = "160"
            &Form      = "frame f-cabcab"}
    for each tt-cli by tt-cli.etbcod:
        display "FILIAL - "
                tt-cli.etbcod     column-label "Filial"
                tt-cli.qtd(total) column-label "Cli.Ativos"
                        with frame f2 down width 200.
    end.
    output close.
    message "Deseja Imprimir relatorio" update sresp.
    if sresp
    then dos silent value("type " + varquivo + " > prn").  
end.
        
    
        













