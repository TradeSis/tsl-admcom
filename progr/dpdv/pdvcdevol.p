{admcab.i}

def input parameter  par-recid-pdvmov   as recid.

find pdvmov where recid(pdvmov) = par-recid-pdvmov no-lock.

def var vhora               as  char format "x(5)" label "Hora".

form                                                                
     pdvmov.sequencia  format "->>9"                                    
     vhora                                                           
     pdvmov.coo                
     pdvmov.ctmcod  column-label "TT"
     pdvtmov.ctmnom format "x(5)"
     pdvmov.codigo_operador column-label "Oper" format "x(06)"
     func.funape format "x(6)"
     pdvmov.valortot    format "(>>>>,>>9.99)"   column-label "Total "  
     pdvmov.valortroco format "->>>9.99" column-label "Troco"
     pdvmov.statusoper format "x(3)" 
     with frame fmov 1 down row 4 overlay  no-box                      
                 width 80 no-underline.      

find pdvtmov of pdvmov no-lock.
find func where func.funcod = int(pdvmov.codigo_operador)  no-lock no-error.
vhora = string(pdvmov.horamov,"HH:MM").

display
    pdvmov.sequencia 
    vhora
    pdvmov.coo
    pdvmov.ctmcod
    pdvtmov.ctmnom when avail pdvtmov
    pdvmov.codigo_operador
    func.funape when avail func
    pdvmov.valortot
    pdvmov.valortroco
    pdvmov.statusoper
    with frame fmov.

 pause.
 
 
/*
*
*    pdvdevol.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" "].
def var esqhel1         as char format "x(80)" extent 5.

def buffer bpdvdevol       for pdvdevol.
def var vpdvdevol         like pdvdevol.movseq.

form
    esqcom1
    with frame f-com1
                 row screen-lines no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find pdvdevol where recid(pdvdevol) = recatu1 no-lock.
    if not available pdvdevol
    then do.
        message "Sem registros" view-as alert-box.
        leave.
        /***esqvazio = yes.****/
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(pdvdevol).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available pdvdevol
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
            find pdvdevol where recid(pdvdevol) = recatu1 no-lock.

            status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(pdvdevol.movseq)
                                        else "".
            run color-message.
            choose field pdvdevol.movseq help ""
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
                    if not avail pdvdevol
                    then leave.
                    recatu1 = recid(pdvdevol).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail pdvdevol
                    then leave.
                    recatu1 = recid(pdvdevol).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail pdvdevol
                then next.
                color display white/red pdvdevol.movseq with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail pdvdevol
                then next.
                color display white/red pdvdevol.movseq with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form pdvdevol
                 with frame f-pdvdevol color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-pdvdevol on error undo.
                    create pdvdevol.
                    update pdvdevol.
                    recatu1 = recid(pdvdevol).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-pdvdevol.
                    disp pdvdevol.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    leave.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(pdvdevol).
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
        pdvdevol.movseq
        pdvdevol.procod
        pdvdevol.movqtm
        pdvdevol.movpc
        pdvdevol.movdes
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
color display message
        pdvdevol.movseq
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        pdvdevol.movseq
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first pdvdevol of pdvmov
                                                no-lock no-error.
    else  
        find last pdvdevol  of pdvmov
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next pdvdevol  of pdvmov
                                                no-lock no-error.
    else  
        find prev pdvdevol   of pdvmov
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev pdvdevol of pdvmov  
                                        no-lock no-error.
    else   
        find next pdvdevol of pdvmov 
                                        no-lock no-error.
        
end procedure.
         

