{admcab.i}
def var vmotcod like motiv.motcod.
def var vfuncod like func.funcod.
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
def var venvia as log format "Sim/Nao" initial yes.
def var vblocok as log.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def var vmovtdc like tipmov.movtdc.
def var vmovseq like movim.movseq.
bl-1:
repeat:
    vblocok = no.
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    
    /*
    do:
        update vfuncod with frame f-senha centered row 4
                            side-label title " Seguranca ".
        find func where func.funcod = vfuncod and
                        func.etbcod = 999 no-lock no-error.
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
        if vsenha = ""
        then undo, retry.
    end.
    */
    
    
    
    update vmotcod label "Tipo Ajuste" colon 20 with frame f1.
    find motiv where motiv.motcod = vmotcod no-lock no-error.
    if not avail motiv
    then do:
        message "Ajuste nao cadastrado".
        undo, retry.
    end.
    display motiv.motnom no-label with frame f1.
    prompt-for estab.etbcod colon 20
               with frame f1 side-labels centered color white/red row 4.

    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    find tabaux where 
                 tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                 tabaux.nome_campo = "BLOCOK" no-error.
    if avail tabaux and tabaux.valor_campo = "SIM"
    then vblocok = yes.
    else vblocok = no.

    update vdata colon 20
           venvia label "Envia p/ Filial" colon 20 with frame f1.

    update vtipo with frame f1.
    
    vserie = "B".
    
    if vtipo
    then vmovtdc = 7.
    else vmovtdc = 8.
    
    find tipmov where tipmov.movtdc = vmovtdc no-lock.
    
    find last bplani use-index nota where bplani.movtdc = vmovtdc and
                                          bplani.etbcod = estab.etbcod and
                                          bplani.emite = estab.etbcod and
                                          bplani.serie = vserie
                                exclusive-lock no-error.
    if not avail bplani
    then vnumero = 1.
    else vnumero = bplani.numero + 1.
    
    update vnumero with frame f1.
    
    find last plani where plani.movtdc = vmovtdc and
                          plani.etbcod = estab.etbcod and
                          plani.emite  = estab.etbcod and
                          plani.numero = vnumero and
                          plani.serie = vserie
                          no-lock no-error.
    if avail plani
    then do:
        message color red/with
        "Movimentação ja existe."
        view-as alert-box.
        undo.
    end.     
    for each tt-movim: delete tt-movim. end.
    repeat:

        prompt-for produ.procod with no-validate
        frame f2 centered down color white/cyan.
        find produ using produ.procod no-lock.
        disp produ.pronom with frame f2.

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod.
        update vest format "->>>>>9" with frame f2.
        vmovseq = vmovseq + 1.
        create tt-movim.
        ASSIGN tt-movim.movtdc = tipmov.movtdc
               tt-movim.PlaCod = vplacod
               tt-movim.etbcod = estab.etbcod
               tt-movim.movseq = vmovseq
               tt-movim.procod = produ.procod
               tt-movim.movqtm = vest
               tt-movim.movpc  = estoq.estcusto
               tt-movim.movdat = vdata
               .
    end.
    sresp = yes.
    message "Confirma gerar movimentacao?" update sresp.
    if sresp
    then do:
        if vtipo = no and vblocok
        then do:
            for each tt-movim:
                assign
                    tt-movim.placod = ?
                    tt-movim.MovHr  = int(time)
                    tt-movim.emite  = estab.etbcod
                    tt-movim.desti  = estab.etbcod
                    tt-movim.movcsticms = "41"
                    tt-movim.movcstpiscof = 49
                    tt-movim.datexp = today
                    .
            end.
        end.
        else do:

            find last cplani where cplani.etbcod = estab.etbcod and
                                   cplani.placod <= 500000
                                        exclusive-lock no-error.
            if avail cplani
            then vplacod = cplani.placod + 1.
            else vplacod = 1.
            do on error undo:
                create plani.
                assign plani.etbcod   = estab.etbcod
                       plani.placod   = vplacod
                       plani.protot   = 0
                       plani.emite    = estab.etbcod
                       plani.platot   = 0
                       plani.serie    = vserie
                       plani.numero   = vnumero
                       plani.movtdc   = tipmov.movtdc
                       plani.desti    = estab.etbcod
                       plani.pladat   = vdata
                       plani.modcod   = tipmov.modcod
                       plani.opccod   = 4
                       plani.dtinclu  = today
                       plani.horincl  = time
                       plani.notsit   = no
                       plani.notobs[2] = motiv.motnom.
            
                if not venvia
                then plani.usercod = "NAO" .
            end.
            
            for each tt-movim where tt-movim.procod > 0:
                create movim.
                buffer-copy tt-movim to movim.
                ASSIGN movim.movtdc = plani.movtdc
                       movim.PlaCod = plani.placod
                       movim.etbcod = plani.etbcod
                       movim.movdat = vdata
                       movim.MovHr  = int(time)
                       movim.emite  = plani.emite
                       movim.desti  = plani.desti.
                 if not venvia
                 then movim.movpro  = no.
                 plani.platot = plani.platot + (movim.movpc * movim.movqtm).
                 plani.protot = plani.protot + (movim.movpc * movim.movqtm).
            end.     
            for each movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat
                     no-lock:
                 run atuest.p (input recid(movim),
                               input "I",
                               input 0).
            end.

        end.
    end.
    if vblocok
    then run emite-NFe-ajuste-estoque.
    pause 1 no-message.
end.

procedure emite-NFe-ajuste-estoque:

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
                       tt-plani.dtinclu  = today
                       tt-plani.horincl  = time
                       tt-plani.notsit   = no
                       tt-plani.notobs[2] = motiv.motnom.

    for each tt-movim where tt-movim.procod = 0 :
        delete tt-movim.
    end.
    def var vmovseq as int.
    vmovseq = 0.
    for each tt-movim:
        vmovseq = vmovseq + 1.
        tt-movim.movseq = vmovseq.
        tt-plani.platot = tt-plani.platot + (tt-movim.movpc * tt-movim.movqtm).
        tt-plani.protot = tt-plani.protot + (tt-movim.movpc * tt-movim.movqtm).
    end.    

    find first tt-movim where tt-movim.procod > 0 no-lock no-error.
    if avail tt-movim
    then do:
        pause 1 no-message.
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
        pause 1 no-message.
    end.
end procedure.

