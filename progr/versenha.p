{admcab.i}

def input  parameter par-progr  as char.
def input  parameter par-setor  as char.
def input  parameter par-titulo as char.
def output parameter par-ok     as log init no.

def var vfuncod like func.funcod.
def var i       as int.
def var vct     as int.
def var vsenha  like func.senha.
def var vsetor  as log.

hide frame f-senha no-pause.
do on error undo with frame f-senha centered row 8 side-label
    title par-titulo + " (" + par-progr + ")":
    update vfuncod.
    find func where func.funcod = vfuncod and
                    func.etbcod = setbcod no-lock no-error.
    if not avail func
    then do:
        message "Funcionario nao Cadastrado".
        undo.
    end.
    disp func.funnom no-label with frame f-senha.

    if par-progr <> ""
    then do.
        find first Seguranca where seguranca.EmpCod = 19 /*0*/
                               and seguranca.etbcod = setbcod /*999*/
                               and seguranca.programa = par-progr
                             no-lock no-error.
        if avail seguranca
        then do.
            find first Seguranca where seguranca.EmpCod = 19 /*0*/
                                   and seguranca.etbcod = setbcod /*999*/
                                   and seguranca.funcod = vfuncod
                                   and seguranca.programa = par-progr
                             no-lock no-error.
            if not avail Seguranca
            then do.
                message "Usuario nao autorizado:" par-progr view-as alert-box.
                leave.
            end.
        end.
    end.

    if num-entries(par-setor) > 0
    then do.
        vsetor = no.
        do vct = 1 to num-entries(par-setor).
            if func.funfunc = entry(vct, par-setor)
            then do.
                vsetor = yes.
                leave.
            end.
        end.
        if not vsetor
        then do:
            message "Funcionario sem Permissao".
            undo.
        end.
    end.
    i = 0.
    repeat:
        i = i + 1.
        update vsenha blank with frame f-senha.
        if vsenha = func.senha
        then do.
            par-ok = yes.
            leave.
        end.
        if vsenha <> func.senha
        then do:
            message "Senha Invalida".
            vsenha = "".
        end.
        if i > 2
        then leave.
    end.
    if vsenha = ""
    then undo.
end.
hide frame f-senha no-pause.