{admcab.i}

def input parameter rec-mvcusto as recid.
find mvcusto where recid(mvcusto) = rec-mvcusto no-lock no-error.
def output parameter vmovcusto as dec.

def var vmovtot as dec.
def var vmovfre as dec.
def var vmovseg as dec.
def var vmovacre as dec.
def var vmovipi as dec.
def var vmovdacess as dec.
def var vmovdes as dec.
def var vpis as dec.
def var vcofins as dec.
def var vsubst as dec.
def var vicms as dec.
def var vqtd-ant as dec.
def var vqtd-atu as dec.
def var vcto-ant as dec.
def var vcto-atu as dec.
def var vcredicmsst as dec.
def var vmovii as dec.

if avail mvcusto
then assign
        vmovii = dec(acha("valii",mvcusto.char2))
        vmovtot = dec(acha("valprodu",mvcusto.char2))
        vmovfre = dec(acha("valfrete",mvcusto.char2))
        vmovseg = dec(acha("valseg",mvcusto.char2))
        vmovacre = dec(acha("valacre",mvcusto.char2))
        vmovipi = dec(acha("valipi",mvcusto.char2))
        vmovdacess = dec(acha("valdesp",mvcusto.char2))
        vmovdes = dec(acha("valdes",mvcusto.char2))
        vpis = dec(acha("valpis",mvcusto.char2))
        vcofins = dec(acha("valcofins",mvcusto.char2))
        vsubst = dec(acha("valsubst",mvcusto.char2))
        vicms = dec(acha("valicms",mvcusto.char2))
        vcredicmsst = dec(acha("CREDICMSST",mvcusto.char2))
        vqtd-ant = dec(acha("qtdestant",mvcusto.char1))
        vqtd-atu = dec(acha("qtdestatu",mvcusto.char1))
        vcto-ant = dec(acha("ctomedant",mvcusto.char1))
        vcto-atu = dec(acha("ctomedatu",mvcusto.char1))
        .

if vmovii = ? then vmovii = 0.

if vsubst = 0
then vmovcusto = vmovtot + vmovfre + vmovseg + vmovacre + vmovii
            + vmovipi + vmovdacess - vmovdes - vpis - vcofins 
             - vicms.
else vmovcusto = vmovtot + vmovfre + vmovseg + vmovacre + vmovii
            + vmovipi + vmovdacess - vmovdes - vpis - vcofins 
             + (vsubst - vicms).


