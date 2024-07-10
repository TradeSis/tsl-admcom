/*     cyb/cybacordo.p
*
#1 TP 29024087 - 11.02.2019
*/
{cabec.i}

def var vbusca as char.
def var vtotal as int.
def var vhora as char format "x(5)" label "Hr".
def var par-busca       as   char.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Acordo ", ""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Filtros","","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def var vprimeiro as log.

pause 0 before-hide.

def buffer bcybacordo    for cybacordo.

def temp-table ttacordo
    field marca   as log format "*/ "
    field rec     as recid
    field idAcordo like cybacordo.idAcordo
    field Situacao like cybacordo.Situacao
    index x idAcordo desc
    /*#1 index y Situacao idAcordo desc*/.

def buffer xttacordo for ttacordo.
    
form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
    
def var vchoose as char format "x(24)"  extent 3
            init [" TODOS",
                  " Pendentes ",
                  " Efetivados "].
                  
def var tchoose as char format "x(15)"  extent 3
            init ["GERAL",
                  "PEN", 
                  "EFE"].

def var vindex as int.
def var pchoose as char format "x(30)".
def var par-idAcordo like cybacordo.idAcordo.

    form
       /** ttacordo.marca  format " / " column-label "" **/
        cybacordo.idAcordo
        cybacordo.dtacordo
        vhora
        cybacordo.etbcod
        cybacordo.clifor
        cybacordo.vlacordo
        cybacordo.dtefetiva
        cybacordo.situacao column-label "Sit"
        with frame frame-a 
        12 down centered color white/red row 4
                          title vchoose[vindex] width 80.
                          

form with frame flinha down no-box.
form 
         par-idAcordo        colon 30
         pchoose        colon 30 label "Situacao"
         with frame fcab side-labels
            row 3 centered
            title "Filtros Acordos ".

repeat.    
    run pfiltros.
    if keyfunction(lastkey) = "end-error"
    then leave.

find first ttacordo no-lock no-error.
if not avail ttacordo
then do:
    message "Nao foram encontrados registros para esta selecao"
            view-as alert-box.
    leave.
end.

