{admcab.i}

def output parameter vfuncod as char format "x(11)".
def output parameter vsenha as char format "x(10)".

def buffer cfunc for func.
def var vconfproc as log format "Sim/Nao".
def var vconfinfo as log format "Sim/Nao".
def var pok as log.
def var vcpf as char format "x(16)".
def buffer bfunc for func.
def buffer btbfuncrh for tbfuncrh.
def buffer baplifun for aplifun.
def buffer badmaplic for admaplic.
def temp-table tt-func like func.
def temp-table tt-aplifun like aplifun.
def temp-table tt-admaplic like admaplic.
def var vapelido as char.
do on endkey undo, return /*on endkey undo, retry*/:
    vsenha = "".
    update vfuncod label "CPF/Matricula"
            help "Informe o CPF ou codigo de matricula." 
           vsenha blank label "Senha"
           with frame f-senh side-label centered row 5.

    if vfuncod = "" then return.
    
    if length(vfuncod) < 10
    then find first func where func.funcod = int(trim(vfuncod)) and
                          func.senha  = vsenha and
                          func.funsit
                    no-lock no-error.
    else find first func where func.cpf = trim(vfuncod) and
                               func.senha = vsenha and
                               func.funsit
                               no-lock no-error.
    if not avail func
    then do:
        message "Funcionario Invalido.".
        undo, retry.
    end.

    vcpf = func.cpf.

    if program-name(2) matches "*logapl*"
    then do:
        find tbfuncrh where tbfuncrh.fun_cpf = string(vcpf,"xxx.xxx.xxx-xx")
                            no-lock no-error.
        if not avail tbfuncrh or tbfuncrh.Dat_adesao_ADM <> ? 
        then do:
            sfuncod = func.funcod.
            return.
        end.
        
    end.
    
    do on error undo, retry:
        for each tt-func: delete tt-func. end.
        for each tt-aplifun: delete tt-aplifun. end.
        for each tt-admaplic: delete tt-admaplic. end.
        hide frame fconfir no-pause.
        hide frame fconfproc no-pause.
        vcpf = func.cpf.
        pok = no.
        run cpf.p(vcpf, output pok).
        if not pok
        then
        update vcpf at 1 label "Confirmar CPF" with frame f-cpf
                1 down side-label centered.
        pok = no.
        run cpf.p(vcpf, output pok).    
        if not pok 
        then do:
            message color red/with
            "CPF informado" vcpf " é invalido."
            view-as alert-box.
            undo.
        end.
        else do:
            vcpf = string(vcpf,"xxx.xxx.xxx-xx").
            find tbfuncrh where tbfuncrh.fun_cpf = vcpf 
                    no-lock no-error.
            if not avail tbfuncrh
            then do:
                message "Não foram encontrados registros necessários"
                 "para realizar o emparelhamento ADM/RH"
                 view-as alert-box.
                 undo.
            end.      
            else do:
                
                find first cfunc where cfunc.funcod = tbfuncrh.cod_cadastro 
                                   and recid(cfunc) = tbfuncrh.rec_func_adm
                                no-lock no-error.
                if avail cfunc
                then do:
                    message color red/with
                        "Emparelhamento ja efetuado onteriormente, favor verificar." view-as alert-box.
                end.
                else do:                
                disp 
                     func.funcod    colon 10
                     func.funnom    colon 10 format "x(25)"
                     func.cpf       colon 10 format "xxx.xxx.xxx-xx"
                     with frame fadm side-label
                     title "ADMCOM"
                     .
                     
                disp tbfuncrh.cod_cadastro colon 10 label "Matricula" 
                     tbfuncrh.fun_nome     colon 10 label "Nome"  format "x(28)"
                     tbfuncrh.fun_cpf      colon 10 label "CPF" 
                     with frame frh  side-label 
                     column 40 title "RH"
                     .
            
                update vconfinfo label "Confira as informações acima. Estão corretas?"  with frame fconfir side-label.
                if not vconfinfo then undo.
                update vconfproc label "Confirma processar o emparelhamento dos cadatros ADM/RH?"  with frame fconfproc side-label.
                if not vconfproc then undo.
                else do:
                    create tt-func.
                    buffer-copy func to tt-func.

                    for each aplifun where
                             aplifun.funcod = func.funcod no-lock:
                        create tt-aplifun.
                        buffer-copy aplifun to tt-aplifun.
                    end.             
                    for each admaplic where
                             admaplic.cliente = string(func.funcod) no-lock.
                        create tt-admaplic.
                        buffer-copy admaplic to tt-admaplic.
                    end.
                    
                    do on error undo, return.
                    for each tt-aplifun where
                             tt-aplifun.funcod = func.funcod:
                        tt-aplifun.funcod = tbfuncrh.cod_cadastro.
                    end. 
                    
                    for each tt-admaplic where
                             tt-admaplic.cliente = string(func.funcod):
                        tt-admaplic.cliente = string(tbfuncrh.cod_cadastro).
                    end. 
                    
                    find current func.
                    func.funsit = no.
                    
                    find current func no-lock.
                    
                    find first tt-func where
                               tt-func.funcod = func.funcod no-error.
                    if avail tt-func
                    then do:           
                        vapelido = entry(num-entries(tbfuncrh.fun_nome," "),
                                        tbfuncrh.fun_nome," ").
                        vapelido = vapelido + " " +
                                entry(1,tbfuncrh.fun_nome," ").
                        assign
                            tt-func.funcod = tbfuncrh.cod_cadastro
                            tt-func.funnom = tbfuncrh.fun_nome
                            tt-func.funape = vapelido
                            tt-func.cpf    = replace(tbfuncrh.fun_cpf,".","")
                            tt-func.cpf    = replace(tt-func.cpf,"-","")
                            .
                    
                        create bfunc.
                        buffer-copy tt-func to bfunc.
                        if length(trim(vfuncod)) < 11
                        then vfuncod = string(bfunc.funcod).
                    end.
                    for each tt-aplifun where
                             tt-aplifun.funcod = tbfuncrh.cod_cadastro no-lock:
                        create baplifun.
                        buffer-copy tt-aplifun to baplifun.
                    end.             
                    for each tt-admaplic where
                             tt-admaplic.cliente = string(tbfuncrh.cod_cadastro)
                             no-lock:
                        create badmaplic.
                        buffer-copy tt-admaplic to badmaplic.
                    end.     

                    find current tbfuncrh.
                    assign
                        tbfuncrh.dat_adesao_adm = today
                        tbfuncrh.hor_adesao_adm = time
                        tbfuncrh.cod_func_adm = func.funcod
                        tbfuncrh.rec_func_adm = recid(bfunc)
                        .
                    
                    find current tbfuncrh no-lock.
                    end.
                    message color red/with
                        "O emparelhamento do teu cadastro ADM/RH foi finalizado com sucesso." skip
                        "Tua matricula a partir de agora sera" bfunc.funcod 
                        ", anote."skip
                        "Tua senha e teus acessos no ADMCOM continuam os mesmos." skip
                        "Para acessar o ADMCOM pode usar tua matricula ou teu CPF."
                        view-as alert-box.
                end.
                end.
            end.             
        end.
    end.

end.    
