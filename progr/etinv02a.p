{admcab.i}

def var vprocod like produ.procod format ">>>>>>>9".
def var varquivo as char.
def var vdir    as char.

def temp-table wetique
    field wrec as recid
    field wqtd as int /*like estoq.estatual*/ format ">>>9"
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

find first wetique no-error.
if not avail wetique
then leave.

message "Gerar Arquivo de Etiquetas?" update sresp.
if sresp
then do:
    if opsys = "UNIX"
    then do:
        vdir = "/admcom/zebra/02/".
        varquivo = vdir + "eti-02.bat".
/***
        if search(varquivo) <> ?
        then do:
***/
            unix silent value("rm -f " + varquivo).
            unix silent value("rm -f " + vdir + "c*.*").
/***
        end.
***/
        unix silent value("rm -f " + vdir + "02.zip").
        unix silent value("rm -f " + vdir + "02.ZIP").

        output to value(vdir + "zipa.sh").
        put unformatted "cd " vdir skip.
        put unformatted "zip -q " vdir 
                "02.zip c*.* eti-02.bat *.GRF PKUNZIP.EXE UZIPA-01.BAT".
        output close.
        unix silent value("chmod 777 " + vdir + "zipa.sh").
    end.
    else do:
        varquivo = "l:~\zebra~\02~\eti-02.bat".
    
        if search(varquivo) <> ?
        then do:
            dos silent del l:~\zebra~\02~\eti-02.bat.
            dos silent del l:~\zebra~\02~\c*.* .
        end.        
    end.
    /**
    if search("l:\zebra\02\eti-02.bat") <> ?
    then do:
        dos silent del l:\zebra\02\eti-02.bat.
        dos silent del l:\zebra\02\c*.* .
    end.
    **/
    
    for each wetique:
        run /*etisp_9.p*/ etinv02b.p (input wetique.wrec,
                     input wetique.wqtd,
                     input wetique.wtaman,
                     "02").
    end.
    if opsys = "UNIX"
    then unix silent value("/admcom/zebra/02/zipa.sh").
end.

