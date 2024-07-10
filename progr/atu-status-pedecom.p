define input parameter ipint-pednum as integer.
define input parameter ipcha-novo-status as character.

def buffer bf-pedecom for pedecom.

define variable vcha-nome-arquivo as character.

find first bf-pedecom where bf-pedecom.etbcod = 200
                        and bf-pedecom.pedtdc = 3
                        and bf-pedecom.pednum = ipint-pednum exclusive-lock.
                            

if avail bf-pedecom
then do:

    do on error undo, retry on endkey undo, retry :

        assign bf-pedecom.status-ped = ipcha-novo-status.

        assign vcha-nome-arquivo = "/admcom/web/status_pedido/"
                                     + string(bf-pedecom.pednum)
                                     + ".xml".
    
        output to value(vcha-nome-arquivo).
    
        put unformatted                                                  
            '<?xml version="1.0" encoding="iso-8859-1"?>'           skip 
            '<pedido>'                                              skip 
            '   <numero_pedido>' bf-pedecom.pednum '</numero_pedido>'skip 
            '   <status_pedido>' bf-pedecom.status-ped '</status_pedido>' skip 
            '</pedido>'                                             skip.
        
        output close.
        
    end.    
    
end.