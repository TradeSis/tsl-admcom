disable triggers for load of produaux.
def var vqtd as int.

message "INICIO " string(time,"hh:mm:ss").
pause 0.
message "INICIO leitura MixmProd " today string(time,"hh:mm:ss").
pause 0.
vqtd = 0.

for each triexporta where
         triexporta.datatrig >= today - 2 and 
         triexporta.tabela = "mixmprod"
         no-lock,
    first mixmprod where 
        recid(mixmprod) = triexporta.Tabela-Recid 
        no-lock:

    if not mixmprod.situacao
    then for each produaux where
                  produaux.procod     = mixmprod.procod and
                  produaux.nome_campo = "MixMProd"
                  :
            replace(produaux.valor_campo,"SIM","NAO").
            produaux.datexp   = today.
            produaux.exportar = yes.                     
         end. 
    else for each mixmgruetb where 
             mixmgruetb.codgrupo = mixmprod.codgrupo no-lock:
             
            find first produaux where
                   produaux.procod     = mixmprod.procod and
                   produaux.nome_campo = "MixMProd" and
                   produaux.valor_campo begins string(mixmgruetb.etbcod,"999")
                   no-error.
            if avail produaux 
            then do:
                if not mixmgruetb.situacao 
                then produaux.valor_campo = 
                        string(mixmgruetb.etbcod,"999") + ",NAO".
                else produaux.valor_campo =
                        string(mixmgruetb.etbcod,"999") + ",SIM".
                assign            
                    produaux.datexp   = today
                    produaux.exportar = yes.
            end.
            else if mixmgruetb.situacao
                then do.
                    create produaux.
                    assign
                        produaux.procod     = mixmprod.procod
                        produaux.nome_campo = "MixMProd"
                        produaux.valor_campo = 
                                string(mixmgruetb.etbcod,"999") + ",SIM"
                        produaux.datexp   = today
                        produaux.exportar = yes.
                end.
        end.
    vqtd = vqtd + 1.
end.    
pause 0.
message "FIM leitura MixmProd " vqtd date string(time,"hh:mm:ss").
pause 0.
message "FIM " string(time,"hh:mm:ss").
pause 0.

quit.

