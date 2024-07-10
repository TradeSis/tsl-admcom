/*
*
*    dtesp.p    -    Esqueleto de Programacao    com esqvazio
* #1 23.07.2018 - Ordenacao
*/
{admcab.i}

def var vordem as int init 1. /* #1 */

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Ordem "," "].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de dtesp ",
             " Alteracao da dtesp ",
             " Exclusao  da dtesp ",
             " Ordenacao",
             " "].

def buffer bdtesp       for dtesp.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

run ordem. /* #1 */

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find dtesp where recid(dtesp) = recatu1 no-lock.
    if not available dtesp
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(dtesp).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available dtesp
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
            find dtesp where recid(dtesp) = recatu1 no-lock.

            status default
                esqhel1[esqpos1] + (if esqpos1 > 1 and
                                      esqhel1[esqpos1] <> ""
                                    then string(dtesp.dtdes)
                                    else "")
                                 + "    P = Pesquisa ".
            run color-message.
            choose field dtesp.datesp help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return "P" "p").
            run color-normal.
            status default "".
        end.

        if keyfunction(lastkey) = "p"
        then do:
            pause 0.
            prompt-for dtesp.etbcod dtesp.datesp 
                with frame f-proc overlay centered row 10
                color message side-label.
            if input frame f-proc dtesp.datesp <> ?
            then find first bdtesp where 
                       bdtesp.etbcod = input frame f-proc dtesp.etbcod and
                       bdtesp.datesp = input frame f-proc dtesp.datesp
                       no-lock no-error.
            else find first bdtesp where
                       bdtesp.etbcod = input frame f-proc dtesp.etbcod
                       no-lock no-error.
            if avail bdtesp
            then recatu1 = recid(bdtesp).
            hide frame f-proco no-pause.
            next bl-princ.           
        end.
            
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
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail dtesp
                    then leave.
                    recatu1 = recid(dtesp).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail dtesp
                    then leave.
                    recatu1 = recid(dtesp).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail dtesp
                then next.
                color display white/red dtesp.datesp with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail dtesp
                then next.
                color display white/red dtesp.datesp with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form dtesp
                 with frame f-dtesp color black/cyan
                      centered side-label row 5 1 col.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do with frame f-dtesp on error undo.
                create dtesp.
                update dtesp.etbcod
                       dtesp.datesp  
                       dtesp.dtdes format "x(50)".
                recatu1 = recid(dtesp).
                leave.
            end.
            if esqcom1[esqpos1] = " Exclusao " or
               esqcom1[esqpos1] = " Alteracao "
            then do with frame f-dtesp.
                disp dtesp.
            end.
            if esqcom1[esqpos1] = " Alteracao "
            then do with frame f-dtesp on error undo.
                find dtesp where recid(dtesp) = recatu1 exclusive.
                update /*dtesp.etbcod
                      dtesp.datesp*/
                      dtesp.dtdes format "x(50)".
            end.
                if esqcom1[esqpos1] = " Exclusao "
                then do on error undo.
                    /* #1 */
                    /*
                    if dtesp.datesp <= today
                    then do.
                        message "Nao e´possivel excluir feriado anterior"
                            "a data de hoje"
                            view-as alert-box.
                        leave.
                    end.
                    */
                    
                    message "Confirma Exclusao de" dtesp.dtdes "?"
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next dtesp where true no-lock no-error.
                    if not available dtesp
                    then do:
                        find dtesp where recid(dtesp) = recatu1 no-lock.
                        find prev dtesp where true no-lock no-error.
                    end.
                    recatu2 = if available dtesp
                              then recid(dtesp)
                              else ?.
 
                    find dtesp where recid(dtesp) = recatu1 exclusive.
                    
                    create hiscampotb.
                        assign
                            hiscampotb.xtabela = "dtesp"
                            hiscampotb.xcampo  = "excluido"
                            hiscampotb.data    = today
                            hiscampotb.hora    = time
                            hiscampotb.etbusuario = func.etbcod
                            hiscampotb.codusuario = func.funcod
                            /*hiscampotb.registro = rowid(dtextra)*/
                            hiscampotb.valor_campo = 
                                string(dtesp.etbcod) + " " +
                                string(dtesp.datesp) + " " +
                                dtesp.dtdes.
                        raw-transfer dtesp to hiscampotb.registro.
 
                    delete dtesp.
                    recatu1 = recatu2.
                    leave.
                end.
            if esqcom1[esqpos1] = " Ordem " /* #1 */
            then do:
                run ordem.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(dtesp).
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
    display dtesp 
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message
        dtesp.datesp
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        dtesp.datesp
        with frame frame-a.
end procedure.


procedure leitura.
    def input parameter par-tipo as char.

    if vordem = 1
    then do.        
        if par-tipo = "pri" 
        then  
            if esqascend  
            then find first dtesp use-index dtesp no-lock no-error.
            else find last dtesp  use-index dtesp no-lock no-error.
                                             
        if par-tipo = "seg" or par-tipo = "down" 
        then  
            if esqascend  
            then find next dtesp  use-index dtesp no-lock no-error.
            else find prev dtesp  use-index dtesp no-lock no-error.

        if par-tipo = "up" 
        then                  
            if esqascend   
            then find prev dtesp use-index dtesp  no-lock no-error.
            else find next dtesp use-index dtesp  no-lock no-error.

    end.

    /* #1 */
    else if vordem = 2
    then do.        
        if par-tipo = "pri" 
        then  
            if esqascend  
            then find first dtesp use-index ind1 no-lock no-error.
            else find last dtesp  use-index ind1 no-lock no-error.
                                             
        if par-tipo = "seg" or par-tipo = "down" 
        then  
            if esqascend  
            then find next dtesp  use-index ind1 no-lock no-error.
            else find prev dtesp  use-index ind1 no-lock no-error.

        if par-tipo = "up" 
        then                  
            if esqascend   
            then find prev dtesp use-index ind1  no-lock no-error.
            else find next dtesp use-index ind1  no-lock no-error.
    end.
    
end procedure.


/* #1 */
procedure ordem.

    def var mordem as char extent 2 format "x(12)" init ["Estab/Data", "Data"].
    disp mordem with frame f-ordem no-label centered title " Ordenacao ".
    choose field mordem with frame f-ordem.
    vordem = frame-index.
    esqascend = vordem = 1.
    recatu1 = ?.

end procedure.

         
