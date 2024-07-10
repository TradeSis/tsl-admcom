{admcab.i}
def var v-livro like forne.livcod.    
def var varquivo as char.
def var vetbcod  like estab.etbcod.
def var vetb  like estab.etbcod.
def var vdt     as date format "99/99/9999".
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.

update vetbcod with frame f1.
find estab where estab.etbcod = vetbcod no-lock.
display estab.etbnom no-label with frame f1.
update vdti label "Data Inicial" colon 16
       vdtf label "Data Final" with frame f1 side-label width 80.


def temp-table wforne
    field wforcod like forne.forcod
    field wnumero like fiscal.numero
    field wfornom like forne.fornom
    field wforcgc like forne.forcgc
    field wuf     like forne.ufecod.


def temp-table tt-forne
    field forcod like forne.forcod
    field livcod like forne.livcod.

def temp-table tt-desti
    field etbcod like estab.etbcod
    field livcod like forne.livcod.
    
    
for each tt-forne.
    delete tt-forne.
end.

for each tt-desti.
    delete tt-desti.
end.




input from l:\work\forne.122.
repeat:
    create tt-forne.
    import tt-forne.
end.
input close.

for each tt-forne where tt-forne.forcod = 0:
    delete tt-forne.
end.



input from l:\work\desti.122.
repeat:
    create tt-desti.
    import tt-desti.
end.
input close.

for each tt-desti where tt-desti.etbcod = 0:
    delete tt-desti.
end.


if vetbcod = 994
then vetb = 54.


if vetbcod = 995
then vetb = 122.


if vetbcod = 996
then vetb = 52.

if vetbcod = 997
then vetb = 51.

if vetbcod = 22
then vetb = 129.





varquivo =  "m:\livros\empresas\" + string(vetb,"999") + "\s" +  
            string(year(vdti),"9999") + ".exp". 



output to value(varquivo).
        
do vdt = vdti to vdtf:

    for each tipmov where tipmov.movtdc = 6  or 
                          tipmov.movtdc = 13 or
                          tipmov.movtdc = 14 or
                          tipmov.movtdc = 16 no-lock,
        each plani where plani.etbcod = estab.etbcod and
                         plani.pladat = vdt and
                         plani.movtdc = tipmov.movtdc no-lock:
    
            
        v-livro = 0.
        if plani.movtdc = 6
        then do:
        
            find first tt-desti where tt-desti.etbcod = plani.desti no-error.
            if not avail tt-desti
            then next.
            else v-livro = tt-desti.livcod.
            
        end.
        else do:
                
            find forne where forne.forcod = plani.desti no-lock no-error.
            if not avail forne
            then next.
        
            find first tt-forne where tt-forne.forcod = forne.forcod no-error.
            if not avail tt-forne
            then next.
            v-livro = tt-forne.livcod.
                
        end.

        
        put plani.numero format "999999" 
            plani.datexp format "99/99/9999"
            plani.platot format ">>>>>>>>>>9.99" 
            v-livro      format "99999" skip.
        
    end.
end.    
 
output close.

    
    
    


