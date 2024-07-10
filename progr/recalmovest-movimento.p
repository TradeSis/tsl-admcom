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
DEF VAR VMOVTDC LIKE PLANI.MOVTDC.
update vetbcod label "Filial" 
    with frame f-data
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
     
update vmovtdc at 1 with frame f-data.
update vdata1 at 1 label "Periodo" 
       vdata2 no-label with frame f-data.

sparam = "MOVIMENTO=SIM" +
         "|MOVTDC=" + STRING(VMOVTDC) +
         "|ETBCOD=" + string(vetbcod) +
         "|DATAINCLUINI=" + string(vdata1) +
         "|DATAINCLUFIM=" + string(vdata2) +
         "|DATAINICIO=01/01/2000" +
         "|ATUALIZAR=SIM" + 
         "|".
         
run removest20142.p.

sparam = "".

return.
