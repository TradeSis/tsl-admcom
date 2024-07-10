def var vdt as date.
def var vetb as int.
    def var vv as int.

def var ii as int.
def var xx as int.
def var zz as char.
pause.



def temp-table tt-tit like fin.titulo.                              


for each lanfor:

    if lanfor.datven <> ?
    then next.


    ii = ii + 1.
    
    if ii mod 100 = 0
    then display ii with 1 down. pause 0.
    
    
    
    do vdt = 12/01/2000 to 12/31/2001:

/*        disp vdt format "99/99/9999" with 1 down. pause 0. */

  
               
    
             
        vetb = 90.       
        
        do vetb = 90 to 990:
        
           if vetb = 993 or vetb = 995 or vetb = 996 or vetb = 998 or vetb = 999                or vetbcod = 900
           then next.

            find first plani where plani.etbcod = vetb and
                                   plani.movtdc = 04   and
                                   plani.pladat = vdt and
                                   plani.numero = int(numdoc) and
                                   plani.platot = lanfor.valtit no-lock no-error.
                               
            if not avail plani
            then do:
                find first plani where plani.etbcod = vetb and
                                       plani.movtdc = 04   and
                                       plani.pladat = vdt and
                                       plani.platot = lanfor.valtit no-lock no-error.
                if avail plani
                then do:
                 
                   assign lanfor.datemi = plani.pladat
                          lanfor.datven = plani.pladat
                          lanfor.numdoc = string(plani.numero)
                          lanfor.clifor = string(plani.emite)
                          lanfor.tipope = "C"  
                          lanfor.tipdoc = "NFF" .
                     
                    
                end.    
            end.                        
            else do: 
                assign lanfor.datemi = plani.pladat 
                       lanfor.datven = plani.pladat 
                       lanfor.numdoc = string(plani.numero) 
                       lanfor.clifor = string(plani.emite) 
                       lanfor.tipope = "C"   
                       lanfor.tipdoc = "NFF" .

            end.
                                        
            
        
        end.
        
    end.
     
 
       
end.
