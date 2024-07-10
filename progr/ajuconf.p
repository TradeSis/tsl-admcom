{admcab.i}
def var vcatcod like produ.catcod.
def var vdata like plani.pladat.
def var vnum7 like plani.numero.
def var vcod7 like plani.placod.
def var vnum8 like plani.numero.
def var vcod8 like plani.placod.
def var vnumero like plani.numero.
def var vplacod like plani.placod.
def buffer cplani for plani.
def buffer bplani for plani.
def var vetbcod like estab.etbcod.
def var vblocok as log.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

repeat:
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    vblocok = no.
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdata with frame f1.
    update vcatcod with frame f1.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f1.
    {confir.i 1 "Ajuste de Confronto"}.

    find tabaux where 
                 tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                 tabaux.nome_campo = "BLOCOK" no-error.
    if avail tabaux and tabaux.valor_campo = "SIM"
    then vblocok = yes.
    else vblocok = no.
    
    do transaction:

    find last cplani where cplani.etbcod = estab.etbcod and
                           cplani.placod <= 500000 exclusive-lock no-error.
    if avail cplani
    then vplacod = cplani.placod + 1.
    else vplacod = 1.
    find last bplani where bplani.movtdc = 7 and
                           bplani.etbcod = estab.etbcod exclusive-lock no-error.
    if not avail bplani
    then vnumero = 1.
    else vnumero = bplani.numero + 1.

    end.

    find tipmov where tipmov.movtdc = 7 no-lock.

    vcod7 = vplacod.
    vnum7 = vnumero.

    do transaction:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.placod   = vcod7
               plani.emite    = estab.etbcod
               plani.serie    = "B"
               plani.numero   = vnum7
               plani.movtdc   = tipmov.movtdc
               plani.desti    = estab.etbcod
               plani.pladat   = vdata
               plani.modcod   = tipmov.modcod
               plani.opccod   = 4
               plani.dtinclu  = vdata
               plani.horincl  = time
               plani.notsit   = no.
    end.

    do transaction:
        find last cplani where cplani.etbcod = estab.etbcod and
                               cplani.placod <= 500000 /* exclusive-lock  */
                                    no-error.
        if avail cplani
        then vplacod = cplani.placod + 1.
        else vplacod = 1.
        find last bplani where bplani.movtdc = 8 and
                               bplani.etbcod = estab.etbcod
                                   /* exclusive-lock */ no-error.
        if not avail bplani
        then vnumero = 1.
        else vnumero = bplani.numero + 1.
    end.

    find tipmov where tipmov.movtdc = 8 no-lock.

    vcod8 = vplacod.
    vnum8 = vnumero.
    if vblocok = no
    then do transaction:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.placod   = vcod8
               plani.emite    = estab.etbcod
               plani.serie    = "B"
               plani.numero   = vnum8
               plani.movtdc   = tipmov.movtdc
               plani.desti    = estab.etbcod
               plani.pladat   = vdata
               plani.modcod   = tipmov.modcod
               plani.opccod   = 4
               plani.dtinclu  = vdata
               plani.horincl  = time
               plani.notsit   = no.
    end.
    else do:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = ?
               tt-plani.emite    = estab.etbcod
               tt-plani.serie    = ?
               tt-plani.numero   = ?
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = estab.etbcod
               tt-plani.pladat   = vdata
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = 5927
               tt-plani.hiccod   = 5927
               tt-plani.dtinclu  = vdata
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.datexp   = today
               tt-plani.notsit   = no
               .

    end.

    for each estoq where estoq.etbcod = vetbcod no-lock.
        find produ where produ.procod = estoq.procod no-lock no-error.
        if not avail produ
        then next.
        if produ.catcod <> vcatcod
        then next.

        if estoq.estmgluc = 0 and
           estoq.estmgoper = 0
        then next.

        if estoq.estmgluc > 0
        then do transaction:
            create movim.
            ASSIGN movim.movtdc = 7
                   movim.PlaCod = vcod7
                   movim.etbcod = estab.etbcod
                   movim.movseq = 1
                   movim.procod = estoq.procod
                   movim.movqtm = estoq.estmgluc
                   movim.movpc  = estoq.estcusto
                   movim.movdat = vdata
                   movim.MovHr  = int(time).
            run atuest.p (input recid(movim),
                          input "I",
                          input 0).
        end.
        else if estoq.estmgoper > 0
             then do transaction:
                if vblocok = no
                then do:
                create movim.
                ASSIGN movim.movtdc = 8
                       movim.PlaCod = vcod8
                       movim.etbcod = estab.etbcod
                       movim.movseq = 1
                       movim.procod = estoq.procod
                       movim.movqtm = estoq.estmgoper
                       movim.movpc  = estoq.estcusto
                       movim.movdat = vdata
                       movim.MovHr  = int(time).
                run atuest.p (input recid(movim),
                              input "I",
                              input 0).
                end.
                else do:
                    create tt-movim.
                    ASSIGN tt-movim.movtdc = tipmov.movtdc
                           tt-movim.PlaCod = ?
                           tt-movim.etbcod = estab.etbcod
                           tt-movim.movseq = 1
                           tt-movim.procod = estoq.procod
                           tt-movim.movqtm = estoq.estmgoper
                           tt-movim.movpc  = estoq.estcusto
                           tt-movim.movdat = vdata
                           tt-movim.MovHr  = int(time)
                           tt-movim.movcsticms = "41"
                           tt-movim.movcstpiscof = 49
                           tt-movim.datexp = today
                           tt-movim.emite = estab.etbcod 
                           tt-movim.desti = estab.etbcod
                           .

                end.
            end.
    end.
    find first tt-movim where tt-movim.procod > 0 no-lock no-error.
    if avail tt-movim and vblocok
    then run emite-NFe-ajuste-estoque.
end.

procedure emite-NFe-ajuste-estoque:
    
    def var p-ok as log init no.
    def var p-valor as char.
    p-valor = "".
    def var nfe-emite like plani.emite.
    if estab.etbcod = 998
    then nfe-emite = 993.
    else nfe-emite = estab.etbcod.
    run le_tabini.p (nfe-emite, 0,
            "NFE - TIPO DOCUMENTO", OUTPUT p-valor) .
    if p-valor = "NFE"
    then
        run manager_nfe.p (input "5927",
                           input ?,
                           output p-ok).
    else message "Erro: Verifique os registros TAB_INI do emitente."    
            view-as alert-box.            

end procedure.

