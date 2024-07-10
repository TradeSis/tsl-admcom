{admcab.i}
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
bl-1:
repeat:

    do on error undo:
        update vfuncod with frame f-senha centered row 4
                            side-label title " Seguranca ".
        find func where func.funcod = vfuncod and
                        func.etbcod = 999 no-lock no-error.
        if not avail func
        then do:
            message "Funcionario nao Cadastrado".
            undo, return.
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
    prompt-for estab.etbcod colon 20
               with frame f1 side-labels centered color white/red row 4.

    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    find tabaux where 
                 tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                 tabaux.nome_campo = "BLOCOK" no-error.
    if avail tabaux and tabaux.valor_campo = "SIM"
    then next.

    update vdata colon 20
           vnumero colon 20
           vtipo with frame f1.
    if vtipo
    then find last plani where plani.movtdc = 7 and
                               plani.emite  = estab.etbcod and
                               plani.etbcod = estab.etbcod and
                               plani.serie  = "B"          and
                               plani.numero = vnumero  no-error.

    else find last plani where plani.movtdc = 8 and
                               plani.emite  = estab.etbcod and
                               plani.etbcod = estab.etbcod and
                               plani.serie  = "B"          and
                               plani.numero = vnumero no-error.
    if not avail plani
    then do:
        message "ajuste nao existe".
        undo, retry.
    end.
    repeat:
        prompt-for produ.procod with no-validate
        frame f2 centered down color white/cyan.
        find produ using produ.procod no-lock.
        disp produ.pronom with frame f2.

        find movim where movim.procod = produ.procod and
                         movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-error.
        if not avail movim
        then do:
            message "Movimento nao existe".
            undo, retry.
        end.
        display movim.procod
                movim.movqtm
                movim.movpc with frame f3.
        message "Deseja Excluir Movimento" update sresp.
        if not sresp
        then leave.

        run atuest.p (input recid(movim),
                      input "E",
                      input 0).
        do transaction:
            delete movim.
        end.
    end.
    find first movim where movim.etbcod = plani.etbcod and
                           movim.placod = plani.placod and
                           movim.movtdc = plani.movtdc and
                           movim.movdat = plani.pladat no-error.
    if not avail movim
    then do transaction:
        delete plani.
    end.

end.
