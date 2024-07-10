TRIGGER PROCEDURE FOR Replication-Write OF clien  OLD BUFFER oldclien.
/* helio 13022023 - ID GLPI 156585 e 156556 Orquestra 456067 e 456058 - include clienhist.i */


    {/admcom/progr/clienhist.i
         &tabela =   clien
         &old    =   oldclien }


    {/admcom/progr/cretrigger.i
         &tabela =   clien
         &old    =   oldclien }


