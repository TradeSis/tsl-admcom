
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.

def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index icla clacod.

def temp-table tt-produ
    field procod like produ.procod
    field pronom like produ.pronom
    field catcod like produ.catcod
    field clacod like produ.clacod
    index ipro procod.
    
output to /gera-embrace/crm_departamento.txt .

for each categoria no-lock:

    put categoria.catcod format ">9" ";"
        categoria.catnom format "x(30)" skip.

end.

output close.



for each produ no-lock:

    disp produ.procod with 1 down. pause 0.

    if produ.catcod <> 31 and
       produ.catcod <> 41
    then next.

    create tt-produ.
    assign tt-produ.procod = produ.procod
           tt-produ.pronom = produ.pronom
           tt-produ.catcod = produ.catcod.
       
    find clase where clase.clacod = produ.clacod no-lock.

    if clase.claordem = yes
    then do:
    
        find first bclase where bclase.clacod = clase.clasup no-lock.
        
        find first tt-clase where tt-clase.clacod = bclase.clacod no-error.
        if not avail tt-clase
        then do:
        
            create tt-clase.
            assign tt-clase.clacod = bclase.clacod
                   tt-clase.clanom = bclase.clanom.
        
        end.
        
        tt-produ.clacod = bclase.clacod.
        
    end.
    else do:
        
        find first bclase where bclase.clacod = clase.clasup no-lock.
        find first cclase where cclase.clacod = bclase.clasup no-lock.
        find first dclase where dclase.clacod = cclase.clasup no-lock.
        
        find first tt-clase where tt-clase.clacod = dclase.clacod no-error.
        if not avail tt-clase
        then do:
        
            create tt-clase.
            assign tt-clase.clacod = dclase.clacod
                   tt-clase.clanom = dclase.clanom.
        
        end.

        tt-produ.clacod = dclase.clacod.

    end.
end.


output to /gera-embrace/crm_setor.txt .
for each tt-clase:

    put tt-clase.clacod format ">>>>>9" ";"
        tt-clase.clanom format "x(30)" skip.

end.
output close.

output to /gera-embrace/crm_produtos.txt .

for each tt-produ:


    put tt-produ.procod format ">>>>>>>9" ";"
        tt-produ.pronom format "x(50)"    ";"
        tt-produ.catcod format ">9"       ";"
        tt-produ.clacod format ">>>>>9" skip.

end.

output close.


