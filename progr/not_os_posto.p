/* 
Envia para posto de assistencia
#1 23.11.2017 - serie do tab_ini
*/
{admcab.i}

def input parameter par-rec as recid.

find etiqseq where recid(etiqseq) = par-rec no-lock.

def shared temp-table wfasstec like asstec.

def var vmovseq like movim.movseq.
def var vobs-os as char.
def var vprotot as dec.
def var p-ok    as log init no.
def var vtabini as char.
def var vetbassist as int.
def var vserie  like plani.serie.

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimaux like movimaux.
def new shared temp-table tt-etiqpla
    field oscod     like etiqpla.oscod
    field etopeseq  like etiqpla.etopeseq
    field etmovcod  like etiqpla.etmovcod.

run le_tabini.p (0, 0, "SSC-ESTABASSIST", OUTPUT vtabini).
vetbassist = int(vtabini).

if setbcod <> vetbassist /*** 416203 ***/
then do.
    message "Emitir NFE somente no SSC. Estab=" vetbassist view-as alert-box.
    return.
end.
    
find first tipmov where tipmov.movtdc = 16 no-lock.
find first opcom where opcom.movtdc = tipmov.movtdc no-lock.
find estab where estab.etbcod = vetbassist no-lock.

run le_tabini.p (estab.etbcod, 0, "NFE - SERIE", OUTPUT vserie). /* #1 */

form
    tipmov.movtdc  colon 16
    tipmov.movtnom no-label
    opcom.opccod   colon 16
    opcom.opcnom   no-label
    estab.etbcod   colon 16
    estab.etbnom
    forne.forcod   colon 16 label "Cod.Assis" validate(true, "")
    forne.fornom   no-label
    forne.ufecod   label "UF"
    tt-plani.platot colon 16
    with frame f-nf side-label row 9 centered width 80.

disp
    tipmov.movtdc
    tipmov.movtnom
    estab.etbcod
    estab.etbnom
    with frame f-nf.

do on error undo with frame f-nf.
    prompt-for forne.forcod.
    find forne where forne.forcod = input forne.forcod no-lock no-error.
    if not avail forne
    then do:
         message "Assistencia nao cadastrada".
         pause.
         undo.
    end.
    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo, retry.
    display forne.fornom forne.ufecod.
end.

    if forne.ufecod = "RS"
    then find opcom where opcom.opccod = "5915" no-lock.
    else find opcom where opcom.opccod = "6915" no-lock.
   
    do transaction:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = ?
               tt-plani.hiccod   = int(opcom.opccod)
               tt-plani.protot   = 0
               tt-plani.emite    = estab.etbcod
               tt-plani.bicms    = 0
               tt-plani.icms     = 0
               tt-plani.frete    = 0
               tt-plani.alicms   = 0
               tt-plani.descpro  = 0
               tt-plani.acfprod  = 0
               tt-plani.seguro   = 0
               tt-plani.desacess = 0
               tt-plani.ipi      = 0
               tt-plani.platot   = vprotot
               tt-plani.serie    = vserie
               tt-plani.numero   = ?
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = forne.forcod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = int(opcom.opccod)
               tt-plani.notfat   = forne.forcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.nottran  = 0
               tt-plani.outras   = 0
               tt-plani.isenta   = 0.
    end.

    vmovseq = 0.
    vobs-os = "OS:".
    for each wfasstec no-lock:
        find asstec where asstec.oscod = wfasstec.oscod no-lock.

        create tt-etiqpla.
        assign
            tt-etiqpla.oscod    = asstec.oscod
            tt-etiqpla.etopeseq = etiqseq.etopeseq
            tt-etiqpla.etmovcod = etiqseq.etmovcod.

        find produ where produ.procod = wfasstec.procod no-lock.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock.

        do transaction:
            find first tt-movim where tt-movim.etbcod = tt-plani.etbcod and
                                      tt-movim.placod = tt-plani.placod and
                                      tt-movim.movtdc = tt-plani.movtdc and
                                      tt-movim.movdat = tt-plani.pladat and
                                      tt-movim.procod = produ.procod
                         no-error.

            find first tt-movimaux where tt-movimaux.etbcod = tt-plani.etbcod
                                     and tt-movimaux.procod = produ.procod
                                     and tt-movimaux.nome_campo = "OS"
                         no-error.

            if not avail tt-movim
            then do:
                vmovseq = vmovseq + 1.
                create tt-movim.
                ASSIGN
                    tt-movim.movtdc = tt-plani.movtdc
                    tt-movim.PlaCod = tt-plani.placod
                    tt-movim.etbcod = tt-plani.etbcod
                    tt-movim.movseq = vmovseq
                    tt-movim.procod = produ.procod
                    tt-movim.movqtm = 1
                    tt-movim.movpc  = estoq.estcusto
                    tt-movim.movdat = tt-plani.pladat
                    tt-movim.MovHr  = tt-plani.horincl
                    tt-movim.desti  = tt-plani.desti
                    tt-movim.emite  = tt-plani.emite
                    tt-movim.ocnum[1] = asstec.oscod
                    tt-movim.datexp = today.

                create tt-movimaux.
                assign
                    tt-movimaux.movtdc = tt-plani.movtdc
                    tt-movimaux.etbcod = tt-plani.etbcod
                    tt-movimaux.placod = tt-plani.placod
                    tt-movimaux.procod = produ.procod
                    tt-movimaux.nome_campo  = "OS"
                    tt-movimaux.valor_campo = "OS:".
            end.
            else tt-movim.movqtm = tt-movim.movqtm + 1.

            if length(tt-movimaux.valor_campo) < 65
            then tt-movimaux.valor_campo = tt-movimaux.valor_campo +
                        string(asstec.oscod) + " ".
            else vobs-os = vobs-os + string(asstec.oscod) + " ".

            delete wfasstec.
        end.
    end.
    for each tt-movim where
             tt-movim.etbcod = tt-plani.etbcod and
             tt-movim.placod = tt-plani.placod and
             tt-movim.movtdc = tt-plani.movtdc and
             tt-movim.movdat = tt-plani.pladat
             no-lock:
        vprotot = vprotot + (tt-movim.movqtm * tt-movim.movpc).
    end.
    
    tt-plani.platot = vprotot.
    tt-plani.protot = vprotot.

disp
    opcom.opccod   colon 16
    opcom.opcnom   no-label
    tt-plani.platot colon 16
    with frame f-nf side-label row 9 centered.

if length(vobs-os) > 4 and length(vobs-os) < 400
then tt-plani.notobs[1] = vobs-os.

do on error undo.
    update
        tt-plani.notobs[1] format "x(70)" when tt-plani.notobs[1] = ""
        tt-plani.notobs[2] format "x(70)"
        tt-plani.notobs[3] format "x(70)"
        with frame f-obs overlay row 16 no-label
                title " Informações Adicionais ".
end.
run manager_nfe.p (input "os_5915",
                   input ?,
                   output p-ok).

