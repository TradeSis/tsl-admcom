define variable vcha-nome-arquivo as character.

define temp-table tt-pedido
    field pednum     as integer
    field status-ped as character
    field rastreador as character
    index idx01 pednum.

            
for each pedecom where pedecom.cod-postagem = "" no-lock,

    last pedid where pedid.etbcod = pedecom.etbcod
                 and pedid.pednum = pedecom.pednum
                 and pedid.pedtdc = pedecom.pedtdc no-lock,
                 
    last wbsdocbase where wbsdocbase.dcbnum = pedid.pednum
                      and wbsdocbase.tdcbcod = "web" no-lock:
    
    do on error undo, retry on endkey undo, retry :
                                    
        for each wbsdocbvol where wbsdocbvol.dcbcod        = wbsdocbase.dcbcod
                              and wbsdocbvol.cod-postagem <> "" 
                              and wbsdocbvol.dtfec        <> ?
                                        no-lock break by wbsdocbvol.dcbcod:

            run p-grava-cod-postagem (input rowid(pedecom)).
    
            assign vcha-nome-arquivo = "/admcom/web/status_pedido/"
                                          + string(pedid.pednum)
                                          + ".xml".
          
            output to value(vcha-nome-arquivo).


            if first-of(wbsdocbvol.dcbcod)
            then do:
            
                put unformatted                                                 
                '<?xml version="1.0" encoding="iso-8859-1"?>'             skip 
                '<pedido>'                                                skip 
                '   <numero_pedido>' pedid.pednum '</numero_pedido>'      skip 
                '   <status_ped>Pedido despachado</status_ped>'           skip 
                '   <data_despacho>' wbsdocbvol.dtfec ' </data_despacho>' skip
                '   <rastreamento>'                                       skip.
                
            end.
            
            put unformatted
                '       <cod>' wbsdocbvol.cod-postagem '</cod>' skip.
            
            if last-of(wbsdocbvol.dcbcod)
            then do:
                
                put unformatted
                '   </rastreamento>'                         skip    
                '</pedido>'                                  skip.
                                                
                                                
            end.
            
            output close.
                                                
        end.
                                                
    end.
        
end.  

procedure p-grava-cod-postagem:

   def buffer bf-pedecom for pedecom.
   
   def input parameter iprow-pedecom as rowid.
   
   find bf-pedecom where rowid(bf-pedecom) = iprow-pedecom exclusive-lock.

   if available bf-pedecom then do:
   
       if bf-pedecom.cod-postagem = ""
       then assign bf-pedecom.cod-postagem = wbsdocbvol.cod-postagem.
       else assign bf-pedecom.cod-postagem = bf-pedecom.cod-postagem
                                                + ","
                                                + wbsdocbvol.cod-postagem.
   
   end.
   
end procedure.


