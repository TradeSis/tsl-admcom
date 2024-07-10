{admcab.i}

def temp-table tt-func like func
    index i1 funnom.

for each func where
         func.usercod <> "" no-lock:
    create tt-func.
    buffer-copy func to tt-func.
end.  

{zoomesq.i tt-func tt-func.usercod tt-func.funnom 40 Funcionario "true"}
