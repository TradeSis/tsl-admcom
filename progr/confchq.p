{admcab.i}

def new shared var vtipo   as log format "PRE/DIA".

def var vlote_1    like lotdep.lote.
def var vlote_2    like lotdep.lote.
def var data_arq like plani.pladat.
def var p-dia like plani.platot.
def var p-pre like plani.platot.

def var vtotal like plani.platot.
def new shared var vdata like plani.pladat.
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
    field chedia like deposito.chedia
    field lote   like lotdep.lote.
    
def new shared temp-table tt-chq like chq
    field lote like lotdep.lote.
    
def var vdia like plani.platot.
def var vpre like plani.platot.
    

repeat:

    for each tt-data:
        delete tt-data.
    end.

    
    for each tt-chq:
        delete tt-chq.
    end.
    
    vdia = 0.
    vpre = 0.

    update vdata    label "Data do Movimento"
           vlote_1  label "Lote" 
           vlote_2  
           vtipo    label "Cheque"
                with frame f1 width 80 side-label.
                
         
    
    for each deposito where deposito.datcon = vdata no-lock: 
        
        find lotdep where lotdep.etbcod = deposito.etbcod and
                          lotdep.datcon = deposito.datmov no-lock no-error.
        if not avail lotdep
        then next.
        if lotdep.lote >= vlote_1 and
           lotdep.lote <= vlote_2
        then.
        else next.
        
        
        find first tt-data where tt-data.etbcod = deposito.etbcod and
                                 tt-data.datmov = deposito.datmov no-error.
        if not avail tt-data
        then do:
            create tt-data.
            assign tt-data.etbcod = deposito.etbcod 
                   tt-data.datmov = deposito.datmov
                   tt-data.lote   = lotdep.lote.
        end.
        assign tt-data.chedre = tt-data.chedre + deposito.chedre
               tt-data.chedia = tt-data.chedia + deposito.chedia.
               
    end.
        
    
    for each tt-data by tt-data.datmov
                     by tt-data.etbcod:
    
        if vtipo
        then vpre = vpre + tt-data.chedre.
        else vdia = vdia + tt-data.chedia.

        for each chq where chq.datemi = tt-data.datmov no-lock.
 
        
            if vtipo
            then do:
                if chq.datemi = chq.data
                then next.
            end.
            else do:
                if chq.datemi <> chq.data
                then next.
            end.
            
            
            find first chqtit of chq no-lock no-error. 
            if not avail chqtit 
            then next.
            
            if chqtit.etbcod <> tt-data.etbcod
            then next.

            create tt-chq. 
            assign tt-chq.data    = chq.data 
                   tt-chq.banco   = chq.banco 
                   tt-chq.agencia = chq.agencia 
                   tt-chq.conta   = chq.conta 
                   tt-chq.numero  = chq.numero 
                   tt-chq.datemi  = chq.datemi 
                   tt-chq.valor   = chq.valor
                   tt-chq.lote    = tt-data.lote.

         
        end.

    
    end.
    
    run chpredia-brw.p (input vpre, 
                        input vdia).
    

         
    
end.
    








    
    
    
    
    
    
