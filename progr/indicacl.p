{admcab.i new}
def input parameter p-recid as recid.

find clien where recid(clien) = p-recid no-lock.

def buffer bclien for clien.

def var vclicod like clien.clicod.

find first indicacl where
           indicacl.clicod = clien.clicod no-lock no-error.
if not avail indicacl
then           
repeat on endkey undo, return with frame f 1 down:
    disp "Cliente indicado por?" .
    update vclicod.
    find first bclien where
           bclien.clicod = vclicod no-lock no-error.
    if not avail bclien
    then do:
        bell.
        message color red/with
            "Codigo " vclicod " nao cadatrado."
                view-as alert-box.
    end.                
    else do:
        disp bclien.clinom no-label.
        sresp = no.
        message "Confirma indicação?" update sresp.
        if sresp
        then do:
                create indicacl.
                assign
                indicacl.clicod = clien.clicod
                indicacl.cod_indica = bclien.clicod
                indicacl.dtindica = today
                indicacl.datexp = today
                indicacl.dtinclu = today
                .
            find current indicacl no-lock .
            leave.    
        end.
        else next.
    end.
end.