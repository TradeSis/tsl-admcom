/*  cad/cr_produ.p   */
def input parameter par-rec as recid.

def var vprocod like produ.procod.

def shared temp-table ttcores
    field corcod   like cor.corcod
    field marc     as log init no
    field perm     as log

    index cor   is primary unique corcod.

def buffer bprodu for produ.
def buffer iprodu for produ.

find produpai where recid(produpai) = par-rec no-lock.
find first iprodu of produpai no-lock no-error.

find grade of produpai no-lock no-error.
if not avail grade
then do.
    message "Problema no cadastro da grade:" produpai.gracod view-as alert-box.
    leave.
end.

do transaction.
    find last bprodu where bprodu.procod <= 900000 exclusive-lock no-error.
    if available bprodu
    then assign vprocod = (if bprodu.procod + 1 = produpai.itecod
                           then produpai.itecod
                           else bprodu.procod).
    else assign vprocod = 400000.

    for each ttcores where ttcores.marc no-lock.
        find cor of ttcores no-lock.
        for each gratam of grade no-lock
                        by gratam.graord.
            find taman of gratam no-lock.
            find produ where produ.itecod = produpai.itecod and
                             produ.corcod = ttcores.corcod  and
                             produ.protam = gratam.tamcod
                       no-lock no-error.
            if avail produ
            then next.

            vprocod = vprocod + 1.
            create produ.
            assign 
                produ.itecod  = produpai.itecod
                produ.procod  = vprocod 
                produ.proindice = string(produ.itecod,"9999999") +
                                  string(int(ttcores.corcod),"9999") +
                                  string(taman.pos,"999")
                produ.pronom  = caps(trim(produpai.pronom) + " " +
                                     trim(cor.cornom) + " " +
                                     trim(taman.tamcod))
                produ.corcod  = caps(ttcores.corcod)
                produ.protam  = caps(gratam.tamcod)
                produ.datexp  = today.
            if avail iprodu
            then buffer-copy iprodu 
                        except procod proindice pronom corcod protam datexp
                        to produ.
        end.
    end.
end.
