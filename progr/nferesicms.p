{cabec.i}

def var vdata  as date.
def var vdtini as date.
def var vdtfin as date.
def var vemite like plani.emite.
def var vdesti like plani.desti.
def buffer bestab for estab.

def temp-table tt-platrans
    field rec   as recid.

def new shared temp-table tt-movtrans
    field rec       as recid
    field vlrnfe    like movim.movpc label "Vl.NFE"

    /*** transferencia ***/
    field transqtm  like movim.movqtm

    /*** ultima compra ***/
    field etbori    like plani.etbcod
    field plaori    like plani.placod
    field serori    like plani.serie
    field movsubst  like movim.movsubst.

def temp-table tt-nfe
    field procod    like movim.procod
    field movqtm    like movim.movqtm
    field movpc     like movim.movpc
    
    index nfe is primary unique procod.

vdtini = date(month(today), 1, year(today)).
vdtfin = today.

do on error undo with frame f1 side-label no-box color message.
    update vdtini label "Emissao de".
    update vdtfin label "Ate".

    update vemite.
    find estab where estab.etbcod = vemite no-lock no-error.
    if not avail estab
    then do:
        message "Emitente nao cadastrado" view-as alert-box.
        undo.
    end.    
    display estab.etbnom no-label with frame f1.

    run not_notgvlclf.p ("estab", recid(estab), output sresp).
    if not sresp
    then undo.

    update vdesti.
    find bestab where bestab.etbcod = vdesti no-lock no-error.
    if not avail bestab
    then do:
        message "Destinatario nao cadastrado" view-as alert-box.
        undo.
    end.    
    display bestab.etbnom no-label with frame f1.

    run not_notgvlclf.p ("estab", recid(bestab), output sresp).
    if not sresp
    then undo.
end.

    do vdata = vdtini to vdtfin.
        for each plani where plani.movtdc = 6
                         and plani.etbcod = estab.etbcod
                         and plani.pladat = vdata
                         and plani.desti  = bestab.etbcod
                         and plani.plaufemi <> ""
                       no-lock.
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.opfcod = 6409
                           no-lock.
                find tt-platrans where tt-platrans.rec = recid(plani)
                              no-lock no-error.
                if not avail tt-platrans
                then do.
                    create tt-platrans.
                    tt-platrans.rec = recid(plani).
                end.
                find tt-movtrans where tt-movtrans.rec = recid(movim)
                              no-lock no-error.
                if not avail tt-movtrans
                then do.
                    create tt-movtrans.
                    tt-movtrans.rec = recid(movim).
                end.                    
            end.
        end.
    end.

/*
*
*    <tabela>.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(14)" extent 5
    initial [" Consulta NFE "," Itens NFE ",""].
def var esqhel1         as char format "x(80)" extent 5.

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-platrans where recid(tt-platrans) = recatu1 no-lock.
    if not available tt-platrans
    then do.
        message "Registros nao encontrados" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tt-platrans).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-platrans
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tt-platrans where recid(tt-platrans) = recatu1 no-lock.
            find plani where recid(plani) = tt-platrans.rec no-lock.

            status default "".
            run color-message.
            choose field plani.numero help ""
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
                    if not avail tt-platrans
                    then leave.
                    recatu1 = recid(tt-platrans).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-platrans
                    then leave.
                    recatu1 = recid(tt-platrans).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-platrans
                then next.
                color display white/red plani.numero with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-platrans
                then next.
                color display white/red plani.numero with frame frame-a.
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

            if esqcom1[esqpos1] = " Consulta NFE "
            then do.
                find plani where recid(plani) = tt-platrans.rec no-lock.
                run not_consnota.p (recid(plani)).
            end.
            if esqcom1[esqpos1] = " Listagem "
            then do.
                leave.
            end.
            if esqcom1[esqpos1] = " Itens NFE "
            then do.
                hide frame frame-a no-pause.
                hide frame f-com1  no-pause.
                run nferesicms2.p (vemite, vdesti, output sresp).
                if sresp
                then leave bl-princ.
                else leave.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-platrans).
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
    find plani where recid(plani) = tt-platrans.rec no-lock.
    display
        plani.etbcod
        plani.numero
        plani.emite
        plani.desti
        plani.platot
        plani.pladat
        string(plani.horincl, "hh:mm")
        with frame frame-a 11 down centered color white/red row 6.
end procedure.


procedure color-message.
    color display message
        plani.numero
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        plani.numero
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then   find first tt-platrans where true no-lock no-error.
    else   find last tt-platrans  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then   find next tt-platrans  where true no-lock no-error.
    else   find prev tt-platrans  where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   find prev tt-platrans where true  no-lock no-error.
    else   find next tt-platrans where true  no-lock no-error.
        
end procedure.

