/*
nftraos_NFe.p - procedure p-gera-nota-e
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
            
def var ok-nfe as log.
def var vmovqtm like  movim.movqtm.
def var vemite  like  estab.etbcod.
def var vprotot like  plani.protot.
def var vplatot like  plani.platot.
def var vetbcod like  plani.etbcod.
def var vopccod like  plani.opccod.
def var vhiccod like  plani.hiccod label "Op.Fiscal" format "9999".
def var vprocod like  produ.procod.
def var vmovseq like movim.movseq.
def var vtqtd   as int format ">>>>,>>9" .
def var vtotal  as dec format ">>>,>>>9.99".
def var vserie  like plani.serie.
def buffer bestab for estab.

def  workfile  w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc format ">>,>>9.99"
               field movpc     as decimal format ">>,>>9.99"
               field oscod     as int format ">>>>>>>9"
               field clicod    as int
               field garbiz    as log.

form
    estab.etbcod  label "Emitente" colon 15
    estab.etbnom  no-label
    tipmov.movtdc colon 15
    tipmov.movtnom no-label
    vhiccod       format "9999" colon 15
    with frame f1 side-label width 80 row 4.
      
do on error undo.
    vtqtd   = 0.
    vtotal  = 0.
    vemite  = estab.etbcod.
    vetbcod = 998.
    vhiccod = 1949.

    find estab where estab.etbcod = setbcod no-lock.
    find bestab where bestab.etbcod = vetbcod no-lock.
    find tipmov where tipmov.movtdc = 51 no-lock.

    /* p/ Ass.tecnica  somente se existi OS */
    for each wfasstec no-lock.
        find asstec where asstec.oscod = wfasstec.oscod no-lock.

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
                   w-movim.clicod = asstec.clicod
                   w-movim.oscod  = asstec.oscod.
            
            release asstec_aux.
            /* Procura Garantia BI$ */
            find first asstec_aux where
                        asstec_aux.oscod = asstec.oscod and
                        asstec_aux.nome_campo = "REGISTRO-TROCA" and
                        asstec_aux.valor_campo = "GARANTIA PLANO BI$"
                                    no-lock no-error.
            if avail asstec_aux
            then assign w-movim.garbiz = yes.
            else assign w-movim.garbiz = no.
                    
            assign vtqtd  = vtqtd + w-movim.movqtm
                   vtotal = vtotal + w-movim.subtotal.
    end.
end.

    display
        vemite @ estab.etbcod
        estab.etbnom
        tipmov.movtdc
        tipmov.movtnom
        vhiccod
        vtqtd   label "TOTAL" colon 15
        vtotal  no-label
    with frame f1.

/***
    if not can-find(first w-movim where w-movim.garbiz = no)
    then do:
         message "Nao sera necessario gerar Nota de Entrada para "
                 "O.S. Garantia BIZ."
                  view-as alert-box.
         undo, retry.
    end.
***/

    sresp = no.
    message "Confirma Geracao de Nota Fiscal?" update sresp.
    if not sresp
    then return. 

    run le_tabini.p (estab.etbcod, 0, "NFE - SERIE", OUTPUT vserie). /* #1 */
    do transaction:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = ?
               tt-plani.emite    = estab.etbcod
               tt-plani.alicms   = 0
               tt-plani.serie    = vserie
               tt-plani.numero   = ?
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = estab.etbcod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.notfat   = bestab.etbcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.hiccod   = vhiccod
               tt-plani.opccod   = vhiccod
               tt-plani.notobs[2] = ""
               tt-plani.notobs[3] = "D" 
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
              tt-plani.isenta = tt-plani.platot - tt-plani.outras
                                - tt-plani.bicms.
    end.

    do transaction:
        vmovseq = 0.
        for each w-movim where w-movim.clicod > 0:
            find produ where recid(produ) = w-movim.wrec no-lock no-error.
            if not avail produ
            then next.
            tt-plani.protot = tt-plani.protot + 
                        (w-movim.movqtm * w-movim.movpc).
            tt-plani.platot = tt-plani.platot + 
                        (w-movim.movqtm * w-movim.movpc).
/***
            tt-plani.notobs[2] = tt-plani.notobs[2] +
                    (if vmovseq = 1 then "O.S.:, " else ", ")
                             + string(w-movim.oscod).
***/
            find tt-movim where tt-movim.etbcod = tt-plani.etbcod
                            and tt-movim.placod = tt-plani.placod
                            and tt-movim.procod = produ.procod
                         no-error.

            find first tt-movimaux where tt-movimaux.etbcod = tt-plani.etbcod
                                     and tt-movimaux.procod = produ.procod
                                     and tt-movimaux.nome_campo = "OS"
                                   no-error.
            if not avail tt-movim
            then do:
                vmovseq = vmovseq + 1.
                create tt-movim.
                assign
                    tt-movim.movtdc = tipmov.movtdc
                    tt-movim.PlaCod = tt-plani.placod
                    tt-movim.etbcod = tt-plani.etbcod
                    tt-movim.procod = produ.procod
                    tt-movim.movqtm = 0
                    tt-movim.desti  = tt-plani.desti
                    tt-movim.emite  = tt-plani.emite
                    tt-movim.movseq = vmovseq
                    tt-movim.movdat = tt-plani.pladat
                    tt-movim.MovHr  = tt-plani.horincl
                    tt-movim.ocnum[7] = w-movim.clicod
                    tt-movim.movpc  = w-movim.movpc.

                create tt-movimaux.
                assign
                    tt-movimaux.movtdc = tt-plani.movtdc
                    tt-movimaux.etbcod = tt-plani.etbcod
                    tt-movimaux.placod = tt-plani.placod
                    tt-movimaux.procod = produ.procod
                    tt-movimaux.nome_campo  = "OS"
                    tt-movimaux.valor_campo = "OS:".
            end.       
            assign  
                tt-movim.movqtm = tt-movim.movqtm + w-movim.movqtm.

            tt-movimaux.valor_campo = tt-movimaux.valor_campo +
                                string(asstec.oscod) + " ".
        end.        
    end.

    run manager_nfe.p (input "os_1949_l",input ? ,output ok-nfe).

