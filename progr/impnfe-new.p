{admcab.i}

message "USE APENAS PARA ALTERAR NFE DE LOJA, POIS ESSE MENU CONECTA NO BANCO DE DADOS DA LOJA INFORMADA!" view-as alert-box title " ATENCAO! ".

def var vetbcod like estab.etbcod.
def var vnumero like com.plani.numero format ">>>>>>>9".
def var vserie as char format "x(3)".
def var vfilial as char.

update 
        vetbcod label "Estabelecimento"
with frame f1 1 down side-label.

find estab where estab.etbcod = vetbcod no-lock no-error.
if estab.tipoLoja <> 'normal' then do:
    message "ESTABELECIMENTO INFORMADO NAO E' LOJA!" view-as alert-box title " ATENCAO! ".
    undo, retry.
end.
repeat:

    update 
            vnumero label "NFe Numero"
            vserie label "NFe Serie" 
    with frame f1.

    if vetbcod < 10 then vfilial = "filial0" + string(vetbcod).
        else vfilial = "filial" + string(vetbcod).

    message "Conectando...".

    /* ------- BANCO NFE ------- */
    if connected ("nfeloja") then disconnect nfeloja.
    connect nfe -H value(vfilial) -S sdrebnfe -N tcp -ld nfeloja no-error.
    if not connected ("nfeloja") then next.

            run impnfe-new2.p (vetbcod, vnumero, vserie).

    if connected ("nfeloja") then disconnect nfeloja.
        /* ------------------------- */

    leave.
    
end.
