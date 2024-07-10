
def input parameter vetbcod like estab.etbcod.
def input parameter vdti    like com.plani.pladat.
def input parameter vdtf    like com.plani.pladat.
def var vnumero             like com.plani.numero.
def var vnum                like com.plani.numero.
def var sresp as log format "Sim/Nao".
def stream spro.
def stream sest.
def stream spla.
def stream smov.
 


output stream spro to l:\dados\produ.d.
output stream sest to l:\dados\estoq.d.
for each produ no-lock:
                             
    display "Atualizando Produtos...." 
            produ.procod no-label 
                with frame f1 1 down centered.
    pause 0.         
                               
    
        
    
    find estoq where estoq.etbcod = vetbcod and
                     estoq.procod = produ.procod  no-lock no-error.
    if not avail com.estoq
    then next.

    export stream spro produ.
    export stream sest estoq.
                                   
end.
output stream spro close.
output stream sest close.


vnum    = 0.
vnumero = 0.
output stream spla to l:\dados\plani.d.
output stream smov to l:\dados\movim.d.
for each tipmov where tipmov.movtdc <> 4 no-lock.
    for each plani where plani.etbcod = vetbcod           and
                         plani.movtdc = tipmov.movtdc and
                         plani.pladat >= vdti             and
                         plani.pladat <= vdtf no-lock.
                             
        display "Atualizando Vendas...."
                 plani.etbcod no-label
                 plani.pladat no-label
                 plani.numero no-label format "9999999"
                        with frame f11 11 down centered.
        pause 0.

        export stream spla plani.
                 
                               
        if plani.numero > vnumero
        then vnumero = plani.numero.
        
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
    
            export stream smov movim.
                    
        end.    
    
    end.
    
end.    


for each plani where plani.desti  = vetbcod           and
                     plani.movtdc = 6                 and
                     plani.pladat >= vdti             and
                     plani.pladat <= vdtf no-lock.
                             
                         
    display "Atualizando Transf...."
                 plani.etbcod no-label
                 plani.pladat no-label
                 plani.numero no-label format "9999999"
                    with frame f22 1 down centered.
    pause 0.         
    export stream spla plani.                                   
        
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock:
                         
        export stream smov movim.
        
    end.    
    
end.

output stream spla close.
output stream smov close.

/*
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
*/        


   



         

                       
