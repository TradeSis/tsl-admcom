/*
*
*    finesp.p    -    Esqueleto de Programacao    com esqvazio
*
#1 TP 30058187 - 27.03.19
*/
{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao ","Produto", "Classe"].

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find finesp where recid(finesp) = recatu1 no-lock.
    if not available finesp
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(finesp).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available finesp
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
            find finesp where recid(finesp) = recatu1 no-lock.
            find finan where finan.fincod = finesp.fincod no-lock no-error.

            status default "".
            run color-message.
            choose field finesp.fincod help ""
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
                    if not avail finesp
                    then leave.
                    recatu1 = recid(finesp).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail finesp
                    then leave.
                    recatu1 = recid(finesp).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail finesp
                then next.
                color display white/red finesp.fincod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail finesp
                then next.
                color display white/red finesp.fincod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form finesp.fincod  label "Plano" colon 20 format ">>>9"
                 finan.finnom   no-label
                 finesp.catcod  label "Departamento" colon 20
                 finesp.datain  label "Periodo Validade" colon 20
                 finesp.datafi  no-label
                 finesp.dataven label "Data Vencimento" colon 20
                 finesp.diaven  colon 20
                 finesp.finarr  colon 20
                 finesp.datexp  colon 20
                 with frame f-finesp color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do with frame f-finesp.
                create finesp. 
                update finesp.fincod.
                find finan where finan.fincod = finesp.fincod no-lock no-error.
                if not avail finan 
                then do: 
                    message "Financiamneto nao cadastrado". 
                    undo, retry. 
                end. 
                display finan.finnom.
                                            
                update finesp.catcod.
                update finesp.datain
                       finesp.datafi
                       finesp.dataven
                       finesp.diaven
                       finesp.finarr.
                finesp.datexp = today.       
                             
                recatu1 = recid(finesp).
                leave.
            end.

            if esqcom1[esqpos1] = " Consulta " or
               esqcom1[esqpos1] = " Exclusao " or
               esqcom1[esqpos1] = " Alteracao "
            then do with frame f-finesp.
                find finan where finan.fincod = finesp.fincod no-lock no-error.
                disp
                    finesp.fincod
                    finan.finnom  when avail finan
                    finesp.catcod
                    finesp.datain
                    finesp.datafi
                    finesp.dataven
                    finesp.diaven
                    finesp.finarr
                    finesp.datexp.
            end.
            if esqcom1[esqpos1] = " Alteracao "
            then do with frame f-finesp on error undo.
                find finesp where recid(finesp) = recatu1 exclusive.
/***
                update finesp.fincod label "Plano".
                find finan where finan.fincod = finesp.fincod no-lock no-error. 
                if not avail finan 
                then do: 
                    message "Financiamneto nao cadastrado". 
                    undo, retry. 
                end. 
                display finan.finnom.
***/                                            
                update finesp.catcod.
                update finesp.datain
                       finesp.datafi
                       finesp.dataven
                       finesp.diaven
                       finesp.finarr.
                finesp.datexp = today. 
            end.

            if esqcom1[esqpos1] = "Produto"
            then do:
                run finpro.p (input finesp.fincod).
                leave.
            end.
 
            if esqcom1[esqpos1] = "Classe"
            then do:
                run fincla.p (input finesp.fincod).
                leave.
            end.
 
            if esqcom1[esqpos1] = " Exclusao "
            then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                message "Confirma Exclusao de" finesp.fincod 
                        "?"
                        update sresp.
                if not sresp
                then undo, leave.

                find next finesp where true NO-LOCK no-error.
                if not available finesp
                then do:
                    find finesp where recid(finesp) = recatu1 NO-LOCK.
                    find prev finesp where true NO-LOCK no-error.
                end.
                recatu2 = if available finesp
                          then recid(finesp)
                          else ?.
                find finesp where recid(finesp) = recatu1 exclusive.

                for each finpro where finpro.fincod = finesp.fincod:
                    delete finpro.
                end.

                for each fincla where fincla.fincod = finesp.fincod:
                    delete fincla.
                end.
                
                for each finfab where finfab.fincod = finesp.fincod:
                    delete finfab.
                end.
 
                delete finesp.
                recatu1 = recatu2.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(finesp).
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
    find finan where finan.fincod = finesp.fincod no-lock no-error.
    display finesp.fincod  column-label "Plano" format ">>>9"
            finan.finnom   when avail finan column-label "Descricao"
            finesp.catcod  column-label "Dep" 
            finesp.datain  column-label "Data Inicial"  
            finesp.datafi  column-label "Data Final" 
            finesp.dataven column-label "Data Venc" 
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
    color display message
        finesp.fincod
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        finesp.fincod
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.

if par-tipo = "pri" 
then  
    if esqascend  
    then find first finesp no-lock no-error.
    else find last finesp  no-lock no-error.

if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next finesp  no-lock no-error.
    else find prev finesp  no-lock no-error.

if par-tipo = "up" 
then                  
    if esqascend   
    then find prev finesp  no-lock no-error.
    else find next finesp  no-lock no-error.

end procedure.

