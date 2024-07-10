def input parameter par-interface as char.

{/admcom/progr/tpalcis-wms.i}

def var varqBEGINS as char.

varqBEGINS = par-interface.
if par-interface = "CREC"
then do:
    find abaswms where abaswms.wms = "ALCIS_ESP" no-lock.
    alcis-diretorio = abaswms.diretorio + "out".
end.
if par-interface = "CONF" or
   par-interface = "EBLJ"
then do:
    find abaswms where abaswms.wms = "ALCIS_MOVEIS" no-lock.
    alcis-diretorio = abaswms.diretorio + "out".
end.
if par-interface = "FCGL"
then do:
    find abaswms where abaswms.wms = "ALCIS_MODA" no-lock.
    alcis-diretorio = abaswms.diretorio + "out".
end.    
if par-interface = "VEXM"
then do:
    find abaswms where abaswms.wms = "ALCIS_VEX" no-lock.
    alcis-diretorio = abaswms.diretorio + "out".
    varqBEGINS = "CONF".
end.    

alcis-diretorio = alcis-diretorio + "/".

def shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char 
    field Arquivo       as char initial ?
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.

def var par-listaArquivo   as char.

par-listaArquivo = "/admcom/relat/buscaarquivo." + varqBEGINS + string(time).
pause 0 .
unix silent value("ls " + alcis-diretorio + varqBEGINS + "* > " + par-listaarquivo + " 2>&1").
hide message no-pause.

input from value(par-listaArquivo) no-echo.
repeat transaction:
    create ttarq.
    ttarq.interface = par-interface.
    ttarq.diretorio = alcis-diretorio.
    import unformatted ttarq.arq.
    ttarq.arquivo = replace(ttarq.arq,alcis-diretorio,""). 
end.
input close.

for each ttarq.
    if ttarq.arq = ""
    then delete ttarq.
/*    else message "ACHOU" ttarq.interface ttarq.diretorio ttarq.arquivo.*/
end.

/*unix silent value("rm -f " + par-listaArquivo).*/
