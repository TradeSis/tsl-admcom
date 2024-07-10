{admcab.i}

        if connected ("crm")
        then disconnect crm.

        /*** Conectando Banco CRM no server CRM ***/
        connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.

               
        if not connected ("crm")
        then do:
            message "Nao foi possivel conectar o banco CRM. Avise o CPD.".
            pause.
            return.
        end.

        run lclimail.p .

        if connected ("crm")
        then disconnect crm.
 