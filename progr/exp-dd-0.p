def var vdir as char init "/admcom/joao/".
def var vdata as date.

/* update vdir label "Diretorio de arquivos"   format "x(50)"
    with frame f1 1 down side-label.

*/

def var varquivo as char.


message "Aqui". pause.

varquivo = vdir + "classes.txt".
/* disp "Gerando arquivo " varquivo format "x(50)"  string(time,"hh:mm")
    with frame f2 1 down row 10 centered no-label no-box. */

output to value(varquivo). 
for each clase no-lock:
    put clase.clacod ";" clase.clanom skip.
end.    
output close.

varquivo = vdir + "fabricantes.txt".
/*disp "Gerando arquivo " varquivo format "x(50)" string(time,"hh:mm")
     with frame f4 1 down  centered no-label no-box.*/

output to value(varquivo). 
for each fabri no-lock:
    put fabri.fabcod ";" fabri.fabnom ";" fabri.fabfant skip.
end.    
output close.

varquivo = vdir + "produtos.txt".
/*
disp "Gerando arquivo " varquivo format "x(50)"  string(time,"hh:mm")
     with frame f5 1 down  centered no-label no-box.
*/
def var vestoq as int.
def var vdtultcmp as date.
def var vultcmp as char.

/**********

output to value(varquivo). 
for each produ no-lock:
    vestoq = 0.
    find first estoq where estoq.procod = produ.procod and
                 estoq.estatual > 0 no-lock no-error.
    if avail estoq
    then vestoq = 1.   
    find last movim where movim.movtdc = 4 and
                          movim.procod = produ.procod no-lock no-error.
    if avail movim
    then vdtultcmp = movim.movdat.
    else vdtultcmp = ?.
    vultcmp = "".
    if vdtultcmp <> ?
    then do:
        vultcmp = string(year(vdtultcmp),"9999") + "-" +
                  string(month(vdtultcmp),"99") + "-" +
                  string(day(vdtultcmp),"99"). 
    end.
    vdata = today.

    put    produ.procod format ">>>>>>>>9" ";"
           produ.catcod ";"
           produ.pronom ";"
           produ.clacod format "->>>>>>9" ";"
           vdata format("99/99/9999") ";"
           string(time,"hh:mm:ss") ";"
           produ.fabcod format ">>>>>>>>9" ";"
           vestoq format "9" ";"
           vultcmp format "x(10)" skip.
end.    
output close.

*******/


/*
varquivo = "Estoques".


disp "Gerando arquivo " varquivo  format "x(50)"  string(time,"hh:mm")
     with frame f6 1 down  centered no-label no-box.
*/
message "estou aqui". pause.

for each estab where estab.etbcod = 995 no-lock:

/*    message "Filial: " estab.etbcod . pause 0. */


    varquivo = vdir + "est" + string(estab.etbcod,"999") + ".txt".
    
    message varquivo.
    output to value(varquivo).
       
    for each estoq where estoq.etbcod = estab.etbcod no-lock:
    
        vdata = today.
                       
        put    estoq.etbcod   ";"
               estoq.procod format ">>>>>>99" ";"
               estoq.estatual format "->>>>>9.99" ";"
               estoq.estvenda ";"
               vdata format("99/99/9999") ";"
               string(time,"hh:mm:ss") ";"
               estoq.estcusto ";" /* skip */
            .
            
        find last movim use-index datsai 
                     where movim.procod = estoq.procod
                       and movim.movtdc = 4 
                     and movim.movdat < today
                       no-lock no-error.
        if avail movim then put movim.movpc.
        put ";".
        find prev movim where movim.procod = estoq.procod
                          and movim.movtdc = 4 no-lock no-error.
        if avail movim then put movim.movpc.
        put ";" skip.                        


    end.
    output close.
end.    
/*
disp "Arquivos gerados          " string(time,"hh:mm")
    with frame f7 1 down centered no-label no-box.
*/


