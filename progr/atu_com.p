
disable triggers for load of comloja.movim.
disable triggers for load of comloja.plani.
def input parameter vetbcod like estab.etbcod.
def input parameter vdti    like com.plani.pladat.
def input parameter vdtf    like com.plani.pladat.
def var vnumero             like com.plani.numero.
def var vnum                like com.plani.numero.
def var sresp as log format "Sim/Nao".



for each com.produ no-lock:
                             
    display "Atualizando Produtos...." 
            com.produ.procod no-label 
                with frame f1 1 down centered.
    pause 0.         
                               
    
        
    find comloja.produ where comloja.produ.procod = com.produ.procod no-error. 
    if not avail comloja.produ 
    then create comloja.produ.

    {produ2.i comloja.produ com.produ}.
    
    find com.estoq where com.estoq.etbcod = vetbcod and
                         com.estoq.procod = com.produ.procod 
                                        no-lock no-error.
    if not avail com.estoq
    then next.
                                         
                                   
    find comloja.estoq where comloja.estoq.etbcod = com.estoq.etbcod and
                             comloja.estoq.procod = com.estoq.procod 
                                        no-error.

    if not avail comloja.estoq 
    then create comloja.estoq. 
    
    {estoq.i comloja.estoq com.estoq}. 
        
end.


vnum    = 0.
vnumero = 0.
for each com.tipmov where com.tipmov.movtdc <> 4 no-lock.
    for each com.plani where com.plani.etbcod = vetbcod           and
                             com.plani.movtdc = com.tipmov.movtdc and
                             com.plani.pladat >= vdti             and
                             com.plani.pladat <= vdtf no-lock.
                             
        display "Atualizando Vendas...."
                 com.plani.etbcod no-label
                 com.plani.pladat no-label
                 com.plani.numero no-label format "9999999"
                        with frame f11 11 down centered.
        pause 0.         
                               
        if com.plani.numero > vnumero
        then vnumero = com.plani.numero.
        
        find comloja.plani where comloja.plani.etbcod = com.plani.etbcod and
                                 comloja.plani.placod = com.plani.placod and
                                 comloja.plani.serie  = com.plani.serie 
                                    no-error.
        if not avail comloja.plani
        then do transaction:
            
            create comloja.plani.
            {plani.i comloja.plani com.plani}.
            comloja.plani.exportado = yes.
            
        end.
        
        for each com.movim where com.movim.etbcod = com.plani.etbcod and
                                 com.movim.placod = com.plani.placod and
                                 com.movim.movtdc = com.plani.movtdc and
                                 com.movim.movdat = com.plani.pladat no-lock:
    
            find comloja.movim where 
                               comloja.movim.etbcod = com.movim.etbcod and
                               comloja.movim.placod = com.movim.placod and
                               comloja.movim.procod = com.movim.procod
                                                no-error.
            if not avail comloja.movim
            then do transaction:

                create comloja.movim.
                {movim.i comloja.movim com.movim}.
                comloja.movim.exportado = yes.
        
            end.
        
        end.    
    
    end.
    
end.    

/*****************  transferencia de entrada ************************/
for each com.plani where com.plani.desti  = vetbcod           and
                         com.plani.movtdc = 6                 and
                         com.plani.pladat >= vdti             and
                         com.plani.pladat <= vdtf no-lock.
                             
                         
    display "Atualizando Transf...."
                 com.plani.etbcod no-label
                 com.plani.pladat no-label
                 com.plani.numero no-label format "9999999"
                    with frame f22 1 down centered.
    pause 0.         
                                   
    find comloja.plani where comloja.plani.etbcod = com.plani.etbcod and
                             comloja.plani.placod = com.plani.placod and
                             comloja.plani.serie  = com.plani.serie no-error.
    if not avail comloja.plani 
    then do transaction: 
        create comloja.plani. 
        {plani.i comloja.plani com.plani}. 
        comloja.plani.exportado = yes.
    end.
        
    for each com.movim where com.movim.etbcod = com.plani.etbcod and
                             com.movim.placod = com.plani.placod and
                             com.movim.movtdc = com.plani.movtdc and
                             com.movim.movdat = com.plani.pladat no-lock:
    
        find comloja.movim where comloja.movim.etbcod = com.movim.etbcod and
                                 comloja.movim.placod = com.movim.placod and
                                 comloja.movim.procod = com.movim.procod 
                                                        no-error.
        if not avail comloja.movim
        then do transaction:

            create comloja.movim.
            {movim.i comloja.movim com.movim}.
            
            comloja.movim.exportado = yes.
        
        end.
        
    end.    
    
end.

do on error undo:
    vnum = vnumero.

    display vnum label "Ultima Venda Na Matriz" format ">>>>>>9"
            with frame f33 centered side-label.
            
    if vnumero = 0
    then vnumero = 1.
    else vnumero = vnumero + 500.        
    update vnumero label "Numeracao Sugerida" format ">>>>>>9"
            with frame f33 centered side-label.
        
            
        
    if vnum > vnumero
    then do:
        message "Numero Invalido".
        pause.
        undo, retry.
    end.
    if vnum < vnumero
    then do:
        message "Confirma nova numeracao" update sresp.
        if not sresp
        then undo, retry.
        else do:
            create comloja.plani.
            assign comloja.plani.movtdc    = 5
                   comloja.plani.PlaCod    = int(string("213") + string(vnumero,"9999999"))
                   comloja.plani.Numero    = vnumero
                   comloja.plani.PlaDat    = today
                   comloja.plani.Serie     = "V"
                   comloja.plani.Desti     = vetbcod
                   comloja.plani.Emite     = vetbcod
                   comloja.plani.EtbCod    = vetbcod
                   comloja.plani.datexp    = today.
        end.
    end.
end.        
        


   



         

                       
