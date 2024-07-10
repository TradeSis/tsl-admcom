
def input param par-today as date.
def var vx as int.
def var ve_situacao as char extent 3 init
    ["ENVIAR","ATUALIZAR","PAGAR"].


def buffer bcslog_controle for cslog_controle.
def var vti as int.
def var vi as int.
def var vaberto as dec.

do vti = 1 to 3:
    message today string(time,"HH:MM:SS") "ARRASTO Pesquisando "
        ve_situacao[vti].
  vx = 0.  
  for each cslog_controle
        where  
                situacao = ve_situacao[vti]
        no-lock.
        vx = vx + 1.
        if vx = 1 or vx mod 50000 = 0 then  disp cslog_controle.loja cslog_controle.contnum cslog_controle.situacao vx.
        
    for each contrato where contrato.clicod = cslog_controle.cliente no-lock.
        if contrato.contnum = cslog_controle.cliente
        then next.
        find bcslog_controle where bcslog_controle.contnum = contrato.contnum
          exclusive no-error.
        if avail bcslog_controle
        then do:  
            if bcslog_controle.situacao <> "ELIMINADO" and
               bcslog_controle.situacao <> "ACOMPANHADO"
            then next.   
        end.
        vaberto = 0.
        for each titulo where 
            titulo.empcod = 19 and 
            titulo.titnat = no and 
            titulo.modcod = contrato.modcod and 
            titulo.etbcod = contrato.etbcod and 
            titulo.clifor = contrato.clicod and 
            titulo.titnum = string(contrato.contnum) 
            no-lock.
            if titulo.titsit <> "LIB"
            then next.
            vaberto = vaberto + titulo.titvlcob.
        end.
        if vaberto <= 0 
        then next.

        if not avail bcslog_controle
        then do:
            create bcslog_controle.
            bcslog_controle.contnum      = contrato.contnum.
            bcslog_controle.dtemissao    = contrato.dtinicial.
            bcslog_controle.cliente      = contrato.clicod.
            bcslog_controle.loja         = contrato.etbcod.
            bcslog_controle.cybaberto   = 0.
            bcslog_controle.cybatrasado   = 0.
            bcslog_controle.cybultdtpag  = ?.
        end.

        bcslog_controle.vlraberto   = vaberto.

        bcslog_controle.situacao = "ARRASTAR".
        
            find cyber_clien where
                cyber_clien.clicod = bcslog_controle.cliente
                no-error.
            if not avail cyber_clien 
            then do:
                create cyber_clien.
                assign
                cyber_clien.clicod = bcslog_controle.cliente
                cyber_clien.situacao = yes
                cyber_clien.dturen   = today.
            end.   

    end.
    
    /**    
    find first bcslog_controle where
        bcslog_controle.cliente = cslog_controle.cliente and
        bcslog_controle.contnum <> cslog_controle.contnum and
        bcslog_controle.situacao = "ACOMPANHADO" and
        bcslog_controle.vlentra <> 0 and
        bcslog_controle.vlentra <> ?
        no-error.
    
    if not avail bcslog_controle
    then next.

    for each bcslog_controle where
        bcslog_controle.cliente = cslog_controle.cliente and
        bcslog_controle.contnum <> cslog_controle.contnum and
        bcslog_controle.situacao = "ACOMPANHADO" and
        bcslog_controle.vlentra <> 0 and
        bcslog_controle.vlentra <> ?.
        

        find contrato where contrato.contnum = bcslog_controle.contnum
              no-lock no-error.
        if not avail contrato then next.

        /***HML {csl/cyberhml.i} **/
        
 
   
        /** arrasta **/
        bcslog_controle.situacao = "ARRASTAR".
        
        vi = vi + 1.        

        if bcslog_controle.situacao = "ARRASTAR"
        then do:
            /**
            find cslog_contrato where
                cslog_contrato.contnum = bcslog_controle.contnum
                no-error.    
            if not avail cslog_contrato
            then do:            
                create cslog_contrato.
                ASSIGN
                cslog_contrato.clicod    = bcslog_controle.cliente
                cslog_contrato.contnum   = bcslog_controle.contnum
                cslog_contrato.Situacao  = yes                    
                cslog_contrato.vlentra   = 0
                cslog_contrato.etbcod    = bcslog_controle.loja
                cslog_contrato.dtinicial = bcslog_controle.dtemissao
                cslog_contrato.banco     = "ARRASTADO".
            end.
            **/
            find cyber_clien where
                cyber_clien.clicod = bcslog_controle.cliente
                no-error.
            if not avail cyber_clien 
            then do:
                create cyber_clien.
                assign
                cyber_clien.clicod = bcslog_controle.cliente
                cyber_clien.situacao = yes
                cyber_clien.dturen   = today.
            end.   
            
        end.
        if vi = 1 or vi mod 100 = 0
        then
           message today string(time,"HH:MM:SS") "ARRASTO Arrastando " vi.

  
    end.
    **/
    

 end.
   message today string(time,"HH:MM:SS") "ARRASTO Pesquisou "
        ve_situacao[vti] vi.
                
end.
            
message today string(time,"HH:MM:SS") "ARRASTO Arrastado " vi.
