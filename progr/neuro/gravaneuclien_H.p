    
    def input   parameter p-cpf             as char.
    def output  parameter p-recid-neuclien  as recid.

def var vdtnasc as date.
 
def shared temp-table PreAutorizacao
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field codigo_cliente  as char
    field cpf             as char
    field tipo_pessoa     as char
    field nome_pessoa     as char
    field data_nascimento as char
    field mae             as char
    field codigo_mae      as char
    field categoria_profissional as char.


    find first PreAutorizacao where
        preAutorizacao.cpf = p-cpf.

    vdtnasc = date(int(substring(preAutorizacao.data_nascimento,6,2)),
                   int(substring(preAutorizacao.data_nascimento,9,2)),
                   int(substring(preAutorizacao.data_nascimento,1,4))).        
            
        
     do on error undo.
        find neuclien where neuclien.cpfcnpj = dec(p-cpf) /** int64 **/
            exclusive
            no-wait 
            no-error.
        if not avail neuclien
        then do.
            if locked neuclien
            then do:
                p-recid-neuclien = ?.
                return.
            end.
            else do:
                create neuclien. 
                neuclien.cpfcnpj = dec(p-cpf). /** int64 **/
                neuclien.tippes = if preAutorizacao.tipo_pessoa = "J"
                                  then no 
                                  else yes.
                neuclien.sit_credito = "". 
                neuclien.etbcod = int(preAutorizacao.codigo_filial).
                neuclien.dtcad   = today.
                
                neuclien.nome_pessoa = preAutorizacao.nome_pessoa. 
                neuclien.dtnasc = vdtnasc. 
                neuclien.nome_mae = preAutorizacao.mae. 
                neuclien.codigo_mae = if preAutorizacao.codigo_mae = "" 
                                      then ? 
                                      else int(preAutorizacao.codigo_mae) no-error. 
                
                p-recid-neuclien = recid(neuclien).
            end.
        end.
        else do:
            p-recid-neuclien = recid(neuclien).
        end.                                    
        
        find neuclien where recid(neuclien) = p-recid-neuclien
            exclusive no-wait no-error.
        if avail neuclien
        then do:    
            assign 
                neuclien.catprof    = preAutorizacao.categoria_profissional.                                          
            find current neuclien no-lock.
        end.
    end.        
