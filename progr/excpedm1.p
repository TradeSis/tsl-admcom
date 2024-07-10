{admcab.i}
/* comentado em 01/08 por Luciano da Linx */
do on error undo.
leave.
end.

def var vetbcod like estab.etbcod.
def var ip   as char format "x(15)".
def var dsresp as log format "SIM/NAO".
def var vdata1 as date format "99/99/9999".

repeat:

    if connected ("comloja")
    then disconnect comloja.
    
    vdata1 = today.
    
    update  vetbcod label "Filial"
            ip  label "IP - Filial" 
            vdata1 label "Data Referencia"
                with frame f1 side-label width 80 1 column
                    title " EXCLUSAO DE PEDIDOS MANUAIS ".

    disp  space(2) skip(1)
          space(5) "TODOS OS PEDIDOS MANUAIS DA FILIAL " 
                   STRING(VETBCOD,">>9") FORMAT "X(3)"
                   " SERAO" 
          space(2) SKIP 
          space(2) "EXCLUIDOS, NA MATRIZ E NA FILIAL." 
          skip(1) 
          space(5) "CONFIRMA A EXCLUSAO DESTES PEDIDOS ?" dsresp
          skip(1)
          with frame f-aviso overlay no-labels NO-ATTR-SPACE
                     centered color messages title " *** ATENCAO *** ".
    
    update dsresp
           with frame f-aviso.
    
    if not dsresp
    then leave.
    
    message "Conectando...".
    connect com -H value(ip) -S sdrebcom -N tcp -ld comloja no-error.
    
    hide message no-pause.
    
    if not connected ("comloja")
    then do:
        
        message "Banco nao conectado.".
        undo, retry.    
        
    end.

    hide message no-pause.

    run excpedm2.p (input vetbcod, input vdata1).
                   
    if connected ("comloja")
    then disconnect comloja.

    for each com.pedid where com.pedid.etbcod = vetbcod 
                         and com.pedid.pedtdc = 3   
                         and com.pedid.pednum < 100000:  
        
        if com.pedid.peddat >= vdata1
        then next.
        
        display "Deletando pedidos manuais na Matriz..."  
                com.pedid.etbcod no-label  
                com.pedid.pednum no-label   
                with frame f2m 1 down centered. pause 0.
    
        for each com.liped of com.pedid:
        
            delete com.liped.
        
        end.
    
        delete com.pedid.
    
    end.

    hide frame f2m no-pause.

    message "Pedidos Manuais Excluidos...".
    
end.