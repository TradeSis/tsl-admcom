/*  Nao colocar admcab.i
    Calcular Pis/Cofins de uma NFE/CTE
*/

def input parameter par-rec as recid.

def buffer bmovim for movim.

def var vbasepiscof as dec.
def var vcstpiscof  as int.
def var vpis        as dec.
def var vcofins     as dec.
def var valiqpis    as dec.
def var valiqcofins as dec.
def var vnotpis     like plani.notpis.
def var vnotcofins  like plani.notcofins.

find plani where recid(plani) = par-rec no-lock.

do on error undo.
    find tipmov of plani no-lock.
    if plani.movtdc = 5
    then find opcom where opcom.opccod = "5102" no-lock no-error.
    else find opcom where opcom.opccod = string(plani.opccod) no-lock no-error.
    if not avail opcom
    then return.

    for each movim where movim.etbcod = plani.etbcod
                     and movim.placod = plani.placod
                     and movim.movtdc = plani.movtdc
                     no-lock.
        run piscofins.
        find first bmovim of movim exclusive no-wait no-error.
        if avail bmovim
        then assign
                bmovim.movbpiscof   = vbasepiscof
                bmovim.movpis       = vpis
                bmovim.movcofins    = vcofins
                bmovim.movalpis     = valiqpis
                bmovim.movalcofins  = valiqcofins
                bmovim.movcstpiscof = vcstpiscof.
            
        vnotpis      = vnotpis    + vpis.
        vnotcofins   = vnotcofins + vcofins.
    end.

    find current plani exclusive no-wait no-error.
    if not locked plani
    then assign
            plani.notpis      = vnotpis
            plani.notcofins   = vnotcofins.
end.

procedure piscofins.

    def var vclfcod    as int.
    def var vdobem     as log.

    assign
        vpis        = 0
        vcofins     = 0
        vcstpiscof  = 0
        valiqpis    = 0
        valiqcofins = 0
        vbasepiscof = 0.

if opcom.piscofins
then do.
    find produ of movim no-lock no-error.
    if avail produ and produ.proipiper = 98 /* Servicos */
    then return.

    vbasepiscof = (movim.movpc * movim.movqtm) + movim.movipi.

    if avail produ
    then do:
    find clafis where clafis.codfis = produ.codfis no-lock no-error.
    if not avail clafis
    then assign
            valiqpis    = 1.65
            valiqcofins = 7.6.
    else do:
        if tipmov.tipemite or
           tipmov.movtvenda
        then assign
                valiqpis    = clafis.pissai
                valiqcofins = clafis.cofinssai.
        else assign
                valiqpis    = clafis.pisent
                valiqcofins = clafis.cofinsent.
    end.
    if tipmov.movtcompra
    then do.
        if tipmov.movtnota
        then vclfcod = plani.desti. /* Emite  */
        else vclfcod = plani.emite. /* Digita */

        find forne where forne.forcod = vclfcod no-lock no-error.
        if avail forne and forne.ufecod = "AM"
        then assign
                valiqpis    = 1
                valiqcofins = 4.6.

        if avail clafis and clafis.log1 /* Monofásico */
        then assign
                valiqpis    = 0
                valiqcofins = 0.
    end.

    if valiqpis > 0
    then vcstpiscof = opcom.cstpiscofins.
    else vcstpiscof = opcom.cstpiscofinsA0.

    if avail clafis and tipmov.movtvenda
    then do.
        if clafis.log1 /* Monofásico */
        then do.
            if tipmov.movtdev
            then vcstpiscof = 98.
            else vcstpiscof = 4.
            assign
                valiqpis    = 0
                valiqcofins = 0.
        end.
        vdobem = no.
        
        /****
        if clafis.codfis = 84715010 and
           movim.movpc <= 2000
        then vdobem = yes.

        if (clafis.codfis = 84713012 or
            clafis.codfis = 84713019 or
            clafis.codfis = 84713090) and 
           movim.movpc <= 4000
        then vdobem = yes.

        if (clafis.codfis > 84714100 and
            clafis.codfis < 84714199) and
           movim.movpc <= 2500
        then vdobem = yes.

        if (clafis.codfis = 85176255 or
            clafis.codfis = 85176262 or
            clafis.codfis = 85176272) and
           movim.movpc <= 200
        then vdobem = yes.

        if clafis.codfis = 85171231 and
           movim.movpc <= 1500
        then vdobem = yes.
        *****/
        
        if vdobem
        then do.
            if tipmov.movtdev
            then vcstpiscof  = 98.
            else vcstpiscof  = 6.
            assign
                valiqpis    = 0
                valiqcofins = 0.
        end.
    end.
    end.
    else  /*not avail produ*/
        assign
            valiqpis    = 1.65
            valiqcofins = 7.6.

    assign
        vpis    = round(vbasepiscof * valiqpis / 100, 2)
        vcofins = round(vbasepiscof * valiqcofins / 100, 2).
end.
else do.
    assign
        vcstpiscof = opcom.cstpiscofins.

    if plani.movtdc = 57
    then vcstpiscof = 98.
end.
            
end procedure.              

