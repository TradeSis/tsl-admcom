{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti    like com.plani.pladat initial today.
def var vdtf    like com.plani.pladat initial today.
def var ip   as char format "x(15)".
def var vsinc as char format "x(20)" extent 10.
vsinc[1] = "PEDIDOS ESPECIAIS".
vsinc[2] = "INTENCAO DE COMPRAS".

def var vindex as int.

disp vsinc with frame f-sinc 1 down centered row 7 no-label
        1 column.
choose field vsinc with frame f-sinc.
vindex = frame-index.

def var l-sinc as char format "x(20)".

hide frame f-sinc.

def var vpedtdc like pedid.pedtdc.

if vindex = 1
    then vpedtdc = 6.
    else if vindex = 2
        then vpedtdc = 21.
 
disp "Sincronizando " vsinc[vindex] no-label with frame f-1 no-box
    color message.
repeat:

    if connected ("gerloja")
    then disconnect gerloja.

    update vetbcod label "Filial"
            with frame f-filial down side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    
    disp estab.etbnom no-label with frame f-filial.
    pause 0.        
    ip = "filial" + string(vetbcod,"999").
    
    message "Conectando..." ip.

    if vpedtdc > 0
    then do:    
        connect com -H value(ip) -S sdrebcom -N tcp -ld comloja no-error.
    
        if not connected ("comloja")
        then do:
        
            message "Banco nao conectado".
            undo, retry.    
        
        end.

        sresp = no.

        run sinc_pedido_especial.p(input vetbcod, 
                                   input vpedtdc, 
                                   output sresp).

        if sresp
        then l-sinc = "Sincronizado OK".  
        else l-sinc = "NAO Sincronizado".
                 
        disp l-sinc no-label with frame f-filial.
        pause 0.         
                   
        if connected ("comloja")
        then disconnect comloja.
    end.
end.