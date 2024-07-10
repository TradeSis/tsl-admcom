TRIGGER PROCEDURE FOR Assign OF estoq.estcusto.
    run triexporta.p
            ("estoq", 
             "TRIGGER_estcusto", 
             recid(estoq)).
                              
