def input parameter vopc as log.
def input parameter vmovtdc like tipmov.movtdc.
def input parameter p-procod like produ.procod.
def output parameter vpis as dec.
def output parameter vcofins as dec.    
    
def var aux-uf as char init "RS".
find produ where produ.procod = p-procod no-lock no-error.
if avail produ
then do:
    find forne where forne.forcod = produ.fabcod no-lock no-error.
    if avail forne
    then aux-uf = forne.ufecod.
    
    if vopc = yes
    then assign vpis = 0.65  
                vcofins = 3.0.
    else do:           
        if vmovtdc = 4 and aux-uf = "AM"
        then assign vpis    = 1
                    vcofins = 4.6.     
        else if produ.codfis = 0
             then assign vpis = 1.65
                         vcofins = 7.6.  
             else do:
                  find clafis where clafis.codfis = produ.codfis 
                        no-lock no-error.
                  if not avail clafis
                  then assign vpis = 0
                              vcofins = 0.
                  else do:
                       if vmovtdc <> 5
                       then assign vpis    = clafis.pisent
                                   vcofins = clafis.cofinsent.
                       else assign vpis    = clafis.pissai
                                   vcofins = clafis.cofinssai.
                  end.                 
             end.
    end.
end.     