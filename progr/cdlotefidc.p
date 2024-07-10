/* 18022022 helio carteira FIDC FINANCEIRA */

/***
    Projeto FIDC: junho/2018

    cdlotefidc.p    -    Esqueleto de Programacao
***/
{admcab.i}
def input param ptitle as char.
def input param pcobcod as int.


def var mtipos as char extent 3 format "x(30)"
    init ["Importacao envio FIDC",
          "Exporta Vencimento",
          "Exporta Pagamento (Cobranca)"].
def var mlottip as char extent 3  init ["IMPORTA","ENVVENC","ENVPAGT"].
def var vtipos as int.
def var vlottip as char.

disp mtipos with frame f-tipos row 5 no-label centered 1 col title ptitle width 80.
choose field mtipos with frame f-tipos. 
vtipos  = frame-index.
vlottip = mlottip[vtipos].
hide frame f-tipos no-pause.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend       as log.
def var esqcom1         as char format "x(14)" extent 5
    initial [" "," Consulta "," Titulos Lote "," "].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find lotefidc where recid(lotefidc) = recatu1 no-lock.
    if not available lotefidc
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(lotefidc).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available lotefidc
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find lotefidc where recid(lotefidc) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field lotefidc.lotnum help ""
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
                    if not avail lotefidc
                    then leave.
                    recatu1 = recid(lotefidc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail lotefidc
                    then leave.
                    recatu1 = recid(lotefidc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail lotefidc
                then next.
                color display white/red lotefidc.lotnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail lotefidc
                then next.
                color display white/red lotefidc.lotnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form lotefidc
                 with frame f-lotefidc color black/cyan
                      centered side-label row 5 1 col.
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Consulta "
            then do with frame f-lotefidc.
                disp lotefidc.
            end.
            if esqcom1[esqpos1] = " Titulos Lote "
            then do:
                hide frame f-com1 no-pause.
                run cdlotefidc-tit.p (recid(lotefidc)).
                view frame f-com1.
                leave.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(lotefidc).
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
        lotefidc.lotnum
        lotefidc.data
        string(lotefidc.hora, "hh:mm") label "Hora" format "x(5)"
        lotefidc.lotqtde
        lotefidc.lotvlr
        lotefidc.funcod
        lotefidc.dtinicial
        lotefidc.dtfinal
        with frame frame-a 11 down centered color white/red row 5
                title mtipos[vtipos].
end procedure.


procedure color-message.
color display message
        lotefidc.lotnum
        lotefidc.data
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        lotefidc.lotnum
        lotefidc.data
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first lotefidc where lotefidc.lottip = vlottip no-lock no-error.
    else find last lotefidc  where lotefidc.lottip = vlottip no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next lotefidc  where lotefidc.lottip = vlottip no-lock no-error.
    else find prev lotefidc  where lotefidc.lottip = vlottip no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev lotefidc  where lotefidc.lottip = vlottip no-lock no-error.
    else find next lotefidc  where lotefidc.lottip = vlottip no-lock no-error.
        
end procedure.

