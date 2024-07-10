
find first tbcntgen where 
          tbcntgen.tipcon = 6 and
          tbcntgen.etbcod = estab.etbcod and
          tbcntgen.numfim = "0" and   
          tbcntgen.numini = string(produ.clacod) and
          tbcntgen.datini <= {1} and
         (tbcntgen.datfim = ? or 
          tbcntgen.datfim >= {1})    
          no-lock no-error.
if not avail tbcntgen
then find first tbcntgen where 
          tbcntgen.tipcon = 6 and
          tbcntgen.etbcod = 0 and
          tbcntgen.numfim = "0" and   
          tbcntgen.numini = string(produ.clacod) and
          tbcntgen.datini <= {1} and
         (tbcntgen.datfim = ? or 
          tbcntgen.datfim >= {1})    
          no-lock no-error.
if not avail tbcntgen
then find first tbcntgen where 
          tbcntgen.tipcon = 6 and
          tbcntgen.etbcod = estab.etbcod and
          tbcntgen.numfim = string(produ.procod) and   
          tbcntgen.numini = "0" and
          tbcntgen.datini <= {1} and
         (tbcntgen.datfim = ? or 
          tbcntgen.datfim >= {1})    
          no-lock no-error.
if not avail tbcntgen
then find first tbcntgen where 
          tbcntgen.tipcon = 6 and
          tbcntgen.etbcod = 0 and
          tbcntgen.numfim = string(produ.procod)  and
          tbcntgen.datini <= {1} and
         (tbcntgen.datfim = ? or 
          tbcntgen.datfim >= {1}) 
           no-lock no-error.
            
           