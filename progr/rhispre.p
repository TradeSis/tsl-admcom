{admcab.i}

def var varquivo as   char.
def var fila     as   char.
def var vdata1   as   date format "99/99/9999".
def var vdata2   as   date format "99/99/9999".
def var vdata    as   date format "99/99/9999".


repeat:

    vdata1 = today. vdata2 = today.
    
    update vdata1 label "Data Inicial"
           vdata2 label "Data Final"
           with frame f-dados centered side-labels. 


    if opsys = "UNIX"
    then do:                                    /*
        find first impress where impress.codimp = setbcod no-lock no-error.
        if avail impress
        then assign fila = string(impress.dfimp)*/  
                    varquivo = "/admcom/relat/rhispre" + string(time).    
    
    end.
    else assign fila = ""
                varquivo = "l:\relat\rhispre" + string(time).

    message "Gerando Relatorio...".
    
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "63" 
        &Cond-Var  = "120"  
        &Page-Line = "66"
        &Nom-Rel   = ""rhispre""  
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """ LISTAGEM DE PRODUTOS COM PRECOS ALTERADOS DE ""
                   + string(vdata1,""99/99/9999"")
                   + "" A ""
                   + string(vdata2,""99/99/9999"")"
        &Width     = "120"
        &Form      = "frame f-cabcab"}
        
        for each hispre where hispre.dtalt >= vdata1
                          and hispre.dtalt <= vdata2 no-lock
                          break by hispre.procod
                                by hispre.dtalt
                                by hispre.hora-inc:
    
            find produ where produ.procod = hispre.procod no-lock no-error.
            
            disp hispre.procod       column-label "Produto"
                 produ.pronom        column-label "Descricao" format "x(38)"
                 hispre.dtalt        column-label "Data Alt"
                 string(hispre.hora-inc,"HH:MM:SS")
                                     column-label "Hora Alt"
                 hispre.funcod       column-label "Func."
                 hispre.estcusto-ant column-label "PCus. Ant"
                 hispre.estcusto-nov column-label "PCus. Atu"
                 hispre.estvenda-ant column-label "PVen. Ant"
                 hispre.estvenda-nov column-label "PVen. Atu"
                 with frame f-hispre width 120 down.
            down with frame f-hispre.
            
        end.
    
    output close.
    
    hide message no-pause.
    
    if opsys = "UNIX"
    then do:

        message "Deseja imprimir relatorio" update sresp.
        if sresp
        then /*os-command silent lpr value(fila + " " + varquivo).*/
             run visurel.p (input varquivo,
                            input "").
                       
    end.
    else do:
        {mrod.i}.
    end.
end.
