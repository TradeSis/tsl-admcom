        if {1} > today or {1} = ? or
           {2} < {1} or
           {1} < today - 360 or
           {2} < today - 360
        then do:
            message color red/with
                "Data Invalida."
                view-as alert-box title " Mensagem ".
            undo, retry.
        end.
        if month({2}) <> month(today)
        then do:
            vdtaux = date(month(today),01,year(today)) + 2.
            repeat:
                if  weekday(vdtaux) = 1 or
                    weekday(vdtaux) = 7
                then do:
                    vdtaux = vdtaux + 1.
                    next.
                end.
                else leave.
            end.
            if today > vdtaux
            then do:
                message "Recebimento nao permitido para Emissao ="
                    string({1}) "e Recebimento =" string({2}).
                undo, retry.
            end.
        end.

        find last autnfent no-lock no-error.
        if avail autnfent and autnfent.autsit
        then do:
            if vrecdat < autnfent.dtautoriza
            then do:
                message color red/with
                "Recebimento bloqueado para data anterior a "
                autnfent.dtautoriza
                view-as alert-box.
                undo, retry.
            end.
        end.
