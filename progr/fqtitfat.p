/*    fqtitag
*/
{admcab.i}

def input parameter par-rec-fatura  as recid.
def input parameter vrow-fcom1      as int.

find contrato where recid(contrato) = par-rec-fatura no-lock.

/*
*
*    titulo.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," "].

form
    esqcom1
    with frame f-com1 row vrow-fcom1 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find titulo where recid(titulo) = recatu1 no-lock.
    if not available titulo
    then do.
        message "Titulos nao encontrados" view-as alert-box.
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
        down
            with frame frame-a.
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
            then do.
                run bsfqtitulo.p (recid(titulo)).
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

procedure frame-a.

    display
        titulo.etbcod  column-label "Etb"
        {titnum.i}
        titulo.modcod
        titulo.titdtven
        titulo.titvlcob column-label "Vl.Cobrado" format ">>>,>>9.99"
        titulo.titvlpag column-label "Vl.Pago"    format ">>>,>>9.99"
        titulo.titdtpag
        titulo.titsit
        with frame frame-a 18 - vrow-fcom1 down centered color white/red
                row vrow-fcom1 + 1 title string(contrato.contnum).
end procedure.


procedure color-message.
    color display message
        titulo.titnum
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        titulo.titnum
        with frame frame-a.
end procedure.


procedure leitura . 

def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then   find first titulo where  titulo.empcod = wempre.empcod and
                                titulo.titnat = no and
                                titulo.modcod = contrato.modcod and
                                titulo.etbcod = contrato.etbcod and
                                titulo.clifor = contrato.clicod and
                                titulo.titnum = string(contrato.contnum)
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then   find next titulo  where  titulo.empcod = wempre.empcod and
                                titulo.titnat = no and
                                titulo.modcod = contrato.modcod and
                                titulo.etbcod = contrato.etbcod and
                                titulo.clifor = contrato.clicod and
                                titulo.titnum = string(contrato.contnum)
                                                no-lock no-error.
             
if par-tipo = "up" 
then   find prev titulo where   titulo.empcod = wempre.empcod and
                                titulo.titnat = no and
                                titulo.modcod = contrato.modcod and
                                titulo.etbcod = contrato.etbcod and
                                titulo.clifor = contrato.clicod and
                                titulo.titnum = string(contrato.contnum)
                                        no-lock no-error.
        
end procedure.

