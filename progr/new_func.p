
{admcab.i}

def var vopcao          as  char format "x(15)" extent 3
                  initial ["  Por Codigo","   Por Nome", "  CPF"] .
def var vsetcod as int label "Setor Aut." format ">9". 
def var vok             as logical.

def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(15)" extent 5
            initial["","  Procura","  Consulta","  Alteração","  Inclusão"].
def var esqcom2         as char format "x(15)" extent 5
            initial["","  Rel ADM/RH","  Pro ADM/RH","  Imp Arq RH",""].
            
def buffer bfunc       for func.
def var vfuncod        as char format "x(11)".
def var vsenha         as char format "x(11)".

form
    esqcom1
    with frame f-com1 row 3 no-box no-labels column 1.

form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

form func except aplicod
         with overlay row 6 2 column centered color white/cyan
                frame f-altera.

def temp-table tt-func like func.
def buffer btt-func for func.

def var vcpf as char format "x(16)".

for each func where func.funsit no-lock.
    vcpf = string(func.cpf,"xxx.xxx.xxx-xx").
    find first tbfuncrh where tbfuncrh.cod_cadastro = func.funcod 
                    and tbfuncrh.fun_cpf = vcpf
                    and tbfuncrh.rec_func_adm = recid(func)
            no-lock no-error.
    if avail tbfuncrh
    then do:
        create tt-func.
        buffer-copy func to tt-func.
    end.    
end. 
def var voq as int format ">>".

find first tt-func where tt-func.funcod > 0 no-lock no-error.
if not avail tt-func
then do on error undo, return:
    voq = 0.
    disp "1-Importar arquivo de funcinorios do RH" skip
         "2-Emparelhamento do cadastro ADM/RH."
         with frame f12.
    update skip(1) voq at 1 label "O que deseja fazer?"
        with frame f12 side-label width 80.
    
    if voq = 1
    then run imparqfunrh.p .
    else if voq = 2 then run convadmrh.p(output vfuncod, output vsenha).

    if keyfunction(lastkey) = "END-ERROR"
    then return.
    for each func where func.funsit no-lock.
        vcpf = string(func.cpf,"xxx.xxx.xxx-xx") .
        find tbfuncrh where tbfuncrh.cod_cadastro = func.funcod
                        and tbfuncrh.fun_cpf = vcpf
                        and tbfuncrh.rec_func_adm = recid(func)
            no-lock no-error.
        if avail tbfuncrh
        then do:
            create tt-func.
            buffer-copy func to tt-func.
        end.    
    end.
end.

