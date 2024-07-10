def input parameter par-interface as char.

def var edi-diretorio as char.
def var varqBEgINS   as char.

varqBEGINS = par-interface. 

/*
if par-interface = "ordrsp" or
   par-interface = "PROCNFE"
 then edi-diretorio = "/EDI_NeogridClient/in/".
 else edi-diretorio = "/admcom/tmp/edi/neogrid/".
*/

edi-diretorio = "/EDI_NeogridClient/in/". /* 29.10.19 */


def shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char 
    field Arquivo       as char initial ?
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.

def var par-listaArquivo   as char.

par-listaArquivo = "/admcom/relat/buscaarquivo." + varqBEGINS + string(time).
pause 0 .
unix silent value("ls " + edi-diretorio + varqBEGINS + "* > " + par-listaarquivo + " 2>&1").
hide message no-pause.

input from value(par-listaArquivo) no-echo.
repeat transaction:
    create ttarq.
    ttarq.interface = par-interface.
    ttarq.diretorio = edi-diretorio.
    import unformatted ttarq.arq.
    ttarq.arquivo = replace(ttarq.arq,edi-diretorio,""). 
end.
input close.

for each ttarq.
    if ttarq.arq = ""
    then delete ttarq.
/*    else message "ACHOU" ttarq.interface ttarq.diretorio ttarq.arquivo.*/
end.

unix silent value("rm -f " + par-listaArquivo).
