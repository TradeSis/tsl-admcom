def var ii as int.
def var xx as char.
for each clien no-lock by dtcad desc:

    ii = 0.
    xx = "".
    do ii = 1 to 50:
    
       if substring(string(zona),ii,1) = "@"
       then xx = "x".
       
       
    end.    
        
            
    if xx <> ""
    then disp clicod zona format "x(50)".


end.