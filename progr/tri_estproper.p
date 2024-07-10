TRIGGER PROCEDURE FOR Assign OF estoq.estproper.
    run triexporta.p
            ("estoq", 
             "TRIGGER_estproper", 
             recid(estoq)).
                              
