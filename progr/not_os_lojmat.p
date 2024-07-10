/*
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
def var vmovqtm   like  movim.movqtm.
def var vemite    like  estab.etbcod.
def var vtrans    like  clien.clicod.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vprotot   like  plani.protot.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vhiccod   like  plani.hiccod label "Op.Fiscal" format "9999".
def var vprocod   like  produ.procod.
def var vmovseq   like movim.movseq.
def var vplacod   like plani.placod.
def var vtqtd     as int format ">>>>,>>9" .
def var vtotal    as dec format ">>>,>>>9.99".
def var vserie    as char format "x(3)".
def buffer bestab for estab.

def  workfile  w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc format ">>,>>9.99"
               field movpc     as decimal format ">>,>>9.99"
               field oscod     as int format ">>>>>>>9"
               field clicod    as int
               field confinado as log
               field garbiz    as log.

form
    estab.etbcod  label "Emitente" colon 15
    estab.etbnom  no-label
    vetbcod        label "Destinatario" colon 15
    bestab.etbnom no-label format "x(20)"
    vnumero       colon 15
    vhiccod       format "9999" colon 15
    with frame f1 side-label width 80 row 4.

do on error undo.    
    vtqtd   = 0.
    vtotal  = 0.        
    vplacod = ?.
    vnumero = ?.
    vetbcod = 988.
    vhiccod = 5152.

    find estab where estab.etbcod = setbcod no-lock.
    find tipmov where tipmov.movtdc = 6 no-lock.
    vemite = estab.etbcod.
    find bestab where bestab.etbcod = vetbcod no-lock.

    disp
        vemite @ estab.etbcod
        estab.etbnom no-label
        vetbcod
        bestab.etbnom no-label
        vhiccod
        with frame f1.

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
            
             find first w-movim where w-movim.oscod = asstec.oscod
                                no-lock no-error.
             if not avail w-movim
             then do:
                  create w-movim.
                  assign w-movim.oscod = asstec.oscod.
/***
                  if asstec.serie = "S"
                  then w-movim.confinado = yes.
                  else w-movim.confinado = no.
***/
             end.     
             assign w-movim.wrec   = recid(produ)
                    w-movim.movpc  = estoq.estcusto
                    w-movim.movqtm = w-movim.movqtm + 1
                    w-movim.subtotal = (w-movim.movpc * w-movim.movqtm)
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
                    
            assign vtqtd = vtqtd + w-movim.movqtm
                   vtotal = vtotal + w-movim.subtotal.
         end.
    end.

disp
    "TOTAL" at 48          
    vtqtd at 56 no-label
    vtotal at 64 no-label
    with frame f1.

if not can-find(first w-movim)
then do:
     message "Nao existem O.S. para geração da Nota Fiscal"
                  view-as alert-box.
     undo, retry.          
end.
    run le_tabini.p (estab.etbcod, 0, "NFE - SERIE", OUTPUT vserie). /* #1 */
    do transaction:    
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = vplacod
               tt-plani.emite    = estab.etbcod
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = bestab.etbcod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.notfat   = bestab.etbcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.hiccod   = vhiccod
               tt-plani.opccod   = vhiccod
               tt-plani.nottran  = vtrans
               tt-plani.notobs[3] = "D" .
    end.

    do transaction:
        tt-plani.notobs[2] = "".
        vmovseq = 0.
        
        for each tt-movim: delete tt-movim. end.
        
        for each w-movim :
            vmovseq = vmovseq + 1.
            find produ where recid(produ) = w-movim.wrec no-lock no-error.
            if not avail produ
            then next.
            tt-plani.protot = tt-plani.protot + 
                                (w-movim.movqtm * w-movim.movpc).
            tt-plani.platot = tt-plani.platot + 
                                (w-movim.movqtm * w-movim.movpc).
/***
            tt-plani.notobs[2] = tt-plani.notobs[2] +
                                (if vmovseq = 1 then "OS:" else ", ")
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
                    tt-movim.movpc  = w-movim.movpc
                    tt-movim.movdat = tt-plani.pladat
                    tt-movim.MovHr  = tt-plani.horincl
                    tt-movim.movcsticms = "51".

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

            delete w-movim.
        end.
    end.

    sresp = no.
    message "Confirma Emissao da Nota?" update sresp.
    if sresp 
    then run manager_nfe.p (input "os_5152", input ?, output ok-nfe).
