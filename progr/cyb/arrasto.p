
def input param par-today as date.

def var ve_situacao as char extent 4 init
    ["ENVIAR","ATUALIZAR","PAGAR","ENVIADO"].


def buffer bcyber_controle for cyber_controle.
def var vti as int.
def var vi as int.

do vti = 1 to 4:
    message today string(time,"HH:MM:SS") "ARRASTO Pesquisando "
        ve_situacao[vti].
  for each cyber_controle
        where  
                situacao = ve_situacao[vti]
        no-lock.

    find first bcyber_controle where
        bcyber_controle.cliente = cyber_controle.cliente and
        bcyber_controle.contnum <> cyber_controle.contnum and
        bcyber_controle.situacao = "ACOMPANHADO" and
        bcyber_controle.vlentra <> 0 and
        bcyber_controle.vlentra <> ?
        no-error.
    
    if not avail bcyber_controle
    then next.

    for each bcyber_controle where
        bcyber_controle.cliente = cyber_controle.cliente and
        bcyber_controle.contnum <> cyber_controle.contnum and
        bcyber_controle.situacao = "ACOMPANHADO" and
        bcyber_controle.vlentra <> 0 and
        bcyber_controle.vlentra <> ?.
        

        find contrato where contrato.contnum = bcyber_controle.contnum
              no-lock no-error.
        if not avail contrato then next.

        /***HML {cyb/cyberhml.i} **/
        
 
   
        /** arrasta **/
        bcyber_controle.situacao = "ARRASTAR".
        
        vi = vi + 1.        

        if bcyber_controle.situacao = "ARRASTAR"
        then do:
            find cyber_contrato where
                cyber_contrato.contnum = bcyber_controle.contnum
                no-error.    
            if not avail cyber_contrato
            then do:            
                create cyber_contrato.
                ASSIGN
                cyber_contrato.clicod    = bcyber_controle.cliente
                cyber_contrato.contnum   = bcyber_controle.contnum
                cyber_contrato.Situacao  = yes                    
                cyber_contrato.vlentra   = 0
                cyber_contrato.etbcod    = bcyber_controle.loja
                cyber_contrato.dtinicial = bcyber_controle.dtemissao
                cyber_contrato.banco     = "ARRASTADO".
            end.
            
            find cyber_clien where
                cyber_clien.clicod = bcyber_controle.cliente
                no-error.
            if not avail cyber_clien 
            then do:
                create cyber_clien.
                assign
                cyber_clien.clicod = bcyber_controle.cliente
                cyber_clien.situacao = yes
                cyber_clien.dturen   = today.
            end.   
            
        end.
        if vi = 1 or vi mod 100 = 0
        then
           message today string(time,"HH:MM:SS") "ARRASTO Arrastando " vi.

  
    end.

 end.
                
end.
            
message today string(time,"HH:MM:SS") "ARRASTO Arrastado " vi.
