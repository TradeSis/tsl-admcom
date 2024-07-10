/***
    Projeto FIDC: junho,julho/2018

    envfidc-tit.p    -    Esqueleto de Programacao
***/
{admcab.i}

def input parameter par-reclote as recid.

def var vpar-ori as char.

find lotefidc where recid(lotefidc) = par-reclote no-lock.
disp lotefidc.lotnum
    lotefidc.data
    string(lotefidc.hora,"hh:mm") format "x(5)"
    lotefidc.lottip
    lotefidc.lotqtde
    with frame f-lote side-label no-box.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Titulo "," "].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find envfidc where recid(envfidc) = recatu1 no-lock.
    if not available envfidc
    then do.
        message "Sem titulos" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(envfidc).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available envfidc
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find envfidc where recid(envfidc) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field envfidc.lotseq help ""
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
                    if not avail envfidc
                    then leave.
                    recatu1 = recid(envfidc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail envfidc
                    then leave.
                    recatu1 = recid(envfidc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail envfidc
                then next.
                color display white/red envfidc.lotseq with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail envfidc
                then next.
                color display white/red envfidc.lotseq with frame frame-a.
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

            if esqcom1[esqpos1] = " Titulo "
            then do.
                find first titulo
                            where titulo.empcod = envfidc.empcod and
                                  titulo.titnat = envfidc.titnat and
                                  titulo.modcod = envfidc.modcod and
                                  titulo.etbcod = envfidc.etbcod and
                                  titulo.clifor = envfidc.clifor and
                                  titulo.titnum = envfidc.titnum and
                                  titulo.titpar = envfidc.titpar
                            no-lock no-error.
                if avail titulo
                then run bsfqtitulo.p (recid(titulo)).
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(envfidc).
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
    find titulo where titulo.empcod = envfidc.empcod and
                      titulo.titnat = envfidc.titnat and
                      titulo.modcod = envfidc.modcod and
                      titulo.etbcod = envfidc.etbcod and
                      titulo.clifor = envfidc.clifor and
                      titulo.titnum = envfidc.titnum and
                      titulo.titpar = envfidc.titpar
                no-lock.
    if titulo.titparger > 0
    then vpar-ori = string(titulo.titparger).
    else vpar-ori = "".
    display
        envfidc.lotseq
        envfidc.etbcod
        envfidc.titnum
        envfidc.titpar
        vpar-ori format "xxx" column-label "Ori"
        envfidc.clifor
        titulo.titvlcob column-label "V.Titulo" format ">>>>9.99"
        titulo.titdtven column-label "Vencimen" format "99/99/99"
        titulo.titdtpag column-label "Pagament" format "99/99/99"
        titulo.titvlpag column-label "Vl.Pagto" format ">>>>9.99"
        with frame frame-a 13 down centered color white/red row 6.
end procedure.


procedure color-message.
    color display message
        envfidc.lotseq
        envfidc.etbcod
        envfidc.clifor
        envfidc.titnum
        envfidc.titpar
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        envfidc.lotseq
        envfidc.etbcod
        envfidc.clifor
        envfidc.titnum
        envfidc.titpar
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first envfidc of lotefidc /*use-index lote*/ no-lock no-error.
    else find last envfidc  of lotefidc /*use-index lote*/ no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next envfidc  of lotefidc /*use-index lote*/ no-lock no-error.
    else find prev envfidc  of lotefidc /*use-index lote*/ no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev envfidc  of lotefidc /*use-index lote*/ no-lock no-error.
    else find next envfidc  of lotefidc /*use-index lote*/ no-lock no-error.
        
end procedure.

