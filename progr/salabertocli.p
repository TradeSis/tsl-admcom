def input parameter p-recid as recid.
def output parameter p-saldo as dec.

find clien where recid(clien) = p-recid no-lock.
for each fin.titulo use-index iclicod
            where fin.titulo.clifor = clien.clicod 
                            no-lock:
    if fin.titulo.modcod <> "CRE" 
    then next.
    if fin.titulo.titsit <> "LIB"
    then next.
    p-saldo = p-saldo + fin.titulo.titvlcob.
end.
for each dragao.titulo use-index iclicod
                where dragao.titulo.clifor = clien.clicod 
                no-lock:
    if dragao.titulo.modcod <> "CRE" 
    then next.
    if dragao.titulo.titsit <> "LIB"
    then next.
    p-saldo = p-saldo + dragao.titulo.titvlcob.
end.             
