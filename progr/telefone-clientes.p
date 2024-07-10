def var maior-credito-aberto as dec.
def var media-credito-aberto as dec.
def var v1 as dec.
def var v2 as dec.
def var vfone like clien.fone format "(99)9999-9999".
def var vcel  like clien.fax  format "(99)9999-9999".

output to /gera-embrace/telefones-clientes.txt.
put "CODIGO;TELEFONE FIXO;TELEFONE CELULAR" SKIP.  
for each clien no-lock:
    if clien.clicod = 1 or
       clien.clicod = 1513 or
       clien.clicod = 0 or
       clien.clicod = 1313
    then next. 
    if (clien.fone = ? or clien.fone = "") and
       (clien.fax  = ? or clien.fax  = "")
    then next. 
    find ncrm where ncrm.clicod = clien.clicod no-lock no-error.
    if not avail ncrm or ncrm.spc
    then next.
    if clien.fone = ?
    then vfone = "".
    else do:
        if length(clien.fone) < 10
        then vfone = "  " + clien.fone.
        else vfone = clien.fone.
    end.
    if clien.fax = ?
    then vcel = "".
    else do:
        if length(clien.fax) < 10
        then vcel = "  " + clien.fax.
        else vcel = clien.fax.
    end.
    put unformatted
        clien.clicod ";"
        vfone format "(99)9999-9999" ";"
        vcel  format "(99)9999-9999"
           skip.
end.
output close.
