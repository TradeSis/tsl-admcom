/*
*
*    Seguranca.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var vsenha as char.
def var vconfsenha as char.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.                    
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [""," Inclusao "," Nova senha "," Exclusao "," Altera"].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de Seguranca ",
             " Exclusao  da Seguranca ",
             " ", " "].
def var esqhel2         as char format "x(12)" extent 5.

def var a-i as int.
def var e-i as int.
/*
if avail seguranca and seguranca.regua[1] <> ""
then do:
    assign   
        esqcom1 = ""
        esqcom2 = ""
        esqcom1[1] = seguranca.regua[1]
        esqcom1[2] = seguranca.regua[2]
        esqcom1[3] = seguranca.regua[3]
        esqcom1[4] = seguranca.regua[4]
        esqcom1[5] = seguranca.regua[5]
        esqcom2[1] = seguranca.regua[6]
        esqcom1[2] = seguranca.regua[7]        
        esqcom1[3] = seguranca.regua[8]
        esqcom1[4] = seguranca.regua[9]
        esqcom1[5] = seguranca.regua[10]
        .
end.
*/

def var /*input parameter*/ par-prog as char format "x(20)".
def buffer bSeguranca       for Seguranca.
def var vSeguranca         like Seguranca.funcod.

def var vmentit     like menu.mentit.
/*
find segur where segur.empcod   = sempcod and
                 segur.funcod   = sfuncod       and
                 segur.programa = "menseg"      no-lock no-error.
if not avail segur
then do:
    leave.
end.
*/

do on error undo, retry:
    update par-prog label "Programa"
        help "Informe o nome do programa que esta no menu." 
        with frame f-prog 1 down side-label width 80.
       
    if search("/admcom/progr/" + par-prog) = ?       
    then do:
        sresp = no.
        message "Programa não encontrado em /admcom/progr/ Confirma?"
                update sresp.
        if not sresp
        then undo, retry.
    end.
    
    find first menu where menu.menpro = par-prog no-lock no-error.

end.

if avail menu
then vmentit = menu.mentit.
else vmentit = par-prog.

form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered
                            overlay width 81.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1
                 centered overlay.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
    pause 0.

def workfile wfseguranca        like seguranca.

for each Seguranca where seguranca.programa = par-prog no-lock.
    create wfseguranca.
    ASSIGN wfseguranca.Programa  = seguranca.Programa
           wfseguranca.EmpCod    = seguranca.EmpCod
           wfseguranca.etbcod    = seguranca.etbcod
           wfseguranca.FunCod    = seguranca.FunCod
           wfseguranca.Regua[ 1] = seguranca.Regua[ 1]
           wfseguranca.Regua[ 2] = seguranca.Regua[ 2]
           wfseguranca.Regua[ 3] = seguranca.Regua[ 3]
           wfseguranca.Regua[ 4] = seguranca.Regua[ 4]
           wfseguranca.Regua[ 5] = seguranca.Regua[ 5]
           wfseguranca.Regua[ 6] = seguranca.Regua[ 6]
           wfseguranca.Regua[ 7] = seguranca.Regua[ 7]
           wfseguranca.Regua[ 8] = seguranca.Regua[ 8]
           wfseguranca.Regua[ 9] = seguranca.Regua[ 9]
           wfseguranca.Regua[10] = seguranca.Regua[10]
           wfseguranca.Regua[11] = seguranca.Regua[11]
           wfseguranca.Regua[12] = seguranca.Regua[12].
end.
find first wfseguranca no-error.
if not avail wfseguranca
then do:
    create wfseguranca.
    ASSIGN wfseguranca.Programa  = par-prog
           wfseguranca.EmpCod    = 0
           wfseguranca.etbcod    = 999
           wfseguranca.FunCod    = 0.
