/*
*
*    tt-plani.p    -    Esqueleto de Programacao    com esqvazio
*
*/

{admcab.i}

def input  param par-movtdc  like plani.movtdc.
def output param par-rec     as recid.

par-movtdc = 5.

def temp-table tt-plani no-undo
    field rec       as recid
    field etbcod    like plani.etbcod
    field pladat    like plani.pladat
    field serie     like plani.serie
    field numero    like plani.numero    
    index idx is primary etbcod asc pladat asc serie asc numero asc.
    

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(38)" extent 2
    initial [" Seleciona"," Consulta Nota Fiscal"].

def buffer btt-plani       for tt-plani.


assign
    esqregua = yes
    esqpos1  = 1.


def var par-etbcod  like plani.etbcod.
def var par-datini  like plani.pladat.
def var par-datfim  like plani.pladat.
def var par-serie   as char format "x(03)".
def var par-numero  like plani.numero init 0.
def var par-desti   like clien.clicod.

par-etbcod = setbcod.
update
    par-etbcod label "Filial"           colon 30
    with frame fcab.

par-datini = date(month(today),01,year(today)). 
par-datini = par-datini - 1. 
par-datini = date(month(par-datini),01,year(par-datini)).

update par-datini with frame fcab.
if setbcod < 500
then disp
    par-datfim label "Ate"       
        with fram fcab.
else 
    update par-datini
           par-datfim
           with frame fcab.
           
if par-datini > par-datfim or
   par-datini = ? or
   par-datfim = ?
then do:
    message "datas invalidas.".
    pause.
    undo.
end.    
         
update
    par-serie  label "Nota de Venda - Serie"    colon 30 
        help "deixe em branco se nao souber a serie" 
    par-numero    format ">>>>>>>>9"
        help "deixe em branco se nao souber o numero" 
    
    par-desti  label "Cliente" colon 30 
        help "deixe em branco se nao souber o cliente" 

    with frame fcab
    side-labels
    row 3
    width 80
    no-box color messages.

for each tt-plani.
    delete tt-plani.
end.    

if par-desti <> 0
then do:
    for each plani where 
        plani.movtdc = par-movtdc and
        plani.desti  = par-desti  and
        plani.pladat >= par-datini and
        plani.pladat <= par-datfim
         no-lock.
         
        if par-etbcod <> 0
        then if par-etbcod <> plani.etbcod
             then next.
        if par-numero <> 0
        then if par-numero <> plani.numero
             then next.
        if par-serie <> ""
        then if par-serie <> plani.serie
             then next.
             
        create tt-plani.
        tt-plani.rec = recid(plani).
        tt-plani.etbcod = plani.etbcod.
        tt-plani.pladat = plani.pladat.
        tt-plani.serie  = plani.serie.
        tt-plani.numero = plani.numero.
        
    end.
end.
else do:
    for each estab where
        if par-etbcod <> 0
        then estab.etbcod = par-etbcod
        else true no-lock.
        for each plani where 
            plani.movtdc = par-movtdc and
            plani.etbcod  = estab.etbcod  and
            plani.pladat >= par-datini and
            plani.pladat <= par-datfim
             no-lock.
            if par-desti <> 0
            then if par-desti <> plani.desti
                 then next.
            if par-numero <> 0
            then if par-numero <> plani.numero
                 then next.
            if par-serie <> ""
            then if par-serie <> plani.serie
                 then next.

            create tt-plani.
            tt-plani.rec = recid(plani).
            tt-plani.etbcod = plani.etbcod.
            tt-plani.pladat = plani.pladat.
            tt-plani.serie  = plani.serie.
            tt-plani.numero = plani.numero.
            
        end.
    end.
end.
form
    esqcom1
    with frame f-com1
                 row 8 no-box no-labels side-labels column 1 centered.

form    
    plani.movtdc
    plani.etbcod
    plani.pladat
    plani.serie
    plani.numero
    plani.desti format ">>>>>>>>999"
    clien.clinom format "x(30)"
    with frame frame-a down  row 9.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-plani where recid(tt-plani) = recatu1 no-lock.
    if not available tt-plani
    then do:
        esqvazio = yes.
        hide message no-pause.
        message "Nota Nao Encontrada no Periodo de " par-datini " ate " par-datfim
            view-as alert-box.
        leave bl-princ.    
    end.    
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-plani).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-plani
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
            find tt-plani where recid(tt-plani) = recatu1 no-lock.
            
            find plani where recid(plani) = tt-plani.rec no-lock.

            status default "".

            run color-message.
            choose field plani.etbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".

        end.
            
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 2 then 2 else esqpos1 + 1.
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
                    if not avail tt-plani
                    then leave.
                    recatu1 = recid(tt-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-plani
                    then leave.
                    recatu1 = recid(tt-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-plani
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-plani
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"

        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta Nota Fiscal  "
                then do:
                    run not_consnota.p (tt-plani.rec).
                end.
                if esqcom1[esqpos1] = " Seleciona "
                then do:
                    par-rec = tt-plani.rec.
                    leave bl-princ.
                end.
                

                          
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-plani).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame fcab no-pause.


procedure frame-a.
    find plani where recid(plani) = tt-plani.rec no-lock.
    find clien where clien.clicod = plani.desti no-lock no-error.

 display
    plani.movtdc
    plani.etbcod
    plani.pladat
    plani.serie
    plani.numero
    plani.desti
    clien.clinom when avail clien
    with frame frame-a.

end procedure.

procedure color-message.
    color display message
    plani.movtdc
        plani.etbcod
    plani.pladat
    plani.serie
    plani.numero
    plani.desti
    clien.clinom
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
    plani.movtdc
        plani.etbcod
    plani.pladat
    plani.serie
    plani.numero
    plani.desti
    clien.clinom
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-plani no-lock no-error.
    else  
        find last tt-plani no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-plani  no-lock no-error.
    else  
        find prev tt-plani no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-plani   no-lock no-error.
    else   
        find next tt-plani   no-lock no-error.
        
end procedure.
