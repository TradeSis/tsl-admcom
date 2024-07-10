def temp-table tt-plani 
    field etbcod like estab.etbcod
    field pladat like com.plani.pladat
    field platot like com.plani.platot
    index i1 etbcod pladat.
    
def temp-table tt-tabdac like tabdac.
def temp-table tt-venda like tabdicem.
def temp-table tt-receb like tabdicre.
def var p-sitlan as char.
def var vtitvlcob as dec.

def var vlvist as dec.
def var v-descarta as log.
def var vcontnum like contratodd.cont-num.
def var vdti as date.
def var vdtf as date.
def var vdifer as dec.
vdifer = 0.
def var vtotplani as dec.
def var vatu as log.
def var vpct as dec.
def var vsel-tot as dec.
def var vtotal as dec format ">>>,>>>,>>9.99".
def var vdata as date.

update vdti vdtf vdifer format ">>>,>>>,>>9.99" vatu vpct.

vtotal = 0.

p-sitlan = "LEBES".

for each contratodd where
         contratodd.dtinicial >= vdti and
         contratodd.dtinicial <= vdtf
         :

    find first tabdac where
         tabdac.etbcod = contratodd.etbcod and
         tabdac.clicod = contratodd.clicod and
         tabdac.numlan = string(contratodd.cont-num) and
         tabdac.parlan = ? and
         tabdac.datemi = contratodd.dtinicial and
         tabdac.tiplan = "EMISSAO" and
         tabdac.sitlan = p-sitlan
         no-error.
    if avail tabdac
    then do:
        find first tabdicem where
               tabdicem.etbcod = contratodd.etbcod and
               tabdicem.datref = contratodd.dtinicial
               no-error.
        if avail tabdicem
        then do:
            vtotal = vtotal + tabdac.vallan.
            
            if vatu
            then do:
            assign
            tabdicem.venda_prazo_adicional = tabdicem.venda_prazo_adicional -
                tabdac.vallan
            tabdicem.venda_prazo_lebes = tabdicem.venda_prazo_lebes -
                tabdac.vallan.
            end.
        end.
        if vatu then
        delete tabdac.
    end.
    if vatu then delete contratodd.
end.
disp vtotal. pause.
