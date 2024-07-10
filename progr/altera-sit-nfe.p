def input  parameter p-recid   as recid.

do on error undo:
   find A01_infnfe where recid(A01_infnfe) = p-recid exclusive-lock.
   A01_InfNFe.solicitacao = "Autorizacao".
   A01_InfNFe.Aguardando = "Envio".
end.
            
