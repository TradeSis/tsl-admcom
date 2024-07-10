{admcab.i}
def temp-table wprodu
    field wpro like produ.procod.
def var vprocod like produ.procod.
def var vsenha like func.senha.
repeat:
    for each wprodu:
        delete wprodu.
    end.
    vsenha = "".
    update vsenha blank with frame f-senha side-label centered.
    if vsenha <> "custom"
    then do:
        message "Senha Incorreta".
        undo, retry.
    end.
    else leave.
end.
if vsenha <> "custom"
then return.

repeat:
    UPDATE vprocod with frame f1 side-label width 80.
    find produ where produ.procod = vprocod no-error.
    if not avail produ
    then do:
        message "Produto nao Cadastrado".
        undo, retry.
    end.
    disp produ.pronom no-label with frame f1.
    find first movim where movim.procod = vprocod no-lock no-error.
    if avail movim
    then do:
        bell.
        message "Existe movimentacao para este produto".
        undo, retry.
    end.
    create wprodu.
    assign wprodu.wpro = vprocod.
end.
sresp = yes.
message "Confirma exclusao do produto" produ.procod update sresp.
if not sresp
then undo, retry.
for each wprodu:
    find produ where produ.procod = wprodu.wpro.
    find propg where propg.pednum = produ.procod and
                     propg.prpdata = today no-error.
    if not avail propg
    then do transaction:
        create propg.
        assign propg.pednum  = produ.procod
               propg.prpdata = today.
    end.
    for each estab no-lock:
        for each estoq where estoq.procod = produ.procod and
                             estoq.etbcod = estab.etbcod:
            do transaction:
                delete estoq.
            end.
        end.
    end.
    for each estab no-lock:
        for each hiest where hiest.etbcod = estab.etbcod and
                             hiest.procod = produ.procod:
            do transaction:
                delete hiest.
            end.
        end.
        for each himov where himov.etbcod = estab.etbcod and
                             himov.procod = produ.procod:
            do transaction:
                delete himov.
            end.
        end.
    end.
    do transaction:
        delete produ.
    end.
end.
