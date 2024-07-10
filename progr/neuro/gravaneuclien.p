    
    def input   parameter p-cpf             as char.
    def input   parameter p-nome_pessoa     as char.
    def input   parameter p-dtnasc          as date.
    def input   parameter p-nome_mae        as char.
    def output  parameter p-recid-neuclien  as recid.
 
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
                assign
                    neuclien.cpfcnpj = dec(p-cpf). /** int64 **/
                    neuclien.nome_pessoa = p-nome_pessoa.
                    neuclien.dtnasc = p-dtnasc.
                    neuclien.nome_mae = p-nome_mae.
                    neuclien.dtcad   = today.
                assign
                    neuclien.sit_credito = "".
            end.
        end.
        p-recid-neuclien = recid(neuclien).
        find current neuclien no-lock.
    end.        
