TRIGGER PROCEDURE FOR Assign OF estoq.estprodat.
    run triexporta.p
            ("estoq", 
             "TRIGGER_estprodat", 
             recid(estoq)).
                              
