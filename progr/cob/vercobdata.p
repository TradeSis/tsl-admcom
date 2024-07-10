/*
*
*    cobranca.p    -    Esqueleto de Programacao    com esqvazio
*
*/

{admcab.i}
def input parameter par-rec as recid.

def var vaberto as dec.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial ["Posicao", "Inclui Cliente", "Exclui Cliente","  ", ""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

find cobdata where recid(cobdata) = par-rec no-lock.

    find cobfil of cobdata no-lock.
    disp 
        cobdata.etbcod
        cobdata.cobcod
        cobfil.cobnom
        cobdata.cobgera
        cobdata.cobqtd
            with frame fcab
            centered 1 down row 3
            no-underline color messages no-box width 80.

    esqpos1  = 1.

    form 
        cobranca.clicod
        clien.clinom
        cobranca.cobeta
        cobranca.cobatr
        vaberto
        with frame frame-a 8 down centered color white/red row 6.


bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find cobranca where recid(cobranca) = recatu1 no-lock.
    if not available cobranca
    then do.
        message "Nenhum Cliente Encontrado"
            view-as alert-box.
        recatu1 = ?.
        return.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(cobranca).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available cobranca
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find cobranca where recid(cobranca) = recatu1 no-lock.

        status default "".

        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field cobranca.clicod
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
        run color-normal.
        pause 0. 

                                                                
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
                    if not avail cobranca
                    then leave.
                    recatu1 = recid(cobranca).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cobranca
                    then leave.
                    recatu1 = recid(cobranca).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cobranca
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cobranca
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        
        
        if keyfunction(lastkey) = "return"
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = "Posicao"
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause. 
                run cob/hiscli2compor.p (cobranca.clicod,"").
                view frame fcab .
                leave.
            end.
            if esqcom1[esqpos1] = "Inclui Cliente"
            then do:
                hide frame frame-a no-pause. 
                run cob/inccob-a.p (recid(cobdata)).
                view frame fcab .
                recatu1 = ?.
                leave.
            end.
            
            if esqcom1[esqpos1] = "Exclui Cliente"
            then do:
                hide frame frame-a no-pause. 
                run cob/exccob2.p (recid(cobranca)).
                view frame fcab .
                recatu1 = ?.
                leave.
            end.
            /**
            if esqcom1[esqpos1] = "Altera Cob"
            then do:
                hide frame frame-a no-pause. 
                run cob/altcob.p (recid(cobranca)).
                view frame fcab .
                recatu1 = ?.
                leave.
            end.
            **/
            
             
            
        end.
        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(cobranca).
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
    find clien of cobranca no-lock no-error.
    vaberto = 0.
    for each titulo where titulo.clifor = clien.clicod no-lock.
        if titulo.modcod <> "CRE" or
           titulo.titsit <> "LIB"
        then next.
           vaberto = vaberto + titulo.titvlcob.
    end.
    disp 
        cobranca.clicod
        clien.clinom when avail clien
        cobranca.cobeta
        cobranca.cobatr
        vaberto
        with frame frame-a.
end procedure.

procedure color-message.
    color display message
        cobranca.clicod
        clien.clinom
        cobranca.cobeta
        cobranca.cobatr
        vaberto

        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        cobranca.clicod
        clien.clinom
        cobranca.cobeta
        cobranca.cobatr
        vaberto

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first cobranca of cobdata
            no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next cobranca of cobdata
            no-lock no-error.
end.    
             
if par-tipo = "up" 
then do:
        find prev cobranca of cobdata
            no-lock no-error.

end.    
        
end procedure.



