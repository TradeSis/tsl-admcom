/*

*
*
*/
{admcab.i}

def input param par-wms like abastipo.abatipo.
def input param par-etbcd  like abascorte.etbcd.
def input param par-etbcod    like abascorte.etbcod.
def input param par-pendente  as log.

def var vhorareal    as char format "x(05)".
def var vhrconfer    as char format "x(05)".
def var vhrimparqui  as char format "x(05)".

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta ","  "," ", " ",""].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.
find abaswms where abaswms.wms = par-wms no-lock.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find abascorte where recid(abascorte) = recatu1 no-lock.
    if not available abascorte
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.
    else do:
        message "Sem Registros...".
        return.
    end.

    recatu1 = recid(abascorte).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available abascorte
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find abascorte where recid(abascorte) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field abascorte.etbcod help ""
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
                    if not avail abascorte
                    then leave.
                    recatu1 = recid(abascorte).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail abascorte
                    then leave.
                    recatu1 = recid(abascorte).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail abascorte
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail abascorte
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
            hide frame frame-a no-pause.
            
            if esqcom1[esqpos1] = " Consulta"
            then do:
                run abas/cortescprod.p (recid(abascorte)).
            end.
            
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(abascorte).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-sub   no-pause.
hide frame f-sub2  no-pause.


procedure frame-a.
    display 

        abascorte.etbcod
        abascorte.box format ">>>"
        abascorte.dcbcod
        abascorte.datareal format "999999"
        string(abascorte.horareal,"HH:MM") @ vhorareal label ""
        abascorte.arquivoIntegracao
        "|"        
        abascorte.dtconfer format "999999"
        string(abascorte.hrconfer,"HH:MM") @ vhrconfer label ""
        abascorte.ArquivoCONF
        with frame frame-a 10 down centered row 5 no-box.


end procedure.


procedure color-message.
    color display message
        abascorte.etbcod
        abascorte.box
        abascorte.dcbcod
        abascorte.datareal
        vhorareal
        abascorte.dtconfer 
        vhrconfer 
        abascorte.arquivoIntegracao

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        abascorte.etbcod
        abascorte.box
        abascorte.dcbcod
        abascorte.datareal
        vhorareal
        abascorte.dtconfer 
        vhrconfer 
        abascorte.arquivoIntegracao

        with frame frame-a.
end procedure.


procedure leitura.

def input parameter par-tipo as char.

if par-tipo = "pri" 
then
    if par-etbcod = 0
    then do:
        if par-pendente
        then do:
            find first abascorte 
                        where   abascorte.interface = abaswms.interface and
                                abascorte.wms = par-wms and 
                                abascorte.etbcd = par-etbcd and 
                                abascorte.dtconfer = ?
                        no-lock no-error.
        end. 
        else do:
            find first abascorte 
                        where    abascorte.interface = abaswms.interface and
                                 abascorte.wms = par-wms and 
                                 abascorte.etbcd = par-etbcd 
                        no-lock no-error.
        end. 
    end.
    else do:
        if par-pendente
        then do:
            find first abascorte 
                        where   abascorte.interface = abaswms.interface and
                                abascorte.wms = par-wms and 
                                abascorte.etbcd = par-etbcd and 
                                abascorte.etbcod = par-etbcod and
                                abascorte.dtconfer = ?
                        no-lock no-error.
        end. 
        else do:
            find first abascorte 
                        where    abascorte.interface = abaswms.interface and
                                 abascorte.wms = par-wms and 
                                 abascorte.etbcd = par-etbcd and
                                 abascorte.etbcod = par-etbcod
                no-lock no-error.
                
        end. 
    end.
                                                
if par-tipo = "seg" or par-tipo = "down" 
then
    if par-etbcod = 0
    then do:
        if par-pendente
        then do:
            find next abascorte 
                        where   abascorte.interface = abaswms.interface and
                                abascorte.wms = par-wms and 
                                abascorte.etbcd = par-etbcd and 
                                abascorte.dtconfer = ?
                        no-lock no-error.
        end. 
        else do:
            find next abascorte 
                        where    abascorte.interface = abaswms.interface and
                                 abascorte.wms = par-wms and 
                                 abascorte.etbcd = par-etbcd 
                        no-lock no-error.

        end. 
    end.
    else do:
        if par-pendente
        then do:
            find next abascorte 
                        where   abascorte.interface = abaswms.interface and
                                abascorte.wms = par-wms and 
                                abascorte.etbcd = par-etbcd and 
                                abascorte.etbcod = par-etbcod and
                                abascorte.dtconfer = ?
             
                        no-lock no-error.
        end. 
        else do:
            find next abascorte 
                        where    abascorte.interface = abaswms.interface and
                                 abascorte.wms = par-wms and 
                                 abascorte.etbcd = par-etbcd and
                                 abascorte.etbcod = par-etbcod
                        no-lock no-error.

        end. 
    end.

             
if par-tipo = "up" 
then
    if par-etbcod = 0
    then do:
        if par-pendente
        then do:
            find prev abascorte 
                        where   abascorte.interface = abaswms.interface and
                                abascorte.wms = par-wms and 
                                abascorte.etbcd = par-etbcd and 
                                abascorte.dtconfer = ?
                        no-lock no-error.
        end. 
        else do:
            find prev abascorte 
                        where    abascorte.interface = abaswms.interface and
                                 abascorte.wms = par-wms and 
                                 abascorte.etbcd = par-etbcd 
                        no-lock no-error.

        end. 
    end.
    else do:
        if par-pendente
        then do:
            find prev abascorte 
                        where   abascorte.interface = abaswms.interface and
                                abascorte.wms = par-wms and 
                                abascorte.etbcd = par-etbcd and 
                                abascorte.etbcod = par-etbcod and
                                abascorte.dtconfer = ?
             
                        no-lock no-error.
        end. 
        else do:
            find prev abascorte 
                        where    abascorte.interface = abaswms.interface and
                                 abascorte.wms = par-wms and 
                                 abascorte.etbcd = par-etbcd and
                                 abascorte.etbcod = par-etbcod
                        no-lock no-error.

        end. 
    end.

end procedure.

