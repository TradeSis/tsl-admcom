{admcab.i}
def var v-livro like forne.livcod.    
def var varquivo as char.
def var vetbcod  like estab.etbcod.
def var vdt     as date format "99/99/9999".
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.


def temp-table tt-emite
    field etbcod like estab.etbcod
    field livcod like forne.livcod.
    
    
for each tt-emite.
    delete tt-emite.
end.



input from l:\work\emite.122.
repeat:
    create tt-emite.
    import tt-emite.
end.
input close.

for each tt-emite where tt-emite.etbcod = 0:
    delete tt-emite.
end.



update vetbcod with frame f1.
find estab where estab.etbcod = vetbcod no-lock.
display estab.etbnom no-label with frame f1.
update vdti label "Data Inicial" colon 16
       vdtf label "Data Final" with frame f1 side-label width 80.




varquivo =  "m:\livros\e" +   string(year(vdti),"9999") + ".exp". 

output to value(varquivo).

    
do vdt = vdti to vdtf:
    
    for each plani where plani.movtdc = 6            and
                         plani.desti  = estab.etbcod and
                         plani.pladat = vdt no-lock:
        
            
        
        find first tt-emite where tt-emite.etbcod = plani.emite no-error.
        if not avail tt-emite 
        then next.

        if plani.numero > 999999
        then next.
        
        put plani.numero format "999999" " "
            plani.datexp format "99/99/9999"
            plani.platot format ">>>>>>>>>>9.99" 
            tt-emite.livcod format "99999" skip.  
        
 
            
    end.
        
end.    
 
output close.

    
    
    


