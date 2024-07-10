{admcab.i}
def var vetb    like estab.etbcod.
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




varquivo =  "m:\livros\empresas\" + string(vetb,"999") + "\e" +  
            string(year(vdti),"9999") + ".exp". 


output to value(varquivo).

    
    for each fiscal where fiscal.desti = estab.etbcod  and
                          fiscal.plarec >= vdti and
                          fiscal.plarec <= vdtf no-lock by fiscal.numero:
     
        
        find forne where forne.forcod = fiscal.emite no-lock no-error.
        if not avail forne
        then next.
        
        find first tt-forne where tt-forne.forcod = forne.forcod no-error.
        if not avail tt-forne
        then next.
        
        
        if fiscal.platot < 0
        then next.

        if fiscal.numero < 0 or
           fiscal.numero > 999999
        then next.
        
        
        put fiscal.numero format "999999" " "
            fiscal.plarec format "99/99/9999"
            fiscal.platot format ">>>>>>>>>>9.99" 
            tt-forne.livcod format "99999" skip.  
        
        
    end.
        
    do vdt = vdti to vdtf:
    
        for each tipmov where tipmov.movtdc = 6 or
                              tipmov.movtdc = 15 no-lock,
            each plani where plani.movtdc = tipmov.movtdc and
                             plani.desti  = estab.etbcod  and
                             plani.pladat = vdt no-lock:
        
            
        
            find first tt-emite where tt-emite.etbcod = plani.emite no-error.
            if not avail tt-emite 
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

    
    
    


