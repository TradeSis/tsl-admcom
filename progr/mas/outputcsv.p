def var varquivo as char format "x(60)".
update varquivo label "Arquivo" 
    with side-labels width 80 row 6 overlay.

output to value(varquivo).
put unformatted skip
    "CPF;LINHA_DIGITAVEL;"
    skip.
    
for each banmassacli where banmassacli.dtenviocsv = ? and banmassacli.dtenvio <> ?.

    find banboleto where recid(banboleto) = banmassacli.banboleto-recid no-lock no-error.
    if not avail banboleto
    then next.
    
    put unformatted
        banmassacli.cpf ";"
        banboleto.LinhaDigitavel ";"
        skip.

    banmassacli.dtenviocsv = today.
    
end.


output close.

message "Arquivo " varquivo " gerado".
pause.

return.
