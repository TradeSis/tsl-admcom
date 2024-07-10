{admcab.i new}
  
def temp-table tt-meta
    field etbcod    as integer
    field clacod    as integer
    field clanom    as character
    field ano       as integer
    field perc      as decimal
    index idx01 etbcod
    index idx02 clacod
    index idx03 ano.
    
def var vint-ano as integer.
     
form vint-ano label "Ano" format ">>>9"
     with frame f01 title "Cadastro de metas por Setor"
            side-label centered row 4.
           
     
update vint-ano
        with frame f01.
    
for each tbmeta where tbmeta.etbcod = setbcod
                  and tbmeta.ano    = vint-ano no-lock,
                  
    first clase where clase.clacod  = tbmeta.cla-cod
                  and clase.clatipo = yes
                  and clase.clasup  = 0 no-lock.
                  
    
    create tt-meta.
    assign tt-meta.etbcod = tbmeta.etbcod
           tt-meta.clacod = tbmeta.cla-cod
           tt-meta.clanom = clase.clanom
           tt-meta.ano    = tbmeta.ano
           tt-meta.perc   = tbmeta.perc.
                  
end.                  

for each clase where clase.clatipo = yes
                 and clase.clasup  = 0
                 and not can-find (first tt-meta
                                   where tt-meta.clacod = clase.clacod)
                                                    no-lock.
                 
    create tt-meta.
    assign tt-meta.etbcod = setbcod
           tt-meta.clacod = clase.clacod
           tt-meta.clanom = clase.clanom
           tt-meta.ano    = vint-ano.
                 
end.                 

for each tt-meta no-lock by tt-meta.clacod.
 
    display tt-meta.clacod format ">>>>9" label "Cod"
            tt-meta.clanom format "x(20)" label "Classe"
            tt-meta.perc   label "Perc"
                    with frame f02 down .

end.


