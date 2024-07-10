{admcab.i}
def var vtipo as log label "Operacao" format "Acrescimo/Decrescimo".
def var i as int.
def var vest like estoq.estatual.
def var vsenha like func.senha.
def buffer bplani for plani.
def buffer cplani for plani.
def var vplacod like plani.placod.
def var vnumero like plani.numero.
def var vserie like plani.serie.
def var vdata  like plani.pladat.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
bl-1:
repeat:
    /*
    do:
        
        prompt-for func.funcod with frame f-senha centered row 4
                            side-label title " Seguranca ".
        find func where func.funcod = input func.funcod and
                        func.etbcod = setbcod no-lock no-error.
        if not avail func
        then do:
            message "Funcionario nao Cadastrado".
            undo, retry.
        end.
        disp func.funnom no-label with frame f-senha.
        if func.funfunc <> "ESTOQUE"
        then do:
            bell.
            message "Funcionario sem Permissao".
            undo, retry.
        end.
        i = 0.
        repeat:
            i = i + 1.
            update vsenha blank with frame f-senha.
            if vsenha = func.senha
            then leave.
            if vsenha <> func.senha
            then do:
                bell.
                message "Senha Invalida".
            end.
            if i > 2
            then leave bl-1.
        end.
        
    end.
    */
    prompt-for estab.etbcod
               with frame f1 side-labels centered color white/red row 4.

    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    update vdata with frame f1.
    find last bplani where bplani.movtdc = 19 and
                           bplani.etbcod = estab.etbcod
                                exclusive-lock no-error.
    if not avail bplani
    then vnumero = 1.
    else vnumero = bplani.numero + 1.
    update vnumero
           vtipo with frame f1.

    repeat:

        prompt-for produ.procod with no-validate
        frame f2 centered down color white/cyan.
        find produ using produ.procod no-lock.
        disp produ.pronom with frame f2.

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod.
        /* vest = estoq.estatual. */
        update vest format "->>>>>9" with frame f2.

        if vtipo
        then do:

            find last cplani where cplani.etbcod = estab.etbcod and
                                   cplani.placod <= 500000
                                exclusive-lock no-error.
            if avail cplani
            then vplacod = cplani.placod + 1.
            else vplacod = 1.
            vserie  = "B".

            find last bplani where bplani.movtdc = 19 and
                                   bplani.etbcod = estab.etbcod
                                   exclusive-lock no-error.
            if not avail bplani
            then vnumero = 1.
            else vnumero = bplani.numero + 1.
            find tipmov where tipmov.movtdc = 19 no-lock.

            do on error undo:
                create plani.
                assign plani.etbcod   = estab.etbcod
                       plani.placod   = vplacod
                       plani.protot   = estoq.estcusto
                       plani.emite    = estab.etbcod
                       plani.platot   = estoq.estcusto
                       plani.serie    = vserie
                       plani.numero   = vnumero
                       plani.movtdc   = tipmov.movtdc
                       plani.desti    = estab.etbcod
                       plani.pladat   = vdata
                       plani.modcod   = tipmov.modcod
                       plani.opccod   = 4
                       plani.dtinclu  = today
                       plani.horincl  = time
                       plani.notsit   = no.

                create movim.
                ASSIGN movim.movtdc = plani.movtdc
                       movim.PlaCod = plani.placod
                       movim.etbcod = plani.etbcod
                       movim.movseq = 1
                       movim.procod = produ.procod
                       movim.movqtm = vest
                       movim.movpc  = estoq.estcusto
                       movim.movdat = plani.pladat
                       movim.MovHr  = int(time).

                       /*
                 run atuest.p (input recid(movim),
                               input "I",
                               input 0). */
            end.

        end.

        if vtipo = no
        then do:
            find tabaux where 
                 tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                 tabaux.nome_campo = "BLOCOK" no-error.
            if avail tabaux and tabaux.valor_campo = "SIM"
            then do:
                run emite-NFe-ajuste-estoque.
                leave.
            end.
            else do: 
            find last cplani where cplani.etbcod = estab.etbcod and
                                   cplani.placod <= 500000
                                exclusive-lock no-error.
            if avail cplani
            then vplacod = cplani.placod + 1.
            else vplacod = 1.
            find last bplani where bplani.movtdc = 20 and
                                   bplani.etbcod = estab.etbcod
                                   exclusive-lock no-error.
            if not avail bplani
            then vnumero = 1.
            else vnumero = bplani.numero + 1.
            vserie  = "B".
            find tipmov where tipmov.movtdc = 20 no-lock.

            do on error undo:
                create plani.
                assign plani.etbcod   = estab.etbcod
                       plani.placod   = vplacod
                       plani.protot   = estoq.estcusto
                       plani.emite    = estab.etbcod
                       plani.platot   = estoq.estcusto
                       plani.serie    = vserie
                       plani.numero   = vnumero
                       plani.movtdc   = tipmov.movtdc
                       plani.desti    = estab.etbcod
                       plani.pladat   = vdata
                       plani.modcod   = tipmov.modcod
                       plani.opccod   = 4
                       plani.dtinclu  = today
                       plani.horincl  = time
                       plani.notsit   = no.

                create movim.
                ASSIGN movim.movtdc = plani.movtdc
                       movim.PlaCod = plani.placod
                       movim.etbcod = plani.etbcod
                       movim.movseq = 1
                       movim.procod = produ.procod
                       movim.movqtm = vest
                       movim.movpc  = estoq.estcusto
                       movim.movdat = plani.pladat
                       movim.MovHr  = int(time).
                                                /*
                 run atuest.p (input recid(movim),
                               input "I",
                               input 0).          */
            end.
            end.
        end.

    end.
end.

procedure emite-NFe-ajuste-estoque:
    
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    
    create tt-plani.
    assign tt-plani.etbcod   = estab.etbcod
           tt-plani.placod   = ?
           tt-plani.protot   = estoq.estcusto
           tt-plani.emite    = estab.etbcod
           tt-plani.platot   = estoq.estcusto
           tt-plani.serie    = ?
           tt-plani.numero   = ?
           tt-plani.movtdc   = 8
           tt-plani.desti    = estab.etbcod
           tt-plani.pladat   = vdata
           tt-plani.modcod   = ""
           tt-plani.opccod   = 5927
           tt-plani.hiccod   = 5927
           tt-plani.dtinclu  = today
           tt-plani.datexp   = today
           tt-plani.horincl  = time
           tt-plani.notsit   = no.

    create tt-movim.
    ASSIGN tt-movim.movtdc = tt-plani.movtdc
               tt-movim.PlaCod = ?
               tt-movim.etbcod = tt-plani.etbcod
               tt-movim.movseq = 1
               tt-movim.procod = produ.procod
               tt-movim.movqtm = vest
               tt-movim.movpc  = estoq.estcusto
               tt-movim.movdat = tt-plani.pladat
               tt-movim.MovHr  = int(time)
               tt-movim.movcsticms = "41"
               tt-movim.movcstpiscof = 49
               tt-movim.datexp = today
               tt-movim.emite = tt-plani.emite
               tt-movim.desti = tt-plani.desti
               .

    find first tt-movim where tt-movim.procod > 0 no-lock no-error.
    if avail tt-movim
    then do:
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
    end.
    else do:
        message color red/with
                      "Nenhum item informado para ajuste."
                      view-as alert-box.
    end.                  
end procedure.
