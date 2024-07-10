def input parameter p-clifor like fin.titulo.clifor.
def shared temp-table d-titulo like fin.titulo.
for each d.titulo where d.titulo.clifor = p-clifor no-lock:
    create d-titulo.
    buffer-copy d.titulo to d-titulo.
end.
    
    