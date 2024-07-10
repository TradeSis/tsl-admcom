def input parameter p-tipo as char.
def input parameter p-emite as int.
def input parameter p-serie as char.

def buffer numfil for nfeloja.a01_infnfe.
def buffer nummat for nfe.a01_infnfe.

if p-tipo = "BUSCA"
then do:
    find last numfil where numfil.emite = p-emite and
                           numfil.serie = p-serie
                           no-lock no-error.
    if avail numfil
    then do:
        find last nummat where nummat.emite = p-emite and
                           nummat.serie = p-serie
                           no-lock no-error.
        if not avail nummat or
            nummat.numero < numfil.numero
        then do:
            create nummat.
            buffer-copy numfil to nummat.
        end.
    end.    
end.
else if p-tipo = "ENVIA"
then do:
    find last nummat where nummat.emite = p-emite and
                           nummat.serie = p-serie
                           no-lock no-error.
    if avail nummat
    then do:
        find last numfil where numfil.emite = p-emite and
                           numfil.serie = p-serie
                           no-lock no-error.
        if not avail numfil or
            numfil.numero < nummat.numero
        then do:
            create numfil.
            buffer-copy nummat to numfil.
        end.
    end. 
end.
