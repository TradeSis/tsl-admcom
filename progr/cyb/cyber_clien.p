/* *    cyb/cyber_clien.p                         */
{admcab.i}
{cyb/cyb_reenvia.i}

def new shared temp-table tt-contrato
    field contnum as char.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(19)" extent 4
    initial [" Contratos "," Controle ", /*" Historico"*/" Consulta",
             " Reenvia Contratos"].

def var vbusca      as char format "x(15)" label "Codigo".
def var primeiro    as log.
def buffer bcyber_clien       for cyber_clien.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find cyber_clien where recid(cyber_clien) = recatu1 no-lock.
    if not available cyber_clien
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(cyber_clien).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available cyber_clien
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
            find cyber_clien where recid(cyber_clien) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field cyber_clien.clicod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up PF7 F7 1 2 3 4 5 6 7 8 9 0 
                      PF4 F4 ESC return) .
            
            if keyfunction(lastkey) = "0" or keyfunction(lastkey) = "1" or
               keyfunction(lastkey) = "2" or keyfunction(lastkey) = "3" or
               keyfunction(lastkey) = "4" or keyfunction(lastkey) = "5" or
               keyfunction(lastkey) = "6" or keyfunction(lastkey) = "7" or
               keyfunction(lastkey) = "8" or keyfunction(lastkey) = "9" 
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                primeiro = yes.
                update vbusca
                    editing:
                        if primeiro
                        then do:
                            apply keycode("cursor-right").
                            primeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end. 
                recatu2 = recatu1. 
                find first cyber_clien where cyber_clien.clicod = int(vbusca)
                                                no-lock no-error.
                if avail cyber_clien
                then recatu1 = recid(cyber_clien). 
                else do.
                    recatu1 = recatu2.
                    
                    find contrato where contrato.contnum = int(vbusca)
                      no-lock no-error.
                    if avail contrato
                    then do.
                        find cyber_clien 
                                    where cyber_clien.clicod = contrato.clicod
                                    no-lock no-error.
                        if avail cyber_clien
                        then recatu1 = recid(cyber_clien).
                    end.
                end.
                leave. 
            end.                           
                      
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 4 then 4 else esqpos1 + 1.
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
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail cyber_clien
                    then leave.
                    recatu1 = recid(cyber_clien).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cyber_clien
                    then leave.
                    recatu1 = recid(cyber_clien).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cyber_clien
                then next.
                color display white/red cyber_clien.clicod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cyber_clien
                then next.
                color display white/red cyber_clien.clicod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form cyber_clien
                 with frame f-cyber_clien color black/cyan
                      centered side-label row 5 1 col.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Contratos "
            then do with frame f-cyber_clien.
                hide frame f-com1  no-pause.
                run cyb/cyber_contrato.p (recid(cyber_clien)).
                view frame f-com1.
                leave.
            end.
            if esqcom1[esqpos1] = " Consulta "
            then do with frame f-cyber_clien.
                disp cyber_clien.
            end.
                if esqcom1[esqpos1] = " Historico "
                then do:
                    hide frame f-com1  no-pause.
                    run cyber/cyber_clien_h.p (recid(cyber_clien)).
                    view frame f-com1.
                end.
            if esqcom1[esqpos1] = " Controle "
            then do:
                hide frame f-com1  no-pause.
                run cyb/cyber_controle.p (recid(cyber_clien)).
                view frame f-com1.
            end.
            if esqcom1[esqpos1] = " Reenvia Contratos"
            then do.
                run reenviar_contratos.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(cyber_clien).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.


procedure frame-a.
    find clien of cyber_clien no-lock.    
    display
        cyber_clien.clicod
        clien.clinom
        cyber_clien.Situacao
        cyber_clien.dturen
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
color display message
        cyber_clien.clicod
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        cyber_clien.clicod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first cyber_clien  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next cyber_clien   no-lock no-error.
             
if par-tipo = "up" 
then find prev cyber_clien   no-lock no-error.
        
end procedure.


procedure reenviar_contratos.

    def var varquivo as char.
    def var vtipooper as log format "Reenviar/Consultar" init yes.
    
    disp "Layout arquivo CSV: Numero do contrato;".
    update
        varquivo  label "Arquivo" format "x(45)"
        vtipooper label "Tipo Operacao" help "Reenviar/Consultar"
        with side-label.
    
    if search(varquivo) = ?
    then do.
        message "Arquivo nao encontrado" view-as alert-box.
        return.
    end.

    empty temp-table tt-contrato.

    input from value(varquivo).
    repeat.
        create tt-contrato.
        import tt-contrato.
        if tt-contrato.contnum <> ""
        then run reenvia (tt-contrato.contnum, vtipooper).
    end.
    input close.
    message "Arquivo processado" view-as alert-box.

    if not vtipooper
    then run cyb/cyb_mostra_reenvia.p.

end procedure.
         
