{admcab.i new}
def buffer bhiest for hies.
def var vetbcod like estab.etbcod.
def var vdata1 as date.
def var vdata2 as date.
def var vdtaux as date.
def var vprocod like produ.procod.
def var vsal-ant as dec.
def var vsal-ent as dec.
def var vsal-sai as dec.
def var vsal-atu as dec.
def var vest-atu as dec.
vetbcod = 0.
vdata1 = today.
vdata2 = today.
update vetbcod label "Filial" with frame f-data
    side-label 1 down width 80 .
find estab where estab.etbcod = vetbcod no-lock no-error.
if not avail estab
then do:
    bell.
    message color red/with
    "Estabelecimento nao cadastrado"
    view-as alert-box.
    return.
end.
disp estab.etbnom no-label with frame f-data.
     
update vprocod  at 1 format ">>>>>>>9" with frame f-data.

find produ where produ.procod = vprocod no-lock no-error.
if not avail produ 
then do:
    bell.
    message color red/with
     "Produto nao cadatrado"
     view-as alert-box.
    return.
end.     

disp produ.pronom no-label with frame f-data.

sparam = "PRODUTO=SIM" +
         "|PROCOD=" + STRING(vprocod) +
         "|ETBCOD=" + string(vetbcod) +
         "|DATAINICIO=01/01/2000" +
         "|CONFIRMAR=SIM" + 
         "|ATUALIZAR=SIM" +
         "|".
         
run removest20142.p.

sparam = "".

return.
