{admcab.i}
def var vdata like plani.pladat.
def temp-table tt-divpre
        field rec as recid
        field divobs like divpre.divobs
        field etbcod like estab.etbcod
        field catcod like produ.catcod
        field pronom like produ.pronom
            index ind-1 etbcod
                        catcod
                        pronom.
 
def var varquivo as char. 
repeat:
    update vdata label "Data" with frame f1 side-label width 80.
    
    for each tt-divpre:
    
        delete tt-divpre.
        
    end.
    
    
    for each estab no-lock:
        
        for each divpre where divpre.etbcod = estab.etbcod and
                              divpre.divdat = vdata no-lock.
            
            /*              
            if divpre.divobs = ""
            then next.
            */
            
            
            find first tt-divpre where tt-divpre.etbcod = divpre.etbcod
                            no-error.
            if not avail tt-divpre
            then do:
                create tt-divpre.
                assign tt-divpre.etbcod = divpre.etbcod.
            end.


            find produ where produ.procod = divpre.procod no-lock no-error.
            if avail produ
            then assign tt-divpre.catcod = produ.catcod
                        tt-divpre.pronom = produ.pronom
                        tt-divpre.etbcod = estab.etbcod.
                        
            if tt-divpre.divobs = "ok"
            then.
            else tt-divpre.divobs = divpre.divobs.

            
        end.
        
    end.        
     
    /*
    
    for each estab no-lock:

        find first tt-divpre where tt-divpre.etbcod = estab.etbcod no-error.
        if not avail tt-divpre
        then next.
        display estab.etbcod column-label "Filial"
                tt-divpre.divobs with frame f2 down centered.
    
    end.

    
    message "Deseja Imprimir" update sresp.
    if sresp = no
    then undo, retry.
    */
    
    varquivo = "..\relat\conf_" + string(time).
    
    {mdad.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "160"
                &Page-Line = "66"
                &Nom-Rel   = ""conf_div""
                &Nom-Sis   = """SISTEMA DE AUDITORIA"""
                &Tit-Rel   = """DIVERGENCIAS DE PRECOS CONFERIDAS NO DIA "" +
                             STRING(VDATA,""99/99/9999"")"
                &Width     = "160"
                &Form      = "frame f-cabcab2"}
    


    for each estab no-lock:
        find first tt-divpre where tt-divpre.etbcod = estab.etbcod no-error.
        if not avail tt-divpre
        then next.
        display estab.etbcod column-label "Filial"
                tt-divpre.divobs with frame f3 down centered.
    end.

    output close.
    {mrod.i}
    
end.
