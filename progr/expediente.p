/*
*
*    expediente.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i new}
def var vx as int.
def buffer bexpediasem for expediasem.
def buffer bexpediente for expediente.
def var vdiasem as char format "x(7)" extent 7.
def var vtitle as char.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 6
    initial [" Inclusao "," Alteracao "," Turnos ", " "," ",
    " "].

def buffer seg-produ for produ.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

form
      expediente.EtbCod
      expediente.seqExpediente
      expediente.Descricao format "x(20)"
      expediente.dataInicial
      expediente.dataFinal
      expediasem.sigla column-label "De"
      bexpediasem.sigla column-label "Ate"
           with frame frame-a 4 down centered color white/red row 5.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find expediente where recid(expediente) = recatu1 no-lock.
    if not available expediente
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(expediente).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available expediente
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
            find expediente where recid(expediente) = recatu1 no-lock.
            clear frame f-sub all no-pause.
            
            vx = 0.
            for each expeturno of expediente no-lock.
                vx = vx + 1.
                if vx > 3 then leave.
                disp expeturno 
                        with frame f-sub row 13 centered
                        title " Turno "
                        3 down retain 3.
                down with frame f-sub.
            end.
            pause 0.

            status default "".
            run color-message.
            choose field expediente.descricao help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
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
                    if not avail expediente
                    then leave.
                    recatu1 = recid(expediente).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail expediente
                    then leave.
                    recatu1 = recid(expediente).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail expediente
                then next.
                color display white/red expediente.descricao with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail expediente
                then next.
                color display white/red expediente.descricao with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            
            form
              expediente.EtbCod                 colon 17
              expediente.seqExpediente          colon 17
              expediente.Descricao  no-label
              expediente.dataInicial    colon 17
              expediente.dataFinal  
              expediasem.sigla label "De" colon 17
              bexpediasem.sigla label "A" 
                with frame f-expediente color black/cyan
                      centered side-label row 5.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
            hide frame frame-a no-pause.
            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do with frame f-expediente on error undo.
                prompt-for expediente.etbcod.
                find last bexpediente where 
                        bexpediente.etbcod = input expediente.etbcod
                        exclusive no-error.

                create expediente.
                expediente.EtbCod = input expediente.etbcod.
                expediente.seqExpediente = if avail bexpediente
                                           then bexpediente.seqexpediente + 1
                                           else 1.
                disp expediente.seqexpediente.
                                           
                update expediente.Descricao.
                expediente.dataInicial = today.
                update expediente.dataInicial.
                if expediente.datainicial = ?
                then do:
                    message "Informe uma data".
                    undo, retry.
                end.                
                update expediente.dataFinal.
                if expediente.dataFinal < expediente.dataInicial
                then do:
                    message "Data nao permitida".
                    undo, retry.
                end.
                run escdiasem ( input "Dia Semana Inicial",
                                output expediente.diasemini).
                find expediasem where 
                        expediasem.diasem =  expediente.diasemini
                        no-lock no-error.
                if not avail expediasem
                then do:
                    message "Dia da Semana nao Cadastrado".
                    undo, retry.
                end.        
                disp expediasem.sigla.
                run escdiasem (input "Dia Semana Final",
                                output expediente.diasemfim).
                find bexpediasem where 
                        bexpediasem.diasem =  expediente.diasemfim
                        no-lock no-error.
                if not avail bexpediasem
                then do:
                    message "Dia da Semana nao Cadastrado".
                    undo, retry.
                end.        
                if expediente.diasemfim < expediente.diasemini
                then do:
                    message "Dia da Semana Final Menor que o Inicial".
                    undo, retry.
                end.
                disp bexpediasem.sigla.
                recatu1 = recid(expediente).
                leave.
            end.
            if esqcom1[esqpos1] = " Alteracao " 
            then do with frame f-expediente on error undo.
                find current expediente exclusive.
                update expediente.Descricao.
                expediente.dataInicial = today.
                update expediente.dataInicial.
                if expediente.datainicial = ?
                then do:
                    message "Informe uma data".
                    undo, retry.
                end.                
                update expediente.dataFinal.
                if expediente.dataFinal < expediente.dataInicial
                then do:
                    message "Data nao permitida".
                    undo, retry.
                end.
                run escdiasem ( input "Dia Semana Inicial",
                                output expediente.diasemini).
                find expediasem where 
                        expediasem.diasem =  expediente.diasemini
                        no-lock no-error.
                if not avail expediasem
                then do:
                    message "Dia da Semana nao Cadastrado".
                    undo, retry.
                end.        
                disp expediasem.sigla.
                run escdiasem (input "Dia Semana Final",
                                output expediente.diasemfim).
                find bexpediasem where 
                        bexpediasem.diasem =  expediente.diasemfim
                        no-lock no-error.
                if not avail bexpediasem
                then do:
                    message "Dia da Semana nao Cadastrado".
                    undo, retry.
                end.        
                if expediente.diasemfim < expediente.diasemini
                then do:
                    message "Dia da Semana Final Menor que o Inicial".
                    undo, retry.
                end.
                disp bexpediasem.sigla.
            end.
            
            if esqcom1[esqpos1] = " Turnos "
            then do:
                hide frame f-com1 no-pause.
                hide frame f-sub no-pause.
                hide frame f-sub2 no-pause.
                run expeturno.p (recid(expediente)).
                leave.
            end.

        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(expediente).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-sub   no-pause.
hide frame f-sub2  no-pause.


procedure frame-a.
    find expediasem where expediasem.diasem = expediente.diasemini no-lock.
    find bexpediasem where bexpediasem.diasem = expediente.diasemfim no-lock.
    display 
      expediente.EtbCod
      expediente.seqExpediente
      expediente.Descricao 
      expediente.dataInicial
      expediente.dataFinal
      expediasem.sigla
      bexpediasem.sigla 
           with frame frame-a.
    
end procedure.


procedure color-message.
    color display message
        expediente.descricao
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        expediente.descricao
        with frame frame-a.
end procedure.


procedure leitura.

def input parameter par-tipo as char.

if par-tipo = "pri" 
then
    if esqascend
    then   find first expediente where true no-lock no-error.
    else   find last expediente  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then
    if esqascend
    then   find next expediente  where true no-lock no-error.
    else   find prev expediente  where true no-lock no-error.
             
if par-tipo = "up" 
then
    if esqascend
    then   find prev expediente where true  no-lock no-error.
    else   find next expediente where true  no-lock no-error.

end procedure.

procedure escdiasem.
def input param par-title as char. 
def output param par-diasem as int.
for each expediasem no-lock.
    vdiasem[expediasem.diasem] = expediasem.sigla.
end.
pause 0.
    
vtitle = par-title.
disp
    vdiasem
        with frame fescdiasem
        row 10
        overlay
        no-labels
        centered
        with title vtitle.
choose field vdiasem
        with frame fescdiasem.
par-diasem = frame-index.
hide frame fescdiasem no-pause.

end procedure.