bl-princ:
repeat:    
    run ptotal.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttacordo where recid(ttacordo) = recatu1 no-lock.
    if not available ttacordo
    then return.
            
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(ttacordo).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttacordo
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
            find ttacordo where recid(ttacordo) = recatu1 no-lock.
            find cybacordo where recid(cybacordo) = ttacordo.rec no-lock.

            disp esqcom1 with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(cybacordo.idAcordo)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(cybacordo.idAcordo)
                                        else "".

            choose field cybacordo.idAcordo help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5 6 7 8 9 0 
                      tab PF4 F4 ESC return).
            
            if keyfunction(lastkey) >= "0" and 
               keyfunction(lastkey) <= "9"
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                vprimeiro = yes.
                update vbusca label "Busca"
                    editing:
                        if vprimeiro
                        then do:
                            apply keycode("cursor-right").
                            vprimeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end.
                recatu2 = recatu1.
                find first bcybacordo where bcybacordo.idAcordo = 
                    int(vbusca)
                                    no-lock no-error.
                if avail bcybacordo
                then do.
                    create ttacordo.
                    ttacordo.rec     = recid(bcybacordo).
                    ttacordo.idAcordo = bcybacordo.idAcordo.
                    recatu1 = recid(ttacordo).
                end.
                else do:
                    recatu1 = recatu2.
                    message "OS nao encontrada".
                    pause 1 no-message.
                end.    
                leave.
            end.

            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttacordo
                    then leave.
                    recatu1 = recid(ttacordo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttacordo
                    then leave.
                    recatu1 = recid(ttacordo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttacordo
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttacordo
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form with frame f-etiqest color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Acordo "
                then do:
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide message no-pause. 
                    hide frame f-com2 no-pause.
                    hide frame ftotal no-pause.
                    recatu2 = recid(cybacordo).
                    run cyb/cybacordoman_v1701.p (input-output recatu2).
                    view frame f-com1.
                    view frame f-com2.
                    run ptotal.
                    view frame ftotal.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "Filtros" 
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run pfiltros.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom2[esqpos2] = "Relatorio" 
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run relatorio.
                    view frame f-com1.
                    view frame f-com2.
                end.
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
        recatu1 = recid(ttacordo).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.
end.

procedure frame-a.
    find cybacordo where recid(cybacordo) = ttacordo.rec no-lock.
    vhora = string(cybacordo.hracordo,"HH:MM").
    
    disp
        cybacordo.idAcordo
        cybacordo.dtacordo
        vhora
        cybacordo.etbcod
        cybacordo.clifor
        cybacordo.vlacordo
        cybacordo.dtefetiva
        cybacordo.situacao 
        with frame frame-a.

end procedure.


procedure leitura.
def input parameter par-tipo as char.

if par-tipo = "pri" 
then find first ttacordo use-index x no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next ttacordo use-index x no-error.

if par-tipo = "up" 
then find prev ttacordo use-index x no-error.

end procedure.
         

procedure ptotal. 
    vtotal = 0.
    for each xttacordo no-lock.
        vtotal = vtotal + 1.
    end.
    pause 0 before-hide.
    disp vtotal label "Total"  to 80
         with frame ftotal row screen-lines - 1 no-box side-labels column 1
                 centered.
end procedure.


procedure montatt.

    for each ttacordo.
        delete ttacordo.
    end.

    if par-idAcordo <> 0
    then do:
        for each cybacordo where cybacordo.idAcordo = par-idAcordo no-lock.
            run criatt.
        end.
        leave.
    end.

    hide message no-pause.

    do:        
        if pchoose = "PEN" or pchoose = "GERAL"
        then do:
            for each cybacordo where cybacordo.dtefetiva = ? no-lock.
                run criatt.
            end.
        end.
        if pchoose = "EFE" or pchoose = "GERAL"
        then do:
            for each cybacordo where cybacordo.dtefetiva <> ? no-lock.
                run criatt.
            end.        
        end.
    end.        
    run ptotal.
                             
end procedure.


procedure criatt.
 
    create ttacordo.
    ttacordo.rec   = recid(cybacordo).
    ttacordo.idAcordo = cybacordo.idAcordo.
    ttacordo.Situacao = cybacordo.Situacao.
    
end procedure.


form with frame flinha no-box width 140.
    def var vtotpc  as dec.

procedure pfiltros.

repeat.
    par-idAcordo = 0.
    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ulti~mo campo".
 
    update par-idAcordo when keyfunction(lastkey) <> "I" and
                      keyfunction(lastkey) <> "CLEAR"
        go-on(F8 PF8)
    with frame fcab.
    if keyfunction(lastkey) = "CLEAR" or 
       keyfunction(lastkey) = "I"
    then     do: 
        recatu2 = ?. 
        run mdfe/manviagem.p (input-output recatu2).  
        find cybacordo where recid(cybacordo) = recatu2 no-lock no-error.
        if avail cybacordo
        then do:
            par-idAcordo = cybacordo.idAcordo.
            return.
        end.
        else do:
            undo.
        end.
    end.

    find cybacordo where cybacordo.idAcordo = par-idAcordo no-lock no-error.
    if par-idAcordo <> 0
    then do:
        if not avail cybacordo
        then do:
            message "Acordo Inexistente".
            undo.
        end.
        else do.
            if avail cybacordo
            then do:
                recatu1 = ?.
                run montatt.
                return.
            end.        
        end.
    end.


        display vchoose
            with frame fff centered row 6 no-label overlay width 80.
        choose field vchoose with frame fff.                         
        pchoose =  tchoose[frame-index].
        message pchoose.
        vindex = frame-index.
        
    
    disp
        pchoose
         par-idAcordo 
         with frame fcab.

        recatu1 = ?.
        run montatt.

    leave.

end.
recatu1 = ?.

run montatt.


end procedure.

