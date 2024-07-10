def input parameter vetbcod like estab.etbcod.
def input parameter vrecmov as recid.
def input-output parameter vestatual like estoq.estatual.

def var vtipo as char init "I".

find movim where recid(movim) = vrecmov  no-error.
 
find produ where produ.procod = movim.procod no-lock no-error.

find first plani where     plani.etbcod = movim.etbcod and
                           plani.placod = movim.placod and
                           plani.movtdc = movim.movtdc and
                           plani.pladat = movim.movdat no-lock no-error.

if movim.movtdc = 6 or movim.movtdc = 3
then do:

    
    if plani.emite = vetbcod
    then vestatual = vestatual - movim.movqtm.
    if plani.desti = vetbcod and
       plani.etbcod <> plani.desti 
    then vestatual = vestatual + movim.movqtm.

end.

    
    /********************** INICIO ENTRADA **********************/
def var vqtdest-ant as dec.
def var vctomed-ant as dec.
def var vqtdest-atu as dec.
def var vctomed-atu as dec.
def var vpis as dec.
def var vcofins as dec.

if movim.movtdc = 4 or
   movim.movtdc = 1 or
   movim.movtdc = 7 or
   movim.movtdc = 12 or
   movim.movtdc = 15 or
   movim.movtdc = 17
then do:
    
    if plani.etbcod = vetbcod
    then vestatual = vestatual + movim.movqtm.

end.

    /*********************** INICIO SAIDA ***********************/
if movim.movtdc = 5 or
   movim.movtdc = 13 or
   movim.movtdc = 14 or
   movim.movtdc = 16 or
   movim.movtdc = 8  or
   movim.movtdc = 18 or
   movim.movtdc = 26
then do:

    if plani.etbcod = vetbcod
    then vestatual = vestatual - movim.movqtm.

end.









