
def var vopc_gnre as int.
def var vnro_gnre as dec.


procedure trata_gnre.

    def var vle_gnre  as log.    
    def var mopc_gnre as char extent 3 format "x(30)"
        init ["GNRE - OBRIGATORIA",
              "GNRE - NAO - IE SUBST.TRIB",
              "GNRE - NAO INFORMADA"].

    for each w-movim no-lock.
        find produ where recid(produ) = w-movim.wrec no-lock.
        if produ.proipiper = 99
        then do.
            vle_gnre = yes.
            leave.
        end.
    end.
    if vle_gnre
    then do.
        vopc_gnre = 0.
        disp mopc_gnre with frame f-gnre no-label 1 col centered title " GNRE ".
        choose field mopc_gnre with frame f-gnre.
        vopc_gnre = frame-index.
        if vopc_gnre = 1
        then update vnro_gnre label "Numero GNRE" format ">>>>>>>>>>>>>>>9"
                    validate (vnro_gnre > 0, "")
                    with frame f-numero-gnre side-label centered.
    end.
    hide frame f-gnre no-pause.

end procedure.


procedure grava_gnre.

    if vopc_gnre > 0
    then do on error undo.
        create planiaux.
        assign
            planiaux.movtdc = plani.movtdc
            planiaux.etbcod = plani.etbcod
            planiaux.placod = plani.placod
            planiaux.emite  = plani.emite
            planiaux.serie  = plani.serie
            planiaux.numero = plani.numero
            planiaux.nome_campo = "GNRE"
            planiaux.valor_campo = "OPCAO=" + string(vopc_gnre) +
                                   (if vnro_gnre > 0
                                    then "|NUMERO=" + string(vnro_gnre)
                                    else "").
    end.
end procedure.

