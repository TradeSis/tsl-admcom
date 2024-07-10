{admcab.i}
pause 0.
def input parameter p-recid as reci.

find pedid where recid(pedid) = p-recid no-lock.

find first plaped where plaped.pedetb = pedid.etbcod and
                      plaped.pedtdc = pedid.pedtdc and
                      plaped.pednum = pedid.pednum 
                      no-lock no-error.
if not avail plaped
then do:
    bell.
    message color red/with
        "Nenhuma entrada para PEDIDO " string(pedid.pednum)
        view-as alert-box.
    return.    
end.
 
for each plaped where plaped.pedetb = pedid.etbcod and
                      plaped.pedtdc = pedid.pedtdc and
                      plaped.pednum = pedid.pednum 
                      no-lock :
    find plani where plani.etbcod = plaped.plaetb and
                     plani.placod = plaped.placod and
                     plani.serie  = plaped.serie and
                     plani.numero = plaped.numero
                      no-lock no-error.
    if avail plani
    then
        disp plani.etbcod  column-label "Fil" format ">>9"
             plani.numero  column-label "Numero" format ">>>>>>>9"
             plani.desti   column-label "Emitente" format ">>>>>>>9"
             plani.pladat  column-label "Emissao"
             plani.dtinclu  column-label "Entrada"
        with frame f-nf overlay row 8 centered
        title " Notas Fiscais de Entrada do PEDIDO " 
        + string(pedid.pednum) + " " 8 down.  
                        
end.  
pause 50 no-message .  
hide frame f-nf no-pause.
    

