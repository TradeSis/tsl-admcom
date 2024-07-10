/* helio 13022023 - ID GLPI 156585 e 156556 Orquestra 456067 e 456058 - historico */
{admcab.i}

    prompt-for clien.clicod colon 20 with frame f-altera.
    find clien using clien.clicod.
        disp clien.clinom
               with color white/cyan
               frame f-altera  centered OVERLAY
               side-label width 80 row 3 
                              title "CONSULTA HISTORICO DE ALTERACAO ESPECIAL DE CLIENTES".

                   
def temp-table tt-hist no-undo
    field dtalt like clienhist.dtalt column-label "Data"
    field hralt as char format "x(5)" column-label "Hora"
    field hora as int
    field funape    as char format "x(10)" column-label "Func"
    field programa like clienhist.programa format "x(10)"
    field Campo as char format "x(10)"
    field Antes as char format "x(30)"
    field Depois as char format "x(30)"
    index x dtalt desc hora desc.

def var vi as int.
for each clienhist of clien no-lock.
    do vi = 1 to num-entries(clienhist.camposdif).
        if entry(vi,clienhist.camposantes) = "-" then next.
        if entry(vi,clienhist.camposantes) = entry(vi,clienhist.camposdepois) then next.
        create tt-hist.
        tt-hist.dtalt   = clienhist.dtalt.
        tt-hist.hralt   = string(clienhist.hralt,"HH:MM").
        tt-hist.hora = clienhist.hralt.
        tt-hist.programa = clienhist.programa.
        find func where func.etbcod = clienhist.etbcod and func.funcod = clienhist.funcod no-lock no-error.
        tt-hist.funape  = if avail func then entry(1,func.funnom," ") else string(clienhist.funcod).
        tt-hist.campo = entry(vi,clienhist.camposdif).
        tt-hist.Antes = entry(vi,clienhist.camposantes).
        tt-hist.Depois = entry(vi,clienhist.camposdepois).
    end.
end.    

/*
*
*    tt-hist.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5.

    form 
        tt-hist.dtalt  
        tt-hist.hralt  
        tt-hist.funape 
        tt-hist.programa skip space(4)
        tt-hist.campo 
        tt-hist.antes space(0) "->" space(0)
        tt-hist.depois 
        with frame frame-a 6 down centered color white/red row 7 no-labels
        title " Historico ".

form
    esqcom1
    with frame f-com1
                 row 6 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-hist where recid(tt-hist) = recatu1 no-lock.
    if not available tt-hist
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(tt-hist).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-hist
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
            find tt-hist where recid(tt-hist) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tt-hist.Campo help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-hist
                    then leave.
                    recatu1 = recid(tt-hist).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-hist
                    then leave.
                    recatu1 = recid(tt-hist).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-hist
                then next.
                color display white/red tt-hist.Campo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-hist
                then next.
                color display white/red tt-hist.Campo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-hist).
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
            tt-hist.dtalt  
        tt-hist.hralt  
        tt-hist.funape 
        tt-hist.programa
        tt-hist.campo tt-hist.antes tt-hist.depois 
        with frame frame-a.
end procedure.


procedure color-message.
    color display message
        tt-hist.campo tt-hist.antes tt-hist.depois 
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        tt-hist.campo tt-hist.antes tt-hist.depois 
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-hist where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next tt-hist  where true no-lock no-error.
             
if par-tipo = "up" 
then find prev tt-hist where true   no-lock no-error.
        
end procedure.

