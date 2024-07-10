def var vdtref as date init 12/31/2019.
{admcab.i new}
pause 0 before-hide.
for each estab where estab.etbcod = 1 no-lock.
disp estab.etbcod.
for each modal where 
    modal.modcod = "CHQ" or modal.modcod = "CRE" or modal.modcod begins "CP" 
    no-lock.
disp modal.modcod.

for each titulo where empcod = 19 and titnat = no and titulo.modcod = modal.modcod and titulo.etbcod = estab.etbcod and
titdtven > vdtref 
no-lock.

    if titulo.titdtven = ?
    then next.
    
    if titulo.titsit = "LIB" or
       titulo.titsit = "PAG"
    then.
    else next.   
    if titulo.titdtemi > vdtref
    then next.
    
    if titulo.titdtpag = ?
    then next.
    
    if titulo.titdtpag > vdtref
    then next.
             /*
    disp titulo.modcod titulo.titdtemi titulo.titdtven titulo.titdtpag titulo.titsit titulo.titvlcob.
               */
    
    run /admcom/progr/fin/geraposcart.p (recid(titulo),"emissao"  ,vdtref).
    run /admcom/progr/fin/geraposcart.p (recid(titulo),"pagamento",vdtref).

end.
end.
end.

