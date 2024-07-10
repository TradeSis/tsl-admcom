def var vdtref as date init 12/31/2019.
{admcab.i new}
pause 0 before-hide.
for each estab where estab.etbcod = 188 no-lock.
disp estab.etbcod.
for each modal where 
    modal.modcod = "CHQ" or modal.modcod = "CRE" or modal.modcod begins "CP" 
    no-lock.
disp modal.modcod.

for each titulo where titnat = no and titulo.titdtpag = ? and titulo.etbcod = estab.etbcod and titulo.modcod = modal.modcod no-lock.

    if titulo.titdtven = ?
    then next.
    
    if titulo.titsit = "LIB" or
       titulo.titsit = "PAG"
    then.
    else next.   
    if titulo.titdtemi > vdtref
    then next.
 
    run /admcom/progr/fin/geraposcart.p (recid(titulo),"emissao",vdtref).
    
end.
end.

end.    
