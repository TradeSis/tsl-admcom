{admcab.i}

def var vfuncod like func.funcod.
def var vetbcod like estab.etbcod.
def var vuserid as char.

vetbcod = setbcod.

update vetbcod at 1 label "Filial"
        with frame f1 side-label 1 down width 80.

find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom no-label with frame f1.

update vfuncod at 1 label "Usuario" with frame f1.

find func where func.funcod = vfuncod and
                func.etbcod = vetbcod no-lock.
                
disp func.funnom no-label with frame f1.
                 
find dbrfunc where dbrfunc.etbcod = vetbcod and
                   dbrfunc.funcod = vfuncod
                   no-error.
if not avail dbrfunc
then do:
    create dbrfunc.
    assign
        dbrfunc.etbcod = vetbcod
        dbrfunc.funcod = vfuncod
    .
end.
    
    update dbrfunc.user_id format "x(40)" at 1 label "Usuario AniTA DBR"
            with frame f1.
            