bl-princ:
repeat:
    assign vok = no.

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    if recatu1 = ?
    then find first tt-func where true NO-LOCK no-error.
    else find tt-func where recid(tt-func) = recatu1 NO-LOCK.
    if not available tt-func
    then do:
        message "Cadastro de funcionarios Vazio".
        undo.
    end.
    
    find func where func.etbcod = tt-func.etbcod and
                    func.funcod = tt-func.funcod no-lock.

    clear frame frame-a all no-pause.
    display
        func.etbcod
        func.funcod
        func.funnom
        func.funfunc column-label "Cargo"
        func.funsit column-label "Situacao"
        with frame frame-a 13 down width 80 color white/red.

    recatu1 = recid(tt-func).
    
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        find next tt-func where true NO-LOCK NO-ERROR.
        if not available tt-func
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.

        find func where func.etbcod = tt-func.etbcod and
                    func.funcod = tt-func.funcod no-lock.

        down with frame frame-a.
        display
            func.etbcod
            func.funcod
            func.funnom
            func.funfunc
            func.funsit
            with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find first tt-func where recid(tt-func) = recatu1 NO-LOCK.

        find func where func.etbcod = tt-func.etbcod and
                    func.funcod = tt-func.funcod no-lock.

        choose field func.funcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  TAB PF4 F4 ESC return).
               
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
          
                  
        /**********          
        if keyfunction(lastkey) = "cursor-right"
        then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            next.
        end.
        ****/
        
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-func where true NO-LOCK no-error.
            if not avail tt-func
            then next.
            find func where func.etbcod = tt-func.etbcod and
                    func.funcod = tt-func.funcod no-lock.
            color display white/red func.funcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-func where true NO-LOCK no-error.
            if not avail tt-func
            then next.
            find func where func.etbcod = tt-func.etbcod and
                    func.funcod = tt-func.funcod no-lock.
            color display white/red func.funcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

        if esqregua
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "  Inclusão"
            then do on error undo with frame f-altera.
                /*create tbfuncrh.
                update tbfuncrh.cod_filial
                       tbfuncrh.cod_cadastro
                       tbfuncrh.fun_nome
                       tbfuncrh.fun_cpf
                       tbfuncrh.fun_cargo
                       .
                  */
                create func.
                update func except func.senha aplicod.
                update vsetcod.
               
                find setaut where setaut.setcod = vsetcod no-lock no-error.
                if not avail setaut
                then do:
                    message "Setor nao cadastrado".
                    undo, retry.
                end.
                /*display setaut.setnom no-label.*/
                func.aplicod = string(vsetcod).
                update func.senha blank.
                func.funnom = caps(func.funnom).

                create tt-func.
                buffer-copy func to tt-func.
                recatu1 = recid(tt-func).
                create tbfuncrh.
                assign vcpf = string(func.cpf,"xxx.xxx.xxx-xx") 
                       tbfuncrh.cod_filial = string(func.etbcod)
                       tbfuncrh.cod_cadastro = func.funcod
                       tbfuncrh.fun_nome = func.funnom
                       tbfuncrh.fun_cpf  = vcpf
                       tbfuncrh.fun_cargo = func.funfunc
                       tbfuncrh.dat_adesao_adm = today
                       tbfuncrh.hor_adesao_adm = time
                       tbfuncrh.cod_func_adm = func.funcod
                       .
                leave.
            end.
            
            if esqcom1[esqpos1] = "  Alteração"
            then do on error undo with frame f-altera:

                find func where func.etbcod = tt-func.etbcod and
                     func.funcod = tt-func.funcod no-lock.
 
                find current func exclusive.
                display func except func.senha aplicod.
                update func EXCEPT FUNCOD func.senha aplicod.
                vsetcod = int(func.aplicod).
                update vsetcod.
                find setaut where setaut.setcod = vsetcod no-lock no-error.
                if not avail setaut
                then do:
                    message "Setor nao cadastrado".
                    undo, retry.
                end.
                /*display setaut.setnom no-label.*/
                func.aplicod = string(vsetcod).
                run funsen.p (input  recid(func),
                              output vok,
                              output vfuncod).

                if vok then update func.senha blank.
                func.funnom = caps(func.funnom).

                buffer-copy func to tt-func.

                recatu1 = recid(tt-func).
                
            end.
            
            if esqcom1[esqpos1] = "  Consulta"
            then do on endkey undo, retry with frame f-altera.
                find func where func.etbcod = tt-func.etbcod and
                    func.funcod = tt-func.funcod no-lock.
                disp func except func.senha func.aplicod.
                pause.
            end.
            
            /*************
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" func.funnom update sresp.
                if not sresp
                then undo.
                run funsen.p (input  recid(func),
                              output vok,
                              output vfuncod).
                if vok
                then do on error undo:
                    find next func where true NO-LOCK no-error.
                    if not available func
                    then do:
                        find func where recid(func) = recatu1 NO-LOCK.
                        find prev func where true NO-LOCK no-error.
                    end.
                    recatu2 = if available func
                              then recid(func)
                              else ?.
                    find func where recid(func) = recatu1.
                    delete func.
                    recatu1 = recatu2.
                    leave.
                end.
            end.
            ***************/
            
            if esqcom1[esqpos1] = "  Procura"
            then do:
                display vopcao
                         help "Escolha a Opcao"
                        with frame fescolha no-label
                        centered row 6 overlay color white/cyan.
                choose field vopcao with frame fescolha.
                if frame-index = 1
                then do with frame fprocura overlay row 9 1 column
                                color white/cyan centered:
                    prompt-for btt-func.funcod
                               /*btt-func.etbcod*/.
                    find first btt-func where 
                               btt-func.funcod = input btt-func.funcod
                                                    NO-LOCK no-error.
                end.
                else if frame-index = 2
                then do with frame fescolha1 side-label
                        column 30 row 9 overlay color white/cyan
                         centered.
                   prompt-for btt-func.funnom.
                   find first btt-func where 
                              btt-func.funnom begins input btt-func.funnom
                                                      NO-LOCK no-error.
                end.
                else do with frame fescolha2 side-label centered
                        :

                    prompt-for btt-func.cpf.  
                          
                    find first btt-func where
                               btt-func.cpf begins input btt-func.cpf
                               NO-LOCK no-error.
                end.
                if avail btt-func
                then do:
                    find first tt-func where
                               tt-func.funcod = btt-func.funcod
                               no-lock no-error.
                    if avail tt-func
                    then recatu1 = recid(tt-func).           
                end.
                leave.
            end.
            
            /*****
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de func" update sresp.
                if not sresp
                then undo.
                recatu2 = recatu1.
                output to printer.
                for each tt-func NO-LOCK:
                    display tt-func.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.
            ***/
            
        end.
        else do:
            if esqcom2[esqpos2] = "  Pro ADM/RH"
            then do:
                hide frame f-com1  no-pause.
                hide frame f-com2  no-pause.
                hide frame frame-a no-pause.
                run convadmrh.p(output vfuncod, output vsenha).
                next bl-princ.
            end.    
            if esqcom2[esqpos2] = "  Imp Arq RH"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                hide frame frame-a no-pause.
                run imparqfunrh.p.
                next bl-princ.
            end.
            if esqcom2[esqpos2] = "  Rel ADM/RH"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                hide frame frame-a no-pause.
                run relefadmrh.
                leave bl-princ.
            end.

        end.
        view frame frame-a.
    end.
        
        if keyfunction(lastkey) = "end-error"
        then next bl-princ /*view frame frame-a*/.
        
        find func where func.etbcod = tt-func.etbcod and
                    func.funcod = tt-func.funcod no-lock.

        display func.etbcod
                func.funcod
                func.funnom
                func.funfunc
                func.funsit
                with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-func).
   end.
