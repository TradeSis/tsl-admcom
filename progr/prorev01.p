{admcab.i new}
def var vdti as date.
def var vdtf as date.
def var vetbcod like estab.etbcod.

def temp-table tt-produ
    field procod like produ.procod
    field etbcod like estab.etbcod
    field mes as int
    field ano as int
    field movqtm like movim.movqtm
    field movpc like movim.movpc
    field total as dec.
    
update vetbcod label " Cod. Filial"
    with frame f1 width 80 side-label.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
end.
vdti = date(if month(today) = 1 then 12 else month(today) - 1,01,
            if month(today) = 1 then year(today) - 1 else year(today)).
vdtf = date(month(today),01,year(today)) - 1.
            
update vdti at 1 label "Data Inicial"   format "99/99/9999"
       vdtf label "Data Final"          format "99/99/9999"
       with frame f1.
       
if vdti = ? or vdtf = ? or vdti > vdtf
then undo.
if day(vdtf) < 28
then undo.
if day(vdti) > 1
then undo.

for each revista where revista.datini >= vdti and
                       revista.datfim <= vdtf
                       no-lock:
      find produ where produ.procod = revista.procod no-lock.
    disp revista.procod no-label
        produ.pronom no-label
        with 1 down row 10 centered no-box color message.
    pause 0.
        
    for each movim where movim.procod = revista.procod and
                         movim.movdat >= vdti and
                         movim.movtdc = 5
                         no-lock:
        find first tt-produ where tt-produ.procod = revista.procod and
                            tt-produ.etbcod = movim.etbcod and
                            tt-produ.ano    = year(movim.movdat) and
                            tt-produ.mes    = month(movim.movdat)
                            no-error.
        if not avail tt-produ
        then do:
            create tt-produ.
            assign
                tt-produ.procod = movim.procod
                tt-produ.etbcod = movim.etbcod
                tt-produ.ano    = year(movim.movdat)
                tt-produ.mes    = month(movim.movdat)
                .
        end.
        tt-produ.movqtm = tt-produ.movqtm + movim.movqtm.
        tt-produ.movpc  = movim.movpc.
        tt-produ.total = tt-produ.total + (movim.movpc * movim.movqtm)
        .                    
    end.
end.
for each tt-produ.
disp tt-produ.
end.