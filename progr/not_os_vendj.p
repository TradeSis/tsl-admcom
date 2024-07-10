/* programa base: nfvenda_j.p */

{admcab.i}

run blok-NFe.p (input setbcod,
                input "emis_nfe.p",
                output sresp).
if not sresp
then return.

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

def var v-ok as log.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like  plani.vencod.
def var vserie    like  plani.serie.
def var vhiccod   like  plani.hiccod.
def var vmovseq   like movim.movseq.
def var vobs      as char format "x(70)" extent 9.
def var vobs-os   as char.

def temp-table w-movim
               field wrec      as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc
               field movpc     as decimal format ">,>>9.99"
               field movalicms like movim.movalicms
               field movalipi  like movim.movalipi.

def var v-title as char.
def var vforcod like forne.forcod.
form
    estab.etbcod  label "Filial" colon 15
    estab.etbnom  no-label
    vforcod       label "Cliente" colon 15
    forne.fornom no-label    
    with frame f1 side-label width 80 row 4 color white/cyan
      title v-title.

find tipmov where tipmov.movtdc = 46 no-lock.
find first opcom where opcom.movtdc = 5 no-lock no-error.
if avail opcom
then v-title = opcom.opcnom.

repeat:
    for each w-movim:
        delete w-movim.
    end.

    find estab where estab.etbcod = setbcod no-lock.
    display
        estab.etbcod
        estab.etbnom with frame f1.
     
    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do.
        message "Fornecedor invalido" view-as alert-box.
        undo.
    end.
    disp forne.fornom with frame f1.
    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo.
    
    if forne.ufecod <> "RS"
    then vhiccod = 6102.
    else vhiccod = 5102.
    vserie = "1".

    find tipmov where tipmov.movtdc = 46 no-lock.

    do on error undo:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = ?
               tt-plani.emite    = estab.etbcod
               tt-plani.serie    = vserie
               tt-plani.numero   = 0
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = vforcod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = vhiccod
               /* tt-plani.opfcod   = opfis.opfcod */
               tt-plani.vencod   = vvencod
               tt-plani.notfat   = estab.etbcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.hiccod   = vhiccod.
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
                    tt-movim.MovHr  = time
                    tt-movim.desti  = tt-plani.desti
                    tt-movim.emite  = tt-plani.emite
                    tt-movim.ocnum[1] = asstec.oscod
                    tt-movim.datexp = today
                    tt-movim.movalicms = 17.

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

    if length(vobs-os) > 4 and length(vobs-os) < 330
    then tt-plani.notobs[1] = vobs-os + " ".
    else do.
        update vobs[1] no-label
               vobs[2] no-label
               vobs[3] no-label
               with frame f-obs.
    end.
        update
               vobs[4] no-label
               vobs[5] no-label
               vobs[6] no-label
/***
               vobs[7] no-label
               vobs[8] no-label
               vobs[9] no-label
***/
               with frame f-obs overlay centered row 16
                          no-label title " Informações Adicionais ".

        assign             
            tt-plani.notobs[1] = vobs[1] + " " + vobs[2] + " " + vobs[3] + " "
            tt-plani.notobs[2] = vobs[4] + " " + vobs[5] + " " + vobs[6] + " ".
/***
            tt-plani.notobs[3] = vobs[7] + " " + vobs[8] + " " + vobs[9]
***/
    run not_nfppro-tt.p.

    sresp = no.
    message "Deseja Alterar o CFOP?" update sresp.    
    if sresp
    then update tt-plani.opccod format ">>9" label "CFOP"
                with frame f-cfop overlay centered row 5
                        title "Alteração de Operação Comercial" side-labels.

    run not_notgdad.p (output sresp).
    if not sresp
    then return.

    run manager_nfe.p (input "5102_j",
                       input ?,
                       output sresp).
end.