end.
    
procedure relefadmrh:

def var vdti as date.
def var vdtf as date.
def var vdt  as date.

def var varquivo as char.

def var vlimite-disponivel as char.
def var vtotal-venda       as decimal.

update vdti label "Ef ADM/RH Periodo de" format "99/99/9999"  with frame f-filtros side-labels width 80.

display " a " with frame f-filtros.

update  vdtf no-label format "99/99/9999"  with frame f-filtros.
    
varquivo = "/admcom/relat/relefadmrh." + string(time).

{mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "110"
        &Page-Line = "66"
        &Nom-Rel   = ""relefadmrh""
        &Nom-Sis   = """ """  
        &Tit-Rel   = """Relatorio de emparelhamento cadastro FUNC ADM/RH "" 
                   + string(vdti,""99/99/9999"") + "" A ""
                   + string(vdtf,""99/99/9999"")"
        &Width     = "110"
        &Form      = "frame f-cabcab"}

for each tbfuncrh where
         tbfuncrh.Dat_adesao_ADM >= vdti and
         tbfuncrh.Dat_adesao_ADM <= vdtf
         no-lock,
    first func where func.funcod = tbfuncrh.cod_cadastro
                 no-lock:
    disp func.funcod func.funnom func.cpf 
         func.funsit 
         tbfuncrh.cod_func_adm
         tbfuncrh.Dat_adesao_ADM
         with frame frel down width 110.
         
end.
output close.

def var varqcsv as char.
varqcsv = varquivo + ".csv".

output to value(varqcsv).
put unformatted
"Codigo;Nome;CPF;Cod Func ADM;Emparelhamento" skip.
 
for each tbfuncrh where
         tbfuncrh.Dat_adesao_ADM >= vdti and
         tbfuncrh.Dat_adesao_ADM <= vdtf
         no-lock,
    first func where func.funcod = tbfuncrh.cod_cadastro
                 no-lock:
    put unformatted
         func.funcod ";"
         func.funnom ";"
         func.cpf    ";"
         func.funsit ";"
         tbfuncrh.cod_func_adm ";"
         tbfuncrh.Dat_adesao_ADM
         skip.
         
end.
output close.

varqcsv = replace(varqcsv,"/admcom","L:").

message color red/with
        "Arquivo CSV gerado"
        varqcsv   skip
        "Tecle ENTER para exibir relatorio"
        view-as alert-box.
        
run visurel.p (input varquivo,
                   input "").
                                                           
end procedure.


