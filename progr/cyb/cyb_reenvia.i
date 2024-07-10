form with frame f_controle with 15 down.

procedure reenvia.

    def input parameter par-contnum  as char.
    def input parameter par-tipooper as log. /* Reenviar/Consultar */

    find first cyber_controle where cyber_controle.contnum = int64(par-contnum)
                    no-lock no-error.
    if not avail cyber_controle
    then return.

    find contrato where contrato.contnum = cyber_controle.contnum
                  no-lock no-error.

    disp
        cyber_controle.loja
        cyber_controle.contnum
        cyber_controle.situacao    format "x(10)"
        cyber_controle.vlraberto   format ">>>>9.99" column-label "Vlr!Aberto"
        cyber_controle.vlratrasado format ">>>>9.99" column-label "Vlr!Atrasad"
        cyber_controle.cybatrasado format ">>>>9.99" column-label "Cyb!Atrasad"
        cyber_controle.dtenvio     format "999999"   column-label "Envio"
        contrato.dtinicial when avail contrato column-label "D.Inic"
                           format "999999"
        contrato.datexp    when avail contrato format "999999"
                           column-label "Dt.Exp"
        with frame f_controle.

    if par-tipooper
    then do transaction.
        find current cyber_controle exclusive.
        pause 0.

        if cyber_controle.situacao = "ENVIADO"
        then cyber_controle.cybatrasado = 99999.

        else if cyber_controle.situacao = "ACOMPANHADO"
        then assign
                cyber_controle.vlraberto = ?
                cyber_controle.vlratrasado = ?.
            
        else if cyber_controle.situacao = "ELIMINADO"
        then assign
                cyber_controle.situacao = "ACOMPANHADO"
                cyber_controle.vlraberto = ?
                cyber_controle.vlratrasado = ?.
    end.
    else pause 0. /* down 1 with frame f_controle. */

end procedure.

