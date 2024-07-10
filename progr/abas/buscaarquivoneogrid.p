/* #1 - helio.neto - 13.08.2019 - mudanca diretorio de entrada */
def input parameter par-interface as char.

def var neo-diretorio as char /* #1 init "/admcom/tmp/impabasneogrid/" */.
/*#1*/
neo-diretorio = "/InNeogrid/".  /*#1*/

def shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char 
    field Arquivo       as char initial ? format "x(30)"
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.

def var par-listaArquivo   as char.


par-listaArquivo = "/admcom/relat/find.NEO" + string(time).

/**unix silent value("find " + neo-diretorio + " -name \"" + par-interface + "*\" -print > " + par-listaArquivo).**/
pause 0.
   unix silent value("ls   " + neo-diretorio + par-interface + "* > " + par-listaarquivo + " 2>&1").
hide message no-pause.

input from value(par-listaArquivo) no-echo.
repeat transaction:
    create ttarq.
    ttarq.interface = par-interface.
    ttarq.diretorio = neo-diretorio.
    import unformatted ttarq.arq.
    ttarq.arquivo = replace(ttarq.arq,neo-diretorio,""). 
end.
input close.

for each ttarq.
    if ttarq.arq = ""
    then delete ttarq.
    else disp ttarq.
end.

/*unix silent value("rm -f " + par-listaArquivo).*/
