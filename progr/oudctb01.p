
def new shared temp-table tt-clien like clien.


form vdti as date format "99/99/9999" label "Periodo de"
     vdtf as date format "99/99/9999" label "Ate"
     with frame f-data 1 down centered side-label
     .

update vdti vdtf with frame f-data.
if vdti = ? or vdtf = ? or vdti > vdtf
then do:
    bell.
    message color red/with
        "Periodo invalido"
        view-as alert-box.
    undo.
end.

def var vcod as char format "x(18)".
def var varq as char.
def var sresp as log format "Sim/Nao".

def var vdata as date.
def stream stela.

output stream stela to terminal.

/**** Exportando Contas a Receber *********/

if opsys = "unix" 
then varq = "/admcom/audit/receber.txt".
else varq = "l:~\audit~\receber.txt".

    message "Confirma exportacao? " update sresp.
    if sresp = no
    then return.

form with frame f-stream 1 down centered no-box row 7 no-label.

for each titulo where   titulo.empcod   = 19 and
                        titulo.titnat    = no and 
                      titulo.titdtemi >= vdti and
                      titulo.titdtemi <= vdtf and
                      titulo.modcod    = "CRE"
                      no-lock:
    find clien where clien.clicod = titulo.clifor no-lock.
    disp stream stela 
            "Contas A Receber (C)..." at 1
            clien.clicod titulo.titnum vdata with frame f-stream.
    pause 0.
         
    put unformatted
        titulo.etbcod format ">>9"
        titulo.clifor  format ">>>>>>>>>>>>>>>>>9"
        "DUP"
        titulo.titnum format "x(12)"
        year(titulo.titdtemi) format "9999"
        month(titulo.titdtemi) format "99"
        day(titulo.titdtemi) format "99"
        clien.cidade[1] format "x(50)"
        clien.ufecod     format "!!"
        "C  "         format "!!!"
        titulo.titvlcob / 100 format "9999999999999999"
        "+"
        year(titulo.titdtemi) format "9999"
        month(titulo.titdtemi) format "99"
        day(titulo.titdtemi) format "99"
        titulo.titvlcob / 100 format "9999999999999999"
        year(titulo.titdtven) format "9999"
        month(titulo.titdtven) format "99"
        day(titulo.titdtven) format "99"
        titulo.titnum + "/" + string(titulo.titpar) format "x(12)"
        "15" format "x(28)"
        "CADASTRAMENTO" format "x(150)"
        skip
        .
    find first tt-clien where
               tt-clien.clicod = clien.clicod no-error.
    if not avail tt-clien
    then do:
        create tt-clien.
        buffer-copy clien to tt-clien.
    end.
                
end.

for each titulo where titulo.titnat    = no and 
                      titulo.titdtpag >= vdti and
                      titulo.titdtpag <= vdtf and
                      titulo.titsit = "PAG" and
                      titulo.modcod    = "CRE"
                      no-lock:
    find clien where clien.clicod = titulo.clifor no-lock.
    disp stream stela 
            "Contas A Receber (R)..." at 1
            clien.clicod titulo.titnum with frame f-stream.
    pause 0.

    put unformatted
        titulo.etbcod format ">>9"
        titulo.clifor  format ">>>>>>>>>>>>>>>>>9"
        "DUP"
        titulo.titnum format "x(12)"
        year(titulo.titdtpag) format "9999"
        month(titulo.titdtpag) format "99"
        day(titulo.titdtpag) format "99"
        clien.cidade[1] format "x(50)"
        clien.ufecod     format "!!"
        "R  "         format "!!!"
        titulo.titvlcob / 100 format "9999999999999999"
        "-"
        year(titulo.titdtemi) format "9999"
        month(titulo.titdtemi) format "99"
        day(titulo.titdtemi) format "99"
        titulo.titvlcob / 100 format "9999999999999999"
        year(titulo.titdtven) format "9999"
        month(titulo.titdtven) format "99"
        day(titulo.titdtven) format "99"
        titulo.titnum + "/" + string(titulo.titpar) format "x(12)"
        "162" format "x(28)"
        "BAIXA" format "x(150)"
        skip
        .
    find first tt-clien where
               tt-clien.clicod = clien.clicod no-error.
    if not avail tt-clien
    then do:
        create tt-clien.
        buffer-copy clien to tt-clien.
    end.
                
end.


output close.

/*** Exportando clientes ****/


if opsys = "unix" 
then varq = "/admcom/audit/clientes.txt".
else varq = "l:~\audit~\clientes.txt".

output to value(varq).

for each tt-clien,
    first clien where clien.clicod = tt-clien.clicod no-lock:

    if clien.ciccgc = ""
    then next.

    disp stream stela 
            "Cadastro P. Fisica ..." at 1
            clien.clicod clien.ciccgc with frame f-stream.
    pause 0.

    put unformatted
        clien.clicod        format "x(18)"        /* 001-018 */
        clien.ciccgc        format "x(18)"        /* 019-036 */
        clien.ciinsc        format "x(20)"        /* 037-056 */
        " "                 format "x(14)"        /* 057-070 */
        clien.clinom        format "x(70)"        /* 071-140 */
        " "                 format "x(70)"        /* 141-210 */
        clien.endereco[1]       format "x(50)"        /* 211-280 */
        string(clien.numero[1]) format "x(10)"       
        clien.compl[1]          format "x(10)"       
        clien.bairro[1]         format "x(20)"        /* 281-300 */
        clien.cidade[1]         format "x(50)"        /* 301-350 */
        clien.ufecod[1]         format "x(02)"        /* 351-352 */
        clien.cep[1]            format "x(08)"        /* 353-360 */
        "BRA"                format "x(06)"        /* 361-366 */
        "BRASIL "            format "x(20)"        /* 367-386 */
        skip.
             
             
end.
output close.
              
output stream stela close.              

return.


