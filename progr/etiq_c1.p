{admcab.i}
def var vtipo as char format "x(08)" extent 2 initial["Deposito","New Free"].
def var vprocod like produ.procod format ">>>>>>>9".
def temp-table wetique
    field wrec as recid
    field wqtd like estoq.estatual.
repeat on error undo, leave:
    update vprocod colon 12 with frame f1 side-label width 80 row 4.
    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do:
        message "Produto nao Cadastrado".
        undo, retry.
    end.
    display produ.pronom no-label with frame f1.
    create wetique.
    assign wetique.wrec = recid(produ).
    update wetique.wqtd label "Quantidade" colon 12 with frame f1.
end.
find first wetique no-error.
if not avail wetique
then leave.
message "Confirma emissao de Etiquetas" update sresp.
if sresp
then do:
    display vtipo with frame f-tipo no-label centered row 10.
    choose field vtipo with frame f-tipo.

    if search("c:\temp\etique.bat") <> ?
    then do:
        dos silent del c:\temp\etique.bat.
        dos silent c:\temp\cris*.* .
    end.

    for each wetique:
        if frame-index = 1
        then do:
            run eti_barl_c1.p (input wetique.wrec,
                            input wetique.wqtd).
        end.
        else do:
            run etifre.p
                /* eti_barl.p */ (input wetique.wrec,
                                  input wetique.wqtd).
            dos silent del l:\free\free.zip . 
            dos silent pkzip -m l:\free\free.zip  l:\free\cris*.* .                      
        end.    
    end.
    find first wetique no-error.
    if avail wetique
    then dos silent c:\temp\etique.bat.
end.
for each wetique:
    delete wetique.
end.
