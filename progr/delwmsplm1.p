/** 29/01/07 **/

def var vdata as date.
def var vdti as date.
def var vdtf as date.
repeat:
update vdti label "De"
       vdtf label "Ate"
       with frame f1
       .
do vdata = vdti to vdtf:
    disp vdata with frame f1.
    pause 0.
    for each estab no-lock:
    disp estab.etbcod. 
    pause 0.
    for each wmsplani where 
            wmsplani.movtdc = 1 and
            wmsplani.desti = estab.etbcod and
            wmsplani.pladat = vdata:
        disp wmsplani.numero with column 10.
        pause 0.
        
        for each wmsmovim where 
                wmsmovim.etbcod = wmsplani.etbcod and
                wmsmovim.placod = wmsplani.placod
                :
            disp wmsmovim.procod format ">>>>>>>>9"  
                with column 20 1 column no-label.
            pause 0.
            delete wmsmovim.
            
        end.    
        delete wmsplani.
    end.
    end.
end.
end.