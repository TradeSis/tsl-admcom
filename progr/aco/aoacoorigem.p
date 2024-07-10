/*
*
*    mdfnfe.p    -    Esqueleto de Programacao    com esqvazio
#1 TP 28872041 16.01.19 - Etbcod e modcod na origem
*
*/
{cabec.i}

def var recatu1         as recid.
def var recatu2 as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Consulta "," ","  ","",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def input parameter par-rec-aoacordo as recid.

find aoacordo where recid(aoacordo) = par-rec-aoacordo no-lock.
find estab  where estab.etbcod = aoacordo.etbcod no-lock.

recatu1 = ?.
    
    form
        aoacorigem.contnum
        aoacorigem.titpar
        titulo.titdtemi
        titulo.titdtpag
        titulo.titvlcob
        aoacorigem.vljur    column-label "Juros"
        aoacorigem.vltot    column-label "Divida"
        with frame frame-a 8 down centered row 09
        title " Contratos Origem " no-underline width 80.

find first aoacorigem of aoacordo no-lock no-error.
if not avail aoacorigem
then do:
    message "origem nao encointrada".
    pause 2.
     return.
end.


bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find aoacorigem where recid(aoacorigem) = recatu1 no-lock.
    if not available aoacorigem
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then
        run frame-a.
    else do.
        recatu1 = ?.
        leave.
    end.

    recatu1 = recid(aoacorigem).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available aoacorigem
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
            find aoacorigem where recid(aoacorigem) = recatu1 no-lock.
            release titulo.
            find contrato of aoacorigem no-lock no-error.
            if avail contrato
            then do:
                find titulo where 
                    titulo.empcod = 19 and titulo.titnat = no and
                    titulo.modcod = contrato.modcod and
                     titulo.etbcod = contrato.etbcod and
                     titulo.clifor = contrato.clicod and
                     titulo.titnum = string(contrato.contnum) and
                      titulo.titpar = aoacorigem.titpar
                      no-lock
                           no-error.
            end.
        color disp messages
        aoacorigem.titpar.
                    
            if not avail titulo
            then do:
                esqcom1[1] = " Consulta".
                esqcom1[2] = " ".
                esqcom1[3] = "" .
                esqcom1[4] = "".
                esqcom1[5] = "".
            end.    

            disp esqcom1 with frame f-com1.
            
            choose field aoacorigem.titpar
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            hide message no-pause.
            status default "".
 
        color disp normal
        aoacorigem.titpar.
 
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
                    if not avail aoacorigem
                    then leave.
                    recatu1 = recid(aoacorigem).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail aoacorigem
                    then leave.
                    recatu1 = recid(aoacorigem).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail aoacorigem
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail aoacorigem
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            leave bl-princ.
        end.    

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Consulta"
            then do:
                run bsfqtitulo.p (input recid(titulo)).
            end.    
                
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(aoacorigem).
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.

            find contrato of aoacorigem no-lock no-error.
            if avail contrato
            then do:
                find titulo where 
                    titulo.empcod = 19 and titulo.titnat = no and
                    titulo.modcod = contrato.modcod and
                     titulo.etbcod = contrato.etbcod and
                     titulo.clifor = contrato.clicod and
                     titulo.titnum = string(contrato.contnum) and
                      titulo.titpar = aoacorigem.titpar
                      no-lock
                           no-error.
            end.

    display 
        aoacorigem.contnum
        aoacorigem.titpar
        aoacorigem.vljur
        aoacorigem.vltot
        
        with frame frame-a.
    if avail titulo
    then disp            
        titulo.titdtemi
        titulo.titdtpag
        titulo.titvlcob
        
        with frame frame-a.

end procedure.

procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find last aoacorigem of aoacordo  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find prev aoacorigem of aoacordo no-lock no-error.
             
if par-tipo = "up" 
then find next aoacorigem of aoacordo no-lock no-error.

end procedure.




