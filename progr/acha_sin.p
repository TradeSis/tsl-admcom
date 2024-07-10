{admcab.i}
def var v-car as char format "x(01)".
def var xx as char.
def var data_arq like plani.pladat.
def var p-dia like plani.platot.
def var p-pre like plani.platot.

def var vtotal like plani.platot.
def var vdata like plani.pladat.
def var varq  as char.
def var varq2 as char.
def var vreg  as char.
def var ii    as int.
def var vv    as int.
def var vbanco   as char.
def var vagencia as char.
def var vconta   as char.
def var vnumero  as char.

def new shared temp-table tt-data
    field etbcod like estab.etbcod
    field datmov like deposito.datmov
    field chedre like deposito.chedre
    field chedia like deposito.chedia.
    
def temp-table tt-chq
    field rec as recid.
    
def new shared temp-table tt-dif
    field banco   like chq.banco
    field agencia like chq.agencia
    field conta   like chq.conta
    field numero  like chq.numero
    field etbcod  like chqtit.etbcod
    field valor   like chq.valor
    field marca   as char format "x(01)".

repeat:


    for each tt-data:
        delete tt-data.
    end.
    
    for each tt-chq:
        delete tt-chq.
    end.
    
    for each tt-dif:
        delete tt-dif.
    end.
    
    vdata = data_arq.
    
    update vdata    label "Data do Movimento"
           data_arq label "Data do Arquivo"
           v-car    label "Sinal"
                with frame f1 width 80 side-label.
    ii = 0.
    
    for each deposito where deposito.datcon = vdata no-lock: 

        find first tt-data where tt-data.etbcod = deposito.etbcod and
                                 tt-data.datmov = deposito.datmov no-error.
        if not avail tt-data
        then do:
            create tt-data.
            assign tt-data.etbcod = deposito.etbcod 
                   tt-data.datmov = deposito.datmov.
        end.
        assign tt-data.chedre = tt-data.chedre + deposito.chedre
               tt-data.chedia = tt-data.chedia + deposito.chedia.
               
    end.    
    

    ii = 0.
    for each tt-data by tt-data.datmov
                     by tt-data.etbcod:
    
        
        for each chq where chq.datemi = tt-data.datmov no-lock.
 
            find first chqtit of chq no-lock no-error. 
            if not avail chqtit 
            then next.
            
            if chqtit.etbcod <> tt-data.etbcod
            then next.

            vv = 0.
            do vv = 1 to 10:
            
                if substring(string(chq.agencia),vv,1) = v-car or
                   substring(string(chq.conta),vv,1) = v-car or
                   substring(string(chq.numero),vv,1) = v-car 
                  
                then do:
                    display chq.agencia
                            chq.conta
                            chq.numero
                            chq.datemi
                            chqtit.etbcod
                                with frame f-con centered down.
                            
                    pause.
                end.
            
                

                
            
            end.
        
            /*
            ii = ii + 1. 
            display chq.banco
                    chq.agencia
                    chq.conta 
                    chq.numero
                    tt-data.etbcod
                    ii with down. 
            */
        end.

    end.
    
    
    
   
    
end.
    
    
