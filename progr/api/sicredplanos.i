

def {1} shared temp-table ttplanos  no-undo serialize-name "planos" 
    field codigoPlano as char
    field descricao as char
    field prazo       as int 
    field taxa        as dec decimals 6.

def {1} shared temp-table tttoken no-undo serialize-name "token"
    field username as char
    field access_token as char
    field expires_in as int.
                    
    
DEFINE DATASET retorno FOR tttoken, ttplanos.


