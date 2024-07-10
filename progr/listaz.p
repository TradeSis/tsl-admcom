{admcab.i}

def new shared temp-table tt-red
    field etbcod like estab.etbcod
    field cxacod like plani.cxacod 
    field data  like plani.pladat
    field sit   as char format "x(20)"
    field valor  like plani.platot.
           
def var vdata like plani.pladat.             

def temp-table tt-cxecf
    field etbcod like estab.etbcod format ">>9"
    field cxacod like caixa.cxacod
    field codimp as int format "99"
        index ind-1 etbcod
                    cxacod.
    
def var vetbcod  like estab.etbcod.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
    

input from ..\admini\cxecf.ini.
repeat:
    create tt-cxecf.
    import tt-cxecf.
end.
input close.


for each tt-cxecf.

    if tt-cxecf.etbcod = 0
    then delete tt-cxecf.
    
end.    


def temp-table tt-imp
    field codimp as int format "99"
    field nome   as char
    field versao as dec format "9.99"
        index ind-1 codimp.
    

input from ..\admini\impressora.ini.
repeat:
    create tt-imp.
    import tt-imp.
end.
input close.

for each tt-imp.
    if tt-imp.codimp = 0
    then delete tt-imp.
end.    

repeat:

    for each tt-red.
        delete tt-red.
    end.
    pause 0.
    update vetbcod label "Filial " 
            with frame f1 side-label width 80.
    
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then display "Todas Filiais" @ estab.etbnom with frame f1.
    else display estab.etbnom no-label with frame f1.
    
    update vdti label "Periodo"  
           vdtf no-label with frame f1.
           
    for each tt-cxecf where if vetbcod = 0
                            then true
                            else tt-cxecf.etbcod = vetbcod:
                                 
        do vdata = vdti to vdtf:
            
            if vdata = today
            then next.
            if weekday(vdata) = 1 
            then next.
            find dtextra where dtextra.exdata = vdata no-error. 
            if avail dtextra 
            then next.
            find dtesp where dtesp.datesp = vdata and
                             dtesp.etbcod = tt-cxecf.etbcod no-lock no-error.
            if avail dtesp
            then next.
            
            find first plani where plani.etbcod = tt-cxecf.etbcod and
                                   plani.movtdc = 05              and
                                   plani.pladat = vdata no-lock no-error.
            if not avail plani
            then next.
                                   
            
            create tt-red.
            assign tt-red.etbcod = tt-cxecf.etbcod
                   tt-red.cxacod = tt-cxecf.cxacod
                   tt-red.data   = vdata
                   tt-red.sit    = "SERIAL - OK".
                   
            find first serial where serial.etbcod = tt-cxecf.etbcod and
                                    serial.cxacod = tt-cxecf.cxacod and
                                    serial.serdat = vdata no-error.
                                                 
            
            if not avail serial or serial.serval = 0
            then tt-red.sit = "SERIAL - ERRO".
            else tt-red.valor = serial.serval.
        
        end.    
    
    end.
                      
    /*
    for each tt-red where tt-red.sit = yes:
        delete tt-red.
    end.              
    */
    
    run listaz0.p.    

end.
    
            


 

   
