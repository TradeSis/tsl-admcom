def input  parameter vdtref like plani.pladat.
def output parameter vtot   like titulo.titvlcob format "z,zzz,zz9.99".
def output parameter vpag   like titulo.titvlpag format "z,zzz,zz9.99".
def output parameter vent   like titulo.titvlcob format "z,zzz,zz9.99".
def output parameter vsal   like titulo.titvlcob format "z,zzz,zz9.99".

vpag = 0.
vtot = 0.
vent = 0.
                   

for each titulo where titulo.empcod = 19    and
                      titulo.modcod = "dup" and
                      titulo.titnat = yes   and
                      titulo.titsit = "LIB"  no-lock:

    vtot = vtot + (titulo.titvlcob).
    /*
    display "Liberados" titulo.etbcod titdtven vtot with 1 down centered. 
    pause 0.
    */
end.


for each titulo where titulo.empcod = 19    and
                      titulo.modcod = "dup" and
                      titulo.titnat = yes   and
                      titulo.titsit = "CON"  no-lock:
    
    vtot = vtot + titulo.titvlcob.
    /*
    display "Confirmados" etbcod titdtven vtot with 1 down centered. 
    pause 0.
    */
end.
                 
    

vpag = 0.

for each titulo where titulo.empcod = 19    and
                      titulo.modcod = "dup" and
                      titulo.titnat = yes   and
                      titulo.titdtpag = vdtref no-lock:
    
    vpag = vpag + titulo.titvlcob.
    
end.

  
vent = 0.


for each plani where plani.datexp = vdtref no-lock.
    if movtdc = 04 or
       movtdc = 01
    then.
    else next.

    for each titulo where titulo.empcod = 19 and 
                          titulo.titnat = yes and
                          titulo.modcod = "DUP" and
                          titulo.etbcod = plani.etbcod and
                          titulo.clifor = plani.emite and
                          titulo.titnum = string(plani.numero) no-lock.
        
        vent = vent + titulo.titvlcob. 
            
    end.

end. 

vsal = (vtot + vpag - vent).

 


      








