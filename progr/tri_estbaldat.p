TRIGGER PROCEDURE FOR Assign OF estoq.estbaldat.
    run triexporta.p
            ("estoq", 
             "TRIGGER_estbaldat", 
             recid(estoq)).
                              
