{admcab.i}

def var vprocod like produ.procod.
def var vdata as date.
def var varquivo as char.
def var vtipo as log format "Sim/Nao".

vdata = today.
update vprocod label "Produto"
       vdata   label "Data Inicio"
       vtipo   label "Relatorio?"
       with frame ff 1 down width 80.

varquivo = "/admcom/relat/procustom-" + string(vprocod) + "."
            + string(time).
            
if vtipo
then output to value(varquivo).

def var vmovalicms like movim.movalicms.

find produ where produ.procod = vprocod no-lock.
disp produ.pronom no-label format "x(20)" with frame ff.
find clafis where clafis.codfis = produ.codfis no-lock.

pause 0 before-hide.

for each mvcusto where 
                   mvcusto.procod = vprocod and
                   mvcusto.dativig >= vdata /*and
                   mvcusto.dativig <= 07/31/14*/
                   no-lock.
    find plani where plani.movtdc = 4 and
                     plani.etbcod = mvcusto.etbcod and
                     plani.placod = mvcusto.placod and
                     plani.serie  = mvcusto.serie
                     no-lock no-error.
    find forne where forne.forcod = plani.emite no-lock no-error.
    /*if not avail forne then next.
    */
    find movim where movim.procod = mvcusto.procod and
                     movim.etbcod = mvcusto.etbcod and
                     movim.placod = mvcusto.placod and
                     movim.movtdc = 4
                     no-lock no-error.
                     
    disp 
         mvcusto.dativig      column-label "Data.Custo"
         mvcusto.estoque      column-label "E.Ant."    format ">>>,>>9.99"
         mvcusto.valctonotaf  column-label "C.Nota"    format ">>>,>>9.99"
         mvcusto.custo2       column-label "C.T.Ant"   format ">>>,>>9.99"
         mvcusto.valctotransf column-label "C.T.Atu"   format ">>>,>>9.99"
         with frame f1 no-box 1 down.

    if avail plani
    then
        disp plani.etbcod
            plani.emite
            plani.numero format ">>>>>>9"
            plani.serie  
            forne.ufecod label "UF"
            with frame f2 side-label no-box.
    if avail movim
    then do:
        if movim.movalicms = 0 and avail clafis and
                (clafis.mva_estado1 > 0 or  clafis.mva_oestado1 > 0)
        then vmovalicms = 12.
        else vmovalicms = movim.movalicms.
 
        disp movim.movpc
              movim.movqtm
              vmovalicms
            with frame f3 side-label no-box.
    end.
    if avail clafis
    then disp 
        clafis.codfis clafis.mva_estado1 format ">>9.99"
        clafis.mva_oestado1 format ">>9.99"
        clafis.perred label "%Red."
        with frame f3 width 80.

    run calculo-cto.
        
    if vtipo 
    then do:
        message mvcusto.char2.
        pause 0.
        put fill("=",120) format "x(120)".
    end.
    else 
        pause.
        
end. 
if vtipo 
then do:
    output close.
    run visurel.p(varquivo,"").
end.    
    
procedure calculo-cto:
    /*421515*/
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
def var vmovcusto as dec.
def var vcredicmsst as dec.
vmovtot = dec(acha("valprodu",mvcusto.char2)).
vmovfre = dec(acha("valfrete",mvcusto.char2)).
vmovseg = dec(acha("valseg",mvcusto.char2)).
vmovacre = dec(acha("valacre",mvcusto.char2)).
vmovipi = dec(acha("valipi",mvcusto.char2)).
vmovdacess = dec(acha("valdesp",mvcusto.char2)).
vmovdes = dec(acha("valdes",mvcusto.char2)).
vpis = dec(acha("valpis",mvcusto.char2)).
vcofins = dec(acha("valcofins",mvcusto.char2)).
vsubst = dec(acha("valsubst",mvcusto.char2)).
vicms = dec(acha("valicms",mvcusto.char2)).
vcredicmsst = dec(acha("CREDICMSST",mvcusto.char2)).

vqtd-ant = dec(acha("qtdestant",mvcusto.char1)).
vqtd-atu = dec(acha("qtdestatu",mvcusto.char1)).
vcto-ant = dec(acha("ctotraant",mvcusto.char1)).
vcto-atu = dec(acha("ctotraatu",mvcusto.char1)).

if vqtd-ant = ? then vqtd-ant = 0.
if vqtd-atu = ? then vqtd-atu = 0.
if vcto-ant = ? then vcto-ant = 0.
if vcto-atu = ? then vcto-atu = 0.

vmovcusto = vmovtot + vmovfre + vmovseg + vmovacre +
            vmovipi + vmovdacess - vmovdes.
if vsubst > 0
then vmovcusto = vmovcusto + (vsubst - vicms).              

def var vmais as char.
vmais = "(" + trim(string(vmovtot,">>>,>>9.99")) .
if vmovfre > 0
then vmais = vmais + " + " + trim(string(vmovfre,">>>,>>9.99")).
if vmovseg > 0
then vmais = vmais + " + " + trim(string(vmovseg,">>>,>>9.99")).
if vmovacre > 0
then vmais = vmais + " + " + trim(string(vmovacre,">>>,>>9.99")).
if vmovdacess > 0
then vmais = vmais + " + " + trim(string(vmovdacess,">>>,>>9.99")).
if vsubst > 0
then vmais = vmais + " + (" + trim(string(vsubst,">>>,>>9.99"))
        + " - " + trim(string(vicms,">>>,>>9.99")) + ")" .
if vmovipi > 0
then vmais = vmais + " + " + trim(string(vmovipi,">>>,>>9.99")).
vmais = vmais + ")".

def var vmenos as char.
vmenos = "(" /*"(" + trim(string(vicms,">>>,>>9.99"))*/.
if vmovdes > 0
then vmenos = vmenos + " + " + trim(string(vmovdes,">>>,>>9.99")).
/*
if vpis  > 0
then vmenos = vmenos + " + " + trim(string(vpis,">>>,>>9.99")).
if vcofins > 0
then vmenos = vmenos + " + " + trim(string(vcofins,">>>,>>9.99")) .
*/
vmenos = vmenos + ")".

def var vcustom as dec.
def var vmovqtm as dec.
vmovqtm = 0.
if avail movim
then vmovqtm = movim.movqtm.
else vmovqtm = vqtd-atu.
vcustom = ((vcto-ant * vqtd-ant) + (vmovcusto * vmovqtm))
            / vqtd-atu.
def var vcharcto as char.
vcharcto = "((" + trim(string(vcto-ant,">>>,>>9.99")) + " * " + 
    string(vqtd-ant) + ") + (" +
    trim(string(vmovcusto,">>>,>>9.99")) + " * " + 
    trim(string(vmovqtm,">>>,>>9.99")) + ")) / "  +
    string(vqtd-atu).
    
if vmais = ?
then. 
else
disp " + " + vmais format "x(78)"
     " - " + vmenos format "x(78)"
     " = " + trim(string(vmovcusto,">>>,>>9.99")) format "x(78)"
     vcharcto format "x(78)"
     " = " + trim(string(vcustom,">>>,>>9.99")) format "x(78)"
     with frame f-cal no-label
     width 80.

end procedure.
                                 
                                 
 