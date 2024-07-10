
{admcab.i}

def var varquivo as char.
def var iProIni  like produ.procod.
def var iProFin  like produ.procod.

assign varquivo = "l:\relat\arqpro.csv".


update iProIni label "Prod Inicial"  form ">>>>>>>>9"
       iProFin label "Final"         form ">>>>>>>>9"
       with width 80 title "Exportacao"
            side-label 2 col 1 down.
 
output to value(varquivo).

put "Codigo"
    ";"
    "Nome"
    ";"
    "Caracteristica"
    ";"
    "Classe"
    ";"
    "Departamento"
    ";"
    "Cor"
    skip.

for each produ where
         produ.procod >= iProIni and
         produ.procod <= iProFin no-lock:

 find first clase where
            clase.clacod = produ.clacod no-lock no-error.
            

 find first categoria where
            categoria.catcod = produ.catcod no-lock no-error.



 put produ.procod form ">>>>>>>>9"
     ";"
     produ.pronom form "x(45)"
     ";"
     produ.procar form "x(45)"
     ";".
 
 if avail clase
 then put clase.clanom form "x(40)"
          ";".
 else put ""
          ";".
 if avail categoria
 then put categoria.catnom form "x(40)"
          ";".
 
 put produ.corcod
     skip.

end.

output close.

os-command silent start value(varquivo).
