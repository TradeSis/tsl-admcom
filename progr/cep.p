def var vcep like clien.cep[1].
def var ii as int.

for each clien no-lock by clicod desc:
    
    vcep = "".
    if substring(clien.cep[1],1,1) <> "9"
    then vcep = "96700000".
    else do:
    
        if length(cep[1]) = 8
        then do:
            do ii = 1 to 8:
                if substring(string(cep[1]),ii,1) = "-" or
                   substring(string(cep[1]),ii,1) = " " or
                   substring(string(cep[1]),ii,1) = "*" or
                   substring(string(cep[1]),ii,1) = "." or
                   substring(string(cep[1]),ii,1) = "/" 
                then vcep = vcep + "0".
                else vcep = vcep + substring(cep[1],ii,1).
            end.
        end.    

        if length(cep[1]) >= 09
        then do:
            do ii = 1 to 10:
                if substring(string(cep[1]),ii,1) = "-" or
                   substring(string(cep[1]),ii,1) = " " or
                   substring(string(cep[1]),ii,1) = "*" or
                   substring(string(cep[1]),ii,1) = "." or
                   substring(string(cep[1]),ii,1) = "/" 
                then.
                else vcep = vcep + substring(cep[1],ii,1).
            end.
        end.    
        

    end.
    disp clien.cep[1]
         vcep.
    
    
end.
