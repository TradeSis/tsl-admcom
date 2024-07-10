{admcab.i}
def var vetbcod like estab.etbcod.
def var vtipo as char format "x(08)" extent 2 initial["Deposito","New Free"].
def var vprocod like produ.procod format ">>>>>>>9".
def temp-table wetique
    field wrec as recid
    field wqtd like estoq.estatual.
def var xx as int.    
    
repeat:
    update vetbcod label "Filial" with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    message "confirma emissao de etiqueta" update sresp.
    if not sresp
    then return.
    for each estoq where estoq.etbcod = vetbcod no-lock.
        display estoq.procod with frame f2 centered side-label 1 down. pause 0.
        if estoq.estatual <= 0
        then next.
        find produ where produ.procod = estoq.procod no-lock no-error.
        if not avail produ
        then next.
        create wetique.
        assign wetique.wrec = recid(produ).
               wetique.wqtd = 5. /* estoq.estatual. */
    end.           

    if search("c:\temp\etique.bat") <> ?
    then do:
        dos silent del c:\temp\etique.bat.
        dos silent c:\temp\cris*.* .
    end.

    for each wetique:
        run etimov.p (input wetique.wrec,
                      input wetique.wqtd).
    end.
    find first wetique no-error.
    if avail wetique
    then dos silent c:\temp\etique.bat.
    for each wetique:
        delete wetique.
    end.
end.
