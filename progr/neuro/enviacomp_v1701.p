pause 0 before-hide.


message today string(time,"HH:MM:SS") "Iniciando Processo Comportamento...".

for each estab no-lock.

    message today string(time,"HH:MM:SS") "Loja" estab.etbcod 
            " Verifica Novos Contratos.".

    run neuro/enviacompnovos_v1701.p    (estab.etbcod).
        
    message today string(time,"HH:MM:SS") "Loja" estab.etbcod 
            " Calcula Limite dos Novos.".

    run neuro/enviacompcalclim_v1701.p  (estab.etbcod).

    message today string(time,"HH:MM:SS") "Loja" estab.etbcod 
            " Verifica Alteracoes Saldo dos Enviados.".

    run neuro/enviacompenviado_v1701.p  (estab.etbcod).

end .

message today string(time,"HH:MM:SS") " Gerando o arquivo".

/** gera arquivo **/
    run neuro/enviacomparquivo_v1701.p.

message today string(time,"HH:MM:SS") "Finalizando o processo Comportamento.".

