/*
*
*    titulo.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," Extrato ",""].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

repeat:
    clear frame FCLIEN  all.
    prompt-for clien.clicod colon 15
               with frame fclien centered
                color white/cyan row 3 side-label no-box.
    find clien using clicod no-lock no-error.
    if not avail clien
    then do:
        message "Cliente Nao cadastrado".
        undo.
    end.
    display clien.clinom no-label with frame fclien.

assign
    esqpos1  = 1
    recatu1  = ?.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find titulo where recid(titulo) = recatu1 no-lock.
    if not available titulo
    then do.
        message "Sem titulos para o cliente" view-as alert-box.
        leave.
    end.

    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(titulo).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find titulo where recid(titulo) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field titulo.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

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
                    if not avail titulo
                    then leave.
                    recatu1 = recid(titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail titulo
                    then leave.
                    recatu1 = recid(titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail titulo
                then next.
                color display white/red titulo.titnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail titulo
                then next.
                color display white/red titulo.titnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Consulta "
            then do with frame f-titulo.
                hide frame f-com1 no-pause.
                run bsfqtitulo.p (recid(titulo)).
            end.
            if esqcom1[esqpos1] = " Extrato "
            then do.
                message "Confirma a emissao do extrato do cliente"
                        clien.clinom "?" update sresp.
                if sresp
                then do.
                    run extrato.p (input recid(clien)).
                    leave.
                end.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(titulo).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

end.

procedure frame-a.

def var vtotal  like titulo.titvlcob.
def var vjuro   like titulo.titvlcob.
def var vacum   like titulo.titvlcob.
def var vdias   as   int.
def var vpar-ori as char.

    vtotal = 0.
    vjuro = 0.
    vdias = 0.

    if titulo.titdtven < today
    then do:
        vdias = today - titulo.titdtven.
        {sel-tabjur.i titulo.etbcod vdias}
        if avail tabjur
        then vjuro  = (titulo.titvlcob * tabjur.fator) - titulo.titvlcob.

        assign 
            vtotal = titulo.titvlcob + vjuro
            vdias  = today - titulo.titdtven.
    end.
    else vtotal = titulo.titvlcob.
    vacum = vacum + vtotal.
    if titulo.titparger > 0
    then vpar-ori = string(titulo.titparger).
    else vpar-ori = "".
    display titulo.etbcod column-label "Etb" format ">>9"
            titulo.titnum
            titulo.titpar
            vpar-ori format "xx" column-label "Ori"
            titulo.modcod
            titulo.titdtven format "99/99/99" column-label "Vencimen"
            vdias   when vdias > 0 column-label "Atraso" format ">>>>>9"
            titulo.titvlcob column-label "Principal" format ">>,>>>.99"
            vjuro   column-label "Juro"  format ">>>9.99"
            vtotal  column-label "Total" format ">>,>>>.99"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        titulo.titnum
        titulo.titpar
        titulo.modcod
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        titulo.titnum
        titulo.titpar
        titulo.modcod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first titulo where
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.clifor = clien.clicod and
                titulo.titsit <> "PAG" and
                titulo.titsit <> "EXC"
                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next titulo  where 
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.clifor = clien.clicod and
                titulo.titsit <> "PAG" and
                titulo.titsit <> "EXC"
                no-lock no-error.
              
if par-tipo = "up" 
then find prev titulo where
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.clifor = clien.clicod and
                titulo.titsit <> "PAG" and
                titulo.titsit <> "EXC"
                no-lock no-error.
        
end procedure.
         
