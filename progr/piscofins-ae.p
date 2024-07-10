/* Calcular Pis/Cofins/Subst de uma NFE/CTE */

def shared temp-table tt-plani no-undo like plani.
def shared temp-table tt-movim no-undo like movim.

def var vbasepiscof as dec.
def var vcstpiscof  as int.
def var vpis        as dec.
def var vcofins     as dec.
def var valiqpis    as dec.
def var valiqcofins as dec.
def var vnotpis     like plani.notpis.
def var vnotcofins  like plani.notcofins.
def var vmovbsubst  like movim.movbsubst.
def var vmovsubst   like movim.movsubst.
def var vnotbsubst  like plani.bsubst.
def var vnotisubst  like plani.icmssubst.


find first tt-plani no-lock.
def var vopccod like plani.opccod.
do on error undo.
    find tipmov of tt-plani no-lock.
    if tipmov.movtdc = 5
    then vopccod = 5102.
    else vopccod = tt-plani.opccod.
    find opcom where opcom.opccod = string(vopccod) no-lock no-error.
    if not avail opcom
    then return.

    for each tt-movim.
        run piscofins.
        assign
            tt-movim.movbpiscof  = vbasepiscof
            tt-movim.movpis      = vpis
            tt-movim.movcofins   = vcofins
            tt-movim.movalpis    = valiqpis
            tt-movim.movalcofins = valiqcofins
            tt-movim.movcstpiscof = vcstpiscof
            vnotpis      = vnotpis    + vpis
            vnotcofins   = vnotcofins + vcofins.

        if tipmov.movtlin
        then assign
                tt-movim.movbsubst = vmovbsubst * tt-movim.movqtm
                tt-movim.movsubst  = vmovsubst  * tt-movim.movqtm
                vnotbsubst = vnotbsubst + tt-movim.movbsubst
                vnotisubst = vnotisubst + tt-movim.movsubst.
    end.
    find current tt-plani exclusive.
    assign
        tt-plani.notpis      = vnotpis
        tt-plani.notcofins   = vnotcofins.

    if tipmov.movtlin
    then assign
        tt-plani.bsubst      = vnotbsubst
        tt-plani.icmssubst   = vnotisubst.
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
    vbasepiscof = (tt-movim.movpc * tt-movim.movqtm) + tt-movim.movipi.

    find produ of tt-movim no-lock.
    find clafis where clafis.codfis = produ.codfis no-lock no-error.
    if not avail clafis
    then
        assign
            valiqpis    = 1.65
            valiqcofins = 7.6.
    else
        if tipmov.tipemite or
           tipmov.movtvenda
        then assign
                valiqpis    = clafis.pissai
                valiqcofins = clafis.cofinssai.
        else assign
                valiqpis    = clafis.pisent
                valiqcofins = clafis.cofinsent.

    if valiqpis > 0
    then vcstpiscof = opcom.cstpiscofins.
    else vcstpiscof = opcom.cstpiscofinsA0.

    if tipmov.movtcompra
    then do.
        if tipmov.movtnota
        then vclfcod = tt-movim.desti. /* Emite  */
        else vclfcod = tt-movim.emite. /* Digita */

        find forne where forne.forcod = vclfcod no-lock no-error.
        if avail forne and forne.ufecod = "AM"
        then
            assign
                valiqpis    = 1
                valiqcofins = 4.6.
 
        run cal-mva-entrada.
     end.

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

        /**********
        if clafis.codfis = 84715010 and
           tt-movim.movpc <= 2000
        then vdobem = yes.

        if (clafis.codfis = 84713012 or
            clafis.codfis = 84713019 or
            clafis.codfis = 84713090) and 
           tt-movim.movpc <= 4000
        then vdobem = yes.

        if (clafis.codfis > 84714100 and
            clafis.codfis < 84714199) and 
           tt-movim.movpc <= 2500
        then vdobem = yes.

        if (clafis.codfis = 85176255 or
            clafis.codfis = 85176262 or
            clafis.codfis = 85176272) and
           tt-movim.movpc <= 200
        then vdobem = yes.

        if clafis.codfis = 85171231 and
           tt-movim.movpc <= 1500
        then vdobem = yes.
        ***************/
        
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

    assign
        vpis    = round(vbasepiscof * valiqpis    / 100, 2)
        vcofins = round(vbasepiscof * valiqcofins / 100, 2).
end.
else do.
    assign
        vcstpiscof = opcom.cstpiscofins.

    if tt-plani.movtdc = 57
    then vcstpiscof = 98.
end.

end procedure.              

procedure cal-mva-entrada:
    def var vmovtot as dec.
    def var vmovfre as dec.
    def var vmovseg as dec.
    def var vmovacre as dec.
    def var vmovipi as dec.
    def var vmovdacess as dec.
    def var vmovdes as dec.
    def var vmovacf as dec.
    def var vmovcusto as dec.
    def var vicms as dec.
    def var vicmssubst as dec.
    
    assign 
            vmovtot = tt-movim.movpc
            vmovfre = if tt-movim.movdev > 0 then tt-movim.movdev
                      else if tt-plani.frete > 0
                           then (tt-plani.frete / tt-plani.protot) * vmovtot
                           else 0 
            vmovseg = if tt-plani.seguro > 0
                      then (tt-plani.seguro / tt-plani.protot) * vmovtot
                      else 0
            vmovacre = if tt-plani.acfprod > 0
                       then (tt-plani.acfprod / tt-plani.protot) * vmovtot
                       else 0
            vmovipi  = if tt-movim.movipi > 0
                       then tt-movim.movipi / tt-movim.movqtm
                       else 0
            vmovdacess = if tt-plani.desacess > 0
                    then (tt-plani.desacess / tt-plani.protot) * vmovtot
                    else 0
            vmovdes = if tt-movim.movdes > 0  then tt-movim.movdes
                      else if tt-plani.descprod > 0
                           then (tt-plani.descprod / tt-plani.protot) * vmovtot
                           else 0
            vmovsubst = if tt-movim.movbsubst > 0 and
                           tt-movim.movsubst  > 0
                        then tt-movim.movsubst
                        else 0
            vicms =  if tt-movim.movalicms > 0
                     then vmovtot * (tt-movim.movalicms / 100)
                     else 0
            vmovcusto = vmovtot + vmovfre + vmovseg + vmovacre +
                        /*vmovipi +*/ vmovdacess - vmovdes  .

        
        if forne.ufecod = "RS"
        then do:
            if avail clafis and
                     clafis.mva_estado1 > 0
            then vmovbsubst = vmovcusto + 
                             ((vmovcusto * clafis.mva_estado1) / 100).
                             
        end.
        else do:
            if avail clafis and
                     clafis.mva_oestado1 > 0
            then vmovbsubst = vmovcusto + 
                             ((vmovcusto * clafis.mva_oestado1) / 100).
        end.             
        if vmovbsubst = 0 and tt-movim.movbsubst > 0
        then vmovbsubst = tt-movim.movbsubst / tt-movim.movqtm.
        if vmovbsubst = 0 and tt-plani.icmssubst > 0
        then vmovbsubst = (tt-plani.icmssubst / tt-plani.protot) * vmovtot.
 
        if vmovbsubst > 0
        then vmovsubst = vmovbsubst * .17.
        else vmovsubst = 0.
        if vmovsubst = 0 and tt-movim.movsubst > 0
        then vmovsubst = tt-movim.movsubst / tt-movim.movqtm.
end procedure.