end.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ? 
    then
        if esqascend
        then
            find first wfseguranca where wfseguranca.programa = par-prog
                                        no-lock no-error.
        else
            find last wfseguranca where wfseguranca.programa = par-prog
                                        no-lock no-error.
    else
        find wfseguranca where recid(wfseguranca) = recatu1 no-lock no-error.
    if not available wfseguranca
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do:
        leave bl-princ.
    end.

    recatu1 = recid(wfseguranca).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next wfseguranca where wfseguranca.programa = par-prog
                                        no-lock.
        else
            find prev wfseguranca where wfseguranca.programa = par-prog
                                        no-lock.
        if not available wfseguranca
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find wfseguranca where recid(wfseguranca) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(wfseguranca.funcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(wfseguranca.funcod)
                                        else "".

            choose field wfseguranca.funcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) color message.

            status default "".

        end.
        {esquema.i &tabela = "wfseguranca"
                   &campo  = "wfseguranca.funcod"
                   &where  = "wfseguranca.programa = par-prog"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form
                seguranca.etbcod   colon 20
                seguranca.funcod   colon 20
                func.funape        no-label
                func.funnom        colon 20
                with frame f-Seguranca 
                    centered side-label row 9 overlay color message.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with width 80 frame f-Seguranca on error undo.
                    create Seguranca.
                    assign seguranca.empcod   = 19
                           seguranca.programa = par-prog
                           seguranca.etbcod   = setbcod.
                    update
                        seguranca.etbcod
                        seguranca.funcod with no-validate.
                    find func where func.etbcod = seguranca.etbcod and
                                    func.funcod = seguranca.funcod 
                              no-lock.
                    display func.funape
                            func.funnom.
                    update seguranca.Regua[1] label "Regua1"
                           seguranca.Regua[2] no-label
                           seguranca.Regua[3] no-label
                           seguranca.Regua[4] no-label
                           /*seguranca.Regua[5] no-label*/ skip
                           seguranca.Regua[6] label "Regua2"
                           seguranca.Regua[7] no-label
                           seguranca.Regua[8] no-label
                           seguranca.Regua[9] no-label
                           /*seguranca.Regua[10] no-label*/
                            .
                    create wfseguranca.
                    ASSIGN wfseguranca.Programa  = seguranca.Programa      
                           wfseguranca.EmpCod    = seguranca.EmpCod
                           wfseguranca.FunCod    = seguranca.FunCod
                           wfseguranca.Regua[ 1] = seguranca.Regua[ 1]
                           wfseguranca.Regua[ 2] = seguranca.Regua[ 2]
                           wfseguranca.Regua[ 3] = seguranca.Regua[ 3]
                           wfseguranca.Regua[ 4] = seguranca.Regua[ 4]
                           wfseguranca.Regua[ 5] = seguranca.Regua[ 5]
                           wfseguranca.Regua[ 6] = seguranca.Regua[ 6]
                           wfseguranca.Regua[ 7] = seguranca.Regua[ 7]
                           wfseguranca.Regua[ 8] = seguranca.Regua[ 8]
                           wfseguranca.Regua[ 9] = seguranca.Regua[ 9]
                           wfseguranca.Regua[10] = seguranca.Regua[10]
                           wfseguranca.Regua[11] = seguranca.Regua[11]
                           wfseguranca.Regua[12] = seguranca.Regua[12].
                    recatu1 = recid(wfseguranca).
                    find first wfseguranca where 
                               wfseguranca.etbcod = setbcod and
                                wfseguranca.funcod = 0
                                    no-error.
                    if avail wfseguranca
                    then delete wfseguranca.
                    pause 1 no-message.
                    next bl-princ.
                end.
                if esqcom1[esqpos1] = " Nova senha " and
                    wfseguranca.funcod <> 0
                then do on error undo, retry 
                    with frame f-SENHA  row 12 1 column centered
                        overlay.
                    assign
                        vsenha = ""
                        vconfsenha = "".
                        
                    disp wfseguranca.funcod  label "       Usuario".
                    update vsenha blank      label "    Nova Senha"
                            vconfsenha blank label "Confirma Senha".
                    if vsenha = vconfsenha
                    then  do:
                        find first seguranca where
                         seguranca.empcod   = wfseguranca.empcod and
                         seguranca.etbcod   = wfseguranca.etbcod and
                         seguranca.funcod   = wfseguranca.funcod and
                         seguranca.programa = wfseguranca.programa no-error.
                        assign
                            seguranca.senha = vsenha
                            wfseguranca.senha = vsenha.
                    end.
                    else do:
                        message "Senha nao confere.".
                        pause.
                        undo, retry.
                    end.
                    hide frame f-senha no-pause.
                end.
                if esqcom1[esqpos1] = " Exclusao " and
                    wfseguranca.funcod <> 0
                then do with frame f-exclui  row 5 1 column centered.
                    message "Confirma Exclusao de" wfSeguranca.funcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find wfseguranca where recid(wfseguranca) = recatu1.
                    find seguranca where
                         seguranca.empcod   = wfseguranca.empcod and
                         seguranca.funcod   = wfseguranca.funcod and
                         seguranca.etbcod   = wfseguranca.etbcod and
                         seguranca.programa = wfseguranca.programa no-error.
                    if avail seguranca
                    then delete seguranca.
                    delete wfseguranca.
                    find first wfseguranca no-error.
                    if not avail wfseguranca
                    then do:
                        create wfseguranca.
                        ASSIGN wfseguranca.Programa  = par-prog
                               wfseguranca.EmpCod    = 0
                               wfseguranca.FunCod    = 0.
                    end.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Altera " and
                    wfseguranca.funcod <> 0
                then do with width 80 frame f-Seguranca on error undo.
                    find wfseguranca where recid(wfseguranca) = recatu1.
                    find seguranca where
                         seguranca.empcod   = wfseguranca.empcod and
                         seguranca.funcod   = wfseguranca.funcod and
                         seguranca.etbcod   = wfseguranca.etbcod and
                         seguranca.programa = wfseguranca.programa no-error.
                    
                    disp   seguranca.funcod .
                    find func where     func.etbcod = seguranca.etbcod and
                                        func.funcod = seguranca.funcod 
                                    no-lock.
                    display func.funape
                            func.funnom.
                    update seguranca.Regua[1] label "Regua1"
                           seguranca.Regua[2] no-label
                           seguranca.Regua[3] no-label
                           seguranca.Regua[4] no-label
                           /*seguranca.Regua[5] no-label*/ skip
                           seguranca.Regua[6] label "Regua2"
                           seguranca.Regua[7] no-label
                           seguranca.Regua[8] no-label
                           seguranca.Regua[9] no-label
                           /*seguranca.Regua[10] no-label*/
                            .
                    assign  
                           wfseguranca.Regua[ 1] = seguranca.Regua[ 1]
                           wfseguranca.Regua[ 2] = seguranca.Regua[ 2]
                           wfseguranca.Regua[ 3] = seguranca.Regua[ 3]
                           wfseguranca.Regua[ 4] = seguranca.Regua[ 4]
                           wfseguranca.Regua[ 5] = seguranca.Regua[ 5]
                           wfseguranca.Regua[ 6] = seguranca.Regua[ 6]
                           wfseguranca.Regua[ 7] = seguranca.Regua[ 7]
                           wfseguranca.Regua[ 8] = seguranca.Regua[ 8]
                           wfseguranca.Regua[ 9] = seguranca.Regua[ 9]
                           wfseguranca.Regua[10] = seguranca.Regua[10]
                           wfseguranca.Regua[11] = seguranca.Regua[11]
                           wfseguranca.Regua[12] = seguranca.Regua[12].
                    recatu1 = recid(wfseguranca).
                    
                    pause 1 no-message.
                    hide frame f-seguranca no-pause.
                    next bl-princ.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(wfseguranca).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com2  no-pause.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
        view frame fc1.
        view frame fc2.

procedure frame-a.

            find func where func.etbcod = setbcod and
                            func.funcod = wfseguranca.funcod no-lock no-error.
            release estab.
            if avail func
            then find estab of wfseguranca no-lock no-error.
            display
                wfseguranca.funcod
                (if not avail func
                 then "PERMISSAO GERAL"
                 else func.funape) @ func.funape
                func.funnom when avail func format "x(25)"
                wfseguranca.etbcod column-label "Etb"
                estab.etbnom when avail estab format "x(20)" label "Filial"
                with frame frame-a 10 down centered color white/red row 7
                        overlay width 80
                        title " Usuarios Com Permissao - " + vmentit + " ".

end procedure.
