/* base: etinv01a.p */

{admcab.i}

def var vpaccod  like pack.paccod.
def var vfila    as char.
def var vrecimp  as recid.
def var varquivo as char.

def temp-table wetique
    field wrec as recid
    field wqtd as int.

def var mdesti as char extent 2 format "x(13)" init [" Arquivo"," Impressora"]. 
def var mpasta as char extent 5 init ["01","02","03","04","05"].
def var vpasta as int.
def var vdesti as int.

disp mdesti with frame f-desti no-label centered title " Destino ".
choose field mdesti with frame f-desti.
vdesti = frame-index.

if vdesti = 1
then do.
    disp mpasta with frame f-pasta no-label centered title " Fila ".
    choose field mpasta with frame f-pasta.
    vpasta = frame-index.
    vfila = mpasta[frame-index].
end.
else if vdesti = 2
then do.
    find first impress where impress.codimp = setbcod no-lock no-error.
    if not avail impress
    then do:
        message "Sem impressora cadastrada para o estab" setbcod
            view-as alert-box.
        undo.
    end.
    run acha_imp.p (input recid(impress), 
                    output vrecimp).
    if vrecimp = ?
    then undo.
    find impress where recid(impress) = vrecimp no-lock.
    assign vfila = impress.dfimp.
end.
hide frame f-desti.
hide frame f-pasta.
disp vfila label "Fila" format "x(30)" with frame f-proc side-label row 3.

repeat on error undo, leave:
    update vpaccod colon 12 with frame f1 side-label width 80 row 6.
    find pack where pack.paccod = vpaccod no-lock no-error.
    if not avail pack
    then do:
        message "Pack nao Cadastrado".
        undo, retry.
    end.
    display pack.pacnom no-label with frame f1.
    
    create wetique.
    assign wetique.wrec = recid(pack).
    
    update wetique.wqtd label "Quantidade" colon 12 format ">>9"
           validate(wetique.wqtd > 0, "")
           with frame f1.
end.

find first wetique no-lock no-error.
if not avail wetique
then leave.

if vdesti = 1
then message "Gerar Arquivo de Etiquetas?" update sresp.
else message "Imprimir Etiquetas?" update sresp.
if not sresp
then return.

if vdesti = 1 /* Arquivo */
then do.
    if opsys = "UNIX"
    then do: /* vfila = "01" "02" "03" "04" */
        varquivo = "/admcom/zebra/" + vfila + "/eti-" + vfila + ".bat".
        if search(varquivo) <> ?
        then do:
            unix silent value("rm " + varquivo + " -f").
            unix silent value("rm /admcom/zebra/" + vfila + "/c*.* -f"). 
        end.
    end.
/***
    else do: /* se necessario revisar */
        varquivo = "l:~\zebra~\01~\eti-01.bat".
    
        if search(varquivo) <> ?
        then do:
            dos silent del l:~\zebra~\01~\eti-01.bat.
            dos silent del l:~\zebra~\01~\c*.* .
        end.        
    end.
***/
end.
else do.
    /* "Deposito","New Free"
     desenvolvido Deposito
    */
end.

for each wetique no-lock:
    run etinvpack2.p (input wetique.wrec,
                      input wetique.wqtd,
                      vdesti,
                      vfila).
end.

