/*
*
*    dpdv/p2kforma.p  Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter  par-recid-pdvmov   as recid.

def var vtottit as dec.
def var vtotvlr as dec.
find pdvmov where recid(pdvmov) = par-recid-pdvmov no-lock.

/*
for each pdvforma of pdvmov no-lock.
    vtottit = vtottit + pdvforma.titvlcob.
    vtotvlr = vtotvlr + pdvforma.valor.
end.
message vtottit vtotvlr.
*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," "].

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
    else find pdvforma where recid(pdvforma) = recatu1 no-lock.
    if not available pdvforma
    then do.
        message "Sem registros: pdvforma" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(pdvforma).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available pdvforma
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find pdvforma where recid(pdvforma) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field pdvforma.seqforma help ""
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
                    if not avail pdvforma
                    then leave.
                    recatu1 = recid(pdvforma).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail pdvforma
                    then leave.
                    recatu1 = recid(pdvforma).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail pdvforma
                then next.
                color display white/red pdvforma.seqforma with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail pdvforma
                then next.
                color display white/red pdvforma.seqforma with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form pdvforma
                 with frame f-pdvforma color black/cyan
                      side-label row 5 3 col.
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                    with frame f-com1.

            if esqcom1[esqpos1] = " Consulta "
            then do with frame f-pdvforma row 6.
                disp pdvforma.
                disp pdvforma.cmocod format ">>>>>9"
                     pdvforma.observacao format "x(64)"
                     substr(pdvforma.observacao, 65, 64).
            end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(pdvforma).
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
    find pdvtforma of pdvforma no-lock no-error.
    display
        pdvforma.seqforma column-label "Seq"
        pdvforma.ctmcod
        pdvforma.pdvtfcod
        pdvtforma.pdvtfnom
        pdvforma.valor
        pdvforma.valor_forma
        pdvforma.valor_acf
        pdvforma.Qtd_parcelas
        pdvforma.modcod
        with frame frame-a 11 down centered color white/red row 6
            title " PdvForma ".
end procedure.


procedure color-message.
color display message
        pdvforma.seqforma
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        pdvforma.seqforma
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first pdvforma of pdvmov no-lock no-error.
    else find last pdvforma  of pdvmov no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next pdvforma  of pdvmov no-lock no-error.
    else find prev pdvforma  of pdvmov no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev pdvforma of pdvmov  no-lock no-error.
    else find next pdvforma of pdvmov  no-lock no-error.
        
end procedure.
