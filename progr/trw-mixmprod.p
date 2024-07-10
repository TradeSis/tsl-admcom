TRIGGER PROCEDURE FOR Replication-Write OF mixmprod.
/*01.08.2019*/
    run triexporta.p
        ("mixmprod",
         "TRIGGER",
         recid(mixmprod)).

