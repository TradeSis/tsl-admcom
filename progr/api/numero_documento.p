def input  parameter par-tipo_documento   as char.
def input  parameter par-numero_documento as char.
def output parameter par-clicod like clien.clicod.

def var vcod   as int.
def var par-ok as log.
       
    if par-tipo_documento = "1" /* CPF */
    then do:
        run cpf.p (par-numero_documento, output par-ok).
        if par-ok
        then find first clien where clien.ciccgc = par-numero_documento
                no-lock no-error.
        else do:
            run cgc.p (par-numero_documento, output par-ok).
            if par-ok
            then find first clien where clien.ciccgc = par-numero_documento
                    no-lock no-error.
        end.
    end.
    if par-tipo_documento = "2" /* codigo-cliente */ 
    then do:
        vcod = int(par-numero_documento) no-error.
        if vcod <> 0 and vcod <> ?
        then do.
            par-ok = yes.
            find first clien where clien.clicod = vcod no-lock no-error.
        end.
    end.

if par-ok and avail clien
then par-clicod = clien.clicod.

