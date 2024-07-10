def var p-today as date.
def var vct     as int.

update p-today label "Data inicial" validate (p-today <> ?, "") with side-label.
pause 0 before-hide.

message "cyber_clien_h" vct.
for each cyber_clien_h where cyber_clien_h.dtenvio >= p-today.
    vct = vct + 1.
    if vct mod 1750 = 0 
    then do.
        disp vct with side-label.
        pause 1.
    end.
    delete cyber_clien_h.
end.    

message "cyber_contrato_h" vct.
for each cyber_contrato_h where cyber_contrato_h.dtenvio >= p-today.
    vct = vct + 1.
    if vct mod 1750 = 0 
    then do.
        disp vct.
        pause 1.
    end.
    delete cyber_contrato_h.
end.    

message "cyber_parcela_h" vct.

for each cyber_parcela where cyber_parcela.titdtpag >= p-today.
    cyber_parcela.titdtpag = ?.
    find cyber_contrato of cyber_parcela.
    cyber_contrato.situacao = yes.
end.

for each cyber_parcela_h where cyber_parcela_h.dtenvio >= p-today.
    vct = vct + 1.
    if vct mod 1750 = 0 
    then do.
        disp vct.
        pause 1.
    end.
    delete cyber_parcela_h.
end.
message "Fim" vct.
