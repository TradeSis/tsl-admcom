{admcab.i}
def var vetb like estab.etbcod.
def var varquivo as char.
def var outras-icms as dec format "->>>,>>9.99".
def var vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     as date format "99/99/9999".
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def stream sarq.

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

def var d-dtini     as   date init today                            no-undo.
def var i-nota      like fiscal.numero                               no-undo.
def var i-seq       as   int format ">>>9"                          no-undo.
def var vcgc as char format "xx.xxx.xxx/xxxx-xx".
def var vemp as int.

def temp-table tt-forne
    field forcod like forne.forcod
    field livcod like forne.livcod.
    
    
for each tt-forne.
    delete tt-forne.
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


def temp-table tt-emite
    field etbcod like estab.etbcod
    field livcod like forne.livcod.
    
    
for each tt-emite.
    delete tt-emite.
end.



input from l:\work\estab.122.
repeat:
    create tt-emite.
    import tt-emite.
end.
input close.

for each tt-emite where tt-emite.etbcod = 0:
    delete tt-emite.
end.


vetb = vetbcod.

if vetbcod = 21
then vetb = 128.

if vetbcod = 22
then vetb = 129.


if vetbcod = 23
then vetb = 137.


if vetbcod = 31
then vetb = 130.


if vetbcod = 35
then vetb = 139.


if vetbcod = 43
then vetb = 123.


if vetbcod = 44
then vetb = 124.


if vetbcod = 45
then vetb = 125.


if vetbcod = 46
then vetb = 133.


if vetbcod = 47
then vetb = 127.


if vetbcod = 48
then vetb = 126.


if vetbcod = 49
then vetb = 131.


if vetbcod = 50
then vetb = 136.


if vetbcod = 51
then vetb = 132.


if vetbcod = 52
then vetb = 135.


if vetbcod = 53
then vetb = 138.


if vetbcod = 54
then vetb = 140.


if vetbcod = 55
then vetb = 141.


if vetbcod = 56
then vetb = 142.


if vetbcod = 57
then vetb = 143.


if vetbcod = 58
then vetb = 144.


if vetbcod = 59
then vetb = 145.


if vetbcod = 19
then vetb = 134.


if vetbcod = 11
then vetb = 121.


if vetbcod = 12
then vetb = 120.


if vetbcod = 13
then vetb = 11.

if vetbcod = 994
then vetb = 54.

if vetbcod = 996
then vetb = 52.

if vetbcod = 997
then vetb = 51.

if vetbcod = 01
then vetb = 50.






varquivo =  "m:\livros\empresas\" + string(vetb,"999") + "\e" +  
            string(year(vdti),"9999") + ".exp". 

output to value(varquivo).

    
    for each fiscal where fiscal.desti = estab.etbcod  and
                          fiscal.plarec >= vdti and
                          fiscal.plarec <= vdtf no-lock by fiscal.numero:
     
        
        find first tt-emite where tt-emite.etbcod = estab.etbcod no-error.
        if not avail tt-emite 
        then next.
        
        if fiscal.numero > 999999 or
           fiscal.platot = 0
        then next.
        
        
        if fiscal.platot < 0
        then next.

        if fiscal.numero < 0 or
           fiscal.numero > 999999
        then next.
        

        
        put fiscal.numero format "999999" " "
            fiscal.plarec format "99/99/9999" 
            fiscal.platot format ">>>>>>>>>>9.99"  
            tt-emite.livcod format "99999" skip.

    end.
        
    do vdt = vdti to vdtf:
    
        for each plani where plani.movtdc = 6            and
                             plani.desti  = estab.etbcod and
                             plani.pladat = vdt no-lock:
        
            
        
            find first tt-emite where tt-emite.etbcod = plani.emite no-error.
            if not avail tt-emite 
            then next.

            if plani.numero > 999999 or
               plani.platot = 0
            then next.
 
            if plani.numero > 999999 or
               plani.numero < 0      or
               plani.platot < 0
            then next.
        
             
            put plani.numero format "999999" " "
                plani.datexp format "99/99/9999"
                plani.platot format ">>>>>>>>>>9.99" 
                tt-emite.livcod format "99999" skip.  
            
 
            
        end.
        
    end.    
 
output close.

    
    
    


