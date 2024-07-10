{admcab.i}

def stream sflag.
output stream sflag to l:\dados\flag.d.
for each flag no-lock.

    display "Exportando..." flag.clicod with 1 down. pause 0.
    export stream sflag flag.        
        
end.
output stream sflag close.


