/*
*
*    mixmgrupo.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial[" Inclusao"," Alteracao"," Situacao"," Listagem"," Prioridade"].
def var esqcom2         as char format "x(12)" extent 5
            initial [" Classes"," Lojas","","",""].

def buffer bmixmgrupo       for mixmgrupo.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find mixmgrupo where recid(mixmgrupo) = recatu1 no-lock.
    if not available mixmgrupo
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(mixmgrupo).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available mixmgrupo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find mixmgrupo where recid(mixmgrupo) = recatu1 no-lock.

            status default "".

            run color-message.
            view frame frame-a.
            choose field mixmgrupo.codgrupo help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
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
                    if not avail mixmgrupo
                    then leave.
                    recatu1 = recid(mixmgrupo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail mixmgrupo
                    then leave.
                    recatu1 = recid(mixmgrupo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail mixmgrupo
                then next.
                color display white/red mixmgrupo.codgrupo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail mixmgrupo
                then next.
                color display white/red mixmgrupo.codgrupo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form mixmgrupo
                 with frame f-mixmgrupo color black/cyan
                      centered side-label row 5 1 col.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-mixmgrupo on error undo.
                    find last bmixmgrupo no-lock no-error.
                    create mixmgrupo.
                    mixmgrupo.codgrupo = if avail bmixmgrupo
                                         then bmixmgrupo.codgrupo + 1
                                         else 1.
                    disp mixmgrupo.codgrupo.
                    update mixmgrupo.nome.
                    update mixmgrupo.prioridade.

                    do on error undo.
                        update mixmgrupo.codtpgrupo.
                        find mixmtipo of mixmgrupo no-lock no-error.
                        if not avail mixmtipo or mixmtipo.situacao = no
                        then do.
                            message "Tipo de Grupo invalido" view-as alert-box.
                            undo.
                        end.
                    end.
                    recatu1 = recid(mixmgrupo).
                    leave.
                end.
                if esqcom1[esqpos1] = " Situacao " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-mixmgrupo.
                    disp mixmgrupo.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-mixmgrupo on error undo.
                    find mixmgrupo where recid(mixmgrupo) = recatu1 exclusive.
                    update mixmgrupo.nome.

                    do on error undo.
                        update mixmgrupo.codtpgrupo.
                        find mixmtipo of mixmgrupo no-lock no-error.
                        if not avail mixmtipo or mixmtipo.situacao = no
                        then do.
                            message "Tipo de Grupo invalido" view-as alert-box.
                            undo.
                        end.
                    end.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" mixmgrupo.nome
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next mixmgrupo where true no-error.
                    if not available mixmgrupo
                    then do:
                        find mixmgrupo where recid(mixmgrupo) = recatu1.
                        find prev mixmgrupo where true no-error.
                    end.
                    recatu2 = if available mixmgrupo
                              then recid(mixmgrupo)
                              else ?.
                    find mixmgrupo where recid(mixmgrupo) = recatu1
                            exclusive.
                    delete mixmgrupo.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Situacao "
                then do on error undo.
                    sresp = no.
                    message "Confirma Alterar Situacao de" mixmgrupo.nome "?"
                            update sresp.
                    if sresp
                    then do.
                        find current mixmgrupo exclusive.
                        mixmgrupo.situacao = not mixmgrupo.situacao.
                    end.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do:
                    run listagem.
                    leave.
                end.
                if esqcom1[esqpos1] = " Prioridade "
                then do on error undo.
                    find current mixmgrupo exclusive.
                    update mixmgrupo.prioridade.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Classes "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run cad_mixmgrcla.p (recid(mixmgrupo)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = " Lojas "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run cad_mixmgretb.p (recid(mixmgrupo)).
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
        recatu1 = recid(mixmgrupo).
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

procedure frame-a.
    find mixmtipo of mixmgrupo no-lock no-error.
    display
        mixmgrupo.codgrupo
        mixmgrupo.nome
        mixmgrupo.prioridade
        mixmgrupo.codtpgrupo
        mixmtipo.nome format "x(20)"
        mixmgrupo.situacao
        with frame frame-a screen-lines - 9 down centered color white/red
         row 5 title " Grupo de Mix de Moda ".
end procedure.


procedure color-message.
color display message
        mixmgrupo.codgrupo
        mixmgrupo.nome
        mixmgrupo.prioridade
        mixmgrupo.situacao
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        mixmgrupo.codgrupo
        mixmgrupo.nome
        mixmgrupo.prioridade
        mixmgrupo.situacao
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first mixmgrupo where true
                                                no-lock no-error.
    else  
        find last mixmgrupo  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next mixmgrupo  where true
                                                no-lock no-error.
    else  
        find prev mixmgrupo   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev mixmgrupo where true  
                                        no-lock no-error.
    else   
        find next mixmgrupo where true 
                                        no-lock no-error.
        
end procedure.

procedure listagem.

def var vtipo  as int.
def var vordem as int.
def var varquivo as char.

def var mtipo  as char extent 2 format "x(10)"
    init ["Analitico","Sintetico"].
def var mordem as char extent 2 format "x(15)"
    init ["Codigo", "Tipo de Grupo"].

disp mtipo with frame f-tipo no-label centered title " Tipo ".
choose field mtipo with frame f-tipo.
vtipo = frame-index.

disp mordem with frame f-ordem no-label centered title " Ordem ".
choose field mordem with frame f-ordem.
vordem = frame-index.

hide frame f-tipo.
hide frame f-ordem.

    varquivo = "/admcom/relat/cad_mixmgr" + string(time).
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "96"
        &Page-Line = "0"
        &Nom-Rel   = ""cad_mixmgr""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """GRUPOS DE MIX DE MODA """
        &Width     = "96"
        &Form      = "frame f-cabcab"}
 
if vordem = 1
then
    for each mixmgrupo use-index mixmgrupo no-lock.
        run imp-grupo.
        if vtipo = 1
        then run imp-analitico.
    end.
else
    for each mixmgrupo no-lock break by mixmgrupo.codtpgrupo.
        run imp-grupo.
        if vtipo = 1
        then run imp-analitico.
    end.

output close.

run visurel.p (input varquivo, input "").

end procedure.

procedure imp-grupo.

    find mixmtipo of mixmgrupo no-lock no-error.
    display
        mixmgrupo.codgrupo
        mixmgrupo.nome
        mixmgrupo.prioridade
        mixmgrupo.codtpgrupo
        mixmtipo.nome
        mixmgrupo.situacao
        with frame f-lin-grupo down no-box width 96.

end procedure.


procedure imp-analitico.

    put skip(1).

    for each mixmgruetb of mixmgrupo no-lock.
        find estab of mixmgruetb no-lock.
        disp mixmgruetb.etbcod at 20
            estab.etbnom
            mixmgruetb.situacao
            with frame f-lin-e down no-box.
    end.

    put skip(1).
    for each mixmgrucla of mixmgrupo no-lock.
        find clase of mixmgrucla no-lock.
        disp mixmgrucla.clacod at 20
            clase.clanom
            mixmgrucla.situacao
            with frame f-lin-c down no-box.
    end.

    put skip(1).

end procedure.

