{admcab.i}
def shared temp-table wfasstec like asstec.
def temp-table wfmovim like movim.

find first wfasstec no-error.
if not avail wfasstec
then return.
find forne where forne.forcod = wfasstec.forcod no-lock.

def var vplacod like plani.placod.
def var vnumero like plani.numero.
def var vmovseq like movim.movseq.
def var vserie  like plani.serie.
def var vprotot as dec.

find first tipmov where tipmov.movtdc = 16 no-lock.
find first opcom where opcom.movtdc = tipmov.movtdc no-lock.
find estab where estab.etbcod = 998 no-lock.
def buffer bplani for plani.
def buffer xestab for estab.

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-osxnf like osxnf.

    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.

    vplacod = ?.
    vnumero = ?.
    vserie = "1".

    if forne.ufecod = "RS"
    then find first opcom where opcom.opccod = "5915" no-lock.
    else find last opcom where opcom.opccod = "6915"  no-lock.
    
    do transaction:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = vplacod
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
               tt-plani.numero   = vnumero
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

    for each wfasstec no-lock:
        find asstec where asstec.oscod = wfasstec.oscod no-lock.
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
            if not avail tt-movim
            then do:
                vmovseq = vmovseq + 1.
                create tt-movim.
                ASSIGN
                    tt-movim.movtdc   = tt-plani.movtdc
                    tt-movim.PlaCod   = tt-plani.placod
                    tt-movim.etbcod   = tt-plani.etbcod
                    tt-movim.movseq   = vmovseq
                    tt-movim.procod   = produ.procod
                    tt-movim.movqtm   = 1
                    tt-movim.movpc    = estoq.estcusto
                    tt-movim.movdat   = tt-plani.pladat
                    tt-movim.MovHr    = int(time)
                    tt-movim.desti    = tt-plani.desti
                    tt-movim.emite    = tt-plani.emite
                    tt-movim.ocnum[1] = asstec.oscod
                    tt-movim.datexp   = today /*asstec.dtenvass*/.
            end.
            else  tt-movim.movqtm = tt-movim.movqtm + 1.
            create tt-osxnf.
            assign
                tt-osxnf.movtdc = tt-plani.movtdc 
                tt-osxnf.etbcod = tt-plani.etbcod 
                tt-osxnf.emite  = tt-plani.emite
                tt-osxnf.serie  = tt-plani.serie
                tt-osxnf.numero = tt-plani.numero
                tt-osxnf.oscod  = asstec.oscod.
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

    def var p-ok as log init no.
    
    update tt-plani.notobs format "x(70)"
            with frame f-obs overlay centered row 16
            no-label title " Informações Adicionais ".
            
    run manager_nfe.p (input "os_5915",
                       input ?,
                       output p-ok).
                       
