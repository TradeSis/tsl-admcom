def var par-interface as char init "confage".
    
def new shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char     
    field Arquivo       as char initial ?
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.
    
    for each ttarq.
        delete ttarq.
    end.    

    message today string(time,"HH:MM:SS") "Rodando importador Conf Age".
    run edi/buscaarquivo.p (input par-interface).

    for each ttarq where ttarq.interface = par-interface.

                disp ttarq. 
                
        run edi/agendamimp.p ( ttarq.arquivo,
                               ttarq.diretorio).
                               
    end.        
 