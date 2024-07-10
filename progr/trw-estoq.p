TRIGGER PROCEDURE FOR Replication-Write OF estoq.

    run triexporta.p
        ("estoq",
         "TRIGGER",
         recid(estoq)).
