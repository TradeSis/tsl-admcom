{admcab.i}
def var vcatcod like produ.catcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vv-i as char.
def var vv-f as char.
def var vdata like plani.pladat.
def temp-table tt-rec
    field procod like produ.procod
    field rec    as recid.
def var varquivo as char.    

repeat:
        
    for each tt-rec:
        delete tt-rec.
    end.
    
    
    update vdti label "Data Inicial" colon 15
           vdtf label "Data Final" 
           vcatcod label "Departamento" colon 15
            with frame f1 side-label width 80.

    find categoria where categoria.catcod = vcatcod no-lock no-error.
    if not avail categoria
    then next.
    display categoria.catnom no-label with frame f1.
    
    vv-i = string(year(vdti)) + 
           string(month(vdti),"99") + 
           string(day(vdti),"99").
    
    do vdata = vdti to vdtf:

        
        vv-i = string(year(vdata)) + 
               string(month(vdata),"99") + 
               string(day(vdata),"99").
    
        for each admprog where menpro begins vv-i no-lock:
    
            find first tt-rec where 
                tt-rec.procod = int(substring(admprog.progtip,1,6)) no-error.
            if not avail tt-rec
            then create tt-rec.
            assign tt-rec.procod = int(substring(admprog.progtip,1,6))
                   tt-rec.rec    = recid(admprog).
                   
            disp progtip format "x(78)" 
                with 1 down. pause 0. 
        
        end.

    end.
     
    varquivo = "..\relat\lisalt" + string(time).
    
    if opsys = "unix"
    then do.
        unix silent unix2dos value(varquivo).
        unix silent chmod 777 value(varquivo).
    end.
     
    {mdad.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63" 
        &Cond-Var  = "147" 
        &Page-Line = "66" 
        &Nom-Rel   = ""lisaltpr""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""
        &Tit-Rel   = """CONFERENCIA DAS ALTERACOES DE PRECO "" +
                      "" - Periodo: "" + string(vdti) + "" A "" +
                            string(vdtf)"
        &Width     = "147"
        &Form      = "frame f-cabcab1"}
    
    
    for each tt-rec by tt-rec.procod.
        find admprog where recid(admprog) = tt-rec.rec no-lock no-error.
        if not avail admprog
        then next.
        find produ where produ.procod = tt-rec.procod no-lock no-error.
        if produ.catcod <> vcatcod
        then next.
        
        disp progtip format "x(78)" 
             produ.pronom when avail produ format "x(40)"
            with frame f3 down no-label width 200.
    end.

    {mrod.i}
    

      
end.
