def stream sbanco.
output stream sbanco to l:\dados\bancos.d.
for each banco no-lock:
        display "Exportando Bancos...."
                banco.bancod no-label with frame f2 1 down centered.
    
        export stream sbanco banco.
        pause 0.
    
end.
output stream sbanco close.
 