/*
 nfoutsai.p
#1 23.11.2017 - serie do tab_ini
*/
{admcab.i}

def input parameter par-rec as recid.

find etiqseq where recid(etiqseq) = par-rec no-lock.

def shared temp-table wfasstec like asstec.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimaux like movimaux.
def new shared temp-table tt-etiqpla
    field oscod     like etiqpla.oscod
    field etopeseq  like etiqpla.etopeseq
    field etmovcod  like etiqpla.etmovcod.
def workfile w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc format ">>,>>9.99"
               field movpc     as decimal format ">>,>>9.99"
               field oscod     as int format ">>>>>>>9"
               field clicod    as int
               field garbiz    as log.
 
def var vmovtdc like tipmov.movtdc.
def var v-ok as log.
def var vclicod   like  clien.clicod.
def var vvencod   like  plani.vencod.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vprotot   like  plani.protot.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(3)".
def var vopccod   like  plani.opccod.
def var vmovseq   like movim.movseq.
def var vplacod   like plani.placod.

form
    vetbcod  label "Filial" colon 15
    estab.etbnom  no-label
    vclicod       label "Cliente" colon 15
    clien.clinom no-label  FORMAT "X(30)"
    vopccod label "Op. Fiscal" colon 15 format ">>>9"
    with frame f1 side-label width 80 row 4 color white/cyan.

do on error undo.
    find tipmov where tipmov.movtdc = 52 no-lock.
   
    vetbcod = setbcod.
    disp vetbcod estab.etbnom with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.
    run not_notgvlclf.p ("Estab", recid(estab), output sresp).
    if not sresp
    then return.
   
    vopccod = 5949.
    vmovtdc = 52.
    vnumero = ?.
    vplacod = ?.
    vplatot = 0.
    run le_tabini.p (estab.etbcod, 0, "NFE - SERIE", OUTPUT vserie). /* #1 */

    display vopccod with frame f1.
    
    /* p/ Ass.tecnica somente se existi OS */
    for each wfasstec no-lock.
        find asstec where asstec.oscod = wfasstec.oscod no-lock.
        vclicod = asstec.clicod.
        create tt-etiqpla.
        assign
            tt-etiqpla.oscod    = asstec.oscod
            tt-etiqpla.etopeseq = etiqseq.etopeseq
            tt-etiqpla.etmovcod = etiqseq.etmovcod.

            find produ where produ.procod = asstec.procod no-lock.
            find estoq where estoq.procod = produ.procod
                         and estoq.etbcod = setbcod
                       no-lock.
            create w-movim.
            assign w-movim.wrec   = recid(produ)
                   w-movim.movpc  = estoq.estcusto
                   w-movim.movqtm = 1
                   w-movim.subtotal = w-movim.movpc * w-movim.movqtm
                   w-movim.clicod = asstec.clicod.

            vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).

            release asstec_aux.
            /* Procura Garantia BI$ */
            find first asstec_aux where
                        asstec_aux.oscod = asstec.oscod and
                        asstec_aux.nome_campo  = "REGISTRO-TROCA" and
                        asstec_aux.valor_campo = "GARANTIA PLANO BI$"
                                    no-lock no-error.
            if avail asstec_aux
            then assign w-movim.garbiz = yes.
            else assign w-movim.garbiz = no.

                create tt-movimaux.
                assign
                    tt-movimaux.movtdc = vmovtdc
                    tt-movimaux.etbcod = estab.etbcod
                    tt-movimaux.placod = vplacod
                    tt-movimaux.procod = produ.procod
                    tt-movimaux.nome_campo  = "OS"
                    tt-movimaux.valor_campo = "OS:" + string(asstec.oscod).
    end.

    find clien where clien.clicod = vclicod no-lock.
    disp clien.clinom with frame f1.
    run not_notgvlclf.p ("clien", recid(clien), output sresp).
    if not sresp
    then return.     
    
    do on error undo:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = vplacod
               tt-plani.protot   = vprotot
               tt-plani.emite    = estab.etbcod
               tt-plani.bicms    = vprotot
               tt-plani.icms     = vprotot * (17 / 100)
               tt-plani.descpro  = 0
               tt-plani.acfprod  = 0
               tt-plani.frete    = 0
               tt-plani.seguro   = 0
               tt-plani.desacess = 0
               tt-plani.ipi      = 0
               tt-plani.platot   = vprotot
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = vmovtdc
               tt-plani.desti    = estab.etbcod /***vclicod***/
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = vopccod
               tt-plani.vencod   = vvencod
               tt-plani.notfat   = estab.etbcod /***vclicod***/
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.hiccod   = vopccod
               tt-plani.notsit   = no
               tt-plani.outras   = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
              tt-plani.isenta    = tt-plani.platot - tt-plani.outras
                              - tt-plani.bicms.
    end.

    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock.
        create tt-movim.
        ASSIGN tt-movim.movtdc = tt-plani.movtdc
               tt-movim.PlaCod = tt-plani.placod
               tt-movim.etbcod = tt-plani.etbcod
               tt-movim.movseq = vmovseq
               tt-movim.procod = produ.procod
               tt-movim.movqtm = w-movim.movqtm
               tt-movim.movpc  = w-movim.movpc
               tt-movim.movdat = tt-plani.pladat
               tt-movim.emite  = tt-plani.emite
               tt-movim.desti  = tt-plani.desti
               tt-movim.MovHr  = tt-plani.horincl.
    end.

    if vmovseq = 0
    then do:
        message "Nota Fiscal sem itens, a emissão será cancelada!"
                view-as alert-box.
        undo, retry.
    end.

    sresp = no.
    message "Confirma Emissao da Nota?" update sresp.
    if sresp
    then run manager_nfe.p (input "5949_c", input ?, output v-ok).
end.

