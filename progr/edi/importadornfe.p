 def var par-interface as char init "PROCNFE".
    
def new shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char     
    field Arquivo       as char initial ?
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.
    
    for each ttarq.
        delete ttarq.
    end.    

    message today string(time,"HH:MM:SS") "Rodando importador NFE" par-interface.
    
    run edi/buscaarquivo.p (input par-interface).

    for each ttarq where ttarq.interface = par-interface.

        run edi/nfexmlimp.p  ( ttarq.arquivo,
                               ttarq.diretorio).
                               
    end.        
 