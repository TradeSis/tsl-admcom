def stream stela.
output stream stela to terminal.
output to c:\dados\produ.d.
for each produ where
             produ.prodtcad >= 07/01/2002 and
             produ.prodtcad <= today no-lock.         
            display stream stela procod with 1 down. pause 0.
    export produ.             
    end.
output close.
output stream stela close.