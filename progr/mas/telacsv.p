/*
*                                 R
*
*/


{admcab.i}

def var par-dtenvio     as date.
def var vhora           as char format "x(05)".

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [""].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


def var cfiltro as char extent 3 format "x(40)"
    init [" Todos"," Sem Boleto "," Com Boleto - Falta Exportar "].
def var xfiltro as char extent 3 format "x(40)"
    init ["","SemBoleto","ComBoleto"].
def var ifiltro as int init 1.    
def var pfiltro as char.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find banmassacli where recid(banmassacli) = recatu1 no-lock.
    if not available banmassacli
    then do.
        if pfiltro = ""
        then do: 
            run mas/inputcsv1.p.
            find first banmassacli no-lock no-error.
            if not avail banmassacli
            then  leave.
        end.    
        pfiltro = "".
        ifiltro = 1.
        recatu1 = ?.
        next.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(banmassacli).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available banmassacli
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find banmassacli where recid(banmassacli) = recatu1 no-lock.
        disp banmassacli.observacao format "x(70)"
            with frame fobs
            row 20
            centered
            no-box
            no-labels.

        status default "".

        esqcom1[1] = "".
        esqcom1[2] = " Filtro ".
                if pfiltro = "ComBoleto"
                then esqcom1[3] = " Gerar CSV".
                else if pfiltro = "SemBoleto"
                     then esqcom1[3] = " Gerar Boleto ".
                     else esqcom1[3] = "".
        
        esqcom1[4] = " Boleto".
        esqcom1[1] = " Puxa CSV CPF".

        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field banmassacli.cpf 
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
                    if not avail banmassacli
                    then leave.
                    recatu1 = recid(banmassacli).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail banmassacli
                    then leave.
                    recatu1 = recid(banmassacli).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail banmassacli
                then next.
                color display white/red banmassacli.cpf with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail banmassacli
                then next.
                color display white/red banmassacli.cpf with frame frame-a.
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

            if esqcom1[esqpos1] = " Filtro "
            then do.
                disp 
                    cfiltro
                        with frame ffiltro
                            overlay
                            row 5
                            no-labels
                            column 30.
                choose field cfiltro
                    with frame ffiltro.
                ifiltro = frame-index.    
                pfiltro = xfiltro[ifiltro].
                hide frame frame-a no-pause.
                recatu1 = ?.
                 leave.
            end.
            
            if esqcom1[esqpos1] = " Gerar Csv "
            then do.
                hide frame frame-a no-pause.
                run mas/outputcsv.p . 
                recatu1 = ?. 
                leave.
            end.
            
            if esqcom1[esqpos1] = " Puxa Csv CPF"
            then do.
                hide frame frame-a no-pause.
                run mas/inputcsv1.p.
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = " Gerar Csv "
            then do.
                hide frame frame-a no-pause.
                run mas/outputcsv.p . 
                recatu1 = ?. 
                leave.
            end.
            
            if esqcom1[esqpos1] = " gerar Boleto"
            then do.
                hide frame frame-a no-pause.
                run mas/emiteboletoapi.p.
                recatu1 = ?.
                leave.
            end.
            

            if esqcom1[esqpos1] = " Boleto "
            then do.
                
                recatu2 = banmassacli.banboleto-recid.
                hide frame frame-a no-pause.
                pause 0.
                run bol/banboletoman_v1701.p (input-output recatu2).
                leave.
            end.
            
            /*
            if esqcom1[esqpos1] = " Consulta "
            then run value(tipo-alcis.consulta) (banmassacli.cpf).
            */
            
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(banmassacli).
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
        banmassacli.dtimportacao  format "999999" column-label "DtImp"
        string(banmassacli.hrimportacao,"HH:MM") @ vhora column-label "HrImp"
        banmassacli.cpf  
        banmassacli.dtenvio
        banmassacli.nossonumero        
        banmassacli.dtenviocsv
        banmassacli.dtvenc        
        with frame frame-a 9 down centered color white/red row 5
        title cfiltro[ifiltro].
end procedure.

procedure color-message.
    color display message
                    banmassacli.dtenvio
                    banmassacli.cpf 
                    vhora
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal

                    banmassacli.dtenvio
                    
                    banmassacli.cpf 
            vhora
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find first banmassacli  where
                banmassacli.dtenviocsv = ? and
                banmassacli.dtenvio    <> ?
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find first banmassacli where
            banmassacli.dtenvio = ?
            no-lock no-error.
    end.
    else do:
        find first banmassacli
            no-lock no-error.
    end.    
    
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find next banmassacli  where
                banmassacli.dtenviocsv = ? and
                banmassacli.dtenvio    <> ?
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find next banmassacli where
            banmassacli.dtenvio = ?
            no-lock no-error.
    end.
    else do:
        find next banmassacli
            no-lock no-error.
    end.    

end.    
             
if par-tipo = "up" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find prev banmassacli  where
                banmassacli.dtenviocsv = ? and
                banmassacli.dtenvio    <> ?
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find prev banmassacli where
            banmassacli.dtenvio = ?
            no-lock no-error.
    end.
    else do:
        find prev banmassacli
            no-lock no-error.
    end.    

end.    
        
end procedure.
