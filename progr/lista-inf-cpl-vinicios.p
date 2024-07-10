{admcab.i new}

def var varq-lista     as char.
def var vlinha         as char.

def temp-table tt-nf
    field numero as integer.

assign varq-lista = "/admcom/audit/lista-nf.csv".

update varq-lista format "x(50)" label "Arquivo"
        with frame f05 side-labels
        title "Informe o caminho do arquivo com a lista de notas".

input from value(varq-lista).
    
repeat:

    import vlinha.
    
    create tt-nf.
    assign tt-nf.numero = integer(vlinha).

end.

output to value("/admcom/audit/lista-nf-result.csv").        

for each tt-nf no-lock.

    for each a01_infnfe where a01_infnfe.etbcod = 993
                          and a01_infnfe.numero = tt-nf.numero no-lock.
    
        for each Z01_InfAdic of a01_infnfe no-lock.
        
            put unformatted
            a01_infnfe.numero ";" Z01_InfAdic.infcpl skip.
                
        end.
                    
    end.

end.









