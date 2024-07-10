{admcab.i}

def var vtipo as char format "x(15)" 
extent 2 initial[" Deposito "," New Free "].
def var vprocod like produ.procod format ">>>>>>>9".
def var vdata as date format "99/99/9999".

def temp-table wetique
    field wrec as recid
    field wqtd like estoq.estatual
    field wtaman as char format "x(3)"
    /*****field wdata  as char format "x(4)"*****/.

repeat on error undo, leave:
    update vprocod colon 12 
           with frame f1 side-label width 80 row 4.
           
    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do:
        message "Produto nao Cadastrado".
        undo, retry.
    end.

    display produ.pronom no-label with frame f1.
    
    create wetique.
    assign wetique.wrec = recid(produ).
    
    vdata = today.
    
    update wetique.wqtd   label "Quantidade" colon 12 
           wetique.wtaman label "Tamanho"    colon 12 /*****
           vdata          label "Data"       colon 12       *****/
           with frame f1.

    /*****
    assign wetique.wdata = substring(string(vdata),9,2) +
                           substring(string(vdata),4,2).
    *****/
    
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
        dos silent del ..\free\etqbz* .
    end.

    for each wetique:
        if frame-index = 1
        then do:
            run etiqbz01.p (input wetique.wrec,
                           input wetique.wqtd,
                           input wetique.wtaman).
            /********
            run /*eti_barl9.p*/ /*etibarl9.p*/ etibar1a.p (input wetique.wrec,
                            input wetique.wqtd,
                            input wetique.wtaman /*****,
                            input wetique.wdata*****/).
            *******/
        end.
        else if frame-index = 2
        then do:
            run etifre9.p (input wetique.wrec,
                           input wetique.wqtd,
                           input wetique.wtaman).

            dos silent del l:\free\free.zip.
            dos silent pkzip -m l:\free\free.zip  l:\free\cris*.* .
        end. 
        /****
        else do:
            run etiqbz01.p (input wetique.wrec,
                           input wetique.wqtd,
                           input wetique.wtaman).

            dos silent del l:\free\free.zip.
            dos silent pkzip -m l:\free\free.zip  l:\free\etqbz*.* .

        end. 
          ******/
    end.
    find first wetique no-error.
    if avail wetique
    then dos silent c:\temp\etique.bat.
end.

for each wetique:
    delete wetique.
end.
