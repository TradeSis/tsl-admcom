def var vdtref as date init 04/30/2020.
{admcab.i new}
def var vdt as date.
pause 0 before-hide.
do vdt = vdtref + 1 to today.

disp vdt with frame fn.


for each estab where estab.etbcod = 188 no-lock.
disp estab.etbcod.
for each modal where 
    modal.modcod = "CHQ" or modal.modcod = "CRE" or modal.modcod begins "CP" 
    no-lock.
disp modal.modcod.


for each titulo where titnat = no and titulo.titdtemi = vdt and titulo.etbcod = estab.etbcod and titulo.modcod = modal.modcod no-lock.

    if titulo.titdtven = ?
    then next.
    
    if titulo.titsit = "LIB" or
       titulo.titsit = "PAG"
    then.
    else next.   
 
    run /admcom/progr/fin/geraposcart.p (recid(titulo),"emissao",vdt).

end.
for each titulo where titnat = no and titulo.titdtpag = vdt and titulo.etbcod = estab.etbcod and titulo.modcod = modal.modcod no-lock.

    if titulo.titdtven = ?
    then next.

    if  titulo.titsit <> "PAG"
    then next.
    run /admcom/progr/fin/geraposcart.p (recid(titulo),"pagamento",vdt).

end. 

end.
end.
end.
