{admcab.i new}
def var vprocod like produ.procod.

update vprocod with frame f1 1 down
        side-label width 80.
        
find produ where produ.procod = vprocod no-lock no-error.
if not avail produ then undo.
        
disp produ.pronom no-label with frame f1.

def temp-table tt-mvcusto like mvcusto
    index i1 dativig descending.


for each mvcusto where mvcusto.procod = produ.procod no-lock:
    create tt-mvcusto.
    buffer-copy mvcusto to tt-mvcusto.
end.
    
form with frame f-linha down.
{setbrw.i}

a-seeid = -1.
a-recid = -1.

form tt-mvcusto.dativig column-label "Data Custo"
     tt-mvcusto.valctomed column-label "Custo Medio"
     tt-mvcusto.valctonota column-label "Custo Nota"
     tt-mvcusto.estoque column-labe "Estoque Custo"
     with frame f-linha down.
     
{sklcls.i
    &file = tt-mvcusto
    &cfield = tt-mvcusto.dativig
    &noncharacter = /*
    &ofield = " tt-mvcusto.valctomed
                tt-mvcusto.valctonota
                tt-mvcusto.estoque
              "
    &where = " use-index i1 "
    &form  = " frame f-linha "
}               
