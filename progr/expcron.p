
def var varquivo as char.
def var iProIni  like produ.procod.
def var iProFin  like produ.procod.

assign varquivo = "l:\rafael\arqpro.txt".


assign iProIni = 1
       iProFin = 500000.
 
output to value(varquivo).


for each produ where
         produ.procod >= iProIni and
         produ.procod <= iProFin no-lock:

 find first clase where
            clase.clacod = produ.clacod no-lock no-error.
            

 find first categoria where
            categoria.catcod = produ.catcod no-lock no-error.

 find first fabri where
            fabri.fabcod = produ.fabcod no-lock no-error. 

 put produ.procod form ">>>>>>>>9"
     ","
     produ.pronom form "x(45)"
     ","
     produ.procar form "x(45)"
     ",".
 
 if avail clase
 then put clase.clanom form "x(40)"
          ",".
 else put space(40)
          ",".

 if avail categoria
 then put categoria.catnom form "x(40)"
      ",".
 else put space(40)
          ",".
 
 put produ.corcod
     ",".
     
 if avail fabri
 then put fabri.fabnom form "x(40)"
          "," skip.
 else put space(40)
          "," skip.

end.

output close.

