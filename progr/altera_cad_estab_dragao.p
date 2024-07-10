{admcab.i new}

def temp-table tt-estab like estab
    field migrou-dragao as logical format "SIM/NAO".

for each estab where tipoloja = "Normal" or tipoloja = "Outlet" no-lock.

    create tt-estab.
    buffer-copy estab to tt-estab.

    find tabaux where
         tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
         tabaux.nome_campo = "MIGROU-DRAGAO" no-error.
    if avail tabaux
    then tt-estab.migrou-dragao = (tabaux.valor_campo = "SIM").
    else tt-estab.migrou-dragao = no.

end.

for each tt-estab .

    display tt-estab.etbcod tt-estab.etbnom migrou-dragao.

    update migrou-dragao.

end.

for each tt-estab .

    find tabaux where
         tabaux.tabela = "ESTAB-" + string(tt-estab.etbcod,"999") and
         tabaux.nome_campo = "MIGROU-DRAGAO" no-error.
    if avail tabaux
    then tabaux.valor_campo = string(tt-estab.migrou-dragao,"SIM/NAO").
    else do:
                
        create tabaux.
        assign
              tabaux.tabela  = "ESTAB-" + string(tt-estab.etbcod,"999")
              tabaux.nome_campo  = "MIGROU-DRAGAO"
              tabaux.valor_campo = string(tt-estab.migrou-dragao,"SIM/NAO")
              tabaux.tipo_campo  = "log"
              tabaux.datexp  = today
              tabaux.exporta = yes.

    end.

end.
        



