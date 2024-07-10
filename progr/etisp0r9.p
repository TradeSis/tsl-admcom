{admcab.i}

def var vprocod like produ.procod format ">>>>>>>9".
def temp-table wetique
    field wrec as recid
    field wqtd like estoq.estatual
    field wtaman as char format "x(3)".

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
    
    update wetique.wqtd label "Quantidade" colon 12 
           wetique.wtaman label "Tamanho"    colon 12
           with frame f1.
           
    
end.
def var varquivo as char.
find first wetique no-error.
if not avail wetique
then leave.
message "Gerar Arquivo de Etiquetas" update sresp.
if sresp
then do:

    if opsys = "UNIX"
    then do:
        varquivo = "/admcom/zebra/sc/eti-sc.bat".
        if search(varquivo) <> ?
        then do:
            unix silent value(" rm " + varquivo + " -f").
            unix silent value(" rm /admcom/zebra/sc/c*.* -f"). 
        end.
    end.
    else do:
        varquivo = "l:~\zebra~\sc~\eti-sc.bat".
    
        if search(varquivo) <> ?
        then do:
            dos silent del l:~\zebra~\sc~\eti-sc.bat.
            dos silent del l:~\zebra~\sc~\c*.* .
        end.        
    end.

    /*
    if search("l:\zebra\sc\eti-sc.bat") <> ?
    then do:

        dos silent del l:\zebra\sc\eti-sc.bat.
        dos silent del l:\zebra\sc\c*.* .
    
    end.
    */
    for each wetique:

        run /*etisp_9.p*/ etiqbz0r.p (input wetique.wrec,
                     input wetique.wqtd,
                     input wetique.wtaman).
    
    end.

end.

for each wetique:
    delete wetique.
 end.
