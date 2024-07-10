/***********************************************************
Nome: leb-etiq-call.p
Descricao: menu impressao etiqueta Call
Autor: Rafael A. (Kbase IT)
Alteracoes: Rafael A. (Kbase IT) - 29/06/2015 - Criacao
***********************************************************/

{admcab.i}

def var vprocod  like produ.procod format ">>>>>>>9".
def var varquivo as char.
def var vdir     as char.

def var fila     as char format "x(20)" no-undo.
def var recimp   as recid.

def temp-table tt-etiq
    field rec as recid
    field qtd as int format ">>>9"
    field taman as char format "x(3)".

repeat on error undo, leave:
    update vprocod colon 12 with frame f1 side-label width 80 row 4.
    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do:
        message "Produto nao Cadastrado".
        undo, retry.
    end.

    display produ.pronom no-label with frame f1.
    
    create tt-etiq.
    assign tt-etiq.rec = recid(produ).
    
    update tt-etiq.qtd   label "Quantidade" colon 12 
           tt-etiq.taman label "Tamanho"    colon 12
           with frame f1.
end.

find first tt-etiq no-lock no-error.

if not avail tt-etiq then leave.

message "Gerar Arquivo de Etiquetas?" update sresp.
if sresp then do:
    if opsys = "UNIX" then do:
        vdir = "/admcom/zebra/05/".
        varquivo = vdir + "eti-05.bat".

        unix silent value("rm -f " + varquivo).
        unix silent value("rm -f " + vdir + "c*.*").

        unix silent value("rm -f " + vdir + "05.zip").
        unix silent value("rm -f " + vdir + "05.ZIP").

        output to value(vdir + "zipa.sh").
        
        put unformatted "cd " vdir skip.
        put unformatted "zip -q " vdir 
                "05.zip c*.* eti-05.bat *.GRF PKUNZIP.EXE UZIPA-01.BAT".
        
        output close.
        
        unix silent value("chmod 777 " + vdir + "zipa.sh").
    end.
    else do:
        varquivo = "l:~\zebra~\05~\eti-05.bat".
    
        if search(varquivo) <> ?
        then do:
            dos silent del l:~\zebra~\05~\eti-05.bat.
            dos silent del l:~\zebra~\05~\c*.* .
        end.        
    end.
    
    /* carrega fila */
    if opsys = "UNIX" then do:
        
        message "Deseja imprimir etiquetas?" update sresp.
        if sresp then do:
            find first impress where impress.codimp = setbcod no-lock no-error.
            if avail impress then do:
                run acha_imp.p (input recid(impress),
                                output recimp).
                                                
                find impress where recid(impress) = recimp no-lock no-error.
                assign fila = string(impress.dfimp).
            end.
        end.
    end.
    else do:
        fila = "".
        if search("c:\temp\etique.bat") <> ? then do:
            dos silent del c:\temp\etique.bat.
            dos silent del c:\temp\cris*.* .
        end.
    end.
    
    for each tt-etiq:
        run leb-etiq-imprime05.p (input tt-etiq.rec,
                                input tt-etiq.qtd,
                                input tt-etiq.taman, input fila).
    end.
    
    find first tt-etiq no-lock no-error.
    if avail tt-etiq then do:
        if opsys = "UNIX"
        then.
        else do:
            os-command silent c:\temp\etique.bat.
        end.
    end.
    
    if opsys = "UNIX" then unix silent value("/admcom/zebra/05/zipa.sh").
end.

for each tt-etiq no-lock:
    delete tt-etiq.
end.
