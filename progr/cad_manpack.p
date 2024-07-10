{admcab.i}

def input parameter par-rec as recid.
def output parameter par-recpack as recid.

def new shared temp-table ttcores
    field corcod like cor.corcod
    field corseq as int

    index cor   is primary unique corcod
    index seq   corseq.

def var vmodpcod like modpack.modpcod.
def var vpacnom  like pack.pacnom.
def var vct      as int.
def var vok      as log.
def buffer bpack for pack.

find produpai where recid(produpai) = par-rec no-lock.

pause 0.
do on error undo with frame f-pack side-label.
    update vmodpcod colon 12.
    find modpack where modpack.modpcod = vmodpcod no-lock no-error.
    if not avail modpack or modpack.situacao = no
    then do.
        message "Modelo de pack invalido" view-as alert-box.
        undo.
    end.
    find grade of modpack no-lock.
    if not grade.situacao
    then do.
        message "Grade esta desativada" view-as alert-box.
        undo.
    end.
    disp modpack.modpnom no-label
        modpack.cores
        grade.gracod colon 12
        grade.granom no-label.

    vok = yes.
    for each gratam of grade no-lock.
        find first produ of produpai where produ.protam = gratam.tamcod
                no-lock no-error.
        if not avail produ
        then do.
            vok = no.
            leave.
        end.
    end.
    if not vok
    then do.
        message "Tamanhos da grade invalidos para este PAI"
            view-as alert-box.
        undo.
    end.

    find last bpack 
                where bpack.paccod >= int(string(produpai.itecod) + "001") and
                      bpack.paccod <= int(string(produpai.itecod) + "999")
                no-lock no-error.
    vpacnom = "PACK " + (if avail bpack
                         then string(bpack.paccod + 1, "999")
                         else "001").

    update vpacnom colon 12.

    run cad_selcorespai.p (produpai.itecod, vmodpcod).
    vct = 0.
    for each ttcores where ttcores.corseq > 0 no-lock.
        vct = vct + 1.
    end.
    if vct <> modpack.cores
    then do.
        message "Quantidade de cores invalida" view-as alert-box.
        undo.
    end.
    message "Confirma criar pack?" update sresp.
    if not sresp
    then return.
    do transaction.
        find last bpack 
                where bpack.paccod >= int(string(produpai.itecod) + "001") and
                      bpack.paccod <= int(string(produpai.itecod) + "999")
                no-lock no-error.
        create pack.
        assign
            pack.paccod  = if avail bpack
                           then bpack.paccod + 1
                           else int(string(produpai.itecod) + "001")
            pack.pacnom  = vpacnom
            pack.modpcod = vmodpcod
            pack.cores   = modpack.cores
            pack.itecod  = produpai.itecod.
        for each ttcores where ttcores.corseq > 0 no-lock.
            for each modpackcortam of modpack
                                   where modpackcortam.cor = ttcores.corseq
                                     and modpackcortam.qtde > 0
                                   no-lock.
                find produ where produ.itecod = produpai.itecod
                             and produ.corcod = ttcores.corcod
                             and produ.protam = modpackcortam.tamcod
                           no-lock.
                create packprod.
                assign
                    packprod.paccod = pack.paccod
                    packprod.procod = produ.procod
                    packprod.qtde   = modpackcortam.qtde

                    pack.qtde = pack.qtde + modpackcortam.qtde.
            end.
        end.                     
    end.
end.
