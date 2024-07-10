/*
Transfere p/loja origem
Transfere para outra filial
#1 23.11.2017 - serie do tab_ini
*/
{admcab.i}

def input parameter par-rec as recid.

find etiqseq where recid(etiqseq) = par-rec no-lock.

def shared temp-table wfasstec like asstec.
def temp-table wfmovim like movim.

def var vplacod like plani.placod.
def var vnumero like plani.numero.
def var vmovseq like movim.movseq.
def var vserie  like plani.serie.
def var vprotot as dec.
def var p-ok    as log init no.
def var p-valor as char.
def var vtabini as char.
def var vetbassist as int.
def var vobs-os as char.
def buffer bestab for estab.

run le_tabini.p (0, 0, "SSC-ESTABASSIST", OUTPUT vtabini).
vetbassist = int(vtabini).

find first wfasstec no-lock no-error.
if not avail wfasstec
then return.

if setbcod <> vetbassist /*** 416203 ***/
then do.
    message "Emitir NFE somente no SSC. Estab=" vetbassist view-as alert-box.
    return.
end.

find first tipmov where tipmov.movtdc = 6 no-lock.
find opcom "5152" no-lock.

find estab where estab.etbcod = vetbassist no-lock.
find bestab where bestab.etbcod = wfasstec.etbcod no-lock.

disp
    estab.etbcod   @ plani.emite   colon 15
    estab.etbnom   no-label
    bestab.etbcod  label "Destino" colon 15
    bestab.etbnom  no-label
    tipmov.movtdc  colon 15
    tipmov.movtnom no-label
    opcom.opccod   colon 15
    opcom.opcnom   no-label
    with frame f-nf side-label.

run not_notgvlclf.p ("Estab", recid(estab), output sresp).
if not sresp
then return.

if etiqseq.etseqclf = "LOJ" or 
   etiqseq.etseqclf = "DEP"
then do with frame f-nf.
    disp 0 @ bestab.etbcod.
    prompt-for bestab.etbcod.
    find bestab where bestab.etbcod = input bestab.etbcod no-lock no-error.
    if not avail bestab or
       (input bestab.etbcod <>  65 and
        input bestab.etbcod <> 107 and
        input bestab.etbcod <> 930 and
        input bestab.etbcod <> 993 and
        input bestab.etbcod <> 998 and
        input bestab.etbcod <> 988 and
        input bestab.etbcod <> 900)
    then do.
        message "Somente estabelecimento 65, 107, 930, 993, 998, 988, 900" 
            view-as alert-box.
        return.
    end.
    disp bestab.etbnom.
end.

run not_notgvlclf.p ("Estab", recid(bestab), output sresp).
if not sresp
then return.

if estab.etbcod = bestab.etbcod
then do.
    message "Estabs sao os mesmos" view-as alert-box.
    return.
end.

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimaux like movimaux.
def new shared temp-table tt-movimimp like movimimp.
def new shared temp-table tt-etiqpla
    field oscod     like etiqpla.oscod
    field etopeseq  like etiqpla.etopeseq
    field etmovcod  like etiqpla.etmovcod.

vplacod = ?.
vnumero = ?.
run le_tabini.p (estab.etbcod, 0, "NFE - SERIE", OUTPUT vserie). /* #1 */

sresp = no.                    
message "Confirma emissao da nota fiscal?" update sresp.
if not sresp
then return.

    do on error undo:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = vplacod
               tt-plani.emite    = estab.etbcod
               tt-plani.plaufemi = estab.ufecod
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = bestab.etbcod
               tt-plani.plaufdes = bestab.ufecod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = int(opcom.opccod)
               tt-plani.notfat   = bestab.etbcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.hiccod   = int(opcom.opccod)
               tt-plani.nottran  = 0
               tt-plani.notobs[3] = "D"
               tt-plani.outras   = 0
               tt-plani.isenta   = 0.
    end.

    vmovseq = 0.
    vobs-os = "OS:".
    for each wfasstec no-lock:
        find asstec where asstec.oscod = wfasstec.oscod no-lock.
        find produ where produ.procod = wfasstec.procod no-lock.
        find estoq where estoq.procod = produ.procod
                     and estoq.etbcod = estab.etbcod
                   no-lock.
        create tt-etiqpla.
        assign
            tt-etiqpla.oscod    = asstec.oscod
            tt-etiqpla.etopeseq = etiqseq.etopeseq
            tt-etiqpla.etmovcod = etiqseq.etmovcod.

        do transaction:
            find first tt-movim where 
                       tt-movim.etbcod = tt-plani.etbcod and
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
                    tt-movim.emite  = tt-plani.emite
                    tt-movim.desti  = tt-plani.desti
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
        end.
        delete wfasstec.
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
    if length(vobs-os) > 4 and length(vobs-os) < 400
    then tt-plani.notobs[1] = vobs-os.

    run manager_nfe.p (input "os_5152",
                       input ?,
                       output p-ok).

