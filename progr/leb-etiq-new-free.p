/***********************************************************
Nome: leb-etiq-new-free.p
Descricao: menu impressao etiqueta New Free
Autor: Rafael A. (Kbase IT)
Alteracoes: Rafael A. (Kbase IT) - 29/06/2015 - Criacao
***********************************************************/

{admcab.i}

def var x as int.
def var recimp as recid.
def var fila as char format "x(20)" no-undo.

def var vtipo as char format "x(08)" extent 2 initial["Deposito","New Free"].
def var vprocod like produ.procod format ">>>>>>>9".
def var vdata as date format "99/99/9999".

def temp-table tt-etiq
    field rec as recid
    field qtd like estoq.estatual
    field taman as char format "x(3)".

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
    
    create tt-etiq.
    assign tt-etiq.rec = recid(produ).
    
    vdata = today.
    
    update tt-etiq.qtd   label "Quantidade" colon 12 
           tt-etiq.taman label "Tamanho"    colon 12
           with frame f1.
end.

find first tt-etiq no-lock no-error.
if not avail tt-etiq then leave.

message "Confirma emissao de Etiquetas" update sresp.
if sresp then do:
    display vtipo with frame f-tipo no-label centered row 10.
    choose field vtipo with frame f-tipo.

    if frame-index = 1
    then x = 1.
    else x = 2.
    
    if opsys = "UNIX" then do:
        
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress then do:
            run acha_imp.p (input recid(impress), 
                            output recimp).
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp). 
        end.
    end.
    else do:
        fila = "".
        if search("c:\temp\etique.bat") <> ?
        then do:
            dos silent del c:\temp\etique.bat.
            dos silent del c:\temp\cris*.* .
        end.
    end.
    
    for each tt-etiq no-lock:
        if x = 1 then do:
            run leb-etiq-imprime.p (input tt-etiq.rec,
                                    input tt-etiq.qtd,
                                    input tt-etiq.taman, input fila).
        end.
        else do:
            run leb-etiq-imprime.p (input tt-etiq.rec,
                                    input tt-etiq.qtd,
                                    input tt-etiq.taman, input fila).

            if opsys = "UNIX"
            then.
            else do:
                os-command silent del l:\free\free.zip.
                os-command silent pkzip -m l:\free\free.zip  l:\free\cris*.* .
            end.                
        end.    
    end.
    find first tt-etiq no-lock no-error.
    if avail tt-etiq then do:
        if opsys = "UNIX"
        then.
        else do:
            os-command silent c:\temp\etique.bat.
        end.            
    end.        
end.

for each tt-etiq no-lock:
    delete tt-etiq.
end.