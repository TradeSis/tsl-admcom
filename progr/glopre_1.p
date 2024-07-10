{admcab.i} 
def workfile wf-data
    field wdata like glopre.dtven
    field wpar  as int.
def var vdata like plani.pladat.
def var vdt   like plani.pladat.
def var ii    as int.
def var vv    as int.
def var mm    as int.
def var vdtven  like glopre.dtven.
def var vnumero like glopre.numero.

repeat:

    vnumero = 0.
    update vnumero label "Numero" with frame f1 side-label width 80.
    find first glopre where glopre.numero = vnumero and
                            glopre.parcela = 1 no-error.
    if not avail glopre
    then do:
        message "Consorcio nao cadastrado".
        undo, retry.
    end.
    find glofin where glofin.gfcod = glopre.gfcod no-lock.
    find clien where clien.clicod = glopre.clicod no-lock.
    display clien.clicod label "Cliente"
            clien.clinom no-label format "x(30)" with frame f1.
    vdtven = glopre.dtven.        
    update vdtven label "Vencimento" with frame f1.
    
    vdt = date(month(vdtven) + 1,1,year(vdtven)).

    mm  = 0. 
    vv  = 1.
            
    for each wf-data: 
        delete wf-data. 
    end.

    do vdata = vdt to (vdt + (glofin.gfmes * 31)).
        if weekday(vdata) = 3 and mm <> month(vdata)
        then assign ii = ii + 1. 
        if ii = 2 
        then do:  
            ii = 0. 
            vv = vv + 1.  
            mm = month(vdata).  
            create wf-data. 
            assign wf-data.wdata = vdata  
                   wf-data.wpar  = vv.  
            if vv = glofin.gfmes 
            then leave. 
        end.
    end.
            
    for each glopre where glopre.numero = vnumero and
                          glopre.parcela > 1:
        
        find first wf-data where wf-data.wpar = glopre.parcela no-lock.
        display glopre.dtven   
                wf-data.wdata
                glopre.parcela with frame f2 centered down.
                
        glopre.datexp = today.
        glopre.dtven  = wf-data.wdata.
        
    end.
end.
